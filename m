Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D201C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 19:24:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 638092083D
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 19:24:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726557AbfBYTYM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 14:24:12 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:52850 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726377AbfBYTYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 14:24:12 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.92)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gyLrB-0003pq-HM; Mon, 25 Feb 2019 13:24:07 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 719F18013FF; Mon, 25 Feb 2019 13:24:05 -0600 (CST)
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
        <ae6267e1924733dbd0611946d546ea3aec1b6ef0.camel@hammerspace.com>
        <ufapnrlqa1z.fsf@epithumia.math.uh.edu>
Date:   Mon, 25 Feb 2019 13:24:05 -0600
In-Reply-To: <ufapnrlqa1z.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Thu, 21 Feb 2019 12:19:04 -0600")
Message-ID: <ufa36obbrje.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

So I've now running this patch ("NFSv4.1: Avoid false retries when RPC
calls are interrupted") for several days with no hangs at all and no
other regressions noted.  What would the next step be?  Will this be
sent upstream?  I'm not sure how to check if this is queued for
submission in someone's tree.

I doubt there is anything I can do to help the process but please let me
know if there is.

 - J<
