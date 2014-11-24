Return-Path: linux-nfs-owner@vger.kernel.org
Received: from api.opinsys.fi ([217.112.254.4]:33226 "EHLO mail.opinsys.fi"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752685AbaKXIkG convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 03:40:06 -0500
Date: Mon, 24 Nov 2014 08:32:21 +0000 (UTC)
From: Tuomas =?utf-8?B?UsOkc8OkbmVu?= <tuomasjjrasanen@opinsys.fi>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Message-ID: <1555471491.95357.1416817941257.JavaMail.zimbra@opinsys.fi>
In-Reply-To: <1904910431.95230.1416815071750.JavaMail.zimbra@opinsys.fi>
Subject: BUG when umounting exported EXT4 fs
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi

We have been experiencing quite regular umount failures on our NFS
servers which are exporting EXT4 /home via exportfs.

Servers are running kernels from mainline 3.10-series.

Both the reproduction steps and symptoms are almost indentical to what
was reported in https://lkml.org/lkml/2013/8/11/26 by Toralf Förster.

The steps to reproduce:
  1. export EXT4 /home via exportfs
  2. let clients work on /home
  3. shutdown clients
  4. service nfs-kernel-server stop
  5. umount /home

Umount causes the following BUG trace:

[685206.207459] Call Trace:
[685206.208356]  [<ffffffff811a2482>] generic_shutdown_super+0x62/0xf0
[685206.209264]  [<ffffffff811a2540>] kill_block_super+0x30/0x80
[685206.210179]  [<ffffffff811a2dcd>] deactivate_locked_super+0x4d/0x80
[685206.211115]  [<ffffffff811a344e>] deactivate_super+0x4e/0x70
[685206.212039]  [<ffffffff811beed6>] mntput_no_expire+0x106/0x160
[685206.212964]  [<ffffffff811c07e9>] SyS_umount+0xa9/0xf0
[685206.213895]  [<ffffffff8170fc6f>] tracesys+0xe1/0xe6
[685206.214838] Code: 81 49 8b 57 78 48 81 c6 20 03 00 00 89 04 24 31 c0 e8 c5 3f 49 00 4d 8b 3f 4d 39 fe 75 c4 4c 39 b3 00 02 00 00 0f 84 97 fe ff ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 
[685206.216885] RIP  [<ffffffff81259782>] ext4_put_super+0x342/0x350
[685206.217913]  RSP <ffff8807d3f7fe28>

The trace is preceded by dumped orphan list info.

The most annoying thing is that in practice, it happens when the server
is rebooted normally, causing the reboot to stall (services have alredy
been shutdown at this point so the remote connection is closed as well).

I tried the following patch (which landed on mainline in 3.11):

commit bf7bd3e98be5c74813bee6ad496139fb0a011b3b
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Thu Aug 15 16:55:26 2013 -0400

    nfsd4: fix leak of inode reference on delegation failure

The patch didn't apply cleanly on top of 3.10.58 but I think I got the
few conflicts right and it seems to have fixed the issue.

Is there any particular reason why the patch has not been included in
3.10 stable -series?

-- 
Tuomas
