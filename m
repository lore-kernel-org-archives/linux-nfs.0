Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33054 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932456AbdA3PfY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Jan 2017 10:35:24 -0500
Date: Mon, 30 Jan 2017 10:35:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.com>
Cc: Linux NFS Mailing <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSDv4: use export cache flushtime for changeid on
 V4ROOT objects.
Message-ID: <20170130153517.GC24786@fieldses.org>
References: <87mve9rs0z.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87mve9rs0z.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 30, 2017 at 05:17:00PM +1100, NeilBrown wrote:
> 
> If you change the set of filesystems that are exported, then
> the contents of various directories in the NFSv4 pseudo-root
> is likely to change.  However the change-id of those
> directories is currently tied to the underlying directory,
> so the clinet may not see the changes in a timely fashion.

Oh, good catch.

> This patch changes the change-id number to be derived from the
> "flush_time" of the export cache.  Whenever any changes are
> made to the set of exported filesystems, this flush_time is
> updated.  The result is that clients see changes to the set
> of exported filesystems much more quickly, often immediately.

And, a clever solution, as usual....

I wonder if it's completely right yet, though.  Off the top of my head:
can't the client see the new flush time before it sees the new contents?
If so, a client that caches both during that window could cache the old
contents indefinitely.

--b.

> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  fs/nfsd/nfs4xdr.c | 10 +++++++---
>  1 file changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 8fae53ce21d1..dbff0122b784 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -1966,9 +1966,13 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
>  	DECODE_TAIL;
>  }
>  
> -static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *inode)
> +static __be32 *encode_change(__be32 *p, struct kstat *stat, struct inode *inode,
> +			     struct svc_export *exp)
>  {
> -	if (IS_I_VERSION(inode)) {
> +	if (exp->ex_flags & NFSEXP_V4ROOT) {
> +		*p++ = cpu_to_be32(convert_to_wallclock(exp->cd->flush_time));
> +		*p++ = 0;
> +	} else if (IS_I_VERSION(inode)) {
>  		p = xdr_encode_hyper(p, inode->i_version);
>  	} else {
>  		*p++ = cpu_to_be32(stat->ctime.tv_sec);
> @@ -2490,7 +2494,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
>  		p = xdr_reserve_space(xdr, 8);
>  		if (!p)
>  			goto out_resource;
> -		p = encode_change(p, &stat, d_inode(dentry));
> +		p = encode_change(p, &stat, d_inode(dentry), exp);
>  	}
>  	if (bmval0 & FATTR4_WORD0_SIZE) {
>  		p = xdr_reserve_space(xdr, 8);
> -- 
> 2.11.0
> 


