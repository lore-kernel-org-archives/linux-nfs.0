From: Miklos Szeredi <miklos@szeredi.hu>
Subject: Re: [fuse-devel] Kernel panic on 2.6.27.9 when NFS exporting fuse
	filesystem
Date: Tue, 27 Jan 2009 20:48:41 +0100
Message-ID: <E1LRtvN-0003zf-8b@pomaz-ex.szeredi.hu>
References: <20090126225404.GA27937@jabberwocky.com>
Cc: fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org,
	Tom Tucker <tom@opengridcomputing.com>,
	"J. Bruce Fields" <bfields@fieldses.org>
To: dshaw-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fxip-0047f.externet.hu ([88.209.222.127]:38696 "EHLO
	pomaz-ex.szeredi.hu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755353AbZA0Tsv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jan 2009 14:48:51 -0500
In-reply-to: <20090126225404.GA27937-wh+mT2OhP0WF0gnf/s2wvA@public.gmane.org> (message from David Shaw
	on Mon, 26 Jan 2009 17:54:04 -0500)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[Forwarding to linux-nfs@ and sunrpc maintainers]

On Mon, 26 Jan 2009, David Shaw wrote:
> Hello,
> 
> This is reasonably repeatable (i.e. not 100%, but certainly more than
> 25%).  The kernel is 2.6.27.9-159.fc10.i686.PAE (this is the most
> recent Fedora 10 PAE kernel), and we're using fuse-2.8.0pre2 on the
> userspace side.  We are NFS-exporting the fuse filesystem.  The
> machine in question is a dual core Pentium D 2.8ghz with 4g of RAM.

Can you try to reproduce this on a vanilla kernel, to exclude the
possibility of a fedora patch being the culprit?

> Occasionally, we get a sudden reboot.  After attaching a serial cable,
> we found this.  It doesn't look directly fuse related from the
> backtrace, but then again, we're not seeing any problems exporting a
> regular (non-fuse) filesystem.
> 
> Any thoughts?

The BUG triggers in this __module_get() in svc_recv():

			/*
			 * We know this module_get will succeed because the
			 * listener holds a reference too
			 */
			__module_get(newxpt->xpt_class->xcl_owner);

Either the comment is wrong or something got corrupted.

Tom, Bruce, any idea what could be causing this?  It doesn't really
look fuse related.

Thanks,
Miklos

> 
> kernel BUG at include/linux/module.h:390!
> invalid opcode: 0000 [#1] SMP 
> Modules linked in: nfsd lockd nfs_acl auth_rpcgss sunrpc exportfs ipt_REDIRECT fuse ipmi_devintf ipmi_si ipmi_msghandler ipv6 iptable_nat nf_nat dm_multipath tg3 i2c_i801 libphy i3000_edac iTCO_wdt iTCO_vendor_support edac_core serio_raw pcspkr dcdbas ata_generic pata_acpi radeon drm i2c_algo_bit i2c_core [last unloaded: scsi_wait_scan]
> 
> Pid: 25841, comm: nfsd Not tainted (2.6.27.9-159.fc10.i686.PAE #1)
> EIP: 0060:[<f8b02cc4>] EFLAGS: 00010246 CPU: 0
> EIP is at svc_recv+0x3a4/0x6c6 [sunrpc]
> EAX: 00000000 EBX: f8b13500 ECX: f8b13500 EDX: 00001000
> ESI: f78b7d90 EDI: f35ea600 EBP: f21c8fbc ESP: f21c8f74
>  DS: 007b ES: 007b FS: 00d8 GS: 0000 SS: 0068
> Process nfsd (pid: 25841, ti=f21c8000 task=f4598000 task.ti=f21c8000)
> Stack: c0893c80 0036ee80 f78b7000 f2549c04 f35ea61c f2549b80 f2549c00 f40a9600 
>        f78b7000 f8bb1622 00000000 f4598000 c042d0f3 00100100 00200200 f3486b00 
>        00000000 f78b7000 f21c8fd0 f8bb16e5 f78b7000 f8bb1622 00000000 f21c8fe0 
> Call Trace:
>  [<f8bb1622>] ? nfsd+0x0/0x167 [nfsd]
>  [<c042d0f3>] ? default_wake_function+0x0/0xd
>  [<f8bb16e5>] ? nfsd+0xc3/0x167 [nfsd]
>  [<f8bb1622>] ? nfsd+0x0/0x167 [nfsd]
>  [<c0443973>] ? kthread+0x3b/0x61
>  [<c0443938>] ? kthread+0x0/0x61
>  [<c04098f7>] ? kernel_thread_helper+0x7/0x10
>  =======================
> Code: 30 01 00 00 8b 57 04 89 f8 ff 52 04 85 c0 89 45 d4 0f 84 11 01 00 00 8b 00 8b 58 04 85 db 74 1f 89 d8 e8 56 d7 94 c7 85 c0 75 04 <0f> 0b eb fe 64 a1 04 c0 88 c0 c1 e0 07 ff 84 03 80 01 00 00 8b 
> EIP: [<f8b02cc4>] svc_recv+0x3a4/0x6c6 [sunrpc] SS:ESP 0068:f21c8f74
> Kernel panic - not syncing: Fatal exception
> 
> Thanks,
> 
> David
> 
> ------------------------------------------------------------------------------
> This SF.net email is sponsored by:
> SourcForge Community
> SourceForge wants to tell your story.
> http://p.sf.net/sfu/sf-spreadtheword
> _______________________________________________
> fuse-devel mailing list
> fuse-devel@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/fuse-devel
> 
