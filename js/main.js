$(document).ready(function()
{
    $(window).scroll(function()
    {
        if ($(this).scrollTop() > $(".banner").height())
        {
            $(".navbar").addClass("scrolled");
        }
        else
        {
            $(".navbar").removeClass("scrolled");
        }
    });
    $(window).trigger('scroll');
});