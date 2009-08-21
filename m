From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux-next: noot failure for next-20090820
Date: Thu, 20 Aug 2009 22:30:46 -0400
Message-ID: <1250821846.6514.23.camel@heimdal.trondhjem.org>
References: <20090821094226.286faa67.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>,
	"Dr. J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090821094226.286faa67.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 09:42 +1000, Stephen Rothwell wrote:
> Hi Trond,
> 
> Booting next-20090820 on three different PowerPC machines get the
> following OOPS:
> 
> calling  .init_nfs_fs+0x0/0x184 @ 1
> Unable to handle kernel paging request for data at address 0x00000000
> Faulting instruction address: 0xc00000000013be00
> Oops: Kernel access of bad area, sig: 11 [#1]
> SMP NR_CPUS=128 NUMA pSeries
> Modules linked in:
> NIP: c00000000013be00 LR: c00000000013bd00 CTR: c00000000056f098
> REGS: c00000007d2db5c0 TRAP: 0300   Not tainted  (2.6.31-rc6-autokern1)
> MSR: 8000000000009032 <EE,ME,IR,DR>  CR: 48000028  XER: 00000005
> DAR: 0000000000000000, DSISR: 0000000040000000
> TASK = c0000000410ca000[1] 'swapper' THREAD: c00000007d2d8000 CPU: 1
> GPR00: c00000000013bd00 c00000007d2db840 c000000000b84e98 0000000000000001 
> GPR04: c000000000a831e8 c0000000410ca948 0000000000000002 c0000000410ca948 
> GPR08: 0000000000000025 0000000000000000 ef7bdef7bdef7bdf 0000000009ac4000 
> GPR12: 0000000088000084 c000000000bd4400 0000000000000000 0000000003000000 
> GPR16: c000000000720608 c00000000071ed80 0000000000000000 00000000003e7800 
> GPR20: 000000000382de28 c00000000082de28 000000000382e098 c00000000082e098 
> GPR24: 0000000000000000 c000000000b25c58 c000000000b25c40 c000000000ac9d18 
> GPR28: c000000000b7ba40 fffffffffffffe10 c000000000ae5e70 0000000000000000 
> NIP [c00000000013be00] .sget+0x14c/0x418
> LR [c00000000013bd00] .sget+0x4c/0x418
> Call Trace:
> [c00000007d2db840] [c00000000013bd00] .sget+0x4c/0x418 (unreliable)
> [c00000007d2db8f0] [c00000000013cca8] .get_sb_single+0x4c/0x114
> [c00000007d2db9a0] [c00000000056f0b8] .rpc_get_sb+0x20/0x38
> [c00000007d2dba20] [c00000000013c54c] .vfs_kern_mount+0x80/0xf8
> [c00000007d2dbac0] [c00000000015d434] .simple_pin_fs+0x74/0x130
> [c00000007d2dbb60] [c000000000570734] .rpc_get_mount+0x2c/0x54
> [c00000007d2dbbe0] [c00000000023ffec] .nfs_cache_register+0x28/0xc0
> [c00000007d2dbd10] [c00000000023fa78] .nfs_dns_resolver_init+0x1c/0x34
> [c00000007d2dbd90] [c000000000813fac] .init_nfs_fs+0x1c/0x184
> [c00000007d2dbe10] [c0000000000094bc] .do_one_initcall+0x90/0x1b0
> [c00000007d2dbf00] [c0000000007f3c98] .kernel_init+0x1f4/0x270
> [c00000007d2dbf90] [c0000000000268f0] .kernel_thread+0x54/0x70
> Instruction dump:
> 48445fad 60000000 387d0070 4bf4f7a9 60000000 7fa3eb78 4bfff911 48442e89 
> 60000000 4bffff04 e93d01f0 3ba9fe10 <e81d01f0> 2fa00000 419e0008 7c00022c 
> ---[ end trace 561bb236c800851f ]---
> Kernel panic - not syncing: Attempted to kill init!
> Call Trace:
> [c00000007d2db220] [c000000000010228] .show_stack+0x70/0x184 (unreliable)
> [c00000007d2db2d0] [c000000000067c40] .panic+0x80/0x1b4
> [c00000007d2db370] [c00000000006c3cc] .do_exit+0x84/0x6fc
> [c00000007d2db430] [c000000000024950] .die+0x24c/0x27c
> [c00000007d2db4d0] [c0000000000328e0] .bad_page_fault+0xb8/0xd4
> [c00000007d2db550] [c0000000000051dc] handle_page_fault+0x3c/0x74
> --- Exception: 300 at .sget+0x14c/0x418
>     LR = .sget+0x4c/0x418
> [c00000007d2db8f0] [c00000000013cca8] .get_sb_single+0x4c/0x114
> [c00000007d2db9a0] [c00000000056f0b8] .rpc_get_sb+0x20/0x38
> [c00000007d2dba20] [c00000000013c54c] .vfs_kern_mount+0x80/0xf8
> [c00000007d2dbac0] [c00000000015d434] .simple_pin_fs+0x74/0x130
> [c00000007d2dbb60] [c000000000570734] .rpc_get_mount+0x2c/0x54
> [c00000007d2dbbe0] [c00000000023ffec] .nfs_cache_register+0x28/0xc0
> [c00000007d2dbd10] [c00000000023fa78] .nfs_dns_resolver_init+0x1c/0x34
> [c00000007d2dbd90] [c000000000813fac] .init_nfs_fs+0x1c/0x184
> [c00000007d2dbe10] [c0000000000094bc] .do_one_initcall+0x90/0x1b0
> [c00000007d2dbf00] [c0000000007f3c98] .kernel_init+0x1f4/0x270
> [c00000007d2dbf90] [c0000000000268f0] .kernel_thread+0x54/0x70
> Rebooting in 180 seconds..-- 0:conmux-control -- time-stamp -- Aug/20/09 19:25:14 --
> 
> It may not be NFS changes ... there were just a few changes in the nfs
> tree between next-20090819 and next-20090820.
> 
Hi Stephen,

Yes, that sounds like the bug that Bruce hit earlier today. I strongly
suspect that it is due to the fact that you both compiled NFS+sunrpc
into the main kernel, and that the NFS init routine is being called
before the sunrpc init routine.

Could both you and Bruce check if the following patch fixes the problem?

Cheers
  Trond
----------------------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Ensure that sunrpc gets initialised before nfs, lockd, etc...

We can oops if rpc_pipefs isn't properly initialised before we start to set
up objects that depend upon it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/sunrpc_syms.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index adaa819..8cce921 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -69,5 +69,5 @@ cleanup_sunrpc(void)
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 MODULE_LICENSE("GPL");
-module_init(init_sunrpc);
+fs_initcall(init_sunrpc); /* Ensure we're initialised before nfs */
 module_exit(cleanup_sunrpc);
