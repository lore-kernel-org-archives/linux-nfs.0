Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:55811 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751485Ab2HNK5X (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Aug 2012 06:57:23 -0400
Message-ID: <502A2F06.7070409@panasas.com>
Date: Tue, 14 Aug 2012 13:57:10 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@emc.com>
Subject: Re: [PATCH-v2 2/3] NFS41: send real write size in layoutget
References: <1344868776-1739-1-git-send-email-bergwolf@gmail.com>  <1344868776-1739-2-git-send-email-bergwolf@gmail.com> <4FA345DA4F4AE44899BD2B03EEEC2FA93A0828@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA93A0828@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/14/2012 03:42 AM, Myklebust, Trond wrote:
<>

>>  void
>>  pnfs_generic_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>>  {
>> +	u64 wb_size;
>> +	unsigned policy = NFS_SERVER(pgio->pg_inode)->pnfs_curr_ld->flags &
>> +						PNFS_LAYOUTGET_POLICY_MASK;
>> +
>>  	BUG_ON(pgio->pg_lseg != NULL);
>>  
>>  	if (req->wb_offset != req->wb_pgbase) {
>>  		nfs_pageio_reset_write_mds(pgio);
>>  		return;
>>  	}
>> +
>> +	if (pgio->pg_dreq == NULL) {
>> +		switch(policy) {
>> +		case PNFS_LAYOUTGET_ISIZE:
>> +			wb_size = i_size_read(pgio->pg_inode) - req_offset(req);
>> +			break;
>> +		case PNFS_LAYOUTGET_SEARCH_HOLE:
>> +			wb_size = pnfs_num_cont_bytes(pgio->pg_inode, req->wb_index);
>> +			break;
>> +		case PNFS_LAYOUTGET_ALL_FILE:
>> +			wb_size = NFS4_MAX_UINT64;
>> +			break;
>> +		default:
>> +			WARN_ONCE(1, "invalid layoutget policy %u", policy);
>> +			wb_size = PAGE_CACHE_SIZE;
>> +			break;
>> +		}
>> +	} else {
>> +		wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
>> +	}
>> +
> 
> Please just calculate the correct value for wb_size inside
> bl_pg_init_write(), and pass it as an extra parameter to
> pnfs_generic_pg_init_write().
> 
> Then add pnfs_pg_init_object_write for objects, that calls the modified
> pnfs_generic_pg_init_write() with the PNFS_LAYOUTGET_ISIZE value.
> 


Lets please completely kill pnfs_generic_pg_init_write() just like 
files did. It gives us nothing and specialty now it is more compact
code to just inline it, like nfs4filelayout.c did.

But please do this on top of my pending patches for 3.6-rcX. They touch
exactly this code in objects.

> Files don't call this function, so adding the PNFS_LAYOUTGET_ALL_FILE
> isn't needed.


BTW:
	filelayout_pg_init_read()
	and 
	pnfs_generic_pg_init_read()
  Is char-by-char Identical, except the very good added comment in
  filelayout_pg_init_read(). Can be merged.

Thanks
Boaz
