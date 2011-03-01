Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:50545 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755814Ab1CAVdg convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Mar 2011 16:33:36 -0500
Received: by wwb22 with SMTP id 22so5021287wwb.1
        for <linux-nfs@vger.kernel.org>; Tue, 01 Mar 2011 13:33:34 -0800 (PST)
In-Reply-To: <AANLkTimtmz_7Q8DsjhhM1M8pFhLfJpannebJsuFuV_C-@mail.gmail.com>
References: <AANLkTimtmz_7Q8DsjhhM1M8pFhLfJpannebJsuFuV_C-@mail.gmail.com>
Date: Tue, 1 Mar 2011 16:33:34 -0500
Message-ID: <AANLkTikKbUvEDY5LWHk5=JOEimS1R+oz-m0bfP=6+YcP@mail.gmail.com>
Subject: nfs4 kernel ops
From: Olga Kornievskaia <aglo@citi.umich.edu>
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Is this an interesting kernel ops for the linux server developers? It
happened while running general tests on the windows client.

This is from benney's tree and it's 2.6.38-rc5. from pnfs-all-latest
branch and commit
9e697ce1a3fc537cf3fb37a3e11e29345eb0f24d


ar  1 15:31:37 localhost kernel: Call Trace:
Mar  1 15:31:37 localhost kernel: [<ffffffff8145bf89>]
__mutex_lock_common+0x12c/0x193
Mar  1 15:31:37 localhost kernel: [<ffffffff81070af8>] ? groups_alloc+0x3d/0xc3
Mar  1 15:31:37 localhost kernel: [<ffffffff8145c009>]
__mutex_lock_slowpath+0x19/0x1b
Mar  1 15:31:37 localhost kernel: [<ffffffff8145c129>] mutex_lock+0x36/0x50
Mar  1 15:31:37 localhost kernel: [<ffffffffa02cba41>]
nfs4_lock_state+0x15/0x27 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02d3d5c>]
nfsd_layout_recall_cb+0xa9/0x32e [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02d76ce>]
pnfsd_lexp_recall_layout+0xfb/0x243 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02b4baf>] ?
nfsd_permission+0x43/0xf6 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02b654b>]
nfsd_setattr+0x124/0x2b3 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02cc457>]
nfsd4_process_open2+0x2dd/0x971 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02c10a7>]
nfsd4_open+0x296/0x2cd [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02c08a7>]
nfsd4_proc_compound+0x229/0x3ba [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02b138f>]
nfsd_dispatch+0xf1/0x1d5 [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa0224e4a>]
svc_process_common+0x2e1/0x4d8 [sunrpc]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02b185a>] ? nfsd+0x0/0x13f [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffffa0225264>]
svc_process+0x11c/0x13c [sunrpc]
Mar  1 15:31:37 localhost kernel: [<ffffffffa02b1950>] nfsd+0xf6/0x13f [nfsd]
Mar  1 15:31:37 localhost kernel: [<ffffffff81069f52>] kthread+0x82/0x8a
Mar  1 15:31:37 localhost kernel: [<ffffffff8100ba24>]
kernel_thread_helper+0x4/0x10
Mar  1 15:31:37 localhost kernel: [<ffffffff81069ed0>] ? kthread+0x0/0x8a
Mar  1 15:31:37 localhost kernel: [<ffffffff8100ba20>] ?
kernel_thread_helper+0x0/0x10
