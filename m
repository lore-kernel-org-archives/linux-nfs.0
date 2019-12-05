Return-Path: <SRS0=1J9Y=Z3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC02DC43603
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Dec 2019 15:03:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C449F24249
	for <linux-nfs@archiver.kernel.org>; Thu,  5 Dec 2019 15:03:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729698AbfLEPDp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 5 Dec 2019 10:03:45 -0500
Received: from fieldses.org ([173.255.197.46]:53076 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729187AbfLEPDo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 5 Dec 2019 10:03:44 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 9AB51BC3; Thu,  5 Dec 2019 10:03:44 -0500 (EST)
Date:   Thu, 5 Dec 2019 10:03:44 -0500
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     Alex Lyakas <alex@zadara.com>
Cc:     linux-nfs@vger.kernel.org
Subject: Re: [RFC-PATCH] nfsd: provide a procfs entry to release stateids of
 a particular local filesystem
Message-ID: <20191205150344.GB22402@fieldses.org>
References: <1567518908-1720-1-git-send-email-alex@zadara.com>
 <20190906161236.GF17204@fieldses.org>
 <CAOcd+r0GRaXP3bes2xw6CFJmPJDTfAAMB7j6G3gzCVKDTC8Sgw@mail.gmail.com>
 <20190910202533.GC26695@fieldses.org>
 <1D90658865CE4379A951E464008D872E@alyakaslap>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1D90658865CE4379A951E464008D872E@alyakaslap>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Thu, Dec 05, 2019 at 01:47:09PM +0200, Alex Lyakas wrote:
> Hi Bruce,
> 
> Have you had a chance to review the V2 of the patch?

I'll take a quick look.--b.

> 
> Thanks,
> Alex.
> 
> 
> -----Original Message----- From: J. Bruce Fields
> Sent: Tuesday, September 10, 2019 11:25 PM
> To: Alex Lyakas
> Cc: linux-nfs@vger.kernel.org ; Shyam Kaushik
> Subject: Re: [RFC-PATCH] nfsd: provide a procfs entry to release
> stateids of a particular local filesystem
> 
> On Tue, Sep 10, 2019 at 10:00:24PM +0300, Alex Lyakas wrote:
> >I addressed your comments, and ran the patch through checkpatch.pl.
> >Patch v2 is on its way.
> 
> Thanks for the revision!  I need to spend the next week or so catching
> up on some other review and then I'll get back to this.
> 
> For now:
> 
> >On Fri, Sep 6, 2019 at 7:12 PM J. Bruce Fields
> ><bfields@fieldses.org> wrote:
> >> You'll want to cover delegations as well.  And probably pNFS layouts.
> >> It'd be OK to do that incrementally in followup patches.
> >Unfortunately, I don't have much understanding of what these are, and
> >how to cover them)
> 
> Delegations are give the client the right to cache files across opens.
> I'm a little surprised your patches are working for you without handling
> delegations.  There may be something about your environment that's
> preventing delegations from being given out.  In the NFSv4.0 case they
> require the server to make a tcp connection back the client, which is
> easy blocked by firewalls or NAT.  Might be worth testing with v4.1 or
> 4.2.
> 
> Anyway, so we probably also want to walk the client's dl_perclnt list
> and look for matching files.
> 
> --b.
