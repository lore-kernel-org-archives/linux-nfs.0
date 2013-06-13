Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52676 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757636Ab3FMTqV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 15:46:21 -0400
Date: Thu, 13 Jun 2013 15:45:46 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 06/14] locks: don't walk inode->i_flock list in
 locks_show
Message-ID: <20130613194545.GC19218@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
 <1370948948-31784-7-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370948948-31784-7-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 07:09:00AM -0400, Jeff Layton wrote:
> When we convert over to using the i_lock to protect the i_flock list,
> that will introduce a potential lock inversion problem in locks_show.
> When we want to walk the i_flock list, we'll need to take the i_lock.
> 
> Rather than do that, just walk the global blocked_locks list and print
> out any that are blocked on the given lock.

I'm OK with this as obviously /proc/locks shouldn't be the common case,
but it still bugs me a bit that we're suddenly making it something like

	O(number of held locks * number of waiters)

where it used to be

	O(number of held lock + number of waiters)

I wonder if there's any solution that's just as easy and avoids scanning
the blocked list each time.

--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/locks.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index e451d18..3fd27f0 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -2249,8 +2249,10 @@ static int locks_show(struct seq_file *f, void *v)
>  
>  	lock_get_status(f, fl, *((loff_t *)f->private), "");
>  
> -	list_for_each_entry(bfl, &fl->fl_block, fl_block)
> -		lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> +	list_for_each_entry(bfl, &blocked_list, fl_link) {
> +		if (bfl->fl_next == fl)
> +			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
> +	}
>  
>  	return 0;
>  }
> -- 
> 1.7.1
> 
