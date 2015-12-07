Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:38039 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753450AbbLGT0r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Dec 2015 14:26:47 -0500
Date: Mon, 7 Dec 2015 11:26:46 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v1 2/3] NFSD: Implement the COPY call
Message-ID: <20151207192646.GB8318@infradead.org>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  static __be32
> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  struct nfsd4_copy *copy, struct file **src, struct file **dst)
> +{
> +	__be32 status;
> +
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
> +						&copy->cp_src_stateid, RD_STATE,
> +						src, NULL);
> +	if (status) {
> +		dprintk("NFSD: nfsd4_copy: couldn't process src stateid!\n");
> +		return status;
> +	}
> +
> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
> +						&copy->cp_dst_stateid, WR_STATE,
> +						dst, NULL);
> +	if (status) {
> +		dprintk("NFSD: nfsd4_copy: couldn't process dst stateid!\n");
> +		fput(*src);
> +	}

This is missing a return status.  On the clone side that caused really
hard to debug crashes when xfstests hit this case.  While you're at it
I'd suggest to also kill the nfsd4_verify_copy heper.  You might also
need a check for invalid file types that maps to the correct NFS error
code, similar to clone.

> +	if (bytes < 0)
> +		status = nfserrno(bytes);

maybe use a goto here?

> +	else {
> +		copy->cp_res.wr_bytes_written = bytes;
> +		copy->cp_res.wr_stable_how = NFS_FILE_SYNC;
> +		copy->cp_consecutive = 1;

is there anything in the linux semantics that guarantees consecutive
operation?

> +		       u64 count)
> +{
> +	ssize_t bytes;
> +	u64 limit = 0x10000000;
> +
> +	if (count > limit)
> +		count = limit;
> +
> +	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
> +	if (bytes > 0)
> +		vfs_fsync_range(dst, dst_pos, dst_pos + bytes, 0);
> +	return bytes;

How about returning NFS_UNSTABLE above and avoiding the fsync here?
