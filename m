Return-Path: <SRS0=6MPh=RA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7FCB1C43381
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 23:15:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5645C21841
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Feb 2019 23:15:30 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728898AbfBYXP3 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Feb 2019 18:15:29 -0500
Received: from mx1.redhat.com ([209.132.183.28]:43076 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727421AbfBYXP3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 25 Feb 2019 18:15:29 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4EEC7C04D293;
        Mon, 25 Feb 2019 23:15:29 +0000 (UTC)
Received: from [172.16.176.1] (ovpn-112-26.rdu2.redhat.com [10.10.112.26])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 0AED75D9C4;
        Mon, 25 Feb 2019 23:15:27 +0000 (UTC)
From:   "Benjamin Coddington" <bcodding@redhat.com>
To:     "Jason L Tibbitts III" <tibbs@math.uh.edu>
Cc:     "Trond Myklebust" <trondmy@hammerspace.com>,
        Anna.Schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Chuck.Lever@oracle.com
Subject: Re: Need help debugging NFS issues new to 4.20 kernel
Date:   Mon, 25 Feb 2019 18:15:26 -0500
Message-ID: <DADB4AE9-5C48-4D31-AAC9-D0C78BDA4442@redhat.com>
In-Reply-To: <ufa36obbrje.fsf@epithumia.math.uh.edu>
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
 <ufa36obbrje.fsf@epithumia.math.uh.edu>
MIME-Version: 1.0
Content-Type: text/plain; format=flowed
Content-Transfer-Encoding: 8BIT
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.31]); Mon, 25 Feb 2019 23:15:29 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Hi Jason,

It looks like Trond has this patch on his "linux-next" and on his 
"testing" branch:

http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=shortlog;h=refs/heads/linux-next

commit 3453d5708b33efe76f40eca1c0ed60923094b971
Author: Trond Myklebust <trond.myklebust@hammerspace.com>
Date:   Wed Jun 20 17:53:34 2018 -0400

     NFSv4.1: Avoid false retries when RPC calls are interrupted

     A 'false retry' in NFSv4.1 occurs when the client attempts to 
transmit a
     new RPC call using a slot+sequence number combination that 
references an
     already cached one. Currently, the Linux NFS client will do this if 
a
     user process interrupts an RPC call that is in progress.
     The problem with doing so is that we defeat the main mechanism used 
by
     the server to differentiate between a new call and a replayed one. 
Even
     if the server is able to perfectly cache the arguments of the old 
call,
     it cannot know if the client intended to replay or send a new call.

     The obvious fix is to bump the sequence number pre-emptively if an
     RPC call is interrupted, but in order to deal with the corner cases
     where the interrupted call is not actually received and processed 
by
     the server, we need to interpret the error NFS4ERR_SEQ_MISORDERED
     as a sign that we need to either wait or locate a correct sequence
     number that lies between the value we sent, and the last value that
     was acked by a SEQUENCE call on that slot.

     Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
     Tested-by: Jason Tibbitts <tibbs@math.uh.edu>

That's usually a good sign that he will include it in a pull request 
when the 5.1 merge window opens.

Anna and Trond trade off sending patches for each linux release, this 
time around Trond will send them.

Without having to take any further steps I expect this will land in 
mainline for 5.1, and fedora will eventually pick it up.

Ben

On 25 Feb 2019, at 14:24, Jason L Tibbitts III wrote:

> So I've now running this patch ("NFSv4.1: Avoid false retries when RPC
> calls are interrupted") for several days with no hangs at all and no
> other regressions noted.  What would the next step be?  Will this be
> sent upstream?  I'm not sure how to check if this is queued for
> submission in someone's tree.
>
> I doubt there is anything I can do to help the process but please let 
> me
> know if there is.
>
>  - J<
