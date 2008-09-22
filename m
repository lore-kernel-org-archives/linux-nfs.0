From: akpm@linux-foundation.org
Subject: [patch for 2.6.27? 2/2] sunrpc: fix oops in rpc_create() when the mount namespace is unshared
Date: Mon, 22 Sep 2008 14:10:55 -0700
Message-ID: <200809222110.m8MLAtMc029920@imap1.linux-foundation.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org,
	akpm@linux-foundation.org, clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org, chuck.lever@oracle.com,
	ebiederm@xmission.com, serue@us.ibm.com
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:36767 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753063AbYIVVND (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Sep 2008 17:13:03 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>

On a system with nfs mounts, if a task unshares its mount namespace,
a oops can occur when the system is rebooted if the task is the last
to unreference the nfs mount. It will try to create a rpc request
using utsname() which has been invalidated by free_nsproxy().

The patch fixes the issue by using the global init_utsname() which is
always valid. the capability of identifying rpc clients per uts namespace
stills needs some extra work so this should not be a problem.

BUG: unable to handle kernel NULL pointer dereference at 00000004
IP: [<c024c9ab>] rpc_create+0x332/0x42f
Oops: 0000 [#1] DEBUG_PAGEALLOC

Pid: 1857, comm: uts-oops Not tainted (2.6.27-rc5-00319-g7686ad5 #4)
EIP: 0060:[<c024c9ab>] EFLAGS: 00210287 CPU: 0
EIP is at rpc_create+0x332/0x42f
EAX: 00000000 EBX: df26adf0 ECX: c0251887 EDX: 00000001
ESI: df26ae58 EDI: c02f293c EBP: dda0fc9c ESP: dda0fc2c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process uts-oops (pid: 1857, ti=dda0e000 task=dd9a0778 task.ti=dda0e000)
Stack: c0104532 dda0fffc dda0fcac dda0e000 dda0e000 dd93b7f0 00000009 c02f2880
       df26aefc dda0fc68 c01096b7 00000000 c0266ee0 c039a070 c039a070 dda0fc74
       c012ca67 c039a064 dda0fc8c c012cb20 c03daf74 00000011 00000000 c0275c90
Call Trace:
 [<c0104532>] ? dump_trace+0xc2/0xe2
 [<c01096b7>] ? save_stack_trace+0x1c/0x3a
 [<c012ca67>] ? save_trace+0x37/0x8c
 [<c012cb20>] ? add_lock_to_list+0x64/0x96
 [<c0256fc4>] ? rpcb_register_call+0x62/0xbb
 [<c02570c8>] ? rpcb_register+0xab/0xb3
 [<c0252f4d>] ? svc_register+0xb4/0x128
 [<c0253114>] ? svc_destroy+0xec/0x103
 [<c02531b2>] ? svc_exit_thread+0x87/0x8d
 [<c01a75cd>] ? lockd_down+0x61/0x81
 [<c01a577b>] ? nlmclnt_done+0xd/0xf
 [<c01941fe>] ? nfs_destroy_server+0x14/0x16
 [<c0194328>] ? nfs_free_server+0x4c/0xaa
 [<c019a066>] ? nfs_kill_super+0x23/0x27
 [<c0158585>] ? deactivate_super+0x3f/0x51
 [<c01695d1>] ? mntput_no_expire+0x95/0xb4
 [<c016965b>] ? release_mounts+0x6b/0x7a
 [<c01696cc>] ? __put_mnt_ns+0x62/0x70
 [<c0127501>] ? free_nsproxy+0x25/0x80
 [<c012759a>] ? switch_task_namespaces+0x3e/0x43
 [<c01275a9>] ? exit_task_namespaces+0xa/0xc
 [<c0117fed>] ? do_exit+0x4fd/0x666
 [<c01181b3>] ? do_group_exit+0x5d/0x83
 [<c011fa8c>] ? get_signal_to_deliver+0x2c8/0x2e0
 [<c0102630>] ? do_notify_resume+0x69/0x700
 [<c011d85a>] ? do_sigaction+0x134/0x145
 [<c0127205>] ? hrtimer_nanosleep+0x8f/0xce
 [<c0126d1a>] ? hrtimer_wakeup+0x0/0x1c
 [<c0103488>] ? work_notifysig+0x13/0x1b
 =======================
Code: 70 20 68 cb c1 2c c0 e8 75 4e 01 00 8b 83 ac 00 00 00 59 3d 00 f0 ff ff 5f 77 63 eb 57 a1 00 80 2d c0 8b 80 a8 02 00 00 8d 73 68 <8b> 40 04 83 c0 45 e8 41 46 f7 ff ba 20 00 00 00 83 f8 21 0f 4c
EIP: [<c024c9ab>] rpc_create+0x332/0x42f SS:ESP 0068:dda0fc2c

Signed-off-by: Cedric Le Goater <clg-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>
Cc: Chuck Lever <chuck.lever@oracle.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/sunrpc/clnt.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff -puN net/sunrpc/clnt.c~sunrpc-fix-oops-in-rpc_create-when-the-mount-namespace-is-unshared net/sunrpc/clnt.c
--- a/net/sunrpc/clnt.c~sunrpc-fix-oops-in-rpc_create-when-the-mount-namespace-is-unshared
+++ a/net/sunrpc/clnt.c
@@ -213,10 +213,10 @@ static struct rpc_clnt * rpc_new_client(
 	}
 
 	/* save the nodename */
-	clnt->cl_nodelen = strlen(utsname()->nodename);
+	clnt->cl_nodelen = strlen(init_utsname()->nodename);
 	if (clnt->cl_nodelen > UNX_MAXNODENAME)
 		clnt->cl_nodelen = UNX_MAXNODENAME;
-	memcpy(clnt->cl_nodename, utsname()->nodename, clnt->cl_nodelen);
+	memcpy(clnt->cl_nodename, init_utsname()->nodename, clnt->cl_nodelen);
 	rpc_register_client(clnt);
 	return clnt;
 
_
