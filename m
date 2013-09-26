Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f47.google.com ([209.85.128.47]:52344 "EHLO
	mail-qe0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752210Ab3IZTxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 15:53:17 -0400
Received: by mail-qe0-f47.google.com with SMTP id b4so1152703qen.34
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 12:53:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130926190611.GP30372@lenny.home.zabbo.net>
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
Date: Thu, 26 Sep 2013 21:53:16 +0200
Message-ID: <CAJfpegvvWhs+jv2J9kOQrB31PEO3kyn_sLm_e2w9YKp=y6EDhA@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: Zach Brown <zab@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
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

On Thu, Sep 26, 2013 at 9:06 PM, Zach Brown <zab@redhat.com> wrote:

>> But I'm not sure it's worth the effort; 99% of the use of this
>> interface will be copying whole files.  And for that perhaps we need a
>> different API, one which has been discussed some time ago:
>> asynchronous copyfile() returns immediately with a pollable event
>> descriptor indicating copy progress, and some way to cancel the copy.
>> And that can internally rely on ->direct_splice(), with appropriate
>> algorithms for determine the optimal  chunk size.
>
> And perhaps we don't.  Perhaps we can provide this much simpler
> data-plane interface that works well enough for most everyone and can
> avoid going down the async rat hole, yet again.

I think either buffering or async is needed to get good perforrmace
without too much complexity in the app (which is not good).  Buffering
works quite well for regular I/O, so maybe its the way to go here as
well.

Thanks,
Miklos
