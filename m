From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 5 - fix build problems in nfs w/o proc_fs on 2.6.0-test5
Date: Fri, 06 Feb 2004 16:13:19 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AoyIp-0007Ft-00@notabene>
References: <20040206161050.27799.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AoyJ4-0008Ip-Q4
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1AoyJ4-0003M1-5P
	for nfs@lists.sourceforge.net; Thu, 05 Feb 2004 21:13:34 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 6 Feb 2004 16:13:25 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>



From: Stephen Hemminger <shemminger@osdl.org>
Date: Fri, 12 Sep 2003 11:31:06 -0700

NFS won't build w/o CONFIG_PROC_FS.  Looks like typo's (or a C++ programmer)
in stats.h

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/stats.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff ./include/linux/sunrpc/stats.h~current~ ./include/linux/sunrpc/stats.h
--- ./include/linux/sunrpc/stats.h~current~	2004-02-06 14:14:37.000000000 +1100
+++ ./include/linux/sunrpc/stats.h	2004-02-06 14:15:06.000000000 +1100
@@ -64,11 +64,12 @@ static inline struct proc_dir_entry *rpc
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
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
