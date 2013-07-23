Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54617 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932595Ab3GWQDD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 12:03:03 -0400
Date: Tue, 23 Jul 2013 12:02:58 -0400
From: Jeff Layton <jlayton@redhat.com>
To: David Howells <dhowells@redhat.com>
Cc: torvalds@linux-foundation.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        Milosz Tanski <milosz@adfin.com>,
        Yacine Belkadi <yacine.belkadi.1@gmail.com>
Subject: Re: [PATCH] Fix __wait_on_atomic_t() to call the action func if the
 counter != 0
Message-ID: <20130723120258.01024e81@tlielax.poochiereds.net>
In-Reply-To: <20130723154924.24306.42326.stgit@warthog.procyon.org.uk>
References: <20130723154924.24306.42326.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 23 Jul 2013 16:49:24 +0100
David Howells <dhowells@redhat.com> wrote:

> Fix __wait_on_atomic_t() so that it calls the action func if the counter != 0
> rather than if the counter is 0 so as to be analogous to __wait_on_bit().
> 
> Thanks to Yacine who found this by visual inspection.
> 
> This will affect FS-Cache in that it will could fail to sleep correctly when
> trying to clean up after a netfs cookie is withdrawn.
> 
> Reported-by: Yacine Belkadi <yacine.belkadi.1@gmail.com>
> Signed-off-by: David Howells <dhowells@redhat.com>
> cc: Yacine Belkadi <yacine.belkadi.1@gmail.com>
> cc: Milosz Tanski <milosz@adfin.com>
> cc: Jeff Layton <jlayton@redhat.com>
> ---
> 
>  kernel/wait.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/kernel/wait.c b/kernel/wait.c
> index ce0daa3..dec68bd 100644
> --- a/kernel/wait.c
> +++ b/kernel/wait.c
> @@ -333,7 +333,8 @@ int __wait_on_atomic_t(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  		prepare_to_wait(wq, &q->wait, mode);
>  		val = q->key.flags;
>  		if (atomic_read(val) == 0)
> -			ret = (*action)(val);
> +			break;
> +		ret = (*action)(val);
>  	} while (!ret && atomic_read(val) != 0);

nit: can you now eliminate the check for "val" in the while condition?
It doesn't look like it harms anything, but eliminating it would
probably simplify the code slightly...

>  	finish_wait(wq, &q->wait);
>  	return ret;
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Jeff Layton <jlayton@redhat.com>
