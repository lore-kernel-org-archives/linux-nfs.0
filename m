Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50088 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932521Ab1EXP5K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:57:10 -0400
Message-ID: <4DDBD53A.6030706@panasas.com>
Date: Tue, 24 May 2011 18:56:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: bhalevy@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com> <4DDBCBBA.5040700@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/24/2011 06:34 PM, Myklebust, Trond wrote:
> On Tue, 2011-05-24 at 18:16 +0300, Benny Halevy wrote:
>> On 2011-05-23 21:50, Boaz Harrosh wrote:
>> > On 05/23/2011 07:33 PM, Benny Halevy wrote:
>> > Benny Hi
>> >
>> > I have a problem that the default wsize is very small 64K and
>> > I get small IOs. I found that the governing member right now
>> > is NFS_SERVER()->wsize
>> >
>> > I did the below hack on My current code, but you took that away
>> > from me.
>> >
>> > diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
>> > index ec40408..f7b09e1 100644
>> > --- a/fs/nfs/objlayout/objlayout.c
>> > +++ b/fs/nfs/objlayout/objlayout.c
>> > +   server->wsize = ((PAGE_SIZE - sizeof(struct bio)) / sizeof(struct bio_vec))
>> > +                   * PAGE_SIZE * 2;
>> > 
>> > -   dprintk("%s: Return data=%p\n", __func__, data);
>> > +   dprintk("%s: Return data=%p wsize=0x%x\n", __func__, data, server->wsize);
>> >     return 0;
>> >  }
>> >
>> > What do you want that we do to replace this. The default 64K is to small.
>> > I don't mind that for pnfs it will be ~0 and the pg_test() will test
>> > for maxc_size as well. But then we'll also need the current size or the
>> > start_index
>> >
>> > Boaz
>>
>> How about this approach?
>>
>> git diff --stat -p -M
>>  fs/nfs/pagelist.c |    2 +-
>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>
>> diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
>> index c80add6..3f5508b 100644
>> --- a/fs/nfs/pagelist.c
>> +++ b/fs/nfs/pagelist.c
>> @@ -293,7 +293,7 @@ static int nfs_pageio_do_add_request(struct
>> nfs_pageio_descriptor *desc,
>>               if (desc->pg_bsize < PAGE_SIZE)
>>                       return 0;
>>               newlen += desc->pg_count;
>> -             if (newlen > desc->pg_bsize)
>> +             if (newlen > desc->pg_bsize && !desc->pg_test)
>>                       return 0;
>>               prev = nfs_list_entry(desc->pg_list.prev);
>>               if (!nfs_can_coalesce_requests(prev, req, desc))
> 
> Alternatively, clean the above up by putting the newlen > desc->pg_bsize
> test into a default nfs_generic_test_coalesce() and require ordinary NFS
> reads and writes to set that as their desc->pg_test().
> 
> Cheers
>   Trond

This all approach sounds very good to me. But please I have some questions?

In the nfs_pageio_descriptor passed to pg_test() together with the two pages:
Which member means the current byte_size (or page_count?) and what is the
meaning of some of these fields

struct nfs_pageio_descriptor {
        ....
	unsigned long		pg_bytes_written;
		Is this for result after read/write?

	size_t			pg_count;
		Is this the number of pages added up to now?
		Do we also have the start of the first page?

	size_t			pg_bsize;
		So I understand this is the max allowed pages. Does
		that mean also the allocated size or Just the negotiated
		size with the server? (Really bad name if you ask me)

	unsigned int		pg_base;
		Is that the index of the first page? That cannot be, the page->index
		needs to be 64bit. So what is this then?
	
	...
};

Thanks
Boaz
