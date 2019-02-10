#!/bin/bash -e

# Player editable parameters
# ------------------------------------------------

# The filename of your content image
CONTENT_IMAGE=content-landscape.jpg

# The filename of your style image
STYLE_IMAGE=content-motion-2.jpg

# Parameters
STYLE_WEIGHT=5e2          # 5e2 (1e0 > 10e5)
CONTENT_WEIGHT=5e0        # 5e0 (1e0 > 10e5)
STYLE_SCALE=1.0           # 1.0 (0.1 > 2.0)

# Advanced Parameters
ORIGINAL_COLORS=0         # 0 ( 0 | 1 )
POOLING=max               # max ( max | avg )
NORMALIZE_GRADIENTS=""   # "" ( "" | "-normalize_gradients" )


# Don't edit anything beneath this!
# ------------------------------------------------

# determine GPU ID by user folder
GPU_ID=0 # init value
USER_NAME=${PWD##*/}
case $USER_NAME in
  anagram|bass|cathode)
    GPU_ID=0
    ;;
  anodyne|bat|cavepainter)
    GPU_ID=1
    ;;
  anteater|boat|cenobite)
    GPU_ID=2
    ;;
  antelope|body|cook)
    GPU_ID=3
    ;;
  brand|coolhunter)
    GPU_ID=4
    ;;
  breakpoint|cranberry)
    GPU_ID=5
    ;;
  brooding|crayon)
    GPU_ID=6
    ;;
  button|cub)
    GPU_ID=7
    ;;
  *)
    GPU_ID=0
    ;;
esac

# echo $GPU_ID

USER_NAME=${PWD##*/}
SCRIPT_NAME=`basename "$0"`
IMAGE_PATH=./pictures/
NEURALSTYLE=~/code/neural-style/

# Generate project name
suffix=""
if [ -z "$1" ]
  then
    # no project name argument supplied
    echo 'no args provided'
    read count < data.txt
    echo 'count '$count
    printf -v suffix "%02d" $count
    echo "suffix "$suffix
    PROJECT_NAME=${SCRIPT_NAME%.sh}-$suffix
    echo "projectname "$$PROJECT_NAME
    ((count = count + 1))
    echo $count > data.txt
  else
    # create new output directory with supplied project name
    PROJECT_NAME=$1
fi

# Color definitions for console output
GREEN="\e[1;32m"
ENDCOL="\e[0m"

# Generate output path and filename(s)
OUTPUT_PATH=./projects/$PROJECT_NAME/
OUTPUT_PATH_MSG=projects/$PROJECT_NAME/
OUTPUT_FILENAME=$PROJECT_NAME
STAGE_1=${OUTPUT_FILENAME}-1.png
STAGE_2=${OUTPUT_FILENAME}-2.png
STAGE_3=${OUTPUT_FILENAME}-3.png
STAGE_4=${OUTPUT_FILENAME}-4.png
STAGE_5=${OUTPUT_FILENAME}-final.png

# Create output directory
if [ -d "$OUTPUT_PATH" ]; then
      echo 'directory exists'
    else
      mkdir $OUTPUT_PATH
fi

# Duplicate this script under the new project name
NEW_SCRIPT_NAME=${OUTPUT_FILENAME}.sh
cp $SCRIPT_NAME $NEW_SCRIPT_NAME

# Welcome message
echo -e "${GREEN}----------------------------------------------------------------------${ENDCOL}"
echo -e "${GREEN}Welcome to Visual Strategies for Neural Artistic Style Transfer!${ENDCOL}"
echo -e "${GREEN}* Project: ${PROJECT_NAME}${ENDCOL}"
echo -e "${GREEN}* User: ${USER_NAME}${ENDCOL}"
echo -e "${GREEN}* Size: 1920px${ENDCOL}"
echo -e "${GREEN}* GPU: ${GPU_ID}${ENDCOL}"
echo -e "${GREEN}A copy of this script was saved here: /users/${USER_NAME}/${NEW_SCRIPT_NAME}${ENDCOL}"
echo -e "${GREEN}Your images will be saved here: /users/${USER_NAME}/${OUTPUT_PATH_MSG}${ENDCOL}"
echo -e "${GREEN}----------------------------------------------------------------------${ENDCOL}"

# Rendering stage 1
th ${NEURALSTYLE}neural_style.lua \
  -visual_strategy $PROJECT_NAME" Stage:1/5" \
  -content_image $IMAGE_PATH$CONTENT_IMAGE \
  -style_image $IMAGE_PATH$STYLE_IMAGE \
  -output_image $OUTPUT_PATH$STAGE_1 \
  -proto_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers_deploy.prototxt \
  -model_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers.caffemodel \
  -style_scale $STYLE_SCALE \
  -print_iter 100 \
  -content_weight $CONTENT_WEIGHT \
  -style_weight $STYLE_WEIGHT \
  -image_size 256 \
  -tv_weight 0 \
  -backend cudnn -cudnn_autotune \
  -gpu $GPU_ID \
  -original_colors $ORIGINAL_COLORS \
  -pooling $POOLING \
  $NORMALIZE_GRADIENTS

# Rendering stage 2
th ${NEURALSTYLE}neural_style.lua \
  -visual_strategy $PROJECT_NAME" Stage:2/5" \
  -init image \
  -init_image $OUTPUT_PATH$STAGE_1 \
  -content_image $IMAGE_PATH$CONTENT_IMAGE \
  -style_image $IMAGE_PATH$STYLE_IMAGE \
  -output_image $OUTPUT_PATH$STAGE_2 \
  -proto_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers_deploy.prototxt \
  -model_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers.caffemodel \
  -style_scale $STYLE_SCALE \
  -print_iter 100 \
  -style_weight $STYLE_WEIGHT \
  -image_size 512 \
  -num_iterations 500 \
  -tv_weight 0 \
  -backend cudnn -cudnn_autotune \
  -gpu $GPU_ID \
  -original_colors $ORIGINAL_COLORS \
  -pooling $POOLING \
  $NORMALIZE_GRADIENTS

# Rendering stage 3
th ${NEURALSTYLE}neural_style.lua \
  -visual_strategy $PROJECT_NAME" Stage:3/5" \
  -init image \
  -init_image $OUTPUT_PATH$STAGE_2 \
  -content_image $IMAGE_PATH$CONTENT_IMAGE \
  -style_image $IMAGE_PATH$STYLE_IMAGE \
  -output_image $OUTPUT_PATH$STAGE_3 \
  -proto_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers_deploy.prototxt \
  -model_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers.caffemodel \
  -style_scale $STYLE_SCALE \
  -print_iter 100 \
  -style_weight $STYLE_WEIGHT \
  -image_size 1024 \
  -num_iterations 200 \
  -tv_weight 0 \
  -backend cudnn -cudnn_autotune \
  -gpu $GPU_ID \
  -original_colors $ORIGINAL_COLORS \
  -pooling $POOLING \
  $NORMALIZE_GRADIENTS

# Rendering stage 4
th ${NEURALSTYLE}neural_style.lua \
  -visual_strategy $PROJECT_NAME" Stage:4/5" \
  -init image \
  -init_image $OUTPUT_PATH$STAGE_3 \
  -content_image $IMAGE_PATH$CONTENT_IMAGE \
  -style_image $IMAGE_PATH$STYLE_IMAGE \
  -output_image $OUTPUT_PATH$STAGE_4 \
  -proto_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers_deploy.prototxt \
  -model_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers.caffemodel \
  -style_scale $STYLE_SCALE \
  -print_iter 10 \
  -style_weight $STYLE_WEIGHT \
  -image_size 1600 \
  -num_iterations 100 \
  -tv_weight 0 \
  -backend cudnn \
  -gpu $GPU_ID \
  -original_colors $ORIGINAL_COLORS \
  -pooling $POOLING \
  $NORMALIZE_GRADIENTS

# Rendering stage 5
th ${NEURALSTYLE}neural_style.lua \
  -visual_strategy $PROJECT_NAME" Stage:5/5" \
  -init image \
  -init_image $OUTPUT_PATH$STAGE_4 \
  -content_image $IMAGE_PATH$CONTENT_IMAGE \
  -style_image $IMAGE_PATH$STYLE_IMAGE \
  -output_image $OUTPUT_PATH$STAGE_5 \
  -proto_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers_deploy.prototxt \
  -model_file ${NEURALSTYLE}models/VGG_ILSVRC_19_layers.caffemodel \
  -style_scale $STYLE_SCALE \
  -print_iter 1 \
  -style_weight $STYLE_WEIGHT \
  -image_size 1920 \
  -num_iterations 50 \
  -tv_weight 0 \
  -lbfgs_num_correction 5 \
  -backend cudnn \
  -gpu $GPU_ID \
  -original_colors $ORIGINAL_COLORS \
  -pooling $POOLING \
  $NORMALIZE_GRADIENTS

# wrapup message
echo -e "${GREEN}----------------------------------------------------------------------${ENDCOL}"
echo -e "${GREEN}Finished rendering${ENDCOL}"
echo -e "${GREEN}* Project: ${PROJECT_NAME}${ENDCOL}"
echo -e "${GREEN}* User: ${USER_NAME}${ENDCOL}"
echo -e "${GREEN}* GPU: ${GPU_ID}${ENDCOL}"
echo -e "${GREEN}A copy of this script was saved here: /users/${USER_NAME}/${NEW_SCRIPT_NAME}${ENDCOL}"
echo -e "${GREEN}Images were saved here: /users/${USER_NAME}/${OUTPUT_PATH_MSG}${ENDCOL}"
echo -e "${GREEN}----------------------------------------------------------------------${ENDCOL}"

