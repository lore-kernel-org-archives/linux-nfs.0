Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:53543 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164Ab1H0Xxn convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Aug 2011 19:53:43 -0400
Subject: Re: [PATCH] NFS: Add "device" tag to /proc/self/mountstats
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E5807A8.2020600@netapp.com>
Date: Sat, 27 Aug 2011 19:52:25 -0400
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Message-Id: <6701215B-7718-4EE2-9EC4-BFE0936B0D2A@oracle.com>
References: <4E5807A8.2020600@netapp.com>
To: Bryan Schumaker <bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Aug 26, 2011, at 4:52 PM, Bryan Schumaker wrote:

> nfsiostat was failing to find mounted filesystems on recent kernels due
> to changes in the VFS that resulted in a missing "device" tag in the
> /proc/self/mountstats file.

What was the commit ID that changed this formal kernel API?  I'd like to see the justification.

> This patch re-adds the "device" tag for NFS
> mount data in /proc/self/mountstats.

The purpose of mountstats is to be an interface that all file systems can use.  If we can't add "device" back to all mounts listed in /proc/self/mountstats, it might be better to adjust nfsiostats to cope.

> Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
> ---
> fs/nfs/super.c |    4 +++-
> 1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index b961cea..e6a0317 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -766,8 +766,10 @@ static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
> 	devname = nfs_path(&dummy, mnt->mnt_root, page, PAGE_SIZE);
> 	if (IS_ERR(devname))
> 		err = PTR_ERR(devname);
> -	else
> +	else {
> +		seq_puts(m, "device ");
> 		seq_escape(m, devname, " \t\n\\");
> +	}
> 	free_page((unsigned long)page);
> 	return err;
> }
> -- 
> 1.7.6

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




