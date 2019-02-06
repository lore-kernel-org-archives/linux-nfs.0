Return-Path: <SRS0=RSPU=QN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B4DBBC169C4
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 12:05:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 812502175B
	for <linux-nfs@archiver.kernel.org>; Wed,  6 Feb 2019 12:05:53 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728991AbfBFMFx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 6 Feb 2019 07:05:53 -0500
Received: from mx1.redhat.com ([209.132.183.28]:54880 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727807AbfBFMFw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Feb 2019 07:05:52 -0500
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8F44CC01DE15;
        Wed,  6 Feb 2019 12:05:52 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 15FA06428F;
        Wed,  6 Feb 2019 12:05:50 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Jason Tibbitts" <tibbs@math.uh.edu>
Cc:     "Trond Myklebust" <trondmy@hammerspace.com>,
        Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Chuck.Lever@oracle.com
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Date:   Wed, 06 Feb 2019 07:05:49 -0500
Message-ID: <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
In-Reply-To: <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <ufak1isms71.fsf@epithumia.math.uh.edu>
 <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Wed, 06 Feb 2019 12:05:52 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On 5 Feb 2019, at 13:12, Jason Tibbitts wrote:

>>>>>> "JLT" == Jason L Tibbitts <tibbs@math.uh.edu> writes:
>
> JLT> I wonder, though; is that likely to be the root of the problem I'm
> JLT> seeing?  The commit description talks about this as a performance
> JLT> regression, but I'm seeing a complete loss of NFS functionality.
>
> It turns out that 4.20.6 (which has the patch in question) does not
> appear to solve my issue.  At least, I've still had a few complete NFS
> hangups on machines running 4.20.6 though I haven't had a chance to
> closely inspect one yet.
>
> As before, any hints about how I could best debug this issue would be
> appreciated.

Hi Jason, you can enable the NFS and SUNRPC tracepoints to get a better idea
of what the client was doing right before the hang or what the client is
trying to do during the hang:

echo "sunrpc:*" >>  /sys/kernel/debug/tracing/set_event
echo "nfs:*" >> /sys/kernel/debug/tracing/set_event

Examine or provide the contents of /sys/kernel/debug/tracing/trace.

Ben
