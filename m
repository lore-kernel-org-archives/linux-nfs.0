Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:46020 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919Ab1H0CHz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 22:07:55 -0400
Message-ID: <4E585163.7070108@panasas.com>
Date: Fri, 26 Aug 2011 19:07:31 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfsd4: fix failure to end nfsd4 grace period
References: <4E45C594.1030609@panasas.com> <20110826201910.GB17196@fieldses.org> <4E5838E0.4090703@panasas.com> <20110827004618.GG18699@fieldses.org> <20110827004708.GA19967@fieldses.org> <20110827004736.GB19967@fieldses.org>
In-Reply-To: <20110827004736.GB19967@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/26/2011 05:47 PM, J. Bruce Fields wrote:
> From: Boaz Harrosh <bharrosh@panasas.com>
> 
> Even if we fail to write a recovery record, we should still mark the
> client as having acquired its first state.  Otherwise we leave 4.1
> clients with indefinite ERR_GRACE returns.
> 
> However, an inability to write stable storage records may cause failures
> of reboot recovery, and the problem should still be brought to the
> server administrator's attention.
> 
> So, make sure the error is logged.
> 
> These errors shouldn't normally be triggered on a corectly functioning
> server--this isn't a case where a misconfigured client could spam the
> logs.
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/nfsd/nfs4recover.c |   15 ++++++++-------
>  1 files changed, 8 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 3e6ebcf..ed083b9 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -130,6 +130,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  	if (!rec_file || clp->cl_firststate)
>  		return 0;
>  
> +	clp->cl_firststate = 1;
>  	status = nfs4_save_creds(&original_cred);
>  	if (status < 0)
>  		return status;
> @@ -144,10 +145,8 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
>  		goto out_unlock;
>  	}
>  	status = -EEXIST;
> -	if (dentry->d_inode) {
> -		dprintk("NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS\n");
> +	if (dentry->d_inode)
>  		goto out_put;
> -	}
>  	status = mnt_want_write(rec_file->f_path.mnt);
>  	if (status)
>  		goto out_put;
> @@ -157,12 +156,14 @@ out_put:
>  	dput(dentry);
>  out_unlock:
>  	mutex_unlock(&dir->d_inode->i_mutex);
> -	if (status == 0) {
> -		clp->cl_firststate = 1;
> +	if (status == 0)
>  		vfs_fsync(rec_file, 0);
> -	}
> +	else
> +		printk(KERN_ERR "NFSD: failed to write recovery record"
> +				" (err %d); please check that %s exists"
> +				" and is writeable", status,
> +				user_recovery_dirname);

Whooff, hey thank you bruce, alot. I'm so sorry I assumed the name was
readily available only I have hard time finding it in 30 seconds of trying.
(So it was me, that's lazy). I did not mean for this to be so much work.

But the up side is that I'm sure some future admin's lives will be relieved
and that's Karma points ;-)

Thanks very much and ACK on both patches. 
Boaz

>  	nfs4_reset_creds(original_cred);
> -	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
>  	return status;
>  }
>  
