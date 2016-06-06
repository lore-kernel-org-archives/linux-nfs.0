Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:48164 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884AbcFFNh4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Jun 2016 09:37:56 -0400
Date: Mon, 6 Jun 2016 09:37:51 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, Steve Dickson <steved@redhat.com>
Message-ID: <309914450.3712032.1465220270981.JavaMail.zimbra@redhat.com>
In-Reply-To: <568964311.3695972.1465219129059.JavaMail.zimbra@redhat.com>
Subject: WARNING at net/ipv4/af_inet.c:155 .inet_sock_destruct+0x170/0x220
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello,

I'm running sporadically into following warning during NFS cthon
special tests (NFSv3, UDP, rhel6 as server):

[ 1085.443289] ------------[ cut here ]------------ 
[ 1085.443302] WARNING: CPU: 9 PID: 31049 at net/ipv4/af_inet.c:155 .inet_sock_destruct+0x170/0x220 
[ 1085.443306] Modules linked in: rpcsec_gss_krb5 nfsv4 nfsv3 nfs fscache nfnetlink_queue nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver rpcrdma ib_isert iscsi_target_mod ib_iser rdma_cm iw_cm libiscsi scsi_transport_iscsi ib_srpt target_core_mod ib_srp ib_ipoib ib_ucm ib_uverbs ib_umad ib_cm ib_sa ib_mad ib_core ib_addr nls_koi8_u nls_cp932 ts_kmp nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack sg pseries_rng nfsd auth_rpcgss nfs_acl lockd sunrpc grace xfs libcrc32c sd_mod ibmvscsi scsi_transport_srp ibmveth dm_mirror dm_region_hash dm_log dm_mod [last unloaded: xt_u32] 
[ 1085.443363] CPU: 9 PID: 31049 Comm: umount.nfs Not tainted 4.6.0 #1 
[ 1085.443366] task: c0000005edde8500 ti: c0000000fd0b0000 task.ti: c0000000fd0b0000 
[ 1085.443370] NIP: c000000000762fd0 LR: c0000000006a487c CTR: c000000000762e60 
[ 1085.443373] REGS: c0000000fd0b3030 TRAP: 0700   Not tainted  (4.6.0) 
[ 1085.443376] MSR: 800000010282b032 <SF,VEC,VSX,EE,FP,ME,IR,DR,RI,TM[E]>  CR: 42002824  XER: 00000006 
[ 1085.443387] CFAR: c000000000762eec SOFTE: 1  
GPR00: c0000000006a487c c0000000fd0b32b0 c0000000010efe00 c0000005f57c3400  
GPR04: 0000000000000500 00000000fffffff1 c0000005f1339080 0000000000000001  
GPR08: c00000000113fe00 0000000000000001 0000000000000001 d000000006795508  
GPR12: c00000000069c330 c00000000e825100 0000000000000000 0000000000000000  
GPR16: 0000000000000000 0000000000000000 0000000000000000 0000000000000000  
GPR20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000  
GPR24: 0000000000000000 0000000000000200 0000000000000000 c0000005f57c35a8  
GPR28: c0000005b19bd6c0 c0000005f57c3588 c0000005faa8c080 c0000005f57c3400  
[ 1085.443426] NIP [c000000000762fd0] .inet_sock_destruct+0x170/0x220 
[ 1085.443430] LR [c0000000006a487c] .sk_destruct+0x3c/0x200 
[ 1085.443433] Call Trace: 
[ 1085.443435] [c0000000fd0b32b0] [c0000000fd0b3340] 0xc0000000fd0b3340 (unreliable) 
[ 1085.443439] [c0000000fd0b3340] [c0000000006a487c] .sk_destruct+0x3c/0x200 
[ 1085.443444] [c0000000fd0b33d0] [c000000000751f80] .udp_lib_close+0x10/0x30 
[ 1085.443448] [c0000000fd0b3440] [c0000000007636e8] .inet_release+0x68/0xb0 
[ 1085.443452] [c0000000fd0b34c0] [c00000000069c370] .sock_release+0x40/0xf0 
[ 1085.443473] [c0000000fd0b3540] [d00000000676b940] .xs_reset_transport+0x110/0x1d0 [sunrpc] 
[ 1085.443492] [c0000000fd0b35e0] [d00000000676ba30] .xs_close+0x30/0x70 [sunrpc] 
[ 1085.443511] [c0000000fd0b3660] [d00000000676baac] .xs_destroy+0x3c/0xa0 [sunrpc] 
[ 1085.443530] [c0000000fd0b36e0] [d000000006766960] .xprt_destroy+0xf0/0x120 [sunrpc] 
[ 1085.443548] [c0000000fd0b3760] [d00000000678fe04] .xprt_switch_free+0xb4/0x150 [sunrpc] 
[ 1085.443567] [c0000000fd0b3810] [d000000006760f8c] .rpc_free_client+0xac/0x130 [sunrpc] 
[ 1085.443586] [c0000000fd0b38a0] [d0000000067612f8] .rpc_release_client+0xb8/0x140 [sunrpc] 
[ 1085.443605] [c0000000fd0b3920] [d0000000067616d4] .rpc_shutdown_client+0xf4/0x140 [sunrpc] 
[ 1085.443620] [c0000000fd0b39f0] [d0000000043705cc] .nfs_free_client+0x4c/0x130 [nfs] 
[ 1085.443634] [c0000000fd0b3a70] [d0000000043707e4] .nfs_put_client+0x134/0x1b0 [nfs] 
[ 1085.443648] [c0000000fd0b3b00] [d000000004371634] .nfs_free_server+0x94/0x130 [nfs] 
[ 1085.443662] [c0000000fd0b3b80] [d000000004383000] .nfs_kill_super+0x40/0x70 [nfs] 
[ 1085.443667] [c0000000fd0b3c10] [c0000000002a4080] .deactivate_locked_super+0xa0/0xf0 
[ 1085.443672] [c0000000fd0b3c90] [c0000000002c9314] .cleanup_mnt+0x54/0xa0 
[ 1085.443676] [c0000000fd0b3d10] [c0000000000d3044] .task_work_run+0xe4/0x120 
[ 1085.443681] [c0000000fd0b3db0] [c000000000016a58] .do_notify_resume+0xf8/0x100 
[ 1085.443685] [c0000000fd0b3e30] [c0000000000097c4] .ret_from_except_lite+0x70/0x74 
[ 1085.443688] Instruction dump: 
[ 1085.443691] 5529d97e 69290001 0b090000 813f014c 7d290034 5529d97e 69290001 0b090000  
[ 1085.443697] 813f00d8 7d290034 5529d97e 69290001 <0b090000> e87f02e0 4bb0fb79 60000000  
[ 1085.443703] ---[ end trace 811d03b71443934f ]--- 

I ran into this warning initially on RHEL7.3 kernel, where
I bisected it to following (first bad) commit:
 [fs] sunrpc: Move UDP receive data path into a workqueue context

I'm looking to confirm this result with 4.6 as well, but given
low reproducibility it will probably take couple days.

Regards,
Jan
