Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:33578 "EHLO
        mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752937AbdEDQWw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 4 May 2017 12:22:52 -0400
Received: by mail-io0-f172.google.com with SMTP id p24so28827215ioi.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 May 2017 09:22:52 -0700 (PDT)
MIME-Version: 1.0
From: "Igor O." <igoros@gmail.com>
Date: Thu, 4 May 2017 09:22:51 -0700
Message-ID: <CABGc9E44m=UvKFtTEaa9hiOJuXfYaNjPr=H92VvqvTbKQ828qQ@mail.gmail.com>
Subject: Race between RPC queuing on xprt_pending and a write space notification?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I am trying to understand an unresponsive NFS client issue that I can
reproduce in a particular workload running for a few hours. The VM
running the NFS client is Ubuntu 14.04.5, so this is using the
4.4.0-34 kernel.

Based on rpc_debug traces, I have a possible hypothesis on how this
can happen as a result of a race on the xprt_pending queue. I was
wondering whether anyone here can comment on whether the hypothesis is
plausible or not.

The client is stuck in the following state:

    * There is one pending RPC (61009) that began transmitting, but
the transmission was incomplete due to EAGAIN, and will never complete
        + RPC 61009 is forever reported as pending by
sunrpc/rpc_clnt/*/tasks in debugfs
        + Obviously no other RPC can transmit, since the transport is
locked by RPC 61009

    * But, there is space in the output TCP buffer:
        + Output TCP socket buffer is empty, according to netstat
        + Server is reporting non-zero TCP window to the client,
according to tcpdump

This is the rpc_debug trace of how RPC 61009 got into this state:

    May  4 06:12:02 ub14045-gold kernel: [155440.176714] RPC: 61009
xprt_transmit(524448)
    May  4 06:12:02 ub14045-gold kernel: [155440.176734] RPC:
xs_tcp_send_request(524448) = 0
    May  4 06:12:02 ub14045-gold kernel: [155440.176735] RPC:
xs_tcp_send_request(261456) = -11
    May  4 06:12:02 ub14045-gold kernel: [155440.176738] RPC: 61009
xmit incomplete (261456 left of 524448)
    May  4 06:12:02 ub14045-gold kernel: [155440.176771] RPC:
write space: waking waiting task on xprt ffff88003d1e7000
    May  4 06:12:02 ub14045-gold kernel: [155440.176778] RPC: 61009
sleep_on(queue "xprt_pending" time 4333753084)
    May  4 06:12:02 ub14045-gold kernel: [155440.176778] RPC: 61009
added to queue ffff88003d1e7258 "xprt_pending"

In other words:

    1. 61009 gets EAGAIN, reports xmit incomplete
    2. In race, write space becomes available, the xprt_pending queue
tasks get woken. The queue is empty, though, because 61009 hasn't
queued itself yet.
    3. 61009 queues itself on xprt_pending queue, but it just missed
the notification.
    4. 61009 is forever stuck on xprt_pending queue. There won't be
any future "write space" notification and it will never time out.

At this point, there isn't any notification that will wake 61009 on
the xprt_pending queue. Since I have a hard mount, there will be no
timeout on the wait, as implemented in xprt_wait_for_buffer_space().

Can anyone provide insight on whether the xprt_pending queue handles
the above race condition? Is there another mechanism apart from "write
space" notification (that can be missed) and timeout (not scheduled
due to hard mount) that should still wake the RPC from the
xprt_pending queue?

Apart from that, any suggested next steps to investigate this?

Thank you for reading,
Igor Ostrovsky
