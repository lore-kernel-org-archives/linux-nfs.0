From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH]: rpc_debug mode causes an oops
Date: Mon, 13 Jan 2003 01:11:31 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15906.1075.831837.959677@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18XsCb-0001di-00
	for <nfs@lists.sourceforge.net>; Sun, 12 Jan 2003 16:11:41 -0800
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


this patch fixes a bug introduced by the recent rpc_procinfo change.
when entering debug mode, one of the debug printk's in sched.c expects
tk_msg.rpc_proc to be non-NULL, but now it can be NULL in certain
legitimate cases.

the rpc_qname cleanup below removes redundant code.

 net/sunrpc/sched.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -u --recursive --new-file linux-2.5.56/net/sunrpc/sched.c linux-2.5.56-01-fix_oops/net/sunrpc/sched.c
--- linux-2.5.56/net/sunrpc/sched.c	2002-11-13 16:09:37.000000000 +0100
+++ linux-2.5.56-01-fix_oops/net/sunrpc/sched.c	2003-01-12 22:39:06.000000000 +0100
@@ -1123,11 +1123,12 @@
 		"-rpcwait -action- --exit--\n");
 	alltask_for_each(t, le, &all_tasks)
 		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
-			t->tk_pid, t->tk_msg.rpc_proc->p_proc,
+			t->tk_pid,
+			(t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : -1),
 			t->tk_flags, t->tk_status,
 			t->tk_client, t->tk_client->cl_prog,
 			t->tk_rqstp, t->tk_timeout,
-			t->tk_rpcwait ? rpc_qname(t->tk_rpcwait) : " <NULL> ",
+			rpc_qname(t->tk_rpcwait),
 			t->tk_action, t->tk_exit);
 	spin_unlock(&rpc_sched_lock);
 }


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
