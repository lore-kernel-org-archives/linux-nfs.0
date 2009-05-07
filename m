From: Eric Paris <eparis@redhat.com>
Subject: Re: [PATCH] inotify: report rounded-up event size to user space
Date: Thu, 07 May 2009 08:16:48 -0400
Message-ID: <1241698608.2899.5.camel@dhcp231-142.rdu.redhat.com>
References: <20090503105456.GA30449@localhost>
	 <20090503124013.GA31700@localhost>
	 <ac3eb2510905030556p4ce25ff1w9aa5cbf76be2e206@mail.gmail.com>
	 <20090504133019.GA14300@localhost>
	 <ac3eb2510905060642o41f9c68rf1138e94d76d611c@mail.gmail.com>
	 <20090507115947.GA20934@localhost>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	"linux-hotplug@vger.kernel.org" <linux-hotplug@vger.kernel.org>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Christoph Hellwig <hch@lst.de>
To: Wu Fengguang <fengguang.wu@intel.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
In-Reply-To: <20090507115947.GA20934@localhost>
Sender: linux-hotplug-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-05-07 at 19:59 +0800, Wu Fengguang wrote:

> ---
> inotify: report rounded-up event size to user space
> 
> Fix a udev madness problem, which falls into an endless loop:
> 
> (1) ppoll([{fd=4, events=POLLIN}, {fd=5, events=POLLIN}, {fd=3, events=POLLIN}], 3, NULL, [], 8) = 1 ([{fd=3, revents=POLLIN}])
> (2) ioctl(3, FIONREAD, [39])                = 0
> (3) read(3, 0x62ad60, 39)                   = -1 EINVAL (Invalid argument)
> 
> In (2) we reported a small len, while in (3) we insist on a rounded up len,
> leading to a failed inotify read(), which will be retried endlessly by udev.
> 
> [  756.569243] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.600103] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.630265] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.670862] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.701845] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.732899] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.763126] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.794829] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.824985] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  756.856760] get_one_event: event_size=48 > count=38, name_len=22, name=61-dev-root-link.rules
> [  761.608521] __ratelimit: 210 callbacks suppressed
> 
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Gaaah should have remembered to do that with the ioctl.
 
Acked-by: Eric Paris <eparis@redhat.com>

Andrew can you add this to your tree, I will roll it into my next patch
set.

-Eric

> ---
>  fs/notify/inotify/inotify_user.c |    4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> --- linux.orig/fs/notify/inotify/inotify_user.c
> +++ linux/fs/notify/inotify/inotify_user.c
> @@ -318,7 +318,9 @@ static long inotify_ioctl(struct file *f
>  		mutex_lock(&group->notification_mutex);
>  		list_for_each_entry(holder, &group->notification_list, event_list) {
>  			event = holder->event;
> -			send_len += sizeof(struct inotify_event) + event->name_len;
> +			send_len += sizeof(struct inotify_event);
> +			send_len += roundup(event->name_len,
> +					sizeof(struct inotify_event));
>  		}
>  		mutex_unlock(&group->notification_mutex);
>  		ret = put_user(send_len, (int __user *) p);

