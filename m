Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56030 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaGJKt2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:49:28 -0400
Date: Thu, 10 Jul 2014 03:49:27 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 017/100] nfsd: make deny mode enforcement more
 efficient and close races in it
Message-ID: <20140710104927.GC6935@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-18-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-18-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +__nfs4_file_get_access(struct nfs4_file *fp, u32 access)
>  {
> -	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
> -	atomic_inc(&fp->fi_access[oflag]);
> +	int oflag = nfs4_access_to_omode(access);
> +
> +	if (oflag == O_RDWR) {
> +		atomic_inc(&fp->fi_access[O_RDONLY]);
> +		atomic_inc(&fp->fi_access[O_WRONLY]);
> +	} else
> +		atomic_inc(&fp->fi_access[oflag]);
>  }

Miught be worth to simply kill the old, simple
__nfs4_file_get_access/__nfs4_file_put_access helper that just wrap
the atomic ops in your earlier patch instead of reshuffling everything
here again.

> +nfs4_file_get_access(struct nfs4_file *fp, u32 access)
>  {
>  	lockdep_assert_held(&fp->fi_lock);
>  
>  	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
>  	access &= NFS4_SHARE_ACCESS_BOTH;
> +
> +	/* Does this access mask make sense? */
>  	if (access == 0)
> +		return nfserr_inval;
>  
> +	/* Does it conflict with a deny mode already set? */
> +	if ((access & fp->fi_share_deny) != 0)
> +		return nfserr_share_denied;
> +
> +	__nfs4_file_get_access(fp, access);
> +	return nfs_ok;

Why bother clearing out the inval bits from access?  Just do a:

	if (access & ~NFS4_SHARE_ACCESS_BOTH)
		return nfserr_inval;

also that check doesn't really belong in here, might be better to add it
to the initial nfs4_file_get_access refactor.

> +static __be32 nfs4_file_check_deny(struct nfs4_file *fp, u32 deny)
> +{
> +	/* Common case is that there is no deny mode. */
> +	deny &= NFS4_SHARE_DENY_BOTH;
> +	if (deny) {

No need to reject invalid ones here unlike the access case?  Any reason
to handle them differently?

Otherwise again no need to clear them out, that just makes the code
harder to read.

> +		/* Note: relies on NFS4_SHARE_DENY_BOTH == READ|WRITE */

READ should be NFS4_SHARE_DENY_READ and same for write I guess?  I don't
really think you need these comments anyway, as this is part of the
protocol.

>  
> +/*
> + * A stateid that had a deny mode associated with it is being released
> + * or downgraded. Recalculate the deny mode on the file.
> + */
> +static void
> +recalculate_deny_mode(struct nfs4_file *fp)
> +{
> +	struct nfs4_ol_stateid *stp;
> +
> +	spin_lock(&fp->fi_lock);
> +	fp->fi_share_deny = 0;
> +	list_for_each_entry(stp, &fp->fi_stateids, st_perfile)
> +		fp->fi_share_deny |= bmap_to_share_mode(stp->st_deny_bmap);

Seems like bmap_to_share_mode is superflous with your change of
st_deny_bmap to a char, this could become:

		fp->fi_share_deny |= stp->st_deny_bmap;

>  /* release all access and file references for a given stateid */
>  static void
>  release_all_access(struct nfs4_ol_stateid *stp)
>  {
>  	int i;
> +	struct nfs4_file *fp = stp->st_file;
> +
> +	if (fp && stp->st_deny_bmap != 0)
> +		recalculate_deny_mode(fp);

Can fp be zero here?

> +out_put_access:
> +	stp->st_access_bmap = old_access_bmap;
> +	nfs4_file_put_access(fp, open->op_share_access);
> +	reset_union_bmap_deny(bmap_to_share_mode(old_deny_bmap), stp);

Instead of setting stp->st_access_bmap to the old bmap and then passing
it to reset_union_bmap_deny just pass the bitmap there directly?  Or
just kill reset_union_bmap_denyand inline it given how simple it should have
become with my previous comments addressed.


>  static __be32
>  nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
>  {
>  	__be32 status;
> +	unsigned char old_deny_bmap;
>  
>  	if (!test_access(open->op_share_access, stp))
> +		return nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
>  
> +	/* test and set deny mode */
> +	spin_lock(&fp->fi_lock);
> +	status = nfs4_file_check_deny(fp, open->op_share_deny);
> +	if (status == nfs_ok) {
> +		old_deny_bmap = stp->st_deny_bmap;
> +		set_deny(open->op_share_deny, stp);

Maybe set_deny should return the old bitmap given that quite a few
callers care?  Maybe the set_deny should even move into
nfs4_file_check_deny which could return the old one, making it an check
and set operation.

> @@ -4603,7 +4673,7 @@ static void get_lock_access(struct nfs4_ol_stateid *lock_stp, u32 access)
>  
>  	if (test_access(access, lock_stp))
>  		return;
> -	nfs4_file_get_access(fp, access);
> +	__nfs4_file_get_access(fp, access);
>  	set_access(access, lock_stp);

Why do we not bother with checking the deny mode here?

