Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:51718 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753066Ab2CaNUH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Mar 2012 09:20:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1SDyDs-0000Tu-Di
	for linux-nfs@vger.kernel.org; Sat, 31 Mar 2012 15:20:04 +0200
Received: from p3e9bbfe5.dip.t-dialin.net ([62.155.191.229])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 31 Mar 2012 15:20:04 +0200
Received: from ponto by p3e9bbfe5.dip.t-dialin.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 31 Mar 2012 15:20:04 +0200
To: linux-nfs@vger.kernel.org
From: Christoph Bartoschek <ponto@pontohonk.de>
Subject: nfsd hangs for more than 120 seconds
Date: Sat, 31 Mar 2012 13:55:44 +0200
Message-ID: <0v7j49-4jc.ln1@homer.bruehl.pontohonk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

we use Ubuntu 10.04.3 LTS and often get a traceback for NFS indicating that 
the daemon hangs for several seconds. At the same time some client machines 
cannot access the server and have to wait. After some minutes everything 
goes on.

What could cause the problem? Is there anything we should change?

Here is the message in the kernel log:

[330573.697121] INFO: task nfsd:1376 blocked for more than 120 seconds.
[330573.708375] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables 
this message.
[330573.730773] nfsd          D 0000000000000001     0  1376      2 
0x00000000
[330573.730776]  ffff88061c21bdc0 0000000000000046 0000000000015f00 
0000000000015f00
[330573.730779]  ffff88061c111ad0 ffff88061c21bfd8 0000000000015f00 
ffff88061c111700
[330573.730781]  0000000000015f00 ffff88061c21bfd8 0000000000015f00 
ffff88061c111ad0
[330573.730784] Call Trace:
[330573.730788]  [<ffffffff81559e67>] __mutex_lock_slowpath+0x107/0x190
[330573.730796]  [<ffffffffa012300f>] ? svc_authorise+0x3f/0x50 [sunrpc]
[330573.730799]  [<ffffffff81559863>] mutex_lock+0x23/0x50
[330573.730807]  [<ffffffffa012d478>] svc_send+0x58/0xe0 [sunrpc]
[330573.730809]  [<ffffffff8105df90>] ? default_wake_function+0x0/0x20
[330573.730817]  [<ffffffffa011faec>] svc_process+0x11c/0x150 [sunrpc]
[330573.730821]  [<ffffffffa0184ae5>] nfsd+0xc5/0x170 [nfsd]
[330573.730830]  [<ffffffffa0184a20>] ? nfsd+0x0/0x170 [nfsd]
[330573.730832]  [<ffffffff81085db6>] kthread+0x96/0xa0
[330573.730835]  [<ffffffff810141aa>] child_rip+0xa/0x20
[330573.730837]  [<ffffffff81085d20>] ? kthread+0x0/0xa0
[330573.730839]  [<ffffffff810141a0>] ? child_rip+0x0/0x20


-- 
Christoph Bartoschek

