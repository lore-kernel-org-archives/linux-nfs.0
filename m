Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDD50C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 16:49:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 98CD62084D
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 16:49:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727107AbfBTQte (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 11:49:34 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:58084 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726192AbfBTQte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 11:49:34 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gwV3o-0005E5-U5; Wed, 20 Feb 2019 10:49:30 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id D1896801B44; Wed, 20 Feb 2019 10:49:28 -0600 (CST)
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
        <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
        <2ab06cbdc19d7a642e04f1e66abbeaa507b034bc.camel@hammerspace.com>
        <ufalg2abf6n.fsf@epithumia.math.uh.edu>
        <ef322de97094192e97bc897c5a9f41687720e076.camel@hammerspace.com>
Date:   Wed, 20 Feb 2019 10:49:28 -0600
In-Reply-To: <ef322de97094192e97bc897c5a9f41687720e076.camel@hammerspace.com>
        (Trond Myklebust's message of "Wed, 20 Feb 2019 16:45:52 +0000")
Message-ID: <ufabm36be1z.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "TM" == Trond Myklebust <trondmy@hammerspace.com> writes:

TM> That's why I sent you a patch that addresses the SEQ_MISORDERED
TM> issue.  Are you saying that failed too?

If you're referring to d72ad5fe4c2206458d127cc31e690318cf2e2731
"NFSv4.1: Avoid false retries when RPC calls are interrupted" which you
just sent a few minutes ago, I'm building it now.  It will take me a
while to roll this out to user desktops and then see if anyone hits it.

 - J<
