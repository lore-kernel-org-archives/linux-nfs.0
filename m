Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f179.google.com ([209.85.210.179]:57240 "EHLO
	mail-ia0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751448Ab3CBAIp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2013 19:08:45 -0500
MIME-Version: 1.0
In-Reply-To: <20130301003038.GA26533@redhat.com>
References: <20130301003038.GA26533@redhat.com>
Date: Fri, 1 Mar 2013 16:08:45 -0800
Message-ID: <CAE9FiQVNUJaWKJfsv=xzrTLTfeosjNVFJ7sNnYu0dTM7QSDhfA@mail.gmail.com>
Subject: Re: lockdep trace from nfsd
From: Yinghai Lu <yinghai@kernel.org>
To: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>,
        bfields@fieldses.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 28, 2013 at 4:30 PM, Dave Jones <davej@redhat.com> wrote:
> [   39.878535] =====================================
> [   39.879670] [ BUG: rpc.nfsd/666 still has locks held! ]
> [   39.880871] 3.8.0+ #3 Not tainted
> [   39.881858] -------------------------------------
> [   39.882850] 2 locks on stack by rpc.nfsd/666:
> [   39.883868]  #0: held:     (nfsd_mutex){+.+.+.}, instance: ffffffffa01cf0b8, at: [<ffffffffa0193d57>] write_ports+0x37/0x7a0 [nfsd]
> [   39.884750]  #1: held:     (rpcb_create_local_mutex){+.+.+.}, instance: ffffffffa016d878, at: [<ffffffffa0153916>] rpcb_create_local+0x46/0x90 [sunrpc]
> [   39.885903]
> stack backtrace:
> [   39.897044] Pid: 666, comm: rpc.nfsd Not tainted 3.8.0+ #3
> [   39.898186] Call Trace:
> [   39.900755]  [<ffffffff810b9c6a>] debug_check_no_locks_held+0x9a/0xa0
> [   39.901823]  [<ffffffffa0145965>] rpc_wait_bit_killable+0x85/0xb0 [sunrpc]
> [   39.902866]  [<ffffffff8161bf10>] __wait_on_bit+0x60/0x90
> [   39.903879]  [<ffffffffa0147860>] ? __rpc_execute+0x170/0x5a0 [sunrpc]
> [   39.904900]  [<ffffffffa01458e0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
> [   39.905969]  [<ffffffff8161bfbc>] out_of_line_wait_on_bit+0x7c/0x90
> [   39.907010]  [<ffffffffa0147860>] ? __rpc_execute+0x170/0x5a0 [sunrpc]
> [   39.908070]  [<ffffffff81075f00>] ? autoremove_wake_function+0x50/0x50
> [   39.909124]  [<ffffffffa0139b50>] ? call_connect+0xa0/0xa0 [sunrpc]
> [   39.910154]  [<ffffffffa0147891>] __rpc_execute+0x1a1/0x5a0 [sunrpc]
> [   39.911176]  [<ffffffff81075e9e>] ? wake_up_bit+0x2e/0x40
> [   39.912058]  [<ffffffffa0147d49>] rpc_execute+0x59/0x180 [sunrpc]
> [   39.912745]  [<ffffffffa013da00>] rpc_run_task+0x70/0x90 [sunrpc]
> [   39.913446]  [<ffffffffa013db23>] rpc_call_sync+0x43/0xa0 [sunrpc]
> [   39.914280]  [<ffffffffa013dbd2>] rpc_ping+0x52/0x70 [sunrpc]
> [   39.914992]  [<ffffffffa013de08>] rpc_create+0x188/0x230 [sunrpc]
> [   39.915735]  [<ffffffff8100a4a9>] ? sched_clock+0x9/0x10
> [   39.916577]  [<ffffffff810b807e>] ? put_lock_stats.isra.25+0xe/0x40
> [   39.917635]  [<ffffffff810b871c>] ? lock_release_holdtime.part.26+0xcc/0x140
> [   39.918667]  [<ffffffffa015331c>] rpcb_create_local_unix+0x5c/0xe0 [sunrpc]
> [   39.919669]  [<ffffffffa0153948>] rpcb_create_local+0x78/0x90 [sunrpc]
> [   39.920705]  [<ffffffffa014a653>] svc_rpcb_setup+0x23/0x50 [sunrpc]
> [   39.921725]  [<ffffffffa014a6b4>] svc_bind+0x34/0x50 [sunrpc]
> [   39.921733]  [<ffffffffa01909ed>] nfsd_create_serv+0x1cd/0x320 [nfsd]
> [   39.921738]  [<ffffffffa0190825>] ? nfsd_create_serv+0x5/0x320 [nfsd]
> [   39.921742]  [<ffffffffa019424a>] write_ports+0x52a/0x7a0 [nfsd]
> [   39.921746]  [<ffffffffa0194138>] ? write_ports+0x418/0x7a0 [nfsd]
> [   39.921750]  [<ffffffff816203c5>] ? _raw_spin_unlock+0x35/0x60
> [   39.921754]  [<ffffffff811de09a>] ? simple_transaction_get+0xca/0xe0
> [   39.921759]  [<ffffffffa0193d20>] ? write_maxblksize+0x2e0/0x2e0 [nfsd]
> [   39.921764]  [<ffffffffa0192367>] nfsctl_transaction_write+0x57/0x90 [nfsd]
> [   39.921768]  [<ffffffff811b45ff>] vfs_write+0xaf/0x190
> [   39.921771]  [<ffffffff811b4955>] sys_write+0x55/0xa0
> [   39.921775]  [<ffffffff81628b99>] system_call_fastpath+0x16/0x1b
>


when try to mount nfs dir, got

[ 1341.534971] INFO: trying to register non-static key.
[ 1341.535279] the code is fine but needs lockdep annotation.
[ 1341.535599] turning off the locking correctness validator.
[ 1341.548353] Pid: 15681, comm: mount.nfs Not tainted
3.8.0-yh-07300-gdae94c7-dirty #1287
[ 1341.568229] Call Trace:
[ 1341.568356]  [<ffffffff81100d4d>] __lock_acquire+0x37d/0xc90
[ 1341.568673]  [<ffffffff810fb778>] ? trace_hardirqs_off_caller+0x28/0x160
[ 1341.588437]  [<ffffffff810668e5>] ? native_sched_clock+0x35/0x80
[ 1341.608187]  [<ffffffff81101c8a>] lock_acquire+0xaa/0x130
[ 1341.608460]  [<ffffffff810bcfa5>] ? flush_work+0x5/0x270
[ 1341.628195]  [<ffffffff810bcfec>] flush_work+0x4c/0x270
[ 1341.628468]  [<ffffffff810bcfa5>] ? flush_work+0x5/0x270
[ 1341.628729]  [<ffffffff810bd008>] ? flush_work+0x68/0x270
[ 1341.648425]  [<ffffffff810bcfa5>] ? flush_work+0x5/0x270
[ 1341.648696]  [<ffffffff810fed93>] ? mark_held_locks+0x123/0x140
[ 1341.668484]  [<ffffffff810be73d>] ? __cancel_work_timer+0x9d/0xe0
[ 1341.688225]  [<ffffffff810be750>] __cancel_work_timer+0xb0/0xe0
[ 1341.688515]  [<ffffffff810be793>] cancel_delayed_work_sync+0x13/0x20
[ 1341.708312]  [<ffffffff8208200f>] xs_destroy+0x3f/0x90
[ 1341.708587]  [<ffffffff8207ec8e>] xprt_destroy+0x8e/0xa0
[ 1341.728280]  [<ffffffff82080de8>] xprt_put+0x18/0x20
[ 1341.728540]  [<ffffffff8207ddf4>] rpc_free_client+0x164/0x180
[ 1341.748282]  [<ffffffff8207dd21>] ? rpc_free_client+0x91/0x180
[ 1341.748667]  [<ffffffff8207dc54>] rpc_release_client+0x74/0xb0
[ 1341.768339]  [<ffffffff8207df51>] rpc_shutdown_client+0x141/0x150
[ 1341.768706]  [<ffffffff8207e62d>] ? rpc_ping+0x5d/0x70
[ 1341.788331]  [<ffffffff8207e820>] rpc_create+0x150/0x200
[ 1341.788710]  [<ffffffff8209148f>] ? rpcb_get_local+0xbf/0xd0
[ 1341.808378]  [<ffffffff820914fc>] rpcb_create_local_unix+0x5c/0xf0
[ 1341.808792]  [<ffffffff82091800>] rpcb_create_local+0x50/0x80
[ 1341.828434]  [<ffffffff8208aef3>] svc_rpcb_setup+0x23/0x50
[ 1341.828791]  [<ffffffff8208af54>] svc_bind+0x34/0x50
[ 1341.848377]  [<ffffffff81373a62>] lockd_up+0x152/0x360
[ 1341.848698]  [<ffffffff813739d8>] ? lockd_up+0xc8/0x360
[ 1341.874014]  [<ffffffff8133a08b>] ? nfs_init_client+0x5b/0xb0
[ 1341.874415]  [<ffffffff8136f9f7>] nlmclnt_init+0x27/0x80
[ 1341.890014]  [<ffffffff81338e13>] nfs_start_lockd+0xa3/0xd0
[ 1341.890364]  [<ffffffff8133a708>] nfs_create_server+0x288/0x520
[ 1341.908405]  [<ffffffff8135288e>] nfs3_create_server+0xe/0x30
[ 1341.908779]  [<ffffffff81343ef9>] nfs_try_mount+0x59/0x90
[ 1341.928405]  [<ffffffff8134648c>] nfs_fs_mount+0xacc/0xb40
[ 1341.928770]  [<ffffffff813435d0>] ? nfs_clone_super+0x140/0x140
[ 1341.948439]  [<ffffffff81342db0>] ? nfs_sb_active+0x30/0x30
[ 1341.948843]  [<ffffffff811ccf90>] mount_fs+0x20/0xf0
[ 1341.968413]  [<ffffffff811e77d6>] vfs_kern_mount+0x76/0x100
[ 1341.968747]  [<ffffffff811e9d00>] do_mount+0x810/0x9e0
[ 1341.988421]  [<ffffffff811e936a>] ? copy_mount_options+0x3a/0x170
[ 1341.988824]  [<ffffffff811e9f6c>] sys_mount+0x9c/0xe0
[ 1342.008444]  [<ffffffff821d7419>] system_call_fastpath+0x16/0x1b


so that is same problem ?
