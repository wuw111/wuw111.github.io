/* ===== U-craft 站点通用脚本 ===== */

/* 滚动渐入动画：为 [data-reveal] 元素添加进入视口后淡入上移的效果 */
function initReveal()
{
    var targets = document.querySelectorAll('[data-reveal]');
    if (!targets.length)
    {
        return;
    }
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    if (reduceMotion || !('IntersectionObserver' in window))
    {
        return;
    }
    var observer = new IntersectionObserver(function(entries)
    {
        entries.forEach(function(entry)
        {
            if (entry.isIntersecting)
            {
                entry.target.classList.add('is-visible');
                observer.unobserve(entry.target);
            }
        });
    }, {
        threshold: 0.15,
        rootMargin: '0px 0px -60px 0px'
    });
    targets.forEach(function(element, index)
    {
        element.classList.add('reveal-init');
        element.style.animationDelay = Math.min(index * 80, 320) + 'ms';
        observer.observe(element);
    });
}

/* 锚点平滑滚动（自动避开固定导航栏的高度） */
function initSmoothScroll()
{
    var reduceMotion = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    document.querySelectorAll('a[href^="#"]').forEach(function(link)
    {
        link.addEventListener('click', function(event)
        {
            var hash = link.getAttribute('href');
            if (!hash || hash === '#')
            {
                return;
            }
            var target = document.querySelector(hash);
            if (!target)
            {
                return;
            }
            event.preventDefault();
            var offset = target.getBoundingClientRect().top + window.pageYOffset - 70;
            window.scrollTo({
                top: offset,
                behavior: reduceMotion ? 'auto' : 'smooth'
            });
        });
    });
}

/* 脚本位于 body 末尾，此处 DOM 已解析完成，先执行可避免元素闪烁 */
initReveal();
initSmoothScroll();

/* 顶部导航栏：滚动经过首屏后切换为白底样式 */
$(document).ready(function()
{
    var $hero = $(".hero").first();
    var threshold = 100;

    function updateThreshold()
    {
        threshold = $hero.length ? $hero.height() : 100;
    }

    function updateNavbar()
    {
        if ($(window).scrollTop() > threshold)
        {
            $(".navbar").addClass("scrolled");
        }
        else
        {
            $(".navbar").removeClass("scrolled");
        }
    }

    $(window).on('scroll', updateNavbar);
    $(window).on('resize', function()
    {
        updateThreshold();
        updateNavbar();
    });

    updateThreshold();
    updateNavbar();
});
