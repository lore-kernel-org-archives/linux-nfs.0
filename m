Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:41507 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbeFDUWR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Jun 2018 16:22:17 -0400
Received: by mail-ua0-f172.google.com with SMTP id a5-v6so6869659uao.8
        for <linux-nfs@vger.kernel.org>; Mon, 04 Jun 2018 13:22:16 -0700 (PDT)
MIME-Version: 1.0
From: Chris Takemura <ctakemura@google.com>
Date: Mon, 4 Jun 2018 13:22:05 -0700
Message-ID: <CAJf8aWTT-UMvTm6uKumm9kVBF+7mcfzoL51GM8kJJ=3TgY_HBg@mail.gmail.com>
Subject: nfsd threads hanging in nfsd4_cstate_assign_replay?
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi linux-nfs,

I've got an NFS server that's behaving a little oddly -- it loses
threads to disk sleep at the rate of about 1 every 5 minutes.  Threads
stuck in this state all have the same stack:

[<ffffffffc069e4ce>] nfsd4_cstate_assign_replay.part.78+0x1e/0x30 [nfsd]
[<ffffffffc06a4ecc>] nfs4_preprocess_seqid_op+0xfc/0x190 [nfsd]
[<ffffffffc06a5bb6>] nfsd4_close+0x66/0x2c0 [nfsd]
[<ffffffffc06934fe>] nfsd4_proc_compound+0x3be/0x720 [nfsd]
[<ffffffffc067fec6>] nfsd_dispatch+0xd6/0x270 [nfsd]
[<ffffffffc04eef16>] svc_process_common+0x456/0x730 [sunrpc]
[<ffffffffc04ef2f5>] svc_process+0x105/0x1c0 [sunrpc]
[<ffffffffc067f8f0>] nfsd+0xf0/0x160 [nfsd]
[<ffffffffb109f158>] kthread+0xd8/0xf0
[<ffffffffb181b6f5>] ret_from_fork+0x55/0x80
[<ffffffffffffffff>] 0xffffffffffffffff

This is on ubuntu, with kernel version 4.4.0-119-generic
#143~14.04.1-Ubuntu.  As you can tell from the backtrace, it's serving
NFS4.

I've been increasing the thread count to compensate for the hung
threads -- note that the total number of threads doesn't affect the
rate of hangs, which is stubbornly constant.

Do you have any idea what could be causing this, and how I can stop
it, preferably without interrupting service?
