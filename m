Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f169.google.com ([209.85.192.169]:57293 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752459AbaDPCvL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 22:51:11 -0400
Received: by mail-pd0-f169.google.com with SMTP id fp1so10246605pdb.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 19:51:11 -0700 (PDT)
Message-ID: <534DEFFF.8090600@gmail.com>
Date: Wed, 16 Apr 2014 10:50:39 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: linux-nfs@vger.kernel.org, Dr Fields James Bruce <bfields@fieldses.org>
Subject: Re: [PATCH] NFS: add FATTR4_WORD1_MODE flags for cache_consistency_bitmask
References: <534A8CEF.6000609@gmail.com>			 <505345D4-4F7C-4970-9EBF-7CFC367575B2@primarydata.com>			 <534AA4FD.3060202@gmail.com>	 <1397402659.6306.5.camel@leira.trondhjem.org>	 <534BDBB6.5030306@gmail.com>		 <4B0A3D7E-5DD0-47A2-B1C8-A2F64E37D781@primarydata.com>		 <534BE338.2030001@gmail.com> <1397487639.7280.4.camel@leira.trondhjem.org>	 <534CBD76.1030109@gmail.com>	 <1FB7545D-81C5-46D5-9A42-322553F122D8@primarydata.com> <1397571892.4709.1.camel@leira.trondhjem.org>
In-Reply-To: <1397571892.4709.1.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2014/4/15 22:24, Trond Myklebust wrote:
> On Tue, 2014-04-15 at 09:22 -0400, Trond Myklebust wrote:
>> On Apr 15, 2014, at 1:02, Kinglong Mee <kinglongmee@gmail.com> wrote:
>>> Next, the "stat testfile" gets data from cache,
>>> because NFS_INO_INVALID_ATTR flags is cleared below.
>>>
>>> Calltrace,
>>> [ 4883.997254] nfs4_proc_write_setup
>>> [ 4884.006885] NFS:  1365 nfs_writeback_done (status 11)
>>> [ 4884.008215] nfs4_write_done
>>> [ 4884.009273] nfs4_write_done_cb
>>> [ 4884.010013] nfs_post_op_update_inode_force_wcc
>>> [ 4884.011221] nfs_update_inode
>>> [ 4884.012001] nfs_update_inode
>>> [ 4884.012952] nfs_writeback_done: before nfs_should_remove_suid
>>> [ 4884.014722] nfs_writeback_done: in nfs_should_remove_suid
>>> [ 4884.016549] nfs4_close_done
>>> [ 4884.017614] nfs_refresh_inode
>>> [ 4884.018645] nfs_update_inode
>>> [ 4884.019693] nfs_update_inode
>>>
>>> But, if getting status before close, the mode can be update to latest.
>>
>> Argh. That is a bug in nfs_update_inode(). It is not supposed to clear NFS_INO_INVALID_ATTR if nfs_fattr does not contain a complete set of attributes.
>>
>> Thanks for testing, Kinglong. This is extremely helpful...
>
> Can you please see if the following patch fixes the above issue?

Thanks Trond,
Yes, the following patch fixes the above issue.
With the two patches you have send, suid/sgid can be updated correctly now.

thanks,
Kinglong Mee

> 8<--------------------------------------------------------------
>>From 12c9c63a005889d70fbcbdb746cd7e7d127b0f01 Mon Sep 17 00:00:00 2001
> From: Trond Myklebust <trond.myklebust@primarydata.com>
> Date: Tue, 15 Apr 2014 10:07:57 -0400
> Subject: [PATCH] NFS: Don't declare inode uptodate unless all attributes were
>   checked
>
> Fix a bug, whereby nfs_update_inode() was declaring the inode to be
> up to date despite not having checked all the attributes.
> The bug occurs because the temporary variable in which we cache
> the validity information is 'sanitised' before reapplying to
> nfsi->cache_validity.
>
> Reported-by: Kinglong Mee <kinglongmee@gmail.com>
> Cc: stable@vger.kernel.org # 3.5+
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> ---
>   fs/nfs/inode.c | 26 +++++++++++++++++---------
>   1 file changed, 17 insertions(+), 9 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index c0f7b1d0b814..a6f9c8581228 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1581,18 +1581,20 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   			inode->i_version = fattr->change_attr;
>   		}
>   	} else if (server->caps & NFS_CAP_CHANGE_ATTR)
> -		invalid |= save_cache_validity;
> +		nfsi->cache_validity |= save_cache_validity;
>
>   	if (fattr->valid & NFS_ATTR_FATTR_MTIME) {
>   		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
>   	} else if (server->caps & NFS_CAP_MTIME)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_REVAL_FORCED);
>
>   	if (fattr->valid & NFS_ATTR_FATTR_CTIME) {
>   		memcpy(&inode->i_ctime, &fattr->ctime, sizeof(inode->i_ctime));
>   	} else if (server->caps & NFS_CAP_CTIME)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_REVAL_FORCED);
>
>   	/* Check if our cached file size is stale */
> @@ -1614,7 +1616,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   					(long long)new_isize);
>   		}
>   	} else
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_REVAL_PAGECACHE
>   				| NFS_INO_REVAL_FORCED);
>
> @@ -1622,7 +1625,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   	if (fattr->valid & NFS_ATTR_FATTR_ATIME)
>   		memcpy(&inode->i_atime, &fattr->atime, sizeof(inode->i_atime));
>   	else if (server->caps & NFS_CAP_ATIME)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATIME
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATIME
>   				| NFS_INO_REVAL_FORCED);
>
>   	if (fattr->valid & NFS_ATTR_FATTR_MODE) {
> @@ -1633,7 +1637,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
>   		}
>   	} else if (server->caps & NFS_CAP_MODE)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_INVALID_ACCESS
>   				| NFS_INO_INVALID_ACL
>   				| NFS_INO_REVAL_FORCED);
> @@ -1644,7 +1649,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   			inode->i_uid = fattr->uid;
>   		}
>   	} else if (server->caps & NFS_CAP_OWNER)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_INVALID_ACCESS
>   				| NFS_INO_INVALID_ACL
>   				| NFS_INO_REVAL_FORCED);
> @@ -1655,7 +1661,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   			inode->i_gid = fattr->gid;
>   		}
>   	} else if (server->caps & NFS_CAP_OWNER_GROUP)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_INVALID_ACCESS
>   				| NFS_INO_INVALID_ACL
>   				| NFS_INO_REVAL_FORCED);
> @@ -1668,7 +1675,8 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>   			set_nlink(inode, fattr->nlink);
>   		}
>   	} else if (server->caps & NFS_CAP_NLINK)
> -		invalid |= save_cache_validity & (NFS_INO_INVALID_ATTR
> +		nfsi->cache_validity |= save_cache_validity &
> +				(NFS_INO_INVALID_ATTR
>   				| NFS_INO_REVAL_FORCED);
>
>   	if (fattr->valid & NFS_ATTR_FATTR_SPACE_USED) {
>
