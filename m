Return-Path: linux-nfs-owner@vger.kernel.org
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:53091 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753555AbaA3QIs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 11:08:48 -0500
Date: Thu, 30 Jan 2014 16:08:38 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
To: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        Gregory Clement <gregory.clement@free-electrons.com>
Subject: Re: Root NFS panicing on Linus' tip (Re: NFS client broken in
	Linus' tip)
Message-ID: <20140130160838.GC15937@n2100.arm.linux.org.uk>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk> <20140130151703.GA20594@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140130151703.GA20594@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 12:17:04PM -0300, Ezequiel Garcia wrote:
> Hi Russell, Trond:
> 
> On Thu, Jan 30, 2014 at 02:08:34PM +0000, Russell King - ARM Linux wrote:
> > I just booted Linus' tip (plus a few other patches to imx-drm and imx
> > code), and stumbled into this interesting scenario:
> > 
> [..]
> 
> > CONFIG_NFS_FS=y
> > CONFIG_NFS_V2=y
> > CONFIG_NFS_V3=y
> > CONFIG_NFS_V3_ACL=y
> 
> Just came across another issue, but a bit more problematic, as my
> kernel (Linus' tip as well) panics, after mounting the rootfs:
> 
> IP-Config: Complete:
>      device=eth0, hwaddr=00:50:43:50:1c:15, ipaddr=192.168.0.159, mask=255.255.255.0, gw=192.168.0.1
>      host=develboard, domain=, nis-domain=(none)
>      bootserver=192.168.0.45, rootserver=192.168.0.45, rootpath=
> VFS: Mounted root (nfs filesystem) on device 0:11.
> devtmpfs: mounted
> Freeing unused kernel memory: 136K (c0465000 - c0487000)
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> pgd = c0004000
> [00000000] *pgd=00000000
> Internal error: Oops: 5 [#1] ARM
> Modules linked in:
> CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.13.0-10094-g9b0cd30 #276
> task: ed839a40 ti: ed83a000 task.ti: ed83a000
> PC is at xattr_resolve_name+0x14/0x94
> LR is at generic_getxattr+0x2c/0x64
> pc : [<c00a7ab0>]    lr : [<c00a7b5c>]    psr: a0000113
> sp : ed83be5c  ip : ed83be74  fp : ed10ebc0
> r10: ed83a000  r9 : ed43d980  r8 : ed81b800
> r7 : c034dad8  r6 : 00000000  r5 : c03f3dcc  r4 : ed43d980
> r3 : 00000014  r2 : ed83be8c  r1 : ed83be74  r0 : 00000000
> Flags: NzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment kernel
> Control: 10c53c7d  Table: 00004059  DAC: 00000015
> Process swapper (pid: 1, stack limit = 0xed83a238)
> Stack: (0xed83be5c to 0xed83c000)
> be40:                                                                ed43d980
> be60: 00000014 ed83be8c 00000000 00000000 c04bc22c c03f3dcc ed83bf14 ed43f340
> be80: ed43d980 c01115cc 00000000 00000041 c04bba6c 00000000 00000000 002040d0
> bea0: ed81bc00 ed10ebc0 ed81bc30 c01116f8 00000000 000004d0 ed8172d0 ed43d980
> bec0: 45878fd4 00000007 bfe01007 ef7f8fc0 c04bba6c ed43d6d8 c04bba6c 00000101
> bee0: 00000000 ed809fd0 ed809fc0 ed809f50 ed809f40 00000000 edb045d8 c0078bcc
> bf00: ed0e5dc0 edb045d8 00000000 bf000000 ed0e5dc0 00000000 00000000 00000000
> bf20: 00000000 00000000 bf000000 ed10ebc0 ed0e5dc0 00000001 edb045d8 c04926d0
> bf40: ed83a000 c0492758 ed10ebc0 c008fc54 00000001 ed0e5dc0 00000002 c0090cec
> bf60: c03ec85c ed0e5df4 00000000 ed839c00 c0487000 c04bcec0 c03e4f08 00000000
> bf80: 00000000 00000000 00000000 00000000 00000000 c00086a8 00000000 c04bcec0
> bfa0: c0344f5c c0345004 00000000 c000e398 00000000 00000000 00000000 00000000
> bfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
> bfe0: 00000000 00000000 00000000 00000000 00000013 00000000 00000000 00000000
> [<c00a7ab0>] (xattr_resolve_name) from [<00000000>] (  (null))
> Code: e1a06000 e5915000 e3550000 0a00001d (e5900000) 
> ---[ end trace 15c15b4afa9eff90 ]---
> swapper (1) used greatest stack depth: 5104 bytes left
> Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b
> 
> Adding a little hack, and could produce a better strack trace.
> See the diff and the stack trace below:
> 
> diff --git a/fs/xattr.c b/fs/xattr.c
> index 3377dff..bd2b173 100644
> --- a/fs/xattr.c
> +++ b/fs/xattr.c
> @@ -740,6 +740,10 @@ xattr_resolve_name(const struct xattr_handler **handlers, const char **name)
>  
>  	if (!*name)
>  		return NULL;
> +	if(!handlers) {
> +		dump_stack();
> +		panic("ouch");
> +	}
>  
>  	for_each_xattr_handler(handlers, handler) {
>  		const char *n = strcmp_prefix(*name, handler->prefix);
> 
> CPU: 0 PID: 1 Comm: swapper Tainted: G        W    3.13.0-10094-g9b0cd30-dirty #279
> [<c0012f40>] (unwind_backtrace) from [<c00107b8>] (show_stack+0x10/0x14)
> [<c00107b8>] (show_stack) from [<c00a8160>] (xattr_resolve_name+0x9c/0xa8)
> [<c00a8160>] (xattr_resolve_name) from [<c00a8274>] (generic_getxattr+0x2c/0x64)
> [<c00a8274>] (generic_getxattr) from [<c01115e0>] (get_vfs_caps_from_disk+0x4c/0xf4)
> [<c01115e0>] (get_vfs_caps_from_disk) from [<c011170c>] (cap_bprm_set_creds+0x84/0x408)
> [<c011170c>] (cap_bprm_set_creds) from [<c008fc54>] (prepare_binprm+0x80/0x11c)
> [<c008fc54>] (prepare_binprm) from [<c0090cec>] (do_execve+0x33c/0x46c)
> [<c0090cec>] (do_execve) from [<c00086a8>] (try_to_run_init_process+0x1c/0x50)
> [<c00086a8>] (try_to_run_init_process) from [<c0345024>] (kernel_init+0xa8/0x110)
> [<c0345024>] (kernel_init) from [<c000e398>] (ret_from_fork+0x14/0x3c)
> Kernel panic - not syncing: ouch
> 
> FWIW, here's my piece of NFS config:
> 
> CONFIG_NFS_FS=y
> CONFIG_NFS_V2=y
> CONFIG_NFS_V3=y
> # CONFIG_NFS_V3_ACL is not set
> # CONFIG_NFS_V4 is not set
> # CONFIG_NFS_SWAP is not set
> CONFIG_ROOT_NFS=y
> # CONFIG_NFSD is not set
> CONFIG_LOCKD=y
> CONFIG_LOCKD_V4=y
> CONFIG_NFS_COMMON=y
> CONFIG_SUNRPC=y
> 
> > I think it's down to this:
> > 
> > commit 013cdf1088d7235da9477a2375654921d9b9ba9f
> > Author: Christoph Hellwig <hch@infradead.org>
> > Date:   Fri Dec 20 05:16:53 2013 -0800
> > 
> >     nfs: use generic posix ACL infrastructure for v3 Posix ACLs
> > 
> >     This causes a small behaviour change in that we don't bother to set
> >     ACLs on file creation if the mode bit can express the access permissions
> >     fully, and thus behaving identical to local filesystems.
> > 
> >     Signed-off-by: Christoph Hellwig <hch@lst.de>
> >     Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
> 
> And also here, reverting the above seem to fix the panic.

Reverting this commit with NFS3 ACLs enabled also fixes the problems I
reported.

-- 
FTTC broadband for 0.8mile line: 5.8Mbps down 500kbps up.  Estimation
in database were 13.1 to 19Mbit for a good line, about 7.5+ for a bad.
Estimate before purchase was "up to 13.2Mbit".
