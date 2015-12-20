Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49312 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbbLTPul (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 20 Dec 2015 10:50:41 -0500
Date: Sun, 20 Dec 2015 07:50:40 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@primarydata.com,
        bfields@fieldses.org, hch@infradead.org
Subject: Re: [PATCH v2 2/3] NFSD: Implement the COPY call
Message-ID: <20151220155040.GB18236@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-3-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1450472727-19893-3-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
> +		  stateid_t *src_stateid, struct file **src,
> +		  stateid_t *dst_stateid, struct file **dst)

I'm not really sold on a helper for two function calls and a simple
conditional.  I'm also not totally against it, though.

> +	p = xdr_encode_hyper(p, write->wr_bytes_written);
> +	*p++ = cpu_to_be32(write->wr_stable_how);
> +	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data, NFS4_VERIFIER_SIZE);

please stick to 80 characters per line.

> +
> +static __be32
> +nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
> +		  struct nfsd4_copy *copy)
> +{
> +	__be32 *p, err;
> +
> +	if (!nfserr) {
> +		err = nfsd42_encode_write_res(resp, &copy->cp_res);
> +		if (err)
> +			return err;
> +
> +		p = xdr_reserve_space(&resp->xdr, 4 + 4);
> +		*p++ = cpu_to_be32(copy->cp_consecutive);
> +		*p++ = cpu_to_be32(copy->cp_synchronous);
> +	}
> +	return nfserr;

seems lke the err variable is redundant and you could just use nfserr.

> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
> +		        struct file *dst, u64 dst_pos,
> +		        u64 count)

the prototype would easily fit on two lines.

> +{
> +	//u64 limit = 0x800000; /* 4 MB */
> +	//u64 limit = 0x1000000; /* 8 MB */
> +	//u64 limit = 0x2000000; /* 16 MB */
> +	//u64 limit = 0x4000000; /* 32 MB */
> +	//u64 limit = 0x8000000; /* 64 MB */
> +	//u64 limit = 0x10000000; /* 128 MB */
> +	//u64 limit = 0x10000000; /* 256 MB */
> +	//u64 limit = 0x20000000; /* 512 MB */
> +	//u64 limit = 0x40000000; /* 1024 MB */
> +	//u64 limit = 0x80000000; /* 2048 MB */
> +
> +	//if (count > limit)
> +	//	count = limit;

This looks like odd left over debug code.  Note that vfs_copy_file_range
has a size_t limit, so we might need some explicit handling here instead
of silent truncation.
