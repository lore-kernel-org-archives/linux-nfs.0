Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:41470 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751300AbbBJPnG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Feb 2015 10:43:06 -0500
Date: Tue, 10 Feb 2015 10:43:06 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: hang on xfstests generic/074
Message-ID: <20150210154306.GF28949@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I finally got around to running xfstests as part of my regular testing
and ran across a reproduceable hang on generic/074:

[110040.300055] INFO: task fstest:22762 blocked for more than 120 seconds.
[110040.300571]       Tainted: G        W      3.19.0-rc4-00206-g53ea83c #16
[110040.301082] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[110040.301656] fstest          D ffff88005246bc98 11320 22762  22761 0x00000000
[110040.302334]  ffff88005246bc98 ffff88005246bc58 0000000000009000 ffff880057c4d7d0
[110040.303185]  ffff88005246bfd8 ffff880052f84b90 ffff880057c4d7d0 0000000000000000
[110040.304041]  0000000000000000 0000000000000001 0000000000000000 ffff88005246bc58
[110040.305096] Call Trace:
[110040.305331]  [<ffffffff810b0ed7>] ? prepare_to_wait+0x27/0x90
[110040.305770]  [<ffffffffa000f492>] ? rpc_make_runnable+0xc2/0xd0 [sunrpc]
[110040.306274]  [<ffffffff81a9550d>] ?  _raw_spin_unlock_irqrestore+0x5d/0x80
[110040.306799]  [<ffffffff81a90910>] ? bit_wait+0x60/0x60
[110040.307258]  [<ffffffff810bad1d>] ?  trace_hardirqs_on_caller+0x15d/0x200
[110040.307798]  [<ffffffff810badcd>] ? trace_hardirqs_on+0xd/0x10
[110040.308283]  [<ffffffff81a90910>] ? bit_wait+0x60/0x60
[110040.308678]  [<ffffffff81a8ffc9>] schedule+0x29/0x70
[110040.309054]  [<ffffffff81a90295>] io_schedule+0x55/0x80
[110040.309510]  [<ffffffff81a90944>] bit_wait_io+0x34/0x60
[110040.309909]  [<ffffffff81a905b7>] __wait_on_bit+0x67/0x90
[110040.310313]  [<ffffffff8114e72d>] ? find_get_pages_tag+0xd/0x210
[110040.310756]  [<ffffffff8114d2c6>] wait_on_page_bit+0xb6/0xc0
[110040.311177]  [<ffffffff810b1410>] ?  autoremove_wake_function+0x40/0x40
[110040.311654]  [<ffffffff8114d422>] filemap_fdatawait_range+0xf2/0x190
[110040.312131]  [<ffffffff8114f062>] filemap_write_and_wait_range+0x42/0x70
[110040.312627]  [<ffffffffa017866f>] nfs4_file_fsync+0x5f/0xb0 [nfsv4]
[110040.313090]  [<ffffffffa0178905>] ?  nfs4_do_check_delegation+0x5/0xc0 [nfsv4]
[110040.313616]  [<ffffffff811d05a9>] vfs_fsync+0x29/0x40
[110040.313991]  [<ffffffffa010fdea>] nfs_file_flush+0x7a/0xb0 [nfs]
[110040.314421]  [<ffffffff8119b093>] filp_close+0x33/0x80
[110040.314801]  [<ffffffff811bce42>] __close_fd+0x82/0xa0
[110040.315178]  [<ffffffff8119b103>] SyS_close+0x23/0x50
[110040.315551]  [<ffffffff81a960d2>] system_call_fastpath+0x12/0x17
[110040.316247] no locks held by fstest/22762.
[110063.328025] nfs: server f21-1 not responding, still trying ...

Is this anything known?

Client and server were running some version of my tree, 19-rc4 based.

--b.
