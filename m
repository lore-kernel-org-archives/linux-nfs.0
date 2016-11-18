Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51216 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752174AbcKRN2e (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 08:28:34 -0500
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Trond Myklebust" <trond.myklebust@primarydata.com>
Cc: "Anna Schumaker" <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, "Scott Mayhew" <smayhew@redhat.com>
Subject: Re: [PATCH v2] Don't invalidate directory mapping until attributes
 expire
Date: Fri, 18 Nov 2016 08:28:31 -0500
Message-ID: <34245253-C2E0-434F-A4FE-D74560EF93BA@redhat.com>
In-Reply-To: <e0f959ab63372fef427e6d1cccf7e85d1f4b51c1.1472225243.git.bcodding@redhat.com>
References: <67cfa1f7f028229bfd4b1ac2619bc85b9e34ef7f.1472059583.git.bcodding@redhat.com>
 <e0f959ab63372fef427e6d1cccf7e85d1f4b51c1.1472225243.git.bcodding@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Any issues with this one?

On 26 Aug 2016, at 11:37, Benjamin Coddington wrote:

> This approach uses another bit in the inode flags..  if that's too 
> expensive
> for this ls -l optimization, I will look for another way.
>
> Change from v1:
> 	Doesn't completely break the commit 311324ad1713 functionality.
>
> 8<-----------------------------------------------------------------------------
>
> Commit 311324ad1713666a6e803aecf0d4e1a136a5b34a ("NFS: Be more 
> aggressive
> in using readdirplus for 'ls -l' situations") removed the optimization
> added by commit 07b5ce8ef2d87f1914054804720d6facbaa3f4ce ("NFS: Make 
> nfs_readdir
> revalidate less often") to bypass the revalidation of the directory 
> mapping
> on subsequent calls into nfs_readdir().  Add that optimization back 
> here.
>
> A directory modified once every second and containing 40k entries 
> takes my
> system around 80 seconds to list.  With this patch, that time is 
> reduced to
> 7 seconds.
>
> Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
> ---
>  fs/nfs/dir.c           | 3 ++-
>  include/linux/nfs_fs.h | 1 +
>  2 files changed, 3 insertions(+), 1 deletion(-)
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 19d93d0cd400..88f5dd561025 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -477,6 +477,7 @@ void nfs_force_use_readdirplus(struct inode *dir)
>  {
>  	if (!list_empty(&NFS_I(dir)->open_files)) {
>  		nfs_advise_use_readdirplus(dir);
> +		set_bit(NFS_INO_FORCE_RDPLUS, &NFS_I(dir)->flags);
>  		nfs_zap_mapping(dir, dir->i_mapping);
>  	}
>  }
> @@ -878,7 +879,7 @@ static bool nfs_dir_mapping_need_revalidate(struct 
> inode *dir)
>
>  	if (nfs_attribute_cache_expired(dir))
>  		return true;
> -	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
> +	if (test_and_clear_bit(NFS_INO_FORCE_RDPLUS, &nfsi->flags))
>  		return true;
>  	return false;
>  }
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index d71278c3c5bd..729cddb7364f 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -211,6 +211,7 @@ struct nfs_inode {
>  #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
>  #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
>  #define NFS_INO_LAYOUTSTATS	(11)		/* layoutstats inflight */
> +#define NFS_INO_FORCE_RDPLUS	(12)		/* force readdirplus */
>
>  static inline struct nfs_inode *NFS_I(const struct inode *inode)
>  {
> -- 
> 2.5.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" 
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
