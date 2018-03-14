Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:21639 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751348AbeCNThE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 14 Mar 2018 15:37:04 -0400
Subject: Re: [PATCH] nfs: nfs_fileid_valid() is wrong on NFSv3 and incomplete
 on NFSv4
To: Eric Rannaud <e@nanocritical.com>, <linux-nfs@vger.kernel.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jessica Peters <jessica.peters@netapp.com>
References: <643b19f35980727fbf9a1756c33a59981b538dd0.1519862053.git.e@nanocritical.com>
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Message-ID: <a4168fd0-dcbf-65c3-f715-a51b30261c5b@Netapp.com>
Date: Wed, 14 Mar 2018 15:36:31 -0400
MIME-Version: 1.0
In-Reply-To: <643b19f35980727fbf9a1756c33a59981b538dd0.1519862053.git.e@nanocritical.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Eric,

On 02/28/2018 07:25 PM, Eric Rannaud wrote:
> On NFSv3, in normal circumstances, NFS_ATTR_FATTR_MOUNTED_ON_FILEID is
> not set on fattr->valid. It is only set in nfs3_decode_dirent() if
> entry->fattr->fileid != entry->ino, which typically only happens for
> mountpoints. (See 1ae04b252351 NFSv3: Use the readdir fileid as the
> mounted-on-fileid.)
> 
> nfs_fileid_valid() returns 'ret1 || ret2', initializing both ret1 and
> ret2 to true, but sets them only conditionally. Therefore, in normal
> circumstances, nfs_fileid_valid() wrongly returns 'false || true' when
> the fileid has changed.
> 
> There is another bug in this function for NFSv4: a server may return a
> fattr with NFS_ATTR_FATTR_FILEID|NFS_ATTR_FATTR_MOUNTED_ON_FILEID.
> nfs_fileid_valid() will fail to detect a change in fileid in the case
> where the fattr->fileid happens to match, by chance, the stored
> nfsi->fileid (copied from a previous fattr->mounted_on_fileid).
> 
> If this is a mountpoint, the current fattr->fileid and the old
> fattr->mounted_on_fileid come from different filesystems and may well
> happen to be identical.
> 
> The condition should be written as an if / else if:
> 
> 	if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
> 	else if (fattr->valid & NFS_ATTR_FATTR_FILEID)

We're requesting both of these attributes as part of the READDIR operation, so won't this return the wrong answer in some cases?

I'm running xfstests "quick" tests with NFS v4.1, and my server is exporting an xfs filesystem for both test and scratch directories (they're on the same partition, but different exported directories using the fsid=X export option).  I'm seeing the following message fairly frequently in my dmesg log once I apply your patch:

      [  222.093367] NFS: server 192.168.100.215 error: fileid changed
                     fsid 0:48: expected fileid 0x60, got 0x60

So I'm thinking that the server is replying with both FATTR_MOUNTED_ON_FILEID and FATTR_FILEID, and then returning false in the mounted-on check when the plain fileid should be compared instead.

I wonder if it would make sense to add another field to the nfs inode to keep track of which fileid is being used.

Thoughts?
Anna

> 
> as is done elsewhere in NFSv4 code.
> ---
>  fs/nfs/inode.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 7d893543cf3b..e1ad5ec75795 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1717,13 +1717,11 @@ EXPORT_SYMBOL_GPL(nfs_post_op_update_inode_force_wcc);
>  static inline bool nfs_fileid_valid(struct nfs_inode *nfsi,
>  				    struct nfs_fattr *fattr)
>  {
> -	bool ret1 = true, ret2 = true;
> -
> -	if (fattr->valid & NFS_ATTR_FATTR_FILEID)
> -		ret1 = (nfsi->fileid == fattr->fileid);
>  	if (fattr->valid & NFS_ATTR_FATTR_MOUNTED_ON_FILEID)
> -		ret2 = (nfsi->fileid == fattr->mounted_on_fileid);
> -	return ret1 || ret2;
> +		return nfsi->fileid == fattr->mounted_on_fileid;
> +	else if (fattr->valid & NFS_ATTR_FATTR_FILEID)
> +		return nfsi->fileid == fattr->fileid;
> +	return true;
>  }
>  
>  /*
> 
