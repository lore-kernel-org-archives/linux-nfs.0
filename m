Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:31850 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753450AbbLGVD5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Dec 2015 16:03:57 -0500
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: Re: [PATCH v1 2/3] NFSD: Implement the COPY call
To: Christoph Hellwig <hch@infradead.org>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
References: <1449176137-4940-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1449176137-4940-3-git-send-email-Anna.Schumaker@Netapp.com>
 <20151207192646.GB8318@infradead.org>
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@primarydata.com>,
        <bfields@fieldses.org>
Message-ID: <5665F42F.1090000@Netapp.com>
Date: Mon, 7 Dec 2015 16:03:43 -0500
MIME-Version: 1.0
In-Reply-To: <20151207192646.GB8318@infradead.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 12/07/2015 02:26 PM, Christoph Hellwig wrote:
>>  static __be32
>> +nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
>> +		  struct nfsd4_copy *copy, struct file **src, struct file **dst)
>> +{
>> +	__be32 status;
>> +
>> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->save_fh,
>> +						&copy->cp_src_stateid, RD_STATE,
>> +						src, NULL);
>> +	if (status) {
>> +		dprintk("NFSD: nfsd4_copy: couldn't process src stateid!\n");
>> +		return status;
>> +	}
>> +
>> +	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
>> +						&copy->cp_dst_stateid, WR_STATE,
>> +						dst, NULL);
>> +	if (status) {
>> +		dprintk("NFSD: nfsd4_copy: couldn't process dst stateid!\n");
>> +		fput(*src);
>> +	}
> 
> This is missing a return status.  On the clone side that caused really
> hard to debug crashes when xfstests hit this case.  While you're at it
> I'd suggest to also kill the nfsd4_verify_copy heper.  You might also
> need a check for invalid file types that maps to the correct NFS error
> code, similar to clone.

I just updated against the clone code, and I made some of these changes earlier this afternoon.  I kept the verify_copy() helper around and changed clone to call it, since all of the stateid verification code would be almost identical.

> 
>> +	if (bytes < 0)
>> +		status = nfserrno(bytes);
> 
> maybe use a goto here?

Maybe.  I'll see how the code looks!

> 
>> +	else {
>> +		copy->cp_res.wr_bytes_written = bytes;
>> +		copy->cp_res.wr_stable_how = NFS_FILE_SYNC;
>> +		copy->cp_consecutive = 1;
> 
> is there anything in the linux semantics that guarantees consecutive
> operation?

I think so.  The splice fallback iterates starting at the beginning of the file, so if something goes wrong later on then the earlier pages should at least be copied.

> 
>> +		       u64 count)
>> +{
>> +	ssize_t bytes;
>> +	u64 limit = 0x10000000;
>> +
>> +	if (count > limit)
>> +		count = limit;
>> +
>> +	bytes = vfs_copy_file_range(src, src_pos, dst, dst_pos, count, 0);
>> +	if (bytes > 0)
>> +		vfs_fsync_range(dst, dst_pos, dst_pos + bytes, 0);
>> +	return bytes;
> 
> How about returning NFS_UNSTABLE above and avoiding the fsync here?

I was just looking into this, too.  I'm trying to figure out the right way to handle this on the client side, since right now we ignore this value.  I have gotten as far as "if the file is open with O_SYNC, then we should commit after copying."

Anna

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

