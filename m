Return-Path: <SRS0=erep=QP=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 15235C169C4
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 12:01:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D859E218DA
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Feb 2019 12:01:15 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726600AbfBHMBP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Feb 2019 07:01:15 -0500
Received: from mx1.redhat.com ([209.132.183.28]:40754 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726568AbfBHMBP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 8 Feb 2019 07:01:15 -0500
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id D2127C079907;
        Fri,  8 Feb 2019 12:01:14 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-2.rdu2.redhat.com [10.10.112.2])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 55F8760123;
        Fri,  8 Feb 2019 12:01:13 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Jason Tibbitts" <tibbs@math.uh.edu>
Cc:     "Trond Myklebust" <trondmy@hammerspace.com>,
        Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Chuck.Lever@oracle.com
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Date:   Fri, 08 Feb 2019 07:01:11 -0500
Message-ID: <B730E8AE-AFA3-4CE7-9103-FCCC35C37EDD@redhat.com>
In-Reply-To: <87d0o3aadg.fsf@hippogriff.math.uh.edu>
References: <ufaimyearlx.fsf@epithumia.math.uh.edu>
 <eff194a660ce562753d0112cdf6b1aacc5aa5dfb.camel@hammerspace.com>
 <ufak1isms71.fsf@epithumia.math.uh.edu>
 <87ftt2cdeq.fsf@hippogriff.math.uh.edu>
 <FC712F54-5A7A-436D-B076-936B29C013F4@redhat.com>
 <87imxwab12.fsf@hippogriff.math.uh.edu>
 <662CE7B3-235E-4E2D-9C8C-0F6233F3085F@redhat.com>
 <87d0o3aadg.fsf@hippogriff.math.uh.edu>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Fri, 08 Feb 2019 12:01:15 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


On 7 Feb 2019, at 10:25, Jason Tibbitts wrote:

>>>>>> "BC" == Benjamin Coddington <bcodding@redhat.com> writes:
>
> BC> -10063 is -NFS4ERR_SEQ_MISORDERED.. I wonder why the
> BC> trace_nfs4_sequence_done() in nfs41_sequence_process() isn't showing
> BC> up in the trace?  Ah.. my fault - add "nfs4:*" to the set_events.
>
> OK, attached is another trace.  Here's the same sequence I snipped
> previously:

So the client is calling SEQ over and over.. xs_stream_read_data sees
-EAGAIN.. I'm not an expert here, and not seeing what's going wrong.

Hmm.. commit c443305529d1d3d3bee0d68fdd14ae89835e091f changed
xs_read_stream_reply() to return recv.copied instead of "ret" to
xprt_complete_rqst()..

You could try reverting that commit and see if the problem goes away..

Ben
