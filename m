Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1050.oracle.com ([156.151.31.82]:39168 "EHLO
	userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754816Ab2JVPug (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Oct 2012 11:50:36 -0400
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
	by userp1050.oracle.com (Sentrion-MTA-4.2.2/Sentrion-MTA-4.2.2) with ESMTP id q9MFb55U029570
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Oct 2012 15:37:05 GMT
Message-ID: <508567C7.6000104@oracle.com>
Date: Mon, 22 Oct 2012 10:35:35 -0500
From: Dave Kleikamp <dave.kleikamp@oracle.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Zach Brown <zab@zabbo.net>,
        "Maxim V. Patlasov" <mpatlasov@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 20/22] nfs: add support for read_iter, write_iter
References: <1350918922-6096-1-git-send-email-dave.kleikamp@oracle.com> <1350918922-6096-21-git-send-email-dave.kleikamp@oracle.com> <4FA345DA4F4AE44899BD2B03EEEC2FA909288AFD@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA909288AFD@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 10/22/2012 10:21 AM, Myklebust, Trond wrote:
>> -----Original Message-----
>> From: Dave Kleikamp [mailto:dave.kleikamp@oracle.com]
>> Sent: Monday, October 22, 2012 11:15 AM
>> To: linux-fsdevel@vger.kernel.org
>> Cc: linux-kernel@vger.kernel.org; Zach Brown; Maxim V. Patlasov; Dave
>> Kleikamp; Myklebust, Trond; linux-nfs@vger.kernel.org
>> Subject: [PATCH 20/22] nfs: add support for read_iter, write_iter
>>
>> This patch implements the read_iter and write_iter file operations which
>> allow kernel code to initiate directIO. This allows the loop device to read and
>> write directly to the server, bypassing the page cache.
>>
>> Signed-off-by: Dave Kleikamp <dave.kleikamp@oracle.com>
>> Cc: Zach Brown <zab@zabbo.net>
>> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
>> Cc: linux-nfs@vger.kernel.org
>> ---
>>  fs/nfs/direct.c        | 169 +++++++++++++++++++++++++++++++++-----------
>> -----
>>  fs/nfs/file.c          |  48 ++++++++++----
>>  fs/nfs/internal.h      |   2 +
>>  fs/nfs/nfs4file.c      |   2 +
>>  include/linux/nfs_fs.h |   6 +-
>>  5 files changed, 155 insertions(+), 72 deletions(-)
>>
>> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c index 4532781..b1fda1c 100644
>> --- a/fs/nfs/direct.c
>> +++ b/fs/nfs/direct.c

>> @@ -429,16 +428,47 @@ static ssize_t
>> nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
>>  	get_dreq(dreq);
>>  	desc.pg_dreq = dreq;
>>
>> -	for (seg = 0; seg < nr_segs; seg++) {
>> -		const struct iovec *vec = &iov[seg];
>> -		result = nfs_direct_read_schedule_segment(&desc, vec,
>> pos, uio);
>> -		if (result < 0)
>> -			break;
>> -		requested_bytes += result;
>> -		if ((size_t)result < vec->iov_len)
>> -			break;
>> -		pos += vec->iov_len;
>> -	}
>> +	if (iov_iter_has_iovec(iter)) {
>> +		const struct iovec *iov = iov_iter_iovec(iter);
>> +		if (uio)
>> +			dreq->flags = NFS_ODIRECT_MARK_DIRTY;
>> +		for (seg = 0; seg < iter->nr_segs; seg++) {
>> +			const struct iovec *vec = &iov[seg];
>> +			result = nfs_direct_read_schedule_segment(&desc,
>> vec,
>> +								  pos, uio);
>> +			if (result < 0)
>> +				break;
>> +			requested_bytes += result;
>> +			if ((size_t)result < vec->iov_len)
>> +				break;
>> +			pos += vec->iov_len;
>> +		}
>> +	} else if (iov_iter_has_bvec(iter)) {
>> +		struct nfs_open_context *ctx = dreq->ctx;
>> +		struct inode *inode = ctx->dentry->d_inode;
>> +		struct bio_vec *bvec = iov_iter_bvec(iter);
>> +		for (seg = 0; seg < iter->nr_segs; seg++) {
>> +			struct nfs_page *req;
>> +			unsigned int req_len = bvec[seg].bv_len;
>> +			req = nfs_create_request(ctx, inode,
>> +						 bvec[seg].bv_page,
>> +						 bvec[seg].bv_offset,
>> req_len);
>> +			if (IS_ERR(req)) {
>> +				result = PTR_ERR(req);
>> +				break;
>> +			}
>> +			req->wb_index = pos >> PAGE_SHIFT;
>> +			req->wb_offset = pos & ~PAGE_MASK;
>> +			if (!nfs_pageio_add_request(&desc, req)) {
>> +				result = desc.pg_error;
>> +				nfs_release_request(req);
>> +				break;
>> +			}
>> +			requested_bytes += req_len;
>> +			pos += req_len;
>> +		}
>> +	} else
>> +		BUG();
> 
> Can we please split the contents of these 2 if statements into 2 helper functions  nfs_direct_do_schedule_read_iovec() and nfs_direct_do_schedule_read_bvec()?
> 

Sure, no problem.

>> @@ -832,17 +861,48 @@ static ssize_t
>> nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
>>  	get_dreq(dreq);
>>  	atomic_inc(&inode->i_dio_count);
>>
>> -	NFS_I(dreq->inode)->write_io += iov_length(iov, nr_segs);
>> -	for (seg = 0; seg < nr_segs; seg++) {
>> -		const struct iovec *vec = &iov[seg];
>> -		result = nfs_direct_write_schedule_segment(&desc, vec,
>> pos, uio);
>> -		if (result < 0)
>> -			break;
>> -		requested_bytes += result;
>> -		if ((size_t)result < vec->iov_len)
>> -			break;
>> -		pos += vec->iov_len;
>> -	}
>> +	NFS_I(dreq->inode)->write_io += iov_iter_count(iter);
>> +
>> +	if (iov_iter_has_iovec(iter)) {
>> +		const struct iovec *iov = iov_iter_iovec(iter);
>> +		for (seg = 0; seg < iter->nr_segs; seg++) {
>> +			const struct iovec *vec = &iov[seg];
>> +			result = nfs_direct_write_schedule_segment(&desc,
>> vec,
>> +								   pos, uio);
>> +			if (result < 0)
>> +				break;
>> +			requested_bytes += result;
>> +			if ((size_t)result < vec->iov_len)
>> +				break;
>> +			pos += vec->iov_len;
>> +		}
>> +	} else if (iov_iter_has_bvec(iter)) {
>> +		struct nfs_open_context *ctx = dreq->ctx;
>> +		struct bio_vec *bvec = iov_iter_bvec(iter);
>> +		for (seg = 0; seg < iter->nr_segs; seg++) {
>> +			struct nfs_page *req;
>> +			unsigned int req_len = bvec[seg].bv_len;
>> +
>> +			req = nfs_create_request(ctx, inode,
>> bvec[seg].bv_page,
>> +						 bvec[seg].bv_offset,
>> req_len);
>> +			if (IS_ERR(req)) {
>> +				result = PTR_ERR(req);
>> +				break;
>> +			}
>> +			nfs_lock_request(req);
>> +			req->wb_index = pos >> PAGE_SHIFT;
>> +			req->wb_offset = pos & ~PAGE_MASK;
>> +			if (!nfs_pageio_add_request(&desc, req)) {
>> +				result = desc.pg_error;
>> +				nfs_unlock_and_release_request(req);
>> +				break;
>> +			}
>> +			requested_bytes += req_len;
>> +			pos += req_len;
>> +		}
>> +	} else
>> +		BUG();
> 
> Ditto...

ok

> 
> Otherwise, everything looks fine to me...
> 
> Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> Cheers
>   Trond

Thanks,
Shaggy
