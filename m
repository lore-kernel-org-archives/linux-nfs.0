Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758647Ab3FCVyS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Jun 2013 17:54:18 -0400
Date: Mon, 3 Jun 2013 17:53:54 -0400
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
Subject: Re: [PATCH v1 02/11] locks: make generic_add_lease and
 generic_delete_lease static
Message-ID: <20130603215353.GE2109@fieldses.org>
References: <1370056054-25449-1-git-send-email-jlayton@redhat.com>
 <1370056054-25449-3-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370056054-25449-3-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 31, 2013 at 11:07:25PM -0400, Jeff Layton wrote:
> Signed-off-by: Jeff Layton <jlayton@redhat.com>

ACK.--b.

> ---
>  fs/locks.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/locks.c b/fs/locks.c
> index 7a02064..e3140b8 100644
> --- a/fs/locks.c
> +++ b/fs/locks.c
> @@ -1337,7 +1337,7 @@ int fcntl_getlease(struct file *filp)
>  	return type;
>  }
>  
> -int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
> +static int generic_add_lease(struct file *filp, long arg, struct file_lock **flp)
>  {
>  	struct file_lock *fl, **before, **my_before = NULL, *lease;
>  	struct dentry *dentry = filp->f_path.dentry;
> @@ -1402,7 +1402,7 @@ out:
>  	return error;
>  }
>  
> -int generic_delete_lease(struct file *filp, struct file_lock **flp)
> +static int generic_delete_lease(struct file *filp, struct file_lock **flp)
>  {
>  	struct file_lock *fl, **before;
>  	struct dentry *dentry = filp->f_path.dentry;
> -- 
> 1.7.1
> 
