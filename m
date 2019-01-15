Return-Path: <SRS0=7zHz=PX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2448C43387
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 23:40:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 71AD620645
	for <linux-nfs@archiver.kernel.org>; Tue, 15 Jan 2019 23:40:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387948AbfAOXkQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 15 Jan 2019 18:40:16 -0500
Received: from mail5.windriver.com ([192.103.53.11]:47924 "EHLO mail5.wrs.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387904AbfAOXkQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 15 Jan 2019 18:40:16 -0500
Received: from ALA-HCB.corp.ad.wrs.com (ala-hcb.corp.ad.wrs.com [147.11.189.41])
        by mail5.wrs.com (8.15.2/8.15.2) with ESMTPS id x0FNcMia013462
        (version=TLSv1 cipher=AES128-SHA bits=128 verify=FAIL);
        Tue, 15 Jan 2019 15:38:32 -0800
Received: from yow-pgortmak-d1.corp.ad.wrs.com (128.224.56.57) by
 ALA-HCB.corp.ad.wrs.com (147.11.189.41) with Microsoft SMTP Server id
 14.3.408.0; Tue, 15 Jan 2019 15:38:12 -0800
Received: by yow-pgortmak-d1.corp.ad.wrs.com (Postfix, from userid 1000)        id
 C95A52E0922; Tue, 15 Jan 2019 18:38:11 -0500 (EST)
Date:   Tue, 15 Jan 2019 18:38:11 -0500
From:   Paul Gortmaker <paul.gortmaker@windriver.com>
To:     Takashi Iwai <tiwai@suse.de>
CC:     Chuck Lever <chuck.lever@oracle.com>,
        Stephen Rothwell <sfr@canb.auug.org.au>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Trond Myklebust <trondmy@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: linux-next: Fixes tag needs some work in the nfs-anna tree
Message-ID: <20190115233811.GD26416@windriver.com>
References: <20190116083831.256824cf@canb.auug.org.au>
 <A4B834E5-2DFD-428E-8E24-9F6F6A822B09@oracle.com>
 <s5hbm4hfu45.wl-tiwai@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <s5hbm4hfu45.wl-tiwai@suse.de>
User-Agent: Mutt/1.5.24 (2015-08-30)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

[Re: linux-next: Fixes tag needs some work in the nfs-anna tree] On 15/01/2019 (Tue 23:12) Takashi Iwai wrote:

> On Tue, 15 Jan 2019 22:41:21 +0100,
> Chuck Lever wrote:
> > 
> > Hi Stephen-
> > 
> > On Jan 15, 2019, at 4:38 PM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> > 
> > > [I am experimenting with checking the Fixes tags in commits in linux-next.
> > > Please let me know if you think I am being too strict.]
> > > 
> > > Hi all,
> > > 
> > > Commit
> > > 
> > >  deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior regression")
> > > 
> > > has problem with this Fixes tag:
> > > 
> > >  Fixes: 918f3c1fe83c ("SUNRPC: Improve latency for interactive ... ")
> > > 
> > > The subject should match the subject of the fixed commit.
> > > 
> > > -- 
> > > Cheers,
> > > Stephen Rothwell
> > 
> > I shortened the commit title so that the Fixes: line is shorter than 68
> > characters. I can leave these titles alone if that's preferred.
> 
> I've sometimes shorted the subject like the above, too, as I find a
> too long text annoying.  Maybe the partial string matching should
> suffice, especially when it ends with "..." ?

The problem is consistency.  Perhaps you shorten at four words.  A
person searches with five words or 70 chars -  they never see your commit.

The idea of consistency across the "Fixes:" tags is to allow a level of
automated processing so that the creators of the stable releases can do
a lot less manual hands-on processing.  They have enough work to do.

Thanks,
Paul.
--

> 
> 
> thanks,
> 
> Takashi
