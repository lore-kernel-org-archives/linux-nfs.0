Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BBD6C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 17:17:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EBEB220823
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 17:17:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726522AbfBHRRp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 12:17:45 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:47758 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727684AbfBHRRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 12:17:45 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gs9mS-000470-LE; Fri, 08 Feb 2019 11:17:38 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 916948014D9; Fri,  8 Feb 2019 11:17:36 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     Benjamin Coddington <bcodding@redhat.com>,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
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
        <7C8B2CA6-0254-44B2-B5A8-A2A9E0C042E9@oracle.com>
Date:   Fri, 08 Feb 2019 11:17:36 -0600
In-Reply-To: <7C8B2CA6-0254-44B2-B5A8-A2A9E0C042E9@oracle.com> (Chuck Lever's
        message of "Fri, 8 Feb 2019 10:19:40 -0500")
Message-ID: <ufaa7j6jj2n.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "CL" == Chuck Lever <chuck.lever@oracle.com> writes:

CL> The server is returning SEQ_MISORDERED to a singleton SEQUENCE.
CL> That suggests the client is trying to re-establish its lease but is
CL> sending a slot nr the server doesn't recognize for the virtual slot
CL> used for this purpose. Could be a problem on either side, and I
CL> don't know enough to say how this loop could have started.

In case I didn't say so earlier, the server is just Centos 7.6 running
that heavily modified 3.10.0-957.1.3.el7.x86_64.  I was not able to
reproduce anything like this throughout the 4.19 cycle but it started
cropping up pretty quickly on user desktops after booting into 4.20.3
(the first of the 4.20 series I tried).  And it does not reoccur after
rebooting back to 4.19.15.  Of course I know that doesn't absolve the
server.

It is possible for me to try to push a mainline kernel to all of the
relevant file servers, but that obviously carries other overhead and
risks that I would certainly prefer to avoid.

I just wish I knew how to reproduce this other than sticking it on a
bunch of machines and waiting until people complain.

 - J<
