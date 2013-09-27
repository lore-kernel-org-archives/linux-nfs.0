Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:50643 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753844Ab3I0OjR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Sep 2013 10:39:17 -0400
Received: by mail-qc0-f180.google.com with SMTP id p19so1767031qcv.39
        for <linux-nfs@vger.kernel.org>; Fri, 27 Sep 2013 07:39:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52458F79.8040801@redhat.com>
References: <1378919210-10372-1-git-send-email-zab@redhat.com>
	<CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
	<20130925183828.GA30372@lenny.home.zabbo.net>
	<CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
	<20130925190620.GB30372@lenny.home.zabbo.net>
	<20130925195526.GA18971@fieldses.org>
	<20130925210742.GG30372@lenny.home.zabbo.net>
	<CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
	<20130926153359.GE704@fieldses.org>
	<CAJfpegsUchb0eX+Hi3rN5Ypje3Y-dgo=pxgM1Y3BQbHVp=1hSw@mail.gmail.com>
	<20130926190611.GP30372@lenny.home.zabbo.net>
	<CAJfpegvvWhs+jv2J9kOQrB31PEO3kyn_sLm_e2w9YKp=y6EDhA@mail.gmail.com>
	<5244A5E7.90808@redhat.com>
	<CAJfpegufnsU0LLvvZDmKpvRn8AaJ7NvKeegg-4YJ5AK9mBDBYQ@mail.gmail.com>
	<52458F79.8040801@redhat.com>
Date: Fri, 27 Sep 2013 16:39:15 +0200
Message-ID: <CAJfpegseipg6DAseBTG4Z6024noQa7owv48rOJznCPiXK+hezw@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Zach Brown <zab@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Sep 27, 2013 at 4:00 PM, Ric Wheeler <rwheeler@redhat.com> wrote:

> I think that you are an order of magnitude off here in thinking about the
> scale of the operations.
>
> An enabled, synchronize copy offload to an array (or one that turns into a
> reflink locally) is effectively the cost of the call itself. Let's say no
> slower than one IO to a S-ATA disk (10ms?) as a pessimistic guess.
> Realistically, that call is much faster than that worst case number.
>
> Copying any substantial amount of data - like the target workload of VM
> images or media files - would be hundreds of MB's per copy and that would
> take seconds or minutes.

Will a single splice-copy operation be interruptible/restartable?  If
not, how should apps size one request so that it doesn't take too much
time?  Even for slow devices (usb stick)?  If it will be restartable,
how?   Can remote copy be done with this?  Over a high latency
network?

Those are the questions I'm worried about.

>
> We should really work on getting the basic mechanism working and robust
> without any complications, then we can look at real, measured performance
> and see if there is any justification for adding complexity.

Go for that.  But don't forget that at the end of the day actual apps
will need to be converted like file managers and "dd" and "cp" and we
definitely don't wont a userspace library to be able to figure out how
the copy is done most efficiently; it's something for the kernel to
figure out.

Thanks,
Miklos
