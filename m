Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1927 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753628Ab1FHOaD convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2011 10:30:03 -0400
Subject: Re: [patch] NFS: using freed variable in debug code
Content-Type: text/plain; charset=us-ascii
From: Weston Andros Adamson <dros@netapp.com>
In-Reply-To: <20110608064300.GE3846@shale.localdomain>
Date: Wed, 8 Jun 2011 10:30:00 -0400
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "open list:NFS, SUNRPC, AND..." <linux-nfs@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
Message-Id: <4E3994E6-9DBF-439B-808E-F134EB5DD923@netapp.com>
References: <20110608064300.GE3846@shale.localdomain>
To: Dan Carpenter <error27@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Oops, good catch!

Actually, we can leave the kfree() where it is.  Using ds->ds_remotestr in the dprintk is a typo - It should be tmp_ds->ds_remotestr.

-dros

On Jun 8, 2011, at 2:43 AM, Dan Carpenter wrote:

> "ds" gets dereferenced after a kfree in the debug output.  I just
> moved the free down a line.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
> index 77c171e..c63bbce 100644
> --- a/fs/nfs/nfs4filelayoutdev.c
> +++ b/fs/nfs/nfs4filelayoutdev.c
> @@ -362,11 +362,11 @@ nfs4_pnfs_ds_add(struct list_head *dsaddrs, gfp_t gfp_flags)
> 				__func__, tmp_ds->ds_remotestr, remotestr);
> 		}
> 		kfree(remotestr);
> -		kfree(ds);
> 		atomic_inc(&tmp_ds->ds_count);
> 		dprintk("%s data server %s found, inc'ed ds_count to %d\n",
> 			__func__, ds->ds_remotestr,
> 			atomic_read(&tmp_ds->ds_count));
> +		kfree(ds);
> 		ds = tmp_ds;
> 	}
> 	spin_unlock(&nfs4_ds_cache_lock);
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

