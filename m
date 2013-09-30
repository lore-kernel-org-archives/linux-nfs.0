Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:49340 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755776Ab3I3P5o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 11:57:44 -0400
Received: by mail-qe0-f53.google.com with SMTP id jy17so3952224qeb.12
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 08:57:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52498F68.8050200@redhat.com>
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
	<CAJfpegv_C6cLOuA-mNtgtf2QbmmmcHwjQVo8mAnhf_wbJ8iRhg@mail.gmail.com>
	<52498DB6.7060901@redhat.com>
	<CAJfpegsvrr7x3MbdpvxUmzq0ZfDHfZkzAar6Od2G7wg8DgPLYQ@mail.gmail.com>
	<52498F68.8050200@redhat.com>
Date: Mon, 30 Sep 2013 17:57:41 +0200
Message-ID: <CAJfpegvvN_5c5oMv8UoODXQHc-DQnijhOtPDXmNamVpQLDoWMQ@mail.gmail.com>
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

On Mon, Sep 30, 2013 at 4:49 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
> On 09/30/2013 10:46 AM, Miklos Szeredi wrote:
>>
>> On Mon, Sep 30, 2013 at 4:41 PM, Ric Wheeler <rwheeler@redhat.com> wrote:
>>>
>>> The way the array based offload (and some software side reflink works) is
>>> not a byte by byte copy. We cannot assume that a valid count can be
>>> returned
>>> or that such a count would be an indication of a sequential segment of
>>> good
>>> data.  The whole thing would normally have to be reissued.
>>>
>>> To make that a true assumption, you would have to mandate that in each of
>>> the specifications (and sw targets)...
>>
>> You're missing my point.
>>
>>   - user issues SIZE_MAX splice request
>>   - fs issues *64M* (or whatever) request to offload
>>   - when that completes *fully* then we return 64M to userspace
>>   - if it completes partially, then we return an error to userspace
>>
>> Again, wouldn't that work?
>>
>> Thanks,
>> Miklos
>
>
> Yes, if you send a copy offload command and it works, you can assume that it
> worked fully. It would be pretty interesting if that were not true :)
>
> If it fails, we cannot assume anything about partial completion.

Sure, that was my understanding from the start.  Maybe I wasn't
precise enough in my explanation.

Thanks,
Miklos
