Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59678 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751404AbaDRMkN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 08:40:13 -0400
Date: Fri, 18 Apr 2014 08:40:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        terry1@beam.ltd.uk
Subject: Re: [PATCH] locks: allow __break_lease to sleep even when break_time
 is 0
Message-ID: <20140418124011.GE18612@fieldses.org>
References: <1397565852-16212-1-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397565852-16212-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Tue, Apr 15, 2014 at 08:44:12AM -0400, Jeff Layton wrote:
> A fl->fl_break_time of 0 has a special meaning to the lease break code
> that basically means "never break the lease". knfsd uses this to ensure
> that leases don't disappear out from under it.
> 
> Unfortunately, the code in __break_lease can end up passing this value
> to wait_event_interruptible as a timeout, which prevents it from going
> to sleep at all. This causes __break_lease to spin in a tight loop and
> causes soft lockups.
> 
> Fix this by ensuring that we pass a minimum value of 1 as a timeout
> instead.
> 
> Cc: <stable@vger.kernel.org>
> Cc: J. Bruce Fields <bfields@fieldses.org>
> Reported-by: Terry Barnaby <terry1@beam.ltd.uk>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/locks.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 13fc7a6d380a..b380f5543614 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1391,11 +1391,10 @@ int __break_lease(struct inode *inode, unsigned int mode, unsigned int type)
>  
>  restart:
>  	break_time = flock->fl_break_time;
> -	if (break_time != 0) {
> +	if (break_time != 0)
>  		break_time -= jiffies;
> -		if (break_time == 0)
> -			break_time++;
> -	}
> +	if (break_time == 0)
> +		break_time++;
>  	locks_insert_block(flock, new_fl);
>  	spin_unlock(&inode->i_lock);
>  	error = wait_event_interruptible_timeout(new_fl->fl_wait,
> -- 
> 1.9.0
> 
