Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49496 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755812Ab1EXPtQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 11:49:16 -0400
Message-ID: <4DDBD378.4090906@panasas.com>
Date: Tue, 24 May 2011 18:49:12 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
CC: bharrosh@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCHSET v6 0/26] pnfs for 2.6.40
References: <4DDA8C3D.5080706@panasas.com> <4DDAAC64.6050807@panasas.com> <4DDBCBBA.5040700@panasas.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB443080D6E54@SACMVEXC2-PRD.hq.netapp.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-24 18:34, Myklebust, Trond wrote:
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
>> > +   server->wsize = ((PAGE_SIZE - sizeof(struct bio)) /
> sizeof(struct bio_vec))
>> > +                   * PAGE_SIZE * 2;
>> > 
>> > -   dprintk("%s: Return data=%p\n", __func__, data);
>> > +   dprintk("%s: Return data=%p wsize=0x%x\n", __func__, data,
> server->wsize);
>> >     return 0;
>> >  }
>> >
>> > What do you want that we do to replace this. The default 64K is to
> small.
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

Good idea!

I'll send a RFC patch including the generic pnfs pg_test for
the layout drivers.

Fred - I hope you haven't started working on pg_test, have you?
Please let me know.

Benny

> 
> Cheers
>   Trond
> --
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

