Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:37496 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755748Ab1KCKm2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 06:42:28 -0400
Date: Thu, 3 Nov 2011 06:42:15 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tejun Heo <tj@kernel.org>, "Rafael J. Wysocki" <rjw@sisk.pl>,
        Steve French <sfrench@samba.org>, linux-kernel@vger.kernel.org,
        linux-pm@vger.kernel.org, linux-cifs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] wait_event_freezekillable: use
 freezer_do_not_count/freezer_count
Message-ID: <20111103064215.48939e1a@tlielax.poochiereds.net>
In-Reply-To: <20111102175327.GA4446@redhat.com>
References: <20111101041337.39077229@tlielax.poochiereds.net>
	<20111101065958.50addab5@tlielax.poochiereds.net>
	<20111101163059.GR18855@google.com>
	<20111101175953.GB5358@redhat.com>
	<20111101180601.GV18855@google.com>
	<20111101181329.GA6739@redhat.com>
	<20111101182753.GW18855@google.com>
	<20111101193923.GA9444@redhat.com>
	<20111101194601.GB9444@redhat.com>
	<20111101215710.GA13803@google.com>
	<20111102175327.GA4446@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2 Nov 2011 18:53:27 +0100
Oleg Nesterov <oleg@redhat.com> wrote:

> fake_signal_wake_up() should not wake up the TASK_KILLABLE tasks,
> we are going to fix this. This means that wait_event_freezekillable()
> can't rely on wakeup from freezer. Reimplement it using
> freezer_do_not_count/freezer_count. This is not really nice, just
> a simple fix for now.
> 
> Signed-off-by: Oleg Nesterov <oleg@redhat.com>
> ---
> 
>  include/linux/freezer.h |   10 +++-------
>  1 file changed, 3 insertions(+), 7 deletions(-)
> 
> --- a/include/linux/freezer.h
> +++ b/include/linux/freezer.h
> @@ -143,13 +143,9 @@ static inline void set_freezable_with_si
>  #define wait_event_freezekillable(wq, condition)			\
>  ({									\
>  	int __retval;							\
> -	for (;;) {							\
> -		__retval = wait_event_killable(wq,			\
> -				(condition) || freezing(current));	\
> -		if (__retval || (condition))				\
> -			break;						\
> -		try_to_freeze();					\
> -	}								\
> +	freezer_do_not_count();						\
> +	__retval = wait_event_killable(wq, (condition));		\
> +	freezer_count();						\
>  	__retval;							\
>  })
>  
> 

I'm not sure we really need this macro anymore since this is much
simpler. I could just move cifs back to using wait_event_killable and
simply wrap it in freezer_do_not_count/freezer_count (with some
comments to explain why we're doing that).

In any event, I plan to test this scheme out today and will let you
know whether it works...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
