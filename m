From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] fix build problems in nfs w/o proc_fs on 2.6.0-test5
Date: Fri, 12 Sep 2003 11:31:06 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030912113106.0c118a45.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19xsht-0006gD-00
	for <nfs@lists.sourceforge.net>; Fri, 12 Sep 2003 11:31:45 -0700
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19xshs-0003ey-OU
	for nfs@lists.sourceforge.net; Fri, 12 Sep 2003 11:31:45 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
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

NFS won't build w/o CONFIG_PROC_FS.  Looks like typo's (or a C++ programmer)
in stats.h

diff -Nru a/include/linux/sunrpc/stats.h b/include/linux/sunrpc/stats.h
--- a/include/linux/sunrpc/stats.h	Fri Sep 12 11:16:32 2003
+++ b/include/linux/sunrpc/stats.h	Fri Sep 12 11:16:32 2003
@@ -64,11 +64,12 @@
 static inline void rpc_proc_unregister(const char *p) {}
 static inline void rpc_proc_zero(struct rpc_program *p) {}
 
-static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s
-						       struct file_operations *) { return NULL; }
+static inline struct proc_dir_entry *svc_proc_register(struct svc_stat *s,
+						       struct file_operations *f) { return NULL; }
 static inline void svc_proc_unregister(const char *p) {}
 
-static inline void svc_seq_show(struct seq_file *, const struct svc_stat *) {}
+static inline void svc_seq_show(struct seq_file *seq, 
+				const struct svc_stat *st) {}
 
 #define proc_net_rpc NULL
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
