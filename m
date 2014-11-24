Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33281 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753204AbaKXRfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 24 Nov 2014 12:35:10 -0500
Date: Mon, 24 Nov 2014 10:35:05 -0700
From: "J. Bruce Fields" <bfields@redhat.com>
To: Tuomas =?iso-8859-1?Q?R=E4s=E4nen?= <tuomasjjrasanen@opinsys.fi>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: BUG when umounting exported EXT4 fs
Message-ID: <20141124173505.GC21584@pad.redhat.com>
References: <1904910431.95230.1416815071750.JavaMail.zimbra@opinsys.fi>
 <1555471491.95357.1416817941257.JavaMail.zimbra@opinsys.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
In-Reply-To: <1555471491.95357.1416817941257.JavaMail.zimbra@opinsys.fi>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 24, 2014 at 08:32:21AM +0000, Tuomas Räsänen wrote:
> Hi
> 
> We have been experiencing quite regular umount failures on our NFS
> servers which are exporting EXT4 /home via exportfs.
> 
> Servers are running kernels from mainline 3.10-series.
> 
> Both the reproduction steps and symptoms are almost indentical to what
> was reported in https://lkml.org/lkml/2013/8/11/26 by Toralf Förster.
> 
> The steps to reproduce:
>   1. export EXT4 /home via exportfs
>   2. let clients work on /home
>   3. shutdown clients
>   4. service nfs-kernel-server stop
>   5. umount /home
> 
> Umount causes the following BUG trace:
> 
> [685206.207459] Call Trace:
> [685206.208356]  [<ffffffff811a2482>] generic_shutdown_super+0x62/0xf0
> [685206.209264]  [<ffffffff811a2540>] kill_block_super+0x30/0x80
> [685206.210179]  [<ffffffff811a2dcd>] deactivate_locked_super+0x4d/0x80
> [685206.211115]  [<ffffffff811a344e>] deactivate_super+0x4e/0x70
> [685206.212039]  [<ffffffff811beed6>] mntput_no_expire+0x106/0x160
> [685206.212964]  [<ffffffff811c07e9>] SyS_umount+0xa9/0xf0
> [685206.213895]  [<ffffffff8170fc6f>] tracesys+0xe1/0xe6
> [685206.214838] Code: 81 49 8b 57 78 48 81 c6 20 03 00 00 89 04 24 31 c0 e8 c5 3f 49 00 4d 8b 3f 4d 39 fe 75 c4 4c 39 b3 00 02 00 00 0f 84 97 fe ff ff <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 
> [685206.216885] RIP  [<ffffffff81259782>] ext4_put_super+0x342/0x350
> [685206.217913]  RSP <ffff8807d3f7fe28>
> 
> The trace is preceded by dumped orphan list info.
> 
> The most annoying thing is that in practice, it happens when the server
> is rebooted normally, causing the reboot to stall (services have alredy
> been shutdown at this point so the remote connection is closed as well).
> 
> I tried the following patch (which landed on mainline in 3.11):
> 
> commit bf7bd3e98be5c74813bee6ad496139fb0a011b3b
> Author: J. Bruce Fields <bfields@redhat.com>
> Date:   Thu Aug 15 16:55:26 2013 -0400
> 
>     nfsd4: fix leak of inode reference on delegation failure
> 
> The patch didn't apply cleanly on top of 3.10.58 but I think I got the
> few conflicts right and it seems to have fixed the issue.
> 
> Is there any particular reason why the patch has not been included in
> 3.10 stable -series?

Probably not.  Could you send your fixed-up version to
stable@vger.kernel.org, with a cc: to me and to
linux-nfs@vger.kernel.org?

You could also add to the changelog a note about the conflicts you had
to fix up, if that looks like it would e helpful.

--b.
