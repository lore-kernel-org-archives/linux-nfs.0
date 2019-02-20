Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0F8DFC43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:13:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA88421738
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 02:13:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726286AbfBTCNU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 21:13:20 -0500
Received: from mx1.math.uh.edu ([129.7.128.32]:33588 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725616AbfBTCNU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 21:13:20 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx1.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gwHNq-0001Vc-EW; Tue, 19 Feb 2019 20:13:15 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 64EE2801B44; Tue, 19 Feb 2019 20:13:14 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "bcodding\@redhat.com" <bcodding@redhat.com>,
        "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever\@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
        <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
        <ufak1isms71.fsf@epithumia.math.uh.edu>
        <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
        <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
        <87imxwab12.fsf@hippogriff.math.uh.edu>
        <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
        <87d0o3aadg.fsf@hippogriff.math.uh.edu>
        <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
        <ufa4l943i6v.fsf@epithumia.math.uh.edu>
        <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
Date:   Tue, 19 Feb 2019 20:13:14 -0600
In-Reply-To: <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
        (Trond Myklebust's message of "Sat, 16 Feb 2019 14:46:45 +0000")
Message-ID: <ufa4l8z5hs5.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "TM" == Trond Myklebust <trondmy@hammerspace.com> writes:

TM> Hmm... Does the following patch help at all?

I un-wrapped it and applied it over 4.20.10 and pushed it out to a
couple of problematic machines.  So far it's been OK there, so I've
rolled it out to 50 desktops (because they happen to have secure boot
disabled and thus allow me to boot custom kernels) and I guess we'll see
how that goes.

 - J<
