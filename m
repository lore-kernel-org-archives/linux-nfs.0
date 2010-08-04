Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from www262.sakura.ne.jp ([202.181.97.72]:52915 "EHLO
	www262.sakura.ne.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757881Ab0HDAOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Aug 2010 20:14:09 -0400
Message-Id: <201008040013.o740DmYK024832@www262.sakura.ne.jp>
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Date: Wed, 04 Aug 2010 09:13:48 +0900
References: <201008020747.o727lqXs064715@www262.sakura.ne.jp> <20100802103214.7eea09eb@corrin.poochiereds.net> <20100802103620.5638dac1@corrin.poochiereds.net> <20100802181634.GD12637@fieldses.org> <201008030109.o73193bp094241@www262.sakura.ne.jp> <20100803154851.GA23467@fieldses.org>
In-Reply-To: <20100803154851.GA23467@fieldses.org>
Content-Type: text/plain; charset="ISO-2022-JP"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> How about this?

After reverting commit 86d0cc3b91315c475c1c38ee7a06b5ebe5c01755 and applying
commit 3deb279d6e5625407919a875db3a2461199566b3, I get below NULL pointer
dereference problem when doing "mount 127.0.0.1:/usr/src/ /mnt/".

[   96.398495] BUG: unable to handle kernel NULL pointer dereference at 00000010
[   96.400348] IP: [<c1356dd4>] svc_process_common+0x2c4/0x5c0
[   96.401606] *pde = 00000000 
[   96.401606] Oops: 0002 [#1] SMP DEBUG_PAGEALLOC
[   96.401606] last sysfs file: /sys/devices/pci0000:00/0000:00:10.0/host0/target0:0:1/0:0:1:0/type
[   96.401606] Modules linked in: nfs ipv6 pcnet32
[   96.401606] 
[   96.401606] Pid: 2623, comm: nfsd Tainted: G        W   2.6.35-next-20100802 #4 440BX Desktop Reference Platform/VMware Virtual Platform
[   96.401606] EIP: 0060:[<c1356dd4>] EFLAGS: 00010246 CPU: 1
[   96.401606] EIP is at svc_process_common+0x2c4/0x5c0
[   96.401606] EAX: 00000000 EBX: dfb8b0c8 ECX: 00000001 EDX: 00000004
[   96.401606] ESI: dfb8b0f0 EDI: 00000010 EBP: dcac4f40 ESP: dcac4ef0
[   96.401606]  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
[   96.401606] Process nfsd (pid: 2623, ti=dcac4000 task=dc85a7b0 task.ti=dcac4000)
[   96.401606] Stack:
[   96.401606]  dc85a7b0 00000002 00000000 dc85ac5c dc85a7b0 dcac4f28 00000004 00000000
[   96.401606] <0> 00000002 000186a3 dcb6c008 dcb6c014 dc805f30 c154ca20 c154cca8 dfb8b000
[   96.401606] <0> 01000000 8c4194fd dfb8b000 dfb8b0c8 dcac4f68 c13571cf dcac4f68 c105d087
[   96.401606] Call Trace:
[   96.401606]  [<c13571cf>] ? svc_process+0xff/0x110
[   96.401606]  [<c105d087>] ? __validate_process_creds+0x47/0xd0
[   96.401606]  [<c1145739>] ? nfsd+0xc9/0x160
[   96.401606]  [<c1035f86>] ? complete+0x46/0x60
[   96.401606]  [<c1055d05>] ? kthread+0x75/0x80
[   96.401606]  [<c1145670>] ? nfsd+0x0/0x160
[   96.401606]  [<c1055c90>] ? kthread+0x0/0x80
[   96.401606]  [<c100317a>] ? kernel_thread_helper+0x6/0x1c
[   96.401606] Code: 4d dc c7 01 00 00 00 00 8b 55 e4 83 46 04 04 8b 42 10 ff 42 18 8b 4d ec 8b b9 6c 0d 00 00 89 45 c8 89 c1 c1 e9 02 31 c0 8b 55 c8 <f3> ab f6 c2 02 74 02 66 ab f6 c2 01 74 01 aa 8b 45 e4 8b 4d ec 
[   96.401606] EIP: [<c1356dd4>] svc_process_common+0x2c4/0x5c0 SS:ESP 0068:dcac4ef0
[   96.401606] CR2: 0000000000000010
[   96.527321] ---[ end trace 0de1e1ad73b15980 ]---

> (By the way, are you using something other than the standard
> /etc/init.d/nfs-kernel-server to start/stop the server?  Or have you
> customized your installation in any way?  Just curious, as the bugs
> you're finding are good, but I'd expect different symptoms from the
> default setup.)
I'm using standard /etc/init.d/nfs-kernel-server script installed by Debian
Sarge and using it without modification.

# ls -l /etc/init.d/nfs-*
-rwxr-xr-x  1 root root 1984 Jan  5  2005 /etc/init.d/nfs-common
-rwxr-xr-x  1 root root 2356 Aug  4  2003 /etc/init.d/nfs-kernel-server
-rwxr-xr-x  1 root root 1241 Jan 30  2006 /etc/init.d/nfs-user-server

Regards.
