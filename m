Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:9538 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751523AbcADTjq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 14:39:46 -0500
Subject: Re: [PATCH v2 2/3] NFSD: Implement the COPY call
To: Christoph Hellwig <hch@infradead.org>
References: <1450472727-19893-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1450472727-19893-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20151220155040.GB18236@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <568ACA7F.7000707@Netapp.com>
Date: Mon, 4 Jan 2016 14:39:43 -0500
MIME-Version: 1.0
In-Reply-To: <20151220155040.GB18236@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/20/2015 10:50 AM, Christoph Hellwig wrote:
>> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		  stateid_t *src_stateid, struct file **src,
>> +		  stateid_t *dst_stateid, struct file **dst)
> 
> I'm not really sold on a helper for two function calls and a simple
> conditional.  I'm also not totally against it, though.

I'm planning to keep the helper, since it's still a big chunk of code that would otherwise need to be duplicated.

> 
>> +	p = xdr_encode_hyper(p, write->wr_bytes_written);
>> +	*p++ = cpu_to_be32(write->wr_stable_how);
>> +	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data, NFS4_VERIFIER_SIZE);
> 
> please stick to 80 characters per line.

Okay.

> 
>> +
>> +static __be32
>> +nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
>> +		  struct nfsd4_copy *copy)
>> +{
>> +	__be32 *p, err;
>> +
>> +	if (!nfserr) {
>> +		err = nfsd42_encode_write_res(resp, &copy->cp_res);
>> +		if (err)
>> +			return err;
>> +
>> +		p = xdr_reserve_space(&resp->xdr, 4 + 4);
>> +		*p++ = cpu_to_be32(copy->cp_consecutive);
>> +		*p++ = cpu_to_be32(copy->cp_synchronous);
>> +	}
>> +	return nfserr;
> 
> seems lke the err variable is redundant and you could just use nfserr.

Sure.

> 
>> +ssize_t nfsd_copy_range(struct file *src, u64 src_pos,
>> +		        struct file *dst, u64 dst_pos,
>> +		        u64 count)
> 
> the prototype would easily fit on two lines.

Fixed.

> 
>> +{
>> +	//u64 limit = 0x800000; /* 4 MB */
>> +	//u64 limit = 0x1000000; /* 8 MB */
>> +	//u64 limit = 0x2000000; /* 16 MB */
>> +	//u64 limit = 0x4000000; /* 32 MB */
>> +	//u64 limit = 0x8000000; /* 64 MB */
>> +	//u64 limit = 0x10000000; /* 128 MB */
>> +	//u64 limit = 0x10000000; /* 256 MB */
>> +	//u64 limit = 0x20000000; /* 512 MB */
>> +	//u64 limit = 0x40000000; /* 1024 MB */
>> +	//u64 limit = 0x80000000; /* 2048 MB */
>> +
>> +	//if (count > limit)
>> +	//	count = limit;
> 
> This looks like odd left over debug code.  Note that vfs_copy_file_range
> has a size_t limit, so we might need some explicit handling here instead
> of silent truncation.

Yeah, I meant to remove that before submitting.  I think an unstable reply works better than a silent (and arbitrary) truncate.

Anna

> 

