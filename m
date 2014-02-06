Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32656 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752618AbaBFSIb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Feb 2014 13:08:31 -0500
Date: Thu, 6 Feb 2014 13:08:12 -0500
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir vs. getattr
Message-ID: <20140206130812.3ec425e9@tlielax.poochiereds.net>
In-Reply-To: <20140206135101.1cc83442@notabene.brown>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	<20130404151507.GA8484@umich.edu>
	<CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	<1365090480.10726.22.camel@leira.trondhjem.org>
	<20140129182532.7479eeda@notabene.brown>
	<1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	<20140129071841.1979a48c@tlielax.poochiereds.net>
	<20140206134539.53d09434@notabene.brown>
	<20140206135101.1cc83442@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 6 Feb 2014 13:51:01 +1100
NeilBrown <neilb@suse.de> wrote:

> 
> On Thu, 6 Feb 2014 13:45:39 +1100 NeilBrown <neilb@suse.de> wrote:
> 

> The idea is that the first time we find that we look up a file in a directory
> and will need to do a GETATTR, we flush the cached data in the directory so
> READDIRPLUS will be used in future.

Nice. I like that idea. If we had previously used READDIRPLUS then we'd
presumably have the inode in cache and would only need to do the
GETATTR if the attributes had expired. If they had expired on that one
then the cached directory data is probably stale as well.

OTOH, files and directories have different actimeo values. If the
acreg* values are smaller than the acdir* values then we may end up
doing more on the wire READDIR* calls than we would have prior to this
patch.

That's not necessarily wrong, but it might change the behavior on some
workloads. I guess I need to ponder that a bit more... ;)

> 
> > The change to nfs_update_inode fixes an issue that had me stumped for a
> > while.  It was still sending lots of GETATTR requests even after it had
> > switched to READDIRPLUS instead of using cached info.  So that might be a
> > genuine bug that should be fixed independently of this patch.
> 
> I managed to post the wrong version of the patch, which didn't have this
> change.  Sorry.
> 
> Here is the real one.
> 
> NeilBrown
> 

Looks good overall, comment inline below...

> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index be38b573495a..b237fd7f2e0e 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -845,9 +845,12 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
>  	desc->dir_cookie = &dir_ctx->dir_cookie;
>  	desc->decode = NFS_PROTO(inode)->decode_dirent;
>  	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
> +	if (desc->plus && ctx->pos == 0)
> +		clear_bit(NFS_INO_DID_FLUSH, &NFS_I(inode)->flags);
>  
>  	nfs_block_sillyrename(dentry);
> -	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
> +	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode) ||
> +	    (NFS_I(inode)->cache_validity & NFS_INO_INVALID_DATA))
>  		res = nfs_revalidate_mapping(inode, file->f_mapping);
>  	if (res < 0)
>  		goto out;
> @@ -1080,6 +1083,16 @@ static int nfs_lookup_revalidate(struct dentry *dentry, unsigned int flags)
>  
>  	/* Force a full look up iff the parent directory has changed */
>  	if (!nfs_is_exclusive_create(dir, flags) && nfs_check_verifier(dir, dentry)) {
> +		if (nfs_server_capable(dir, NFS_CAP_READDIRPLUS)
> +		    && ((NFS_I(inode)->cache_validity &
> +			 (NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
> +			|| nfs_attribute_cache_expired(inode))
> +		    && !test_and_set_bit(NFS_INO_DID_FLUSH, &NFS_I(dir)->flags)
> +			) {
> +			nfs_advise_use_readdirplus(dir);
> +			goto out_zap_parent;
> +		}
> +
>  		if (nfs_lookup_verify_inode(inode, flags))
>  			goto out_zap_parent;
>  		goto out_valid;
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 28a0a3cbd3b7..3996e6c7a728 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -1526,6 +1526,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
>  
>  	save_cache_validity = nfsi->cache_validity;
>  	nfsi->cache_validity &= ~(NFS_INO_INVALID_ATTR
> +			| NFS_INO_INVALID_LABEL
>  			| NFS_INO_INVALID_ATIME
>  			| NFS_INO_REVAL_FORCED
>  			| NFS_INO_REVAL_PAGECACHE);

Well spotted. Honestly, I'm not sure that NFS_INO_INVALID_LABEL really
provides any value at all. I think the idea was to have that indicate
when the security label is invalid for labeled NFS, but it seems to
only be set and cleared in conjunction with NFS_INO_INVALID_ATTR.

It might be best to just dump that flag altogether and rely on
NFS_INO_INVALID_ATTR to indicate an invalid label as well. It really is
just another attribute after all (at least in the current
implementation).

As to your earlier point, yeah I think that fix is probably best done
in a separate patch since it's not directly related to the original
issue.

> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index 0ae5807480f4..c282ce3e5349 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -218,6 +218,7 @@ struct nfs_inode {
>  #define NFS_INO_COMMIT		(7)		/* inode is committing unstable writes */
>  #define NFS_INO_LAYOUTCOMMIT	(9)		/* layoutcommit required */
>  #define NFS_INO_LAYOUTCOMMITTING (10)		/* layoutcommit inflight */
> +#define NFS_INO_DID_FLUSH	(11)
>  
>  static inline struct nfs_inode *NFS_I(const struct inode *inode)
>  {


-- 
Jeff Layton <jlayton@redhat.com>
