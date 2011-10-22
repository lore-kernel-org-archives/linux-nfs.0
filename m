Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout0.thls.bbc.co.uk ([132.185.240.35]:61716 "EHLO
	mailout0.thls.bbc.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751492Ab1JVJBy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 Oct 2011 05:01:54 -0400
Received: from gateh.kw.bbc.co.uk (gateh.kw.bbc.co.uk [132.185.132.17])
	by mailout0.thls.bbc.co.uk (8.14.4/8.14.3) with ESMTP id p9M8SeZT015823
	for <linux-nfs@vger.kernel.org>; Sat, 22 Oct 2011 09:28:40 +0100 (BST)
Received: from mailhub.rd.bbc.co.uk ([172.29.120.130])
	by gateh.kw.bbc.co.uk (8.13.6/8.13.6) with ESMTP id p9M8Sdib021746
	for <linux-nfs@vger.kernel.org>; Sat, 22 Oct 2011 09:28:39 +0100 (BST)
Received: from lxg1.rd.bbc.co.uk ([172.29.123.71]:57493)
	by mailhub.rd.bbc.co.uk with esmtp (Exim 4.72)
	(envelope-from <davidf@rd.bbc.co.uk>)
	id 1RHWwZ-0000a5-BY
	for linux-nfs@vger.kernel.org; Sat, 22 Oct 2011 09:28:39 +0100
Received: from davidf by lxg1.rd.bbc.co.uk with local (Exim 4.72)
	(envelope-from <davidf@rd.bbc.co.uk>)
	id 1RHWwZ-0001KS-7L
	for linux-nfs@vger.kernel.org; Sat, 22 Oct 2011 09:28:39 +0100
Date: Sat, 22 Oct 2011 08:28:38 +0000
From: David Flynn <davidf@rd.bbc.co.uk>
To: linux-nfs@vger.kernel.org
Subject: NFS4 client blocked (kernel 3.0.4)
Message-ID: <20111022082838.GB32587@rd.bbc.co.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear all,

When mounting a solaris NFS4 export on a v3.0.4 client, we've experienced
processes becoming blocked.  Any further attempt to access the mountpoint
from another process also blocks.  Other mountpoints are unaffected.
I have not identified a test case to reproduce the behaviour.

Any thoughts on the matter would be most welcome,

Kind regards,

..david

from /proc/mounts:
home:/home/ /home nfs4 rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,clientaddr=172.29.190.20,minorversion=0,local_lock=none,addr=172.29.120.140 0 0

[105121.204200] INFO: task bash:4457 blocked for more than 120 seconds.
[105121.247424] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[105121.299955] bash            D ffffffff818050a0     0  4457      1 0x00000000
[105121.347840]  ffff8802954b5c28 0000000000000082 ffff8802954b5db8 0000000000012a40
[105121.397793]  ffff8802954b5fd8 0000000000012a40 ffff8802954b4000 0000000000012a40
[105121.441724]  0000000000012a40 0000000000012a40 ffff8802954b5fd8 0000000000012a40
[105121.441728] Call Trace:
[105121.441740]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
[105121.441744]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
[105121.441746]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
[105121.441749]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
[105121.441751]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
[105121.441756]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
[105121.441759]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
[105121.441761]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
[105121.441786]  [<ffffffffa023a7d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
[105121.441789]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
[105121.441791]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
[105121.441793]  [<ffffffff8111050b>] filemap_fdatawait+0x2b/0x30
[105121.441795]  [<ffffffff81112124>] filemap_write_and_wait+0x44/0x60
[105121.441803]  [<ffffffffa0232805>] nfs_getattr+0x105/0x120 [nfs]
[105121.441806]  [<ffffffff81605e88>] ? do_page_fault+0x258/0x550
[105121.441810]  [<ffffffff81175b31>] vfs_getattr+0x51/0x120
[105121.441812]  [<ffffffff81175c70>] vfs_fstatat+0x70/0x90
[105121.441814]  [<ffffffff81175ccb>] vfs_stat+0x1b/0x20
[105121.441816]  [<ffffffff81175f14>] sys_newstat+0x24/0x40
[105121.441820]  [<ffffffff8101449a>] ? init_fpu+0x4a/0x150
[105121.441822]  [<ffffffff81602955>] ? page_fault+0x25/0x30
[105121.441825]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b
[105121.441837] INFO: task bash:5612 blocked for more than 120 seconds.
[105121.441838] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[105121.441840] bash            D 0000000000000005     0  5612      1 0x00000000
[105121.441843]  ffff8801f25d5ca8 0000000000000086 ffff8800163e9b08 0000000000012a40
[105121.441845]  ffff8801f25d5fd8 0000000000012a40 ffff8801f25d4000 0000000000012a40
[105121.441848]  0000000000012a40 0000000000012a40 ffff8801f25d5fd8 0000000000012a40
[105121.441850] Call Trace:
[105121.441853]  [<ffffffff81110030>] ? __lock_page+0x70/0x70
[105121.441855]  [<ffffffff8160007c>] io_schedule+0x8c/0xd0
[105121.441857]  [<ffffffff8111003e>] sleep_on_page+0xe/0x20
[105121.441859]  [<ffffffff816008ff>] __wait_on_bit+0x5f/0x90
[105121.441861]  [<ffffffff81110203>] wait_on_page_bit+0x73/0x80
[105121.441863]  [<ffffffff81085bf0>] ? autoremove_wake_function+0x40/0x40
[105121.441866]  [<ffffffff8111c5e5>] ? pagevec_lookup_tag+0x25/0x40
[105121.441868]  [<ffffffff81110436>] filemap_fdatawait_range+0xf6/0x1a0
[105121.441876]  [<ffffffffa023a7d0>] ? nfs_destroy_directcache+0x20/0x20 [nfs]
[105121.441878]  [<ffffffff8111bae1>] ? do_writepages+0x21/0x40
[105121.441880]  [<ffffffff811116bb>] ? __filemap_fdatawrite_range+0x5b/0x60
[105121.441882]  [<ffffffff81111730>] filemap_write_and_wait_range+0x70/0x80
[105121.441886]  [<ffffffff8119cc6a>] vfs_fsync_range+0x5a/0x90
[105121.441888]  [<ffffffff8119cd0c>] vfs_fsync+0x1c/0x20
[105121.441894]  [<ffffffffa022ec74>] nfs_file_flush+0x54/0x80 [nfs]
[105121.441898]  [<ffffffff8116ee7f>] filp_close+0x3f/0x90
[105121.441900]  [<ffffffff8116f8a7>] sys_close+0xb7/0x120
[105121.441902]  [<ffffffff8160a702>] system_call_fastpath+0x16/0x1b
