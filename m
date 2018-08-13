Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f66.google.com ([209.85.160.66]:38017 "EHLO
        mail-pl0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725896AbeHMGX2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2018 02:23:28 -0400
To: trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
From: Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [BUG] fs: nfs: callback_proc: a possible sleep-in-atomic-context bug
 in nfs4_callback_sequence()
Message-ID: <d2edd56f-782e-737b-b6a8-ca0b5be94f00@gmail.com>
Date: Mon, 13 Aug 2018 11:43:04 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The kernel may sleep with holding a spinlock.

The function call paths (from bottom to top) in Linux-4.16 are:

[FUNC] schedule_timeout
fs/nfs/nfs4session.c, 223: schedule_timeout in nfs4_slot_wait_on_seqid
fs/nfs/callback_proc.c, 466: nfs4_slot_wait_on_seqid in 
referring_call_exists
fs/nfs/callback_proc.c, 544: referring_call_exists in nfs4_callback_sequence
fs/nfs/callback_proc.c, 504: spin_lock in nfs4_callback_sequence

I do not find a good way to fix, so I only report.
This is found by my static analysis tool (DSAC).


Thanks,
Jia-Ju Bai
