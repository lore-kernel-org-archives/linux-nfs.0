Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55784 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751317AbdGQMIL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 17 Jul 2017 08:08:11 -0400
Date: Mon, 17 Jul 2017 20:08:09 +0800
From: Eryu Guan <eguan@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Christoph Hellwig <hch@lst.de>
Subject: [4.13-rc1 regression] fstests generic/013 crashed nfsd on ppc64 host
Message-ID: <20170717120809.GQ2478@eguan.usersys.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

I hit a nfsd crash in fstests generic/013 run with 4.13-rc1 kernel, NFS
version 4.0/4.1/4.2, v3 passed the test, and it only happens on
ppc64/ppc64le hosts for me. git bisect pointed first bad to

commit 1c5876ddbdb401f814ef717394826e7dfb6704d4
Author: Christoph Hellwig <hch@lst.de>
Date:   Mon May 8 23:27:10 2017 +0200

    sunrpc: move p_count out of struct rpc_procinfo

    p_count is the only writeable memeber of struct rpc_procinfo, which is
    a good candidate to be const-ified as it contains function pointers.

    This patch moves it into out out struct rpc_procinfo, and into a
    separate writable array that is pointed to by struct rpc_version and
    indexed by p_statidx.

    Signed-off-by: Christoph Hellwig <hch@lst.de>

I was testing with a local mounted NFS share, but I can also reproduce
it by running generic/013 from a remote nfs client. If you need more
information please let me know.

Thanks,
Eryu

[  992.581712] run fstests generic/013 at 2017-07-16 07:30:42 
[  993.895088] Unable to handle kernel paging request for data at address 0x2f7362696e2f6e76 
[  993.895113] Faulting instruction address: 0xd000000006660428 
[  993.895121] Oops: Kernel access of bad area, sig: 11 [#1] 
[  993.895126] SMP NR_CPUS=2048  
[  993.895127] NUMA  
[  993.895130] pSeries 
[  993.895137] Modules linked in: rpcsec_gss_krb5 nfsv4 dns_resolver nfs fscache ext4 mbcache jbd2 nx_crypto sg pseries_rng nfsd auth_rpcgss nfs_acl lockd sunrpc grace ip_tables xfs libcrc32c sd_mod ibmvscsi scsi_transport_srp ibmveth 
[  993.895168] CPU: 11 PID: 335 Comm: kworker/11:1 Not tainted 4.13.0-rc1 #1 
[  993.895197] Workqueue: rpciod .rpc_async_schedule [sunrpc] 
[  993.895203] task: c0000001f94cf780 task.stack: c0000001f952c000 
[  993.895208] NIP: d000000006660428 LR: d0000000066748d4 CTR: d0000000066603d0 
[  993.895214] REGS: c0000001f952f7e0 TRAP: 0380   Not tainted  (4.13.0-rc1) 
[  993.895219] MSR: 800000000280b032 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI> 
[  993.895225]   CR: 22004024  XER: 00000001 
[  993.895233] CFAR: d0000000066748d0 SOFTE: 1  
[  993.895233] GPR00: d0000000066748d4 c0000001f952fa60 d0000000066b5d78 c0000001bcee7d00  
[  993.895233] GPR04: c0000000fefc19e8 c0000001bcee7d48 002d1e7473db58e8 0000000000000001  
[  993.895233] GPR08: d0000000079dd588 2f7362696e2f6e66 0000000000000008 d0000000079d45f8  
[  993.895233] GPR12: d000000006660010 c00000000e986e00 c000000000110ab0 c0000001f81d0040  
[  993.895233] GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000  
[  993.895233] GPR20: 0000000000000000 fffffffffffffe00 0000000000000000 0000000000000001  
[  993.895233] GPR24: d0000000066b9f34 c0000001bcee7d30 0000000000000000 d0000000066aac68  
[  993.895233] GPR28: c0000001bc79cc00 0000000000000001 c0000001bc79cc00 c0000001bcee7d00  
[  993.895313] NIP [d000000006660428] .call_start+0x58/0x120 [sunrpc] 
[  993.895337] LR [d0000000066748d4] .__rpc_execute+0xc4/0x540 [sunrpc] 
[  993.895342] Call Trace: 
[  993.895346] [c0000001f952fa60] [0000000000000001] 0x1 (unreliable) 
[  993.895370] [c0000001f952faf0] [d0000000066748d4] .__rpc_execute+0xc4/0x540 [sunrpc] 
[  993.895379] [c0000001f952fbe0] [c000000000108e74] .process_one_work+0x194/0x480 
[  993.895387] [c0000001f952fc90] [c0000000001091e8] .worker_thread+0x88/0x510 
[  993.895393] [c0000001f952fd70] [c000000000110c0c] .kthread+0x15c/0x1a0 
[  993.895401] [c0000001f952fe30] [c00000000000b520] .ret_from_kernel_thread+0x58/0xb8 
[  993.895407] Instruction dump: 
[  993.895411] e9430078 ebc300a8 7928ffe3 ebaa0026 40c2006c e95e0180 80fe0044 e90a0010  
[  993.895421] 78ea1f24 7d28502a 2fa90000 419e0018 <e9490010> 7ba91764 7d0a482e 39080001  
[  993.895433] ---[ end trace aeee2c84dc1574c0 ]--- 

And gdb shows:

(gdb) l *(call_start+0x60)
0x4b0 is in call_start (net/sunrpc/clnt.c:1529).
1524                            rpc_proc_name(task),
1525                            (RPC_IS_ASYNC(task) ? "async" : "sync"));
1526
1527            /* Increment call count (version might not be valid for ping) */
1528            if (clnt->cl_program->version[clnt->cl_vers])
1529                    clnt->cl_program->version[clnt->cl_vers]->counts[idx]++;
1530            clnt->cl_stats->rpccnt++;
1531            task->tk_action = call_reserve;
1532    }
1533
