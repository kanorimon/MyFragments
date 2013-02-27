function submitWithValueAndConfirm(formid, commitValue)
{
     var objForm = document.getElementById(formid);
     objForm.memo_tweet_flg.value = commitValue;
     objForm.submit();
}