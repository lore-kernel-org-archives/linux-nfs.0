Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:54766 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750889Ab1HLUgY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Aug 2011 16:36:24 -0400
Message-ID: <4E458EBB.5020104@panasas.com>
Date: Fri, 12 Aug 2011 13:36:11 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@redhat.com>
CC: Casey Bodley <cbodley@citi.umich.edu>,
        NFS list <linux-nfs@vger.kernel.org>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        Malcolm Locke <malc@wholemeal.co.nz>
Subject: Re: Grace period NEVER ends
References: <4E44790A.8000106@panasas.com> <4E447EEB.501@panasas.com> <4E4481F0.2050806@panasas.com> <20110812021556.GD9761@pad.fieldses.org> <CAMeBU_28VPCtExvU1gr3oTbLLyqp=qFwFjxehoea64Xqi=_ncQ@mail.gmail.com> <20110812143228.GD16960@pad.fieldses.org>
In-Reply-To: <20110812143228.GD16960@pad.fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/12/2011 07:32 AM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 10:08:03AM -0400, Casey Bodley wrote:
>> On Thu, Aug 11, 2011 at 10:15 PM, J. Bruce Fields <bfields@redhat.com> wrote:
>>> On Thu, Aug 11, 2011 at 06:29:20PM -0700, Boaz Harrosh wrote:
>>>> With this patch I'm back to the previous behavior. That is
>>>> wait your grace period then continue.
>>>
>>> Is it true for some reason that the client never sends RECLAIM_COMPLETE?
>>
>> I tested this yesterday with the windows client and saw the same
>> never-ending grace period on OPEN.  We do send RECLAIM_COMPLETE, and
>> it completes successfully.  Other operations like CREATE and REMOVE
>> succeed as well.
> 
> Argh.  Does this help?
> 
> Unfortunately, this doesn't explain Malcolm Locke's problem, as it's 4.1
> specific.
> 
> --b.
> 
> commit d43b4d070a24edcbe5f5e9ffcf7a33bbeccdd47d
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Fri Aug 12 10:27:18 2011 -0400
> 
>     nfsd4: fix failure to end nfsd4 grace period
>     
>     Even if we fail to write a recovery record to stable storage, we should
>     still mark the client as having acquired its first state.  Otherwise we
>     leave 4.1 clients with indefinite ERR_GRACE returns.
>     
>     Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> 
> diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
> index 29d77f6..4c7537d 100644
> --- a/fs/nfsd/nfs4recover.c
> +++ b/fs/nfsd/nfs4recover.c
> @@ -156,10 +156,9 @@ out_put:
>  	dput(dentry);
>  out_unlock:
>  	mutex_unlock(&dir->d_inode->i_mutex);
> -	if (status == 0) {
> -		clp->cl_firststate = 1;
> +	if (status == 0)
>  		vfs_fsync(rec_file, 0);
> -	}
> +	clp->cl_firststate = 1;
>  	nfs4_reset_creds(original_cred);
>  	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
>  	return status;

I don't think this fix is enough what about the failure of nfs4_save_creds
It can only fail with -ENOMEM do you hang the client in this case?
What about:

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 29d77f6..3becde7 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -129,9 +129,12 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	if (!rec_file || clp->cl_firststate)
 		return 0;
 
+	clp->cl_firststate = 1;
 	status = nfs4_save_creds(&original_cred);
-	if (status < 0)
+	if (unlikely(status < 0)) {
+		printk(KERN_ERR "!!!nfs4_save_creds Returned => %d\n", status);
 		return status;
+	}
 
 	dir = rec_file->f_path.dentry;
 	/* lock the parent */
@@ -140,6 +143,7 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 	dentry = lookup_one_len(dname, dir, HEXDIR_LEN-1);
 	if (IS_ERR(dentry)) {
 		status = PTR_ERR(dentry);
+		printk(KERN_ERR "NFSD: lookup_one_len => %d\n", status);
 		goto out_unlock;
 	}
 	status = -EEXIST;
@@ -148,18 +152,21 @@ nfsd4_create_clid_dir(struct nfs4_client *clp)
 		goto out_put;
 	}
 	status = mnt_want_write(rec_file->f_path.mnt);
-	if (status)
+	if (unlikely(status)) {
+		printk(KERN_ERR "!!!mnt_want_write Returned => %d\n", status);
 		goto out_put;
+	}
 	status = vfs_mkdir(dir->d_inode, dentry, S_IRWXU);
+	if (unlikely(status))
+		printk(KERN_ERR "!!!vfs_mkdir Returned => %d\n", status);
+
 	mnt_drop_write(rec_file->f_path.mnt);
 out_put:
 	dput(dentry);
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
-	if (status == 0) {
-		clp->cl_firststate = 1;
+	if (status == 0)
 		vfs_fsync(rec_file, 0);
-	}
 	nfs4_reset_creds(original_cred);
 	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
 	return status;

I think Some of these prints should be delegated to a KERN_ERR since
it is a possible setup problem. 

I get these a lot:
	NFSD: nfsd4_create_clid_dir: DIRECTORY EXISTS

what is suppose to delete this directory? I did a clean
umount and reboot. Next time up it is there.

I guess that explains my problem. So yes this fixes it for
me too. I'm able to run as usual.

Thanks
Boaz
