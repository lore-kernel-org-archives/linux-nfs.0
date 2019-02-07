Return-Path: <SRS0=BC+Y=QO=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01C8CC282C2
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 11:14:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE9B52147C
	for <linux-nfs@archiver.kernel.org>; Thu,  7 Feb 2019 11:14:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726579AbfBGLOB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 7 Feb 2019 06:14:01 -0500
Received: from mx1.redhat.com ([209.132.183.28]:51134 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726448AbfBGLOA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 7 Feb 2019 06:14:00 -0500
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6D8FF8E591;
        Thu,  7 Feb 2019 11:14:00 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id DE721277A7;
        Thu,  7 Feb 2019 11:13:58 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Jason Tibbitts" <tibbs@math.uh.edu>
Cc:     "Trond Myklebust" <trondmy@hammerspace.com>,
        Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Chuck.Lever@oracle.com
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Date:   Thu, 07 Feb 2019 06:13:57 -0500
Message-ID: <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
In-Reply-To: <87imxwab12.fsf@hippogriff.math.uh.edu>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <ufak1isms71.fsf@epithumia.math.uh.edu>
 <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
 <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
 <87imxwab12.fsf@hippogriff.math.uh.edu>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 07 Feb 2019 11:14:00 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 6 Feb 2019, at 15:59, Jason Tibbitts wrote:

> This machine has a load of 93; a bunch of those are just df commands
> started by a monitoring process.  So far the user hasn't complained, so
> I can still poke at the machine for a while.

-10063 is -NFS4ERR_SEQ_MISORDERED.. I wonder why the
trace_nfs4_sequence_done() in nfs41_sequence_process() isn't showing up in
the trace?  Ah.. my fault - add "nfs4:*" to the set_events.

Ben
