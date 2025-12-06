var countInput;
var resultDisplay;
var calculateBtn;
function init()
{
    countInput = document.getElementById('count');
    resultDisplay = document.getElementById('result');
    calculateBtn = document.getElementById('calculateBtn');
    bindEvents();
    calculate();
}
function bindEvents()
{
    if (countInput)
    {
        countInput.addEventListener('input', function()
        {
            if (this.value.trim() !== '')
            {
                calculate();
            }
        });
        countInput.addEventListener('blur', validateInput);
    }
    if (calculateBtn)
    {
        calculateBtn.addEventListener('click', calculate);
    }
}
function validateInput()
{
    if (!countInput)
    {
        return true;
    }
    var value = countInput.value.trim();
    var homeCount = Number(value);
    if (value === '')
    {
        showError('请输入Home数量');
        return false;
    }
    if (isNaN(homeCount))
    {
        showError('请输入有效的数字');
        return false;
    }
    if (homeCount < 0 || homeCount > 150)
    {
        showError('请输入0到150之间的数字');
        return false;
    }
    return true;
}
function calculate()
{
    if (!validateInput())
    {
        return;
    }
    var inputValue = countInput.value;
    var homeCount = Number(inputValue);
    if (isNaN(homeCount) || homeCount < 0 || homeCount > 150)
    {
        showError('请输入0到150之间的数字');
        return;
    }
    var cost = Math.round(200 * homeCount + homeCount * Math.pow(10, 1.2 + 0.005 * homeCount));
    var formattedCost = cost.toLocaleString();
    resultDisplay.textContent = '新建第 ' + (homeCount + 1) + ' 个Home需要 ' + formattedCost + ' 金币';
    resultDisplay.className = 'result success';
}
function showError(message)
{
    if (resultDisplay)
    {
        resultDisplay.textContent = message;
        resultDisplay.className = 'result error';
    }
}
if (document.readyState === 'loading')
{
    document.addEventListener('DOMContentLoaded', init);
}
else
{
    init();
}