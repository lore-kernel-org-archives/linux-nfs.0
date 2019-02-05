Return-Path: <SRS0=v/uS=QM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6983DC282CB
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 18:12:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4B3B42175B
	for <linux-nfs@archiver.kernel.org>; Tue,  5 Feb 2019 18:12:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726685AbfBESMv (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 5 Feb 2019 13:12:51 -0500
Received: from mx1.math.uh.edu ([129.7.128.32]:54526 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726534AbfBESMv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 5 Feb 2019 13:12:51 -0500
Received: from c-73-155-225-101.hsd1.tx.comcast.net ([73.155.225.101] helo=hippogriff.math.uh.edu)
        by mx1.math.uh.edu with esmtpsa (TLSv1.3:TLS_AES_256_GCM_SHA384:256)
        (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gr5DE-0005mX-Pf; Tue, 05 Feb 2019 12:12:49 -0600
From:   Jason Tibbitts <tibbs@math.uh.edu>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever\@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
        <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
        <ufak1isms71.fsf@epithumia.math.uh.edu>
Date:   Tue, 05 Feb 2019 12:12:45 -0600
In-Reply-To: <ufak1isms71.fsf@epithumia.math.uh.edu> (Jason L. Tibbitts, III's
        message of "Fri, 25 Jan 2019 13:51:30 -0600")
Message-ID: <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "JLT" == Jason L Tibbitts <tibbs@math.uh.edu> writes:

JLT> I wonder, though; is that likely to be the root of the problem I'm
JLT> seeing?  The commit description talks about this as a performance
JLT> regression, but I'm seeing a complete loss of NFS functionality.

It turns out that 4.20.6 (which has the patch in question) does not
appear to solve my issue.  At least, I've still had a few complete NFS
hangups on machines running 4.20.6 though I haven't had a chance to
closely inspect one yet.

As before, any hints about how I could best debug this issue would be
appreciated.

 - J<
