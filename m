From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH]: rpc_debug mode causes an oops
Date: Thu, 9 Jan 2003 12:07:21 -0500 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301091158540.25663-100000@dexter.citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dexter.citi.umich.edu ([141.211.133.33] ident=[BNMDs6jvBsLxQRhguhdE0cDrjsccunOl])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Wg9T-0006h3-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Jan 2003 09:07:31 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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

hi trond-

this patch fixes a bug introduced by the recent rpc_procinfo change.  
when entering debug mode, one of the debug printk's in sched.c expects
tk_msg.rpc_proc to be non-NULL, but now it can be NULL in certain
legitimate cases.

the rpc_qname cleanup below removes redundant code.

apply against 2.5.55.

 net/sunrpc/sched.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff -Naurp 00-stock/net/sunrpc/sched.c 01-debug-oops/net/sunrpc/sched.c
--- 00-stock/net/sunrpc/sched.c	Wed Jan  8 23:04:15 2003
+++ 01-debug-oops/net/sunrpc/sched.c	Thu Jan  9 10:55:36 2003
@@ -1123,11 +1123,12 @@ void rpc_show_tasks(void)
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
