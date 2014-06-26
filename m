Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41705 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755560AbaFZB03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jun 2014 21:26:29 -0400
Date: Wed, 25 Jun 2014 21:26:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 000/104] nfsd: eliminate the client_mutex
Message-ID: <20140626012629.GA19952@fieldses.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <20140619113328.598cf759@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140619113328.598cf759@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing this, by the way.--b.

[  512.960652] nfsd: non-standard errno: -7
[  650.442646] ------------[ cut here ]------------
[  650.442754] WARNING: CPU: 3 PID: 647 at fs/nfsd/nfs4state.c:761
revoke_delegation+0xa7/0xb0 [nfsd]()
[  650.442760] Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss
oid_registry nfs_acl lockd sunrpc
[  650.442792] CPU: 3 PID: 647 Comm: kworker/u8:2 Not tainted
3.16.0-rc2-00479-gb675b9c #2982
[  650.442796] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  650.442814] Workqueue: nfsd4 laundromat_main [nfsd]
[  650.442821]  0000000000000009 ffff880036287c48 ffffffff81a439d6
0000000000000001
[  650.442836]  0000000000000000 ffff880036287c88 ffffffff8106d65c
ffff880036287c68
[  650.442851]  ffff8800312aee60 ffff88001bcfe800 ffff8800312aeeb0
ffffffff822c7cc0
[  650.442865] Call Trace:
[  650.442878]  [<ffffffff81a439d6>] dump_stack+0x4f/0x7c
[  650.442889]  [<ffffffff8106d65c>] warn_slowpath_common+0x8c/0xc0
[  650.442897]  [<ffffffff8106d6aa>] warn_slowpath_null+0x1a/0x20
[  650.442917]  [<ffffffffa011a607>] revoke_delegation+0xa7/0xb0 [nfsd]
[  650.442936]  [<ffffffffa011aaec>] laundromat_main+0x2dc/0x480 [nfsd]
[  650.442956]  [<ffffffffa011a9f4>] ? laundromat_main+0x1e4/0x480
[nfsd]
[  650.442967]  [<ffffffff8108924e>] process_one_work+0x1ce/0x500
[  650.442976]  [<ffffffff810891db>] ? process_one_work+0x15b/0x500
[  650.442985]  [<ffffffff81089b9b>] worker_thread+0x11b/0x4f0
[  650.442995]  [<ffffffff810bba2d>] ? trace_hardirqs_on+0xd/0x10
[  650.443004]  [<ffffffff81a4c36b>] ?
_raw_spin_unlock_irqrestore+0x4b/0x80
[  650.443013]  [<ffffffff81089a80>] ? init_pwq+0x190/0x190
[  650.443022]  [<ffffffff81090ac4>] kthread+0xe4/0x100
[  650.443032]  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
[  650.443041]  [<ffffffff81a4caac>] ret_from_fork+0x7c/0xb0
[  650.443050]  [<ffffffff810909e0>] ? __init_kthread_worker+0x70/0x70
[  650.443055] ---[ end trace e3faa7f0516143d3 ]---
