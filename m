Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:61773 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754390Ab0FOUNj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jun 2010 16:13:39 -0400
Message-ID: <4C17DEF5.7000609@panasas.com>
Date: Tue, 15 Jun 2010 16:13:41 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Andy Adamson <andros@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs-2.6.35-rc3 writeback hang w/ cthon test5
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

client and server running pnfs-all-2.6.35-rc3-2010-06-15
client runs on UML
server runs on redhat-3 and with files pnfsd_local_exp (Fedora 13 KVM)

./test5: read and write
Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
Got error -10052 from the server on DESTROY_SESSION. Session has been destroyed regardless...
INFO: task flush-0:18:2310 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
flush-0:18    D 0000003d8c2dc84f  6928  2310      2 0x00000000
       74b4c000 78f9e980 74b4dc60 601a89b0 74b4dcd0 74b4dcd0 74b4c000 00000000 
       74b4dcc0 74b4dcd0 62499130 00000002 74b4dc70 60092704 74b4dcb0 601a8ea3 
Call Trace: 
74b4dbc8:  [<6002bbba>] dequeue_task+0x3b/0x4d
74b4dbe8:  [<600137df>] _switch_to+0x5e/0xae
74b4dc18:  [<601a89b0>] schedule+0x1d9/0x21f
74b4dc68:  [<60092704>] inode_wait+0x9/0xd
74b4dc78:  [<601a8ea3>] __wait_on_bit+0x47/0x78
74b4dc80:  [<600926fb>] inode_wait+0x0/0xd
74b4dcb8:  [<6009b159>] inode_wait_for_writeback+0x8f/0xae
74b4dce0:  [<60043474>] wake_bit_function+0x0/0x2a
74b4dd28:  [<6009c225>] wb_writeback+0x183/0x1a4
74b4ddd8:  [<6009c429>] wb_do_writeback+0x13a/0x150
74b4dde0:  [<60039686>] process_timeout+0x0/0xb
74b4de58:  [<6009c47e>] bdi_writeback_task+0x3f/0xf7
74b4de68:  [<600690be>] bdi_task_init+0x71/0x7d
74b4de90:  [<6006996e>] bdi_start_fn+0x0/0xc7
74b4dea8:  [<600699da>] bdi_start_fn+0x6c/0xc7
74b4dec8:  [<6006996e>] bdi_start_fn+0x0/0xc7
74b4ded8:  [<60043086>] kthread+0x91/0x99
74b4df48:  [<600213a1>] run_kernel_thread+0x41/0x4a
74b4df58:  [<60042ff5>] kthread+0x0/0x99
74b4df98:  [<60021388>] run_kernel_thread+0x28/0x4a
74b4dfc8:  [<60013757>] new_thread_handler+0x72/0x9c
