Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f49.google.com ([209.85.128.49]:46191 "EHLO
	mail-qe0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754776Ab3I3Pie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 11:38:34 -0400
Received: by mail-qe0-f49.google.com with SMTP id s14so3877919qeb.22
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 08:38:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52498AA8.2090204@redhat.com>
References: <20130925210742.GG30372@lenny.home.zabbo.net>
	<CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
	<20130926185508.GO30372@lenny.home.zabbo.net>
	<5244A68F.906@redhat.com>
	<20130927200550.GA22640@fieldses.org>
	<20130927205013.GZ30372@lenny.home.zabbo.net>
	<CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
	<52474839.2080201@redhat.com>
	<CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
	<20130930143432.GG16579@fieldses.org>
	<CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
	<52499026.3090802@redhat.com>
	<CAJfpegtpXuh9070ALGy16Y8kdgioBqSf4JQqBBCF4FHvFJWAWQ@mail.gmail.com>
	<52498AA8.2090204@redhat.com>
Date: Mon, 30 Sep 2013 17:38:33 +0200
Message-ID: <CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zach Brown <zab@redhat.com>, Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Schumaker, Bryan" <Bryan.Schumaker@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 4:28 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
> On 09/30/2013 10:24 AM, Miklos Szeredi wrote:
>>
>> On Mon, Sep 30, 2013 at 4:52 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
>>>
>>> On 09/30/2013 10:51 AM, Miklos Szeredi wrote:
>>>>
>>>> On Mon, Sep 30, 2013 at 4:34 PM, J. Bruce Fields <bfields@fieldses.org>
>>>> wrote:
>>>>>>
>>>>>> My other worry is about interruptibility/restartability.  Ideas?
>>>>>>
>>>>>> What happens on splice(from, to, 4G) and it's a non-reflink copy?
>>>>>> Can the page cache copy be made restartable?   Or should splice() be
>>>>>> allowed to return a short count?  What happens on (non-reflink) remote
>>>>>> copies and huge request sizes?
>>>>>
>>>>> If I were writing an application that required copies to be
>>>>> restartable,
>>>>> I'd probably use the largest possible range in the reflink case but
>>>>> break the copy into smaller chunks in the splice case.
>>>>>
>>>> The app really doesn't want to care about that.  And it doesn't want
>>>> to care about restartability, etc..  It's something the *kernel* has
>>>> to care about.   You just can't have uninterruptible syscalls that
>>>> sleep for a "long" time, otherwise first you'll just have annoyed
>>>> users pressing ^C in vain; then, if the sleep is even longer, warnings
>>>> about task sleeping too long.
>>>>
>>>> One idea is letting splice() return a short count, and so the app can
>>>> safely issue SIZE_MAX requests and the kernel can decide if it can
>>>> copy the whole file in one go or if it wants to do it in smaller
>>>> chunks.
>>>>
>>> You cannot rely on a short count. That implies that an offloaded copy
>>> starts
>>> at byte 0 and the short count first bytes are all valid.
>>
>> Huh?
>>
>> - app calls splice(from, 0, to, 0, SIZE_MAX)
>>   1) VFS calls ->direct_splice(from, 0,  to, 0, SIZE_MAX)
>>      1.a) fs reflinks the whole file in a jiffy and returns the size of
>> the file
>>      1 b) fs does copy offload of, say, 64MB and returns 64M
>>   2) VFS does page copy of, say, 1MB and returns 1MB
>> - app calls splice(from, X, to, X, SIZE_MAX) where X is the new offset
>> ...
>>
>> The point is: the app is always doing the same (incrementing offset
>> with the return value from splice) and the kernel can decide what is
>> the best size it can service within a single uninterruptible syscall.
>>
>> Wouldn't that work?
>>

>
> No.
>
> Keep in mind that the offload operation in (1) might fail partially. The
> target file (the copy) is allocated, the question is what ranges have valid
> data.

You are talking about case 1.a, right?  So if the offload copy 0-64MB
fails partially, we return failure from splice, yet some of the copy
did succeed.  Is that the problem?  Why?

Thanks,
Miklos
