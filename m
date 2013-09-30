Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:35172 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754134Ab3I3MUb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 08:20:31 -0400
Received: by mail-qc0-f175.google.com with SMTP id v2so3519099qcr.6
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 05:20:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52474839.2080201@redhat.com>
References: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
	<20130925183828.GA30372@lenny.home.zabbo.net>
	<CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
	<20130925190620.GB30372@lenny.home.zabbo.net>
	<20130925195526.GA18971@fieldses.org>
	<20130925210742.GG30372@lenny.home.zabbo.net>
	<CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
	<20130926185508.GO30372@lenny.home.zabbo.net>
	<5244A68F.906@redhat.com>
	<20130927200550.GA22640@fieldses.org>
	<20130927205013.GZ30372@lenny.home.zabbo.net>
	<CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
	<4FA345DA4F4AE44899BD2B03EEEC2FA9467EF2D7@SACEXCMBX04-PRD.hq.netapp.com>
	<52474839.2080201@redhat.com>
Date: Mon, 30 Sep 2013 14:20:30 +0200
Message-ID: <CAJfpegsN7Hu8uecSVQrhax+n+zhq=uUgpzOk=qZ6_n383tdNCQ@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Zach Brown <zab@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumaker.anna@gmail.com>,
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

On Sat, Sep 28, 2013 at 11:20 PM, Ric Wheeler <rwheeler@redhat.com> wrote:

>>> I don't see the safety argument very compelling either.  There are real
>>> semantic differences, however: ENOSPC on a write to a
>>> (apparentlíy) already allocated block.  That could be a bit unexpected.
>>> Do we
>>> need a fallocate extension to deal with shared blocks?
>>
>> The above has been the case for all enterprise storage arrays ever since
>> the invention of snapshots. The NFSv4.2 spec does allow you to set a
>> per-file attribute that causes the storage server to always preallocate
>> enough buffers to guarantee that you can rewrite the entire file, however
>> the fact that we've lived without it for said 20 years leads me to believe
>> that demand for it is going to be limited. I haven't put it top of the list
>> of features we care to implement...
>>
>> Cheers,
>>     Trond
>
>
> I agree - this has been common behaviour for a very long time in the array
> space. Even without an array,  this is the same as overwriting a block in
> btrfs or any file system with a read-write LVM snapshot.

Okay, I'm convinced.

So I suggest

 - mount(..., MNT_REFLINK): *allow* splice to reflink.  If this is not
set, fall back to page cache copy.
 - splice(... SPLICE_REFLINK):  fail non-reflink copy.  With this app
can force reflink.

Both are trivial to implement and make sure that no backward
incompatibility surprises happen.

My other worry is about interruptibility/restartability.  Ideas?

What happens on splice(from, to, 4G) and it's a non-reflink copy?
Can the page cache copy be made restartable?   Or should splice() be
allowed to return a short count?  What happens on (non-reflink) remote
copies and huge request sizes?

Thanks,
Miklos
