Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54831 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750962Ab1EXRID (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 13:08:03 -0400
Message-ID: <4DDBE5D8.6060408@panasas.com>
Date: Tue, 24 May 2011 20:07:36 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com>		 <4DDBCBBA.5040700@panasas.com>		 <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>		 <4DDBD53A.6030706@panasas.com>	 <1306254106.4162.9.camel@lade.trondhjem.org> <4DDBE3BF.6080900@panasas.com> <1306256706.7109.0.camel@lade.trondhjem.org>
In-Reply-To: <1306256706.7109.0.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 08:05 PM, Trond Myklebust wrote:
> On Tue, 2011-05-24 at 19:58 +0300, Boaz Harrosh wrote: 
>> Thanks Trond, I think I understand and can write the proper implementation
>> for objects->pg_test now. One more question. I need the file offset
>> of the beginning of the write would that then be:
>>
>> int objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
>> 		      struct nfs_page *req)
>> }
>> 	struct nfs_page *first_pg = list_entry(pgio->pg_list.next, struct nfs_page, wb_list);
>>
>> 	u64 io_offset = (first_pg->wb_index << PAGE_SHIFT) + first_pg->wb_offset;
>> 	...
>> }
> 
> Yes. That looks correct.
> 

Grate the new skim with pg_test looks perfect. We have all we need and it will be
really nice with the raid5/6 code. I think I will use a similar system in exofs
now.

Thanks
Boaz
