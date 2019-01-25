Return-Path: <SRS0=p/Fe=QB=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465F1C282C0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 19:51:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 18088218B0
	for <linux-nfs@archiver.kernel.org>; Fri, 25 Jan 2019 19:51:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726218AbfAYTvf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 25 Jan 2019 14:51:35 -0500
Received: from mx2.math.uh.edu ([129.7.128.33]:46284 "EHLO mx2.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725778AbfAYTvf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 25 Jan 2019 14:51:35 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx2.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gn7Vi-00030c-Ds; Fri, 25 Jan 2019 13:51:32 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 55E31801554; Fri, 25 Jan 2019 13:51:30 -0600 (CST)
From:   Jason L Tibbitts III <tibbs@math.uh.edu>
To:     Trond Myklebust <trondmy@hammerspace.com>
Cc:     "Anna.Schumaker\@netapp.com" <Anna.Schumaker@netapp.com>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Chuck.Lever\@oracle.com" <Chuck.Lever@oracle.com>
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
        <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
Date:   Fri, 25 Jan 2019 13:51:30 -0600
In-Reply-To: <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
        (Trond Myklebust's message of "Thu, 24 Jan 2019 19:58:40 +0000")
Message-ID: <ufak1isms71.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

>>>>> "TM" == Trond Myklebust <trondmy@hammerspace.com> writes:

TM> Commit deaa5c96c2f7 ("SUNRPC: Address Kerberos performance/behavior
TM> regression") was supposed to be marked for stable as a fix.

I wonder, though; is that likely to be the root of the problem I'm
seeing?  The commit description talks about this as a performance
regression, but I'm seeing a complete loss of NFS functionality.

Sadly I still don't have a reproducer, so outside of just deploying the
patch and hoping, I have no way to actually test this.  So far I've been
running things like:

  stress-ng --all 0 --class 'filesystem' -t 10m --times

in an NFS4-krb5p mounted directory without being able to reproduce the
problem.  That drives the load up close to 200 but everything seems to make
progress.  So it must be some specific sequence that causes it; I just
don't know which.

I did get this to show up in the kernel log, though, when I typed "df"
while running that stress-ng command was running:

[94547.656419] NFS: server nas00 error: fileid changed
               fsid 0:57: expected fileid 0x6bc27eb, got 0x9996c6

I've never seen that one before, but it doesn't seem to hurt anything.
(This is still with 4.20.3.)

 - J<
