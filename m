Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:57353 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750774AbbCKLuY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Mar 2015 07:50:24 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1YVf9Z-0002ah-WB
	for linux-nfs@vger.kernel.org; Wed, 11 Mar 2015 12:50:22 +0100
Received: from pd953ef04.dip0.t-ipconnect.de ([217.83.239.4])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 12:50:21 +0100
Received: from holger.hoffstaette by pd953ef04.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Wed, 11 Mar 2015 12:50:21 +0100
To: linux-nfs@vger.kernel.org
From: Holger =?iso-8859-1?q?Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>
Subject: Broken suspend since 3.18.9
Date: Wed, 11 Mar 2015 11:50:02 +0000 (UTC)
Message-ID: <pan.2015.03.11.11.50.02@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Since 3.18.9 suspend no longer works reliably (only ~10% of the time), unlike 3.18.8;
the suspend sequence starts, but after a few seconds the machine just returns to
wakeup state.

The following log spew points the finger at NFS-related changes:

Mar 11 00:54:45 ragnarok kernel: PM: Syncing filesystems ... done.
Mar 11 00:55:05 ragnarok kernel: Freezing user space processes ... (elapsed 0.001 seconds) done.
Mar 11 00:55:05 ragnarok kernel: Freezing remaining freezable tasks ... 
Mar 11 00:55:05 ragnarok kernel: nfsv4.1-svc     D ffff88061f411740     0 22942      2 0x00000000
Mar 11 00:55:05 ragnarok kernel:  ffff8800d63cfd98 0000000000000046 ffff8800d63cfc78 0000000000009000
Mar 11 00:55:05 ragnarok kernel:  ffff88059b582ca0 ffff8800d63cffd8 ffff88059b583020 01ffffffa07c0798
Mar 11 00:55:05 ragnarok kernel:  0000000000011740 ffffffff81816500 ffff88061f411740 ffff88055cc48ee0
Mar 11 00:55:05 ragnarok kernel: Call Trace:
Mar 11 00:55:05 ragnarok kernel:  [<ffffffffa07c57e4>] ? rpc_release_resources_task+0x34/0x40 [sunrpc]
Mar 11 00:55:05 ragnarok kernel:  [<ffffffffa07c64de>] ? __rpc_execute+0x18e/0x360 [sunrpc]
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff8108ad4b>] ? lock_timer_base.isra.36+0x2b/0x50
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff8108ae1f>] ? try_to_del_timer_sync+0x4f/0x70
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81535c02>] schedule_timeout+0x102/0x1f0
Mar 11 00:55:05 ragnarok kernel:  [<ffffffffa07c67b0>] ? rpc_do_put_task+0x80/0x90 [sunrpc]
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff8108a7b0>] ? migrate_timer_list+0xb0/0xb0
Mar 11 00:55:05 ragnarok kernel:  [<ffffffffa03c1f7a>] nfs41_callback_svc+0x16a/0x180 [nfsv4]
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81074710>] ? __wake_up_sync+0x20/0x20
Mar 11 00:55:05 ragnarok kernel:  [<ffffffffa03c1e10>] ? nfs4_callback_svc+0x60/0x60 [nfsv4]
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81067c2b>] kthread+0xdb/0x100
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81067b50>] ? kthread_create_on_node+0x180/0x180
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81536d2c>] ret_from_fork+0x7c/0xb0
Mar 11 00:55:05 ragnarok kernel:  [<ffffffff81067b50>] ? kthread_create_on_node+0x180/0x180
Mar 11 00:55:05 ragnarok kernel: 
Mar 11 00:55:05 ragnarok kernel: Restarting kernel threads ... done.
Mar 11 00:55:05 ragnarok kernel: Restarting tasks ... done.

I found that shutting down the automount service (thus killing all NFS mounts)
makes things work immediately. The same symptom can be seen in 3.19.1, which
- as far as I can tell - got the same commits recently.

Any ideas? I can gladly test patches.

Thanks!

Holger

