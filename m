Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:50192 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753948Ab3CAAan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Feb 2013 19:30:43 -0500
Date: Thu, 28 Feb 2013 19:30:38 -0500
From: Dave Jones <davej@redhat.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: lockdep trace from nfsd
Message-ID: <20130301003038.GA26533@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[   39.878535] =====================================
[   39.879670] [ BUG: rpc.nfsd/666 still has locks held! ]
[   39.880871] 3.8.0+ #3 Not tainted
[   39.881858] -------------------------------------
[   39.882850] 2 locks on stack by rpc.nfsd/666:
[   39.883868]  #0: held:     (nfsd_mutex){+.+.+.}, instance: ffffffffa01cf0b8, at: [<ffffffffa0193d57>] write_ports+0x37/0x7a0 [nfsd]
[   39.884750]  #1: held:     (rpcb_create_local_mutex){+.+.+.}, instance: ffffffffa016d878, at: [<ffffffffa0153916>] rpcb_create_local+0x46/0x90 [sunrpc]
[   39.885903] 
stack backtrace:
[   39.897044] Pid: 666, comm: rpc.nfsd Not tainted 3.8.0+ #3
[   39.898186] Call Trace:
[   39.900755]  [<ffffffff810b9c6a>] debug_check_no_locks_held+0x9a/0xa0
[   39.901823]  [<ffffffffa0145965>] rpc_wait_bit_killable+0x85/0xb0 [sunrpc]
[   39.902866]  [<ffffffff8161bf10>] __wait_on_bit+0x60/0x90
[   39.903879]  [<ffffffffa0147860>] ? __rpc_execute+0x170/0x5a0 [sunrpc]
[   39.904900]  [<ffffffffa01458e0>] ? __rpc_wait_for_completion_task+0x30/0x30 [sunrpc]
[   39.905969]  [<ffffffff8161bfbc>] out_of_line_wait_on_bit+0x7c/0x90
[   39.907010]  [<ffffffffa0147860>] ? __rpc_execute+0x170/0x5a0 [sunrpc]
[   39.908070]  [<ffffffff81075f00>] ? autoremove_wake_function+0x50/0x50
[   39.909124]  [<ffffffffa0139b50>] ? call_connect+0xa0/0xa0 [sunrpc]
[   39.910154]  [<ffffffffa0147891>] __rpc_execute+0x1a1/0x5a0 [sunrpc]
[   39.911176]  [<ffffffff81075e9e>] ? wake_up_bit+0x2e/0x40
[   39.912058]  [<ffffffffa0147d49>] rpc_execute+0x59/0x180 [sunrpc]
[   39.912745]  [<ffffffffa013da00>] rpc_run_task+0x70/0x90 [sunrpc]
[   39.913446]  [<ffffffffa013db23>] rpc_call_sync+0x43/0xa0 [sunrpc]
[   39.914280]  [<ffffffffa013dbd2>] rpc_ping+0x52/0x70 [sunrpc]
[   39.914992]  [<ffffffffa013de08>] rpc_create+0x188/0x230 [sunrpc]
[   39.915735]  [<ffffffff8100a4a9>] ? sched_clock+0x9/0x10
[   39.916577]  [<ffffffff810b807e>] ? put_lock_stats.isra.25+0xe/0x40
[   39.917635]  [<ffffffff810b871c>] ? lock_release_holdtime.part.26+0xcc/0x140
[   39.918667]  [<ffffffffa015331c>] rpcb_create_local_unix+0x5c/0xe0 [sunrpc]
[   39.919669]  [<ffffffffa0153948>] rpcb_create_local+0x78/0x90 [sunrpc]
[   39.920705]  [<ffffffffa014a653>] svc_rpcb_setup+0x23/0x50 [sunrpc]
[   39.921725]  [<ffffffffa014a6b4>] svc_bind+0x34/0x50 [sunrpc]
[   39.921733]  [<ffffffffa01909ed>] nfsd_create_serv+0x1cd/0x320 [nfsd]
[   39.921738]  [<ffffffffa0190825>] ? nfsd_create_serv+0x5/0x320 [nfsd]
[   39.921742]  [<ffffffffa019424a>] write_ports+0x52a/0x7a0 [nfsd]
[   39.921746]  [<ffffffffa0194138>] ? write_ports+0x418/0x7a0 [nfsd]
[   39.921750]  [<ffffffff816203c5>] ? _raw_spin_unlock+0x35/0x60
[   39.921754]  [<ffffffff811de09a>] ? simple_transaction_get+0xca/0xe0
[   39.921759]  [<ffffffffa0193d20>] ? write_maxblksize+0x2e0/0x2e0 [nfsd]
[   39.921764]  [<ffffffffa0192367>] nfsctl_transaction_write+0x57/0x90 [nfsd]
[   39.921768]  [<ffffffff811b45ff>] vfs_write+0xaf/0x190
[   39.921771]  [<ffffffff811b4955>] sys_write+0x55/0xa0
[   39.921775]  [<ffffffff81628b99>] system_call_fastpath+0x16/0x1b

