Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:52042 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752121Ab3I1Ftr convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Sep 2013 01:49:47 -0400
Received: by mail-qa0-f43.google.com with SMTP id k15so1058909qaq.16
        for <linux-nfs@vger.kernel.org>; Fri, 27 Sep 2013 22:49:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130927205013.GZ30372@lenny.home.zabbo.net>
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
Date: Sat, 28 Sep 2013 07:49:46 +0200
Message-ID: <CAJfpegtdiQzP7t5hc_OaHjSGTrjdZLfKi6fiKqBQ_+AP2Y0-oQ@mail.gmail.com>
Subject: Re: [RFC] extending splice for copy offloading
From: Miklos Szeredi <miklos@szeredi.hu>
To: Zach Brown <zab@redhat.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Ric Wheeler <rwheeler@redhat.com>,
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

On Fri, Sep 27, 2013 at 10:50 PM, Zach Brown <zab@redhat.com> wrote:
>> Also, I don't get the first option above at all.  The argument is that
>> it's safer to have more copies?  How much safety does another copy on
>> the same disk really give you?  Do systems that do dedup provide
>> interfaces to turn it off per-file?

I don't see the safety argument very compelling either.  There are
real semantic differences, however: ENOSPC on a write to a
(apparentlíy) already allocated block.  That could be a bit
unexpected.  Do we need a fallocate extension to deal with shared
blocks?

Thanks,
Miklos
