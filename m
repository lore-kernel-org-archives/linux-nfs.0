From: Chuck Lever <cel@citi.umich.edu>
Subject: [PATCH] BPB (brown paper bag) rpc_show_tasks
Date: Fri, 2 May 2003 15:37:55 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.BSO.4.33.0305021535490.2377-100000@citi.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from citi.umich.edu ([141.211.92.141])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19BgM2-0007s3-00
	for <nfs@lists.sourceforge.net>; Fri, 02 May 2003 12:37:58 -0700
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

the recently-applied patch to fix the rpc_show_tasks() Oops is incomplete.
this applies over 2.5.68 and should address all of the issues in
rpc_show_tasks().

diff -Naurp old/net/sunrpc/sched.c new/net/sunrpc/sched.c
--- old/net/sunrpc/sched.c	Fri May  2 15:31:37 2003
+++ new/net/sunrpc/sched.c	Fri May  2 15:32:43 2003
@@ -1149,9 +1149,10 @@ void rpc_show_tasks(void)
 	alltask_for_each(t, le, &all_tasks)
 		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
 			t->tk_pid,
-			(t->tk_msg.rpc_proc->p_proc ? t->tk_msg.rpc_proc->p_proc : -1),
+			(t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : -1),
 			t->tk_flags, t->tk_status,
-			t->tk_client, t->tk_client->cl_prog,
+			t->tk_client,
+			(t->tk_client ? t->tk_client->cl_prog : 0),
 			t->tk_rqstp, t->tk_timeout,
 			rpc_qname(t->tk_rpcwait),
 			t->tk_action, t->tk_exit);

	- Chuck Lever
--
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
