From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: (unknown)
Date: Tue, 6 Jan 2009 11:02:47 +0100
Message-ID: <20090106100246.GA13742@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bfields@fieldses.org, hch@lst.de, neilb@suse.de
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:45566 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750830AbZAFKCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Jan 2009 05:02:52 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi,

with todays -git i see the following lockdep warning, that wasnt there
yesterday. It occurs after booting the box.

[   83.741022] Installing knfsd (copyright (C) 1996 okir-pn4DOG8n3UYbFoVRYvo4fw@public.gmane.org).
[   84.115838] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4 state
recovery directory
[   84.133473] NFSD: starting 90-second grace period
[  174.132715] 
[  174.132724] =============================================
[  174.133004] [ INFO: possible recursive locking detected ]
[  174.133133] 2.6.28 #85
[  174.133232] ---------------------------------------------
[  174.133428] nfsd4/3693 is trying to acquire lock:
[  174.133548]  (&type->i_mutex_dir_key#2){--..}, at: [<c01c4212>]
vfs_fsync+0x62/0xe0
[  174.133991] 
[  174.133994] but task is already holding lock:
[  174.134251]  (&type->i_mutex_dir_key#2){--..}, at: [<d1c224f7>]
nfsd4_sync_rec_dir+0x17/0x40 [nfsd]
[  174.134774] 
[  174.134777] other info that might help us debug this:
[  174.134983] 4 locks held by nfsd4/3693:
[  174.135151]  #0:  (nfsd4){--..}, at: [<c0139d4a>]
run_workqueue+0x7a/0x1e0
[  174.135539]  #1:  ((laundromat_work).work){--..}, at: [<c0139d4a>]
run_workqueue+0x7a/0x1e0
[  174.135968]  #2:  (client_mutex){--..}, at: [<d1c1e9f6>]
laundromat_main+0x26/0x2a0 [nfsd]
[  174.136021]  #3:  (&type->i_mutex_dir_key#2){--..}, at: [<d1c224f7>]
nfsd4_sync_rec_dir+0x17/0x40 [nfsd]
[  174.136021] 
[  174.136021] stack backtrace:
[  174.136021] Pid: 3693, comm: nfsd4 Not tainted 2.6.28 #85
[  174.136021] Call Trace:
[  174.136021]  [<c05abdb6>] ? printk+0x18/0x1a
[  174.136021]  [<c014f626>] __lock_acquire+0xe76/0x1110
[  174.136021]  [<c014f934>] lock_acquire+0x74/0xa0
[  174.136021]  [<c01c4212>] ? vfs_fsync+0x62/0xe0
[  174.136021]  [<c05acfac>] mutex_lock_nested+0x8c/0x2c0
[  174.136021]  [<c01c4212>] ? vfs_fsync+0x62/0xe0
[  174.136021]  [<c01c4212>] ? vfs_fsync+0x62/0xe0
[  174.136021]  [<c01c4212>] vfs_fsync+0x62/0xe0
[  174.136021]  [<d1c074be>] nfsd_sync_dir+0xe/0x10 [nfsd]
[  174.136021]  [<d1c22501>] nfsd4_sync_rec_dir+0x21/0x40 [nfsd]
[  174.136021]  [<d1c22595>] nfsd4_recdir_purge_old+0x75/0x80 [nfsd]
[  174.136021]  [<d1c1ea1e>] laundromat_main+0x4e/0x2a0 [nfsd]
[  174.136021]  [<c0139d4a>] ? run_workqueue+0x7a/0x1e0
[  174.136021]  [<c0139dac>] run_workqueue+0xdc/0x1e0
[  174.136021]  [<c0139d4a>] ? run_workqueue+0x7a/0x1e0
[  174.136021]  [<d1c1e9d0>] ? laundromat_main+0x0/0x2a0 [nfsd]
[  174.136021]  [<c013a1a7>] worker_thread+0x87/0xf0
[  174.136021]  [<c013dac0>] ? autoremove_wake_function+0x0/0x50
[  174.136021]  [<c013a120>] ? worker_thread+0x0/0xf0
[  174.136021]  [<c013d80a>] kthread+0x3a/0x70
[  174.136021]  [<c013d7d0>] ? kthread+0x0/0x70
[  174.136021]  [<c0103cf3>] kernel_thread_helper+0x7/0x14

Greetings, Eric
