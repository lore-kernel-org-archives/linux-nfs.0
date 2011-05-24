Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54526 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120Ab1EXQ7H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 12:59:07 -0400
Message-ID: <4DDBE3BF.6080900@panasas.com>
Date: Tue, 24 May 2011 19:58:39 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com>	 <4DDBCBBA.5040700@panasas.com>	 <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>	 <4DDBD53A.6030706@panasas.com> <1306254106.4162.9.camel@lade.trondhjem.org>
In-Reply-To: <1306254106.4162.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 07:21 PM, Trond Myklebust wrote:
> On Tue, 2011-05-24 at 18:56 +0300, Boaz Harrosh wrote: 
>> In the nfs_pageio_descriptor passed to pg_test() together with the two pages:
>> Which member means the current byte_size (or page_count?) and what is the
>> meaning of some of these fields
>>
>> struct nfs_pageio_descriptor {
>>         ....
>> 	unsigned long		pg_bytes_written;
>> 		Is this for result after read/write?
> 
> This is the total number of bytes we successfully called
> nfs_pageio_doio() for. In other words, it should represent the total
> number of bytes we put on the wire.
> 
>> 	size_t			pg_count;
>> 		Is this the number of pages added up to now?
>> 		Do we also have the start of the first page?
> 
> This is the number of bytes we have successfully coalesced into the
> current i/o.
> 
>> 	size_t			pg_bsize;
>> 		So I understand this is the max allowed pages. Does
>> 		that mean also the allocated size or Just the negotiated
>> 		size with the server? (Really bad name if you ask me)
> 
> It means the 'block size'. In ordinary NFS parlance that will be the
> 'rsize' or the 'wsize'.
> 
>> 	unsigned int		pg_base;
>> 		Is that the index of the first page? That cannot be, the page->index
>> 		needs to be 64bit. So what is this then?
> 
> It is used when dealing with I/O requests that are not page aligned.
> 
> If you consider the pages that we are to write out in the current I/O as
> a single buffer, then the pg_base is the offset of the first byte to
> write out/read in.
> 

Thanks Trond, I think I understand and can write the proper implementation
for objects->pg_test now. One more question. I need the file offset
of the beginning of the write would that then be:

int objlayout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
		      struct nfs_page *req)
}
	struct nfs_page *first_pg = list_entry(pgio->pg_list.next, struct nfs_page, wb_list);

	u64 io_offset = (first_pg->wb_index << PAGE_SHIFT) + first_pg->wb_offset;
	...
}

Thanks
Boaz
