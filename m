Return-Path: <SRS0=V3X6=Q4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 538DFC43381
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 18:19:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2ED6F2083B
	for <linux-nfs@archiver.kernel.org>; Thu, 21 Feb 2019 18:19:13 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727041AbfBUSTM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 21 Feb 2019 13:19:12 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:49102 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726165AbfBUSTM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 21 Feb 2019 13:19:12 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gwsw4-000117-Rw; Thu, 21 Feb 2019 12:19:06 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id C3B7F801B44; Thu, 21 Feb 2019 12:19:04 -0600 (CST)
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
Date:   Thu, 21 Feb 2019 12:19:04 -0600
In-Reply-To: <ae6267e1924733dbd0611946d546ea3aec1b6ef0.camel@hammerspace.com>
        (Trond Myklebust's message of "Wed, 20 Feb 2019 15:41:31 +0000")
Message-ID: <ufapnrlqa1z.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "TM" == Trond Myklebust <trondmy@hammerspace.com> writes:

TM> Can you please try the following patch? It uses a different approach
TM> to dealing with interrupted NFSv4.1 RPC calls.

I can say that so far, after applying this last night to 50 machines and
users having logged for a bit over five hours now, things appear to be
working properly.  I haven't seen any issues this morning whereas with
an unpatched kernel I would have expected to see several hangs (or at
least user-initiated reboots) by now.

I will of course continue to monitor things, but at this point, feel
free to add

Tested-by: Jason Tibbitts <tibbs@math.uh.edu>

 - J<
