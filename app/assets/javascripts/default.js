function submitWithValueAndConfirm(formid, commitValue)
{
 if (window.confirm(text)) {
     var objForm = document.getElementById(formid);
     objForm.tweet_flg.value = commitValue;
     objForm.submit();
 } else {
  return false;
 }
}