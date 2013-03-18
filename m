Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ea0-f178.google.com ([209.85.215.178]:41296 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab3CRQWf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Mar 2013 12:22:35 -0400
Received: by mail-ea0-f178.google.com with SMTP id g14so2673964eak.23
        for <linux-nfs@vger.kernel.org>; Mon, 18 Mar 2013 09:22:34 -0700 (PDT)
Message-ID: <51473F46.10401@tonian.com>
Date: Mon, 18 Mar 2013 18:22:30 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "stable@kernel.org" <stable@kernel.org>
Subject: Re: [PATCH] pnfs: do not reset to mds if wb_offset != wb_pgbase
References: <1363617532-24172-1-git-send-email-bhalevy@tonian.com> <1363622128.4351.15.camel@leira.trondhjem.org>
In-Reply-To: <1363622128.4351.15.camel@leira.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2013-03-18 17:55, Myklebust, Trond wrote:
> On Mon, 2013-03-18 at 16:38 +0200, Benny Halevy wrote:
>> We're seeing roughly 20% of the I/Os going to the MDS
>> when installing a VM over KVM in "none" caching mode (O_DIRECT).
>> Instrumenting the client reveled that this is caused by buffer
>> alignment vs. file offset alignment.
>> Besides being a performance problem, when the MDS caches data
>> this is also manifested as data corruption when data is written
>> first via the MDS, then via the DS, eventually the stale data is
>> read back from the MDS.
> 
> That's why we should return the layout.
> 

We are not in this case.

>> Note that this check exists also for the file layout specific
>> pg_init_* functions.  The objects (ORE) and block
>> (bl_{read,write}_pagelist) layouts seem to deal correctly with
>> splitting IOs in the case where req->wb_offset != req->wb_pgbase
>> though this hasn't been tested wen submitting this patch.
>>
>> Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>> Cc: stable@kernel.org [>= 3.5]
>> Cc: Boaz Harrosh <bharrosh@panasas.com>
>> Cc: Peng Tao <tao.peng@emc.com>
>> ---
>>  fs/nfs/pnfs.c | 18 ++++++++++--------
>>  1 file changed, 10 insertions(+), 8 deletions(-)
>>
>> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
>> index 483bd94..f12e456 100644
>> --- a/fs/nfs/pnfs.c
>> +++ b/fs/nfs/pnfs.c
>> @@ -1322,10 +1322,11 @@ struct pnfs_layout_segment *
>>  
>>  	WARN_ON_ONCE(pgio->pg_lseg != NULL);
>>  
>> -	if (req->wb_offset != req->wb_pgbase) {
>> -		nfs_pageio_reset_read_mds(pgio);
>> -		return;
>> -	}
>> +	if (req->wb_offset != req->wb_pgbase)
>> +		dprintk("%s: inode=%ld: offset=%llu wb_bytes=%u wb_offset=%u wb_pgbase=%u\n",
>> +			__func__, pgio->pg_inode->i_ino,
>> +			(((unsigned long long)req->wb_index) << PAGE_CACHE_SHIFT) + req->wb_offset,
>> +			req->wb_bytes, req->wb_offset, req->wb_pgbase);
>>  
>>  	if (pgio->pg_dreq == NULL)
>>  		rd_size = i_size_read(pgio->pg_inode) - req_offset(req);
>> @@ -1351,10 +1352,11 @@ struct pnfs_layout_segment *
>>  {
>>  	WARN_ON_ONCE(pgio->pg_lseg != NULL);
>>  
>> -	if (req->wb_offset != req->wb_pgbase) {
>> -		nfs_pageio_reset_write_mds(pgio);
>> -		return;
>> -	}
>> +	if (req->wb_offset != req->wb_pgbase)
>> +		dprintk("%s: inode=%ld: offset=%llu wb_bytes=%u wb_offset=%u wb_pgbase=%u\n",
>> +			__func__, pgio->pg_inode->i_ino,
>> +			(((unsigned long long)req->wb_index) << PAGE_CACHE_SHIFT) + req->wb_offset,
>> +			req->wb_bytes, req->wb_offset, req->wb_pgbase);
>>  
>>  	pgio->pg_lseg = pnfs_update_layout(pgio->pg_inode,
>>  					   req->wb_context,
> 
> NACK. I see no evidence that we've addressed the issues that were raised
> by Fred in commit 1825a0d08f22463e5a8f4b1636473efd057a3479 (NFS: prepare
> coalesce testing for directio).
> If you think that his concerns about the coalescing assumptions are no
> longer true, then please point to why this is the case. AFAICR that
> patch was added to fix corruption issues.
> 

We see no problems with this patch with the workloads we're testing.
Do you have a test that reproduces the original problem that we can try running?

Benny
