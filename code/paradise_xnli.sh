TOTAL_NUM_UPDATES=100000 # 10 epochs through IMDB for bsz 32
WARMUP_UPDATES=6000      # 6 percent of the number of updates
LR=1e-05                # Peak LR for polynomial LR scheduler.
HEAD_NAME=classification_head     # Custom name for the classification head.
NUM_CLASSES=3           # Number of classes for the classification task.
MAX_SENTENCES=8      # Batch size.
ROBERTA_PATH=$HOME/storage/detrans_checkpoints/detrans20_dict.pt #$HOME/storage/outputs/detrans20/checkpoint_best.pt #$HOME/detrans20-plm.pt # $HOME/storage/outputs/detrans20/checkpoint_best.pt

mkdir -p $2
CUDA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 fairseq-train $1 \
    --layernorm-embedding \
    --restore-file $ROBERTA_PATH \
    --batch-size $MAX_SENTENCES \
    --max-tokens 4096 \
    --task sentence_prediction \
    --reset-optimizer --reset-dataloader --reset-meters \
    --required-batch-size-multiple 1 \
    --valid-subset test \
    --save-interval-updates 300 \
    --keep-interval-updates 3 \
    --init-token 0 --separator-token 2 \
    --arch mbart_base \
    --criterion sentence_prediction \
    --classification-head-name $HEAD_NAME \
    --num-classes $NUM_CLASSES \
    --dropout 0.1 --attention-dropout 0.1 \
    --weight-decay 0.1 --optimizer adam --adam-betas "(0.9, 0.98)" --adam-eps 1e-06 \
    --clip-norm 0.0 \
    --add-lang-token \
    --classification-aggregator encoder_decoder \
    --pretraining-task denoising_translation \
    --langs="en,fr,es,de,el,bg,ru,tr,ar,vi,th,zh,hi,sw,ur,ja,eu,ro,si,ne" \
    --lr-scheduler polynomial_decay --lr $LR --total-num-update $TOTAL_NUM_UPDATES --warmup-updates $WARMUP_UPDATES \
    --fp16 --fp16-init-scale 4 --threshold-loss-scale 1 --fp16-scale-window 128 \
    --max-epoch 100 \
    --best-checkpoint-metric accuracy --maximize-best-checkpoint-metric \
    --shorten-method "truncate" \
    --add-prev-output-tokens \
    --find-unused-parameters \
    --pooler-activation-fn tanh \
    --pooler-dropout 0.0 \
    --update-freq 2  --save-dir $2/checkpoints | tee $2/output.log
