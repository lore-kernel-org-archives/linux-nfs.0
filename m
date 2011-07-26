Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:40338 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751377Ab1GZR5j convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 Jul 2011 13:57:39 -0400
Received: by vxh35 with SMTP id 35so503124vxh.19
        for <linux-nfs@vger.kernel.org>; Tue, 26 Jul 2011 10:57:38 -0700 (PDT)
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51838E@SACMVEXC2-PRD.hq.netapp.com>
References: <1309743002-1658-1-git-send-email-bergwolf@gmail.com>
 <4E18614C.4010002@tonian.com> <F19688880B763E40B28B2B462677FBF805BF0610CE@MX09A.corp.emc.com>
 <1311621204.28209.14.camel@lade.trondhjem.org> <CA+a=Yy59HXXjd4HgrqeANaQZKO9rRPKzM+r3NNq2KSMV_L4S_w@mail.gmail.com>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51825D@SACMVEXC2-PRD.hq.netapp.com>
 <CA+a=Yy7sCuFE3N_bBsMShr1tLLg4jz9tSpBU9aH08aHCn5uvFQ@mail.gmail.com> <2E1EB2CF9ED1CB4AA966F0EB76EAB4430A51838E@SACMVEXC2-PRD.hq.netapp.com>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 27 Jul 2011 01:57:18 +0800
Message-ID: <CA+a=Yy7Vj6mNOdQ-uDLajngibisET1ttHLgZLmzxeMMWTyrHSQ@mail.gmail.com>
Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: tao.peng@emc.com, linux-nfs@vger.kernel.org, bhalevy@tonian.com
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jul 27, 2011 at 1:37 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>> -----Original Message-----
>> From: Peng Tao [mailto:bergwolf@gmail.com]
>> Sent: Tuesday, July 26, 2011 1:33 PM
>> To: Myklebust, Trond
>> Cc: tao.peng@emc.com; linux-nfs@vger.kernel.org; bhalevy@tonian.com
>> Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
>>
>> On Tue, Jul 26, 2011 at 11:50 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>> >> -----Original Message-----
>> >> From: Peng Tao [mailto:bergwolf@gmail.com]
>> >> Sent: Tuesday, July 26, 2011 11:37 AM
>> >> To: Myklebust, Trond
>> >> Cc: tao.peng@emc.com; linux-nfs@vger.kernel.org; bhalevy@tonian.com
>> >> Subject: Re: [PATCH] NFS41: Drop lseg ref before fallthru to MDS
>> >>
>> >> Hi, Trond,
>> >>
>> >> On Tue, Jul 26, 2011 at 3:13 AM, Trond Myklebust
>> >> <Trond.Myklebust@netapp.com> wrote:
>> >> > On Wed, 2011-07-20 at 01:52 -0400, tao.peng@emc.com wrote:
>> >> >> Hi, Trond,
>> >> >>
>> >> >> Any comments on this patch? I still get kernel crash when pnfs
>> write
>> >> is attempted but fails and calls pnfs_ld_write_done(). It seems
>> object
>> >> layout uses the same code path as well. But I don't find the patch
>> in
>> >> either your tree or Benny's tree. Are there any concerns?
>> >> >>
>> >> >> Thanks,
>> >> >> Tao
>> >> >
>> >> > The whole pnfs_ld_write_done thing is bogus and needs to be
>> replaced
>> >> > with something sane. It is trying to initiate a WRITE RPC call
>> with
>> >> the
>> >> > wrong block size, and is calling the MDS rpc_call_done() and
>> >> > rpc_release() with an uninitialised rpc task pointer.
>> >> >
>> >> > Ditto for pnfs_ld_read_done.
>> >> Thanks for your explanation. Is there any plan on how to fix
>> >> pnfs_ld_read/write_done? Basically, we would need an interface that
>> >> can redirect the IO to MDS if pnfs_error is set or do all necessary
>> >> cleanup work to end read/write if pnfs_error is 0. IMHO, the
>> >> recoalesce logic need to access nfs_pageio_descriptor but we do not
>> >> have that information at pnfs_ld_read/write_done.
>> >
>> > As far as I can see, the right thing to do is to mark the layout as
>> invalid and then redirty the page. It should be easy to have fsync()
>> re-send the pages in this case. These should be extremely rare events,
>> since we expect to catch most of the pNFS failures when we do the
>> actual LAYOUTGET in the ->pg_init().
>> Agreed. This should be easier than re-coalescing and sending to MDS at
>> read/write_done.
>>
>> >
>> > My main worry is for aio/dio where there is no good mechanism for
>> retrying. I'm still working on that...
>> For dio, we may have to send the failed pages to MDS instead of
>> relying on next fsync() to retry.
>
> The problem isn't what to do, it is more one of _who_ does it. The rpciod/nfsiod queues aren't the ideal place to set up a resend since it involves allocating memory.
How about having a pnfs private workqueue to take care of the resend?
There are some other places default workqueue is used in io path in
both block and object layout code. It can be problematic if the
default workqueue is blocked.  e.g. if someone on the default
workqueue allocates memory and reclaim code comes into pnfs path.
Using default workqueue here can cause application hang forever. If we
have a private workqueue, these problems can be solve IMO.

Best,
Tao


>
> Cheers
>  Trond
>



-- 
Thanks,
-Bergwolf
