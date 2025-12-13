$(document).ready(function()
{
    $(window).scroll(function()
    {
        var scrollPos = $(window).scrollTop();
        if (scrollPos > 50)
        {
            $('.navbar').addClass('scrolled');
        }
        else
        {
            $('.navbar').removeClass('scrolled');
        }
    });
    
    if ($(window).scrollTop() > 50)
    {
        $('.navbar').addClass('scrolled');
    }
});