Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:4449 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754918Ab2GXBCf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Jul 2012 21:02:35 -0400
Date: Mon, 23 Jul 2012 21:01:56 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: trond.myklebust@netapp.com, viro@ZenIV.linux.org.uk,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: explicitly reject LOCK_MAND flock() requests
Message-ID: <20120723210156.1dafd3b6@corrin.poochiereds.net>
In-Reply-To: <1343072783-29737-1-git-send-email-jlayton@redhat.com>
References: <1343072783-29737-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jul 2012 15:46:23 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> We have no mechanism to emulate LOCK_MAND locks on NFSv4, so explicitly
> return -EINVAL if someone requests it.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/nfs/file.c |    9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 61d3670..15f4bbb 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -834,6 +834,15 @@ static int nfs_flock(struct file *filp, int cmd, struct file_lock *fl)
>  	if (!(fl->fl_flags & FL_FLOCK))
>  		return -ENOLCK;
>  
> +	/*
> +	 * The NFSv4 protocol doesn't support LOCK_MAND, which is not part of
> +	 * any standard. In principle we might be able to support LOCK_MAND
> +	 * on NFSv2/3 since NLMv3/4 support DOS share modes, but for now the
> +	 * NFS code is not set up for it.
> +	 */
> +	if (fl->fl_type & LOCK_MAND)
> +		return -EINVAL;
> +
>  	if (NFS_SERVER(inode)->flags & NFS_MOUNT_LOCAL_FLOCK)
>  		is_local = 1;
>  

Hmm...it looks like GFS2 does a similar check and returns -EOPNOTSUPP.
Should we do the same here instead of -EINVAL?

-- 
Jeff Layton <jlayton@redhat.com>
