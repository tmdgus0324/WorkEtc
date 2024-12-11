<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Popup 테스트</title>

    <script type="text/javascript">
        function setCookie(name, value, days) {
            if(days) {
                var date = new Date();
                date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
                var expires = "; expires=" + date.toGMTString();
            } else {
                var expires = "";
            }

            document.cookie = name + "=" + value + expires + "; path=/";
        }

        function fncClose() {
            if(document.overseasform.notice.checked){
                setCookie("startPopup", "done", 1);     // 부모창 쿠키값과 일치해야 한다.
            }

            self.Close();
        }
    </script>
</head>
<body>
    <form name='overseasform'>
        Popup 테스트입니다. <br>
        <input type="checkbox" name="notice" value=""><font size="2">오늘 하루 이 창을 열지 않음</font> &nbsp;
        <button type="button" onclick="fncClose()">창닫기</button>
    </form>
</body>
</html>