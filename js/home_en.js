var countInput;
var resultDisplay;
function init()
{
    countInput = document.getElementById('count');
    resultDisplay = document.getElementById('result');
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
        showError('Please enter the number of Homes');
        return false;
    }
    if (isNaN(homeCount))
    {
        showError('Please enter a valid number');
        return false;
    }
    if (homeCount < 0 || homeCount > 150)
    {
        showError('Please enter a number from 0 to 150');
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
        showError('Please enter a number from 0 to 150');
        return;
    }
    var cost = Math.round(200 * homeCount + homeCount * Math.pow(10, 1.2 + 0.005 * homeCount));
    var formattedCost = cost.toLocaleString();
    resultDisplay.textContent = 'Creating Home #' + (homeCount + 1) + ' costs ' + formattedCost + ' gold';
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