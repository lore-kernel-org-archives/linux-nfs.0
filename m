Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f43.google.com ([209.85.128.43]:35061 "EHLO
	mail-qe0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755541Ab3I3OvM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2013 10:51:12 -0400
Received: by mail-qe0-f43.google.com with SMTP id gh4so3922888qeb.30
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2013 07:51:11 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130930143432.GG16579@fieldses.org>
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
Date: Mon, 30 Sep 2013 16:51:10 +0200
Message-ID: <CAJfpeguMCzv-UhrXrG7e9Q7F_0aEe3_ZMumFwLu3hxcewA_7gA@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ric Wheeler <rwheeler@redhat.com>,
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

On Mon, Sep 30, 2013 at 4:34 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
>> My other worry is about interruptibility/restartability.  Ideas?
>>
>> What happens on splice(from, to, 4G) and it's a non-reflink copy?
>> Can the page cache copy be made restartable?   Or should splice() be
>> allowed to return a short count?  What happens on (non-reflink) remote
>> copies and huge request sizes?
>
> If I were writing an application that required copies to be restartable,
> I'd probably use the largest possible range in the reflink case but
> break the copy into smaller chunks in the splice case.
>

The app really doesn't want to care about that.  And it doesn't want
to care about restartability, etc..  It's something the *kernel* has
to care about.   You just can't have uninterruptible syscalls that
sleep for a "long" time, otherwise first you'll just have annoyed
users pressing ^C in vain; then, if the sleep is even longer, warnings
about task sleeping too long.

One idea is letting splice() return a short count, and so the app can
safely issue SIZE_MAX requests and the kernel can decide if it can
copy the whole file in one go or if it wants to do it in smaller
chunks.

Thanks,
Miklos
