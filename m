Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from linear.rut.org ([199.125.85.39]:56780 "EHLO linear.rut.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757286Ab0D1WXk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 18:23:40 -0400
Date: Wed, 28 Apr 2010 18:23:39 -0400
From: Robert Henney <robh@rut.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NULL pointer dereference in 2.6.32.12 on mount attempt
Message-ID: <20100428222339.GA3490@rut.org>
References: <20100428191758.GA16717@rut.org> <1272486263.2864.57.camel@localhost.localdomain>
Content-Type: multipart/mixed; boundary="sdtB3X0nJg68CQEu"
In-Reply-To: <1272486263.2864.57.camel@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Apr 28, 2010 at 04:24:23PM -0400, Trond Myklebust wrote:
> On Wed, 2010-04-28 at 15:17 -0400, Robert Henney wrote: 

> > /etc/exports on the server, possibly bogus although the server never
> > complains and still probably shouldn't trigger a NULL dereference in 
> > the client:
> >   /stow *(ro,fsid=0,crossmnt,no_subtree_check)
> >   /stow -mp,ro,all_squash,async,no_subtree_check \
> >     199.125.85.51  \
> >     199.125.85.134 \
> >     66.55.209.223
> 
> You probably want to add at least a 'fsid=0' option to that second line.
>
> > /etc/fstab on the client:
> >   199.125.85.39:/stow /stow nfs4 noatime
> 
> Should be
> 
> 199.125.85.39:/ /stow nfs4

if I correct both of the above as you say, then it works.  :)

I should mention though that occasionally when reproducing the bug on 
the client it caused the server kernel (debian lenny
linux-image-2.6.26-2-686) to report its own kernel bug and nfsd on the
server became hosed and unusable for all clients until the server was
rebooted.  kern.log output attached.

since I can only reproduce the kernel bugs using a "wrong" exports
file, I'm not sure how critical they are anymore.

> > the mount command never outputs but has a return code of 2 and the mount
> > is not successful.
> 
> That looks like a stack overflow to me, but it's hard to tell.
> 
> What happens if you do
> 
> echo 1025 > /proc/sys/sunrpc/nfs_debug
> 
> prior to trying the mount?

the client becomes slow enough to be unusable after the value of nfs_debug
is changed to 1025, which is probably due to it being a diskless client.  
although the root filesystem is not the mount causing the issue, I can
try and get a dedicated test machine set up soon to aid further testing.

--sdtB3X0nJg68CQEu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="server_kern.log"

Apr 28 16:28:56 linear kernel: ------------[ cut here ]------------
Apr 28 16:28:56 linear kernel: kernel BUG at include/linux/module.h:386!
Apr 28 16:28:56 linear kernel: invalid opcode: 0000 [#1] SMP 
Apr 28 16:28:56 linear kernel: Modules linked in: nbd nfsd auth_rpcgss exportfs nfs lockd nfs_acl sunrpc ipt_REJECT nf_conntrack_ipv4 xt_connlimit nf_conntrack xt_tcpudp iptable_filter ip_tables x_tables ipv6 jfs nls_base w83781d hwmon_vid loop snd_pcm snd_timer snd soundcore snd_page_alloc serio_raw psmouse pcspkr i2c_viapro button i2c_core via686a shpchp pci_hotplug parport_pc parport via_agp agpgart evdev ext3 jbd mbcache raid1 md_mod ide_disk sd_mod floppy pdc202xx_old sata_sil24 8139too mii uhci_hcd usbcore ata_generic libata scsi_mod dock ide_pci_generic via82cxxx ide_core thermal processor fan thermal_sys [last unloaded: nbd]
Apr 28 16:28:56 linear kernel:
Apr 28 16:28:56 linear kernel: Pid: 1372, comm: nfsd Not tainted (2.6.26-2-686 #1)
Apr 28 16:28:56 linear kernel: EIP: 0060:[<e0d4c49f>] EFLAGS: 00010246 CPU: 0
Apr 28 16:28:56 linear kernel: EIP is at svc_recv+0x38d/0x64a [sunrpc]
Apr 28 16:28:56 linear kernel: EAX: 00000000 EBX: e0d5fd40 ECX: e0d5fd40 EDX: 00000100
Apr 28 16:28:56 linear kernel: ESI: de4c6200 EDI: c1879f9c EBP: de40d000 ESP: c1879f8c
Apr 28 16:28:56 linear kernel: DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
Apr 28 16:28:56 linear kernel: Process nfsd (pid: 1372, ti=c1878000 task=ded095e0 task.ti=c1878000)
Apr 28 16:28:56 linear kernel: Stack: 000dbba0 d49d6800 de7e2de0 d9cd8960 00000000 ded095e0 c011b6fc 00100100 
Apr 28 16:28:56 linear kernel:       00200200 00000000 204b7b32 00000000 de40d000 e0d9b696 fffffeff ffffffff 
Apr 28 16:28:56 linear kernel:       fffffef8 ffffffff e0d9b5c0 00000000 00000000 00000000 c01044f7 de40d000 
Apr 28 16:28:56 linear kernel: Call Trace:
Apr 28 16:28:56 linear kernel: [<c011b6fc>] default_wake_function+0x0/0x8
Apr 28 16:28:56 linear kernel: [<e0d9b696>] nfsd+0xd6/0x268 [nfsd]
Apr 28 16:28:56 linear kernel: [<e0d9b5c0>] nfsd+0x0/0x268 [nfsd]
Apr 28 16:28:56 linear kernel: [<c01044f7>] kernel_thread_helper+0x7/0x10
Apr 28 16:28:56 linear kernel: =======================
Apr 28 16:28:56 linear kernel: Code: 01 00 00 8b 44 24 04 8b 50 04 ff 52 04 85 c0 89 c6 0f 84 25 01 00 00 8b 00 8b 58 04 85 db 74 1f 89 d8 e8 78 0a 3f df 85 c0 75 04 <0f> 0b eb fe 64 a1 04 40 3b c0 c1 e0 05 ff 84 18 00 01 00 00 8b 
Apr 28 16:28:56 linear kernel: EIP: [<e0d4c49f>] svc_recv+0x38d/0x64a [sunrpc] SS:ESP 0068:c1879f8c
Apr 28 16:28:56 linear kernel: ---[ end trace 9ac34e4b66bab117 ]---

--sdtB3X0nJg68CQEu--
