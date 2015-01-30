Return-Path: linux-kernel-owner@vger.kernel.org
From: Nix <nix@esperi.org.uk>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: 3.18.x: the return of the NFSv3 client BUG on reboot
Date: Fri, 30 Jan 2015 21:17:14 +0000
Message-ID: <871tmcarz9.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm seeing these BUGs, fairly reliably, on multiple NFSv3 clients (x86
and x86-64) as of 3.18. As with the bug a few months ago, it seems to be
a side effect of trying to create a new client while shutting everything
down:

[  567.092093] BUG: unable to handle kernel NULL pointer dereference at 00000004
[  567.100044] IP: [<c034fbc0>] rpc_new_client+0x13b/0x1f2
[  567.100044] *pde = 00000000
[  567.100044] Oops: 0000 [#1]
[  567.100044] CPU: 0 PID: 521 Comm: su Not tainted 3.18.5+ #1
[  567.100044] task: de28cfc0 ti: de2ba000 task.ti: de2ba000
[  567.100044] EIP: 0060:[<c034fbc0>] EFLAGS: 00010246 CPU: 0
[  567.100044] EIP is at rpc_new_client+0x13b/0x1f2
[  567.100044] EAX: 00000000 EBX: c000c800 ECX: 0000bae0 EDX: 00000005
[  567.100044] ESI: 00000000 EDI: de2ea800 EBP: 00000007 ESP: de2bbcac
[  567.100044]  DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
[  567.100044] CR0: 8005003b CR2: 00000004 CR3: 1f63b000 CR4: 00000090
[  567.100044] Stack:
[  567.100044]  000000d0 de2ea800 de2bbd4c 00000000 de2bbd4c de2bbd4c de2bbd10 de2bbf8c
[  567.100044]  c03501ca de2bbd4c df57a940 de2bbd10 c0350334 00000010 c0451150 000280da
[  567.100044]  00000002 00000006 c044b178 00000000 de2bbddc 00000010 df57a940 00000000
[  567.100044] Call Trace:
[  567.100044]  [<c03501ca>] ? rpc_create_xprt+0xc/0x74
[  567.100044]  [<c0350334>] ? rpc_create+0x102/0x10f
[  567.100044]  [<c019ec6a>] ? __block_commit_write.isra.25+0x56/0x7f
[  567.100044]  [<c0359f38>] ? rpcb_create+0x6e/0x7c
[  567.100044]  [<c035a6ab>] ? rpcb_getport_async+0x124/0x25a
[  567.100044]  [<c0133bdf>] ? update_curr+0x81/0xb3
[  567.100044]  [<c0133e97>] ? check_preempt_wakeup+0xf0/0x134
[  567.100044]  [<c013110f>] ? check_preempt_curr+0x21/0x59
[  567.100044]  [<c03552c8>] ? rpcauth_lookupcred+0x3f/0x47
[  567.100044]  [<c017ebb6>] ? __kmalloc+0xa3/0xc4
[  567.100044]  [<c0354c3d>] ? rpc_malloc+0x39/0x48
[  567.100044]  [<c034ef39>] ? call_bind+0x2d/0x2e
[  567.100044]  [<c0354aa5>] ? __rpc_execute+0x5c/0x187
[  567.100044]  [<c03500f2>] ? rpc_run_task+0x55/0x5a
[  567.100044]  [<c0350160>] ? rpc_call_sync+0x69/0x81
[  567.100044]  [<c01e219e>] ? nsm_mon_unmon+0x8c/0xa0
[  567.100044]  [<c01e23c5>] ? nsm_unmonitor+0x5f/0xd3
[  567.100044]  [<c016b3cc>] ? bdi_unregister+0xf2/0x100
[  567.100044]  [<c01df4cc>] ? nlm_destroy_host_locked+0x4f/0x7c
[  567.100044]  [<c01df703>] ? nlmclnt_release_host+0xd8/0xe5
[  567.100044]  [<c01dddd5>] ? nlmclnt_done+0xc/0x14
[  567.100044]  [<c01ce621>] ? nfs_free_server+0x16/0x72
[  567.100044]  [<c01837a4>] ? deactivate_locked_super+0x26/0x37
[  567.100044]  [<c019493e>] ? cleanup_mnt+0x40/0x59
[  567.100044]  [<c012e185>] ? task_work_run+0x4f/0x5f
[  567.100044]  [<c0121373>] ? do_exit+0x264/0x670
[  567.100044]  [<c0182848>] ? vfs_write+0x98/0x151
[  567.100044]  [<c01829c4>] ? SyS_write+0x41/0x82
[  567.100044]  [<c01217cc>] ? do_group_exit+0x2b/0x5d
[  567.100044]  [<c012180d>] ? SyS_exit_group+0xf/0xf
[  567.100044]  [<c03679f6>] ? syscall_call+0x7/0x7
[  567.100044] Code: 89 43 40 8b 44 24 04 89 43 18 8d 43 78 8b 53 40 89 43 3c 8b 12 e8 32 ac 00 00 c7 03 01 00 00 00 a1 dc f0 42 c0 8b 80 00 03 00 00 <8b> 70 04 83 c6 45 89 f0 e8 77 d1 eb ff 83 f8 20 7f 05 89 43 44
[  567.100044] EIP: [<c034fbc0>] rpc_new_client+0x13b/0x1f2 SS:ESP 0068:de2bbcac
[  567.100044] CR2: 0000000000000004
[  567.100044] ---[ end trace 9d49b8a60cfa6a52 ]---
[  567.100044] Kernel panic - not syncing: Fatal exception
[  567.100044] Kernel Offset: 0x0 from 0xc0100000 (relocation range: 0xc0000000-0xe07fffff)
[  567.100044] Rebooting in 5 seconds..

Notably, these only seem to happen after at least one instance of the
dreaded, frequently-occurring but normally harmless

[  101.019879] xprt_adjust_timeout: rq_timeout = 0!
[  101.047744] lockd: server spindle.srvr.nix not responding, still trying

(i.e. if you manage to reboot before one of these happens -- as happened
recently when I was bisecting another problem -- you don't seem to get a
panic).

NFS-related .config options:

CONFIG_NFS_FS=y
# CONFIG_NFS_V2 is not set
CONFIG_NFS_V3=y
CONFIG_NFS_V3_ACL=y
CONFIG_NFS_V4=y
# CONFIG_NFS_SWAP is not set
# CONFIG_NFS_V4_1 is not set
# CONFIG_NFS_USE_LEGACY_DNS is not set
CONFIG_NFS_USE_KERNEL_DNS=y
CONFIG_NFSD=y
CONFIG_NFSD_V2_ACL=y
CONFIG_NFSD_V3=y
CONFIG_NFSD_V3_ACL=y
# CONFIG_NFSD_V4 is not set
CONFIG_GRACE_PERIOD=y
CONFIG_LOCKD=y
CONFIG_LOCKD_V4=y
CONFIG_NFS_ACL_SUPPORT=y
CONFIG_NFS_COMMON=y
CONFIG_SUNRPC=y
CONFIG_SUNRPC_GSS=y

If there's any more info I can provide, just ask. I can reproduce this
one quite fast and I have a box I can test on easily (it's my firewall
so I'm knocked off the net every time I do it, but it's not doing many
other jobs and I can reboot it without losing any state to speak of).
