Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58574 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792AbbGMEVK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jul 2015 00:21:10 -0400
Date: Mon, 13 Jul 2015 14:20:59 +1000
From: NeilBrown <neilb@suse.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 10/10 v7] nfsd: Allows user un-mounting filesystem where
 nfsd exports base on
Message-ID: <20150713142059.493a790e@noble>
In-Reply-To: <20150713133934.6a4ef77d@noble>
References: <55A11010.6050005@gmail.com>
	<55A111A8.2040701@gmail.com>
	<20150713133934.6a4ef77d@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 13 Jul 2015 13:39:34 +1000 NeilBrown <neilb@suse.com> wrote:


> The work item and completion are a bit unfortunate too.
> 
> I guess the problem here is that pin_kill() can run while there are
> some inactive references to the cache item.  There can then be a race
> over who will use path_put_unpin to put the dentry.
> 
> Could we fix that by having expXXX_pin_kill() use kref_get_unless_zero()
> on the cache item.
> If that succeeds, then path_put_unpin hasn't been called and it won't be.
> So expXXX_pin_kill can call it and then set CACHE_NEGATIVE.
> If it fails, then it has already been called and nothing else need be done.
> Almost.
> If kref_get_unless_zero() fails, pin_remove() may not have been called
> yet, but it will be soon.  We might need to wait.
> It would be nice if pin_kill() would check ->done again after calling p->kill.
> e.g.
> 
> diff --git a/fs/fs_pin.c b/fs/fs_pin.c
> index 611b5408f6ec..c2ef5c9d4c0d 100644
> --- a/fs/fs_pin.c
> +++ b/fs/fs_pin.c
> @@ -47,7 +47,9 @@ void pin_kill(struct fs_pin *p)
>  		spin_unlock_irq(&p->wait.lock);
>  		rcu_read_unlock();
>  		p->kill(p);
> -		return;
> +		if (p->done > 0)
> +			return;
> +		spin_lock_irq(&p->wait.lock);
>  	}
>  	if (p->done > 0) {
>  		spin_unlock_irq(&p->wait.lock);
> 
> I think that would close the last gap, without needing extra work
> items and completion in the nfsd code.
> 
> Al: would you be OK with that change to pin_kill?

Actually, with that change to pin_kill, this side of things becomes
really easy.
All expXXX_pin_kill needs to do is call your new cache_delete_entry.
If that doesn't cause the entry to be put, then something else has a
temporary reference which will be put soon.  In any case, pin_kill()
will wait long enough, but not indefinitely.
No need for kref_get_unless_zero() or any of that.

NeilBrown
