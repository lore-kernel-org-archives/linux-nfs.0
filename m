Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:44598 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754538Ab1H0AXO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Aug 2011 20:23:14 -0400
Message-ID: <4E5838E0.4090703@panasas.com>
Date: Fri, 26 Aug 2011 17:22:56 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [RFC] nfsd4: This is: "fix failure to end nfsd4 grace period"
 ++
References: <4E45C594.1030609@panasas.com> <20110826201910.GB17196@fieldses.org>
In-Reply-To: <20110826201910.GB17196@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/26/2011 01:19 PM, J. Bruce Fields wrote:
> On Fri, Aug 12, 2011 at 05:30:12PM -0700, Boaz Harrosh wrote:

<snip>

> @@ -156,12 +155,14 @@ out_put:
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
> +				" (err %d); please check that recovery"
> +				" directory exists and is writeable",
> +				status);

Bruce Hi

Which of the variables has the directory path?
Would we like to add that information in the print. From my experience
alot of times those type of problems is the mis-communication of
the path names, and it helps to see what name was actually attempted.

Other wise looks good
Thanks


>  	nfs4_reset_creds(original_cred);
> -	dprintk("NFSD: nfsd4_create_clid_dir returns %d\n", status);
>  	return status;
>  }
>  

