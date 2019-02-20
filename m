Return-Path: <SRS0=q2Lh=Q3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAD90C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:25:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA61B2086A
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Feb 2019 15:25:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727174AbfBTPZU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Feb 2019 10:25:20 -0500
Received: from mx1.math.uh.edu ([129.7.128.32]:57880 "EHLO mx1.math.uh.edu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726405AbfBTPZT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Feb 2019 10:25:19 -0500
Received: from epithumia.math.uh.edu ([129.7.128.2])
        by mx1.math.uh.edu with esmtp (Exim 4.91)
        (envelope-from <tibbs@math.uh.edu>)
        id 1gwTkG-00087f-Kf; Wed, 20 Feb 2019 09:25:14 -0600
Received: by epithumia.math.uh.edu (Postfix, from userid 7225)
        id 8CEA5801B44; Wed, 20 Feb 2019 09:25:12 -0600 (CST)
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
Date:   Wed, 20 Feb 2019 09:25:12 -0600
In-Reply-To: <e8887651e91b1d0110cab2330a03e3e3ccef742b.camel@hammerspace.com>
        (Trond Myklebust's message of "Sat, 16 Feb 2019 14:46:45 +0000")
Message-ID: <ufapnrmbhyf.fsf@epithumia.math.uh.edu>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Sadly, after a bit more testing I find that 4.20.10 with that patch
applied still exhibits the problem.  Just found a machine where NFS hung
up just six minutes after the user logged in.  As always: nothing is
logged to the client or the server.  I turned on the tracing as
requested previously and see what I think it just the same sequence as
before.  Please let me know if there is any other information I can
provide.  Right now I'm going to build 4.20.10 with my previously posted
revert patch applied and roll that out to the same 50 hosts and see how
it fares.

 - J<

    kworker/u8:0-12608 [001] .... 47884.661073: rpc_request: task:20469@1 nfsv4 SEQUENCE (async)
    kworker/u8:0-12608 [001] .... 47884.661073: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_reserve [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661074: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_reserveresult [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661074: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_refresh [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661075: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_refreshresult [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661076: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_allocate [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661076: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_encode [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661091: rpc_task_run_action: task:20469@1 flags=5281 state=001d status=0 action=call_bind [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661091: rpc_task_run_action: task:20469@1 flags=5281 state=001d status=0 action=call_connect [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661092: rpc_task_run_action: task:20469@1 flags=5281 state=001d status=0 action=call_transmit [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661106: xprt_transmit: peer=[172.21.86.74]:2049 xid=0x0d7ca068 status=0
    kworker/u8:0-12608 [001] .... 47884.661107: rpc_task_run_action: task:20469@1 flags=5a81 state=0015 status=0 action=call_transmit_status [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661107: rpc_task_sleep: task:20469@1 flags=5a81 state=0015 status=0 timeout=60000 queue=xprt_pending
    kworker/u9:0-12884 [002] .... 47884.661371: xprt_lookup_rqst: peer=[172.21.86.74]:2049 xid=0x0d7ca068 status=0
    kworker/u9:0-12884 [002] .... 47884.661372: xprt_complete_rqst: peer=[172.21.86.74]:2049 xid=0x0d7ca068 status=112
    kworker/u9:0-12884 [002] .... 47884.661373: rpc_task_wakeup: task:20469@1 flags=5a81 state=0006 status=0 timeout=60000 queue=xprt_pending
    kworker/u9:0-12884 [002] .... 47884.661375: xs_stream_read_request: peer=[172.21.86.74]:2049 xid=0x0d7ca068 copied=112 reclen=112 offset=112
    kworker/u9:0-12884 [002] .... 47884.661376: xs_stream_read_data: peer=[172.21.86.74]:2049 err=-11 total=116
    kworker/u8:0-12608 [001] .... 47884.661388: rpc_task_run_action: task:20469@1 flags=5a81 state=0005 status=0 action=xprt_timer [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661389: rpc_task_run_action: task:20469@1 flags=5a81 state=0005 status=0 action=call_status [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661389: rpc_task_run_action: task:20469@1 flags=5a81 state=0005 status=0 action=call_decode [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661408: rpc_task_run_action: task:20469@1 flags=5a81 state=0005 status=-10063 action=rpc_exit_task [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661409: nfs4_sequence_done: error=-10063 (SEQ_MISORDERED) session=0x4480e725 slot_nr=0 seq_nr=1 highest_slotid=0 target_highest_slotid=0 status_flags=0 ()
    kworker/u8:0-12608 [001] .... 47884.661410: rpc_stats_latency: task:20469@1 xid=0x0d7ca068 nfsv4 SEQUENCE backlog=21 rtt=278 execute=339
    kworker/u8:0-12608 [001] .... 47884.661412: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=rpc_prepare_task [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661413: nfs4_setup_sequence: session=0x4480e725 slot_nr=0 seq_nr=1 highest_used_slotid=0
    kworker/u8:0-12608 [001] .... 47884.661413: rpc_task_run_action: task:20469@1 flags=5281 state=0005 status=0 action=call_start [sunrpc]
    kworker/u8:0-12608 [001] .... 47884.661414: rpc_request: task:20469@1 nfsv4 SEQUENCE (async)
   
