From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] kNFSd - 5 of 5 - fix build problems in nfs w/o proc_fs
Date: Sun, 8 Feb 2004 15:48:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040208204835.GF27482@fieldses.org>
References: <20040206161050.27799.patches@notabene> <E1AoyIo-0007FS-00@notabene> <20040207012423.396efe73.akpm@osdl.org> <20040208043723.GC13391@fieldses.org> <20040207214637.387d3018.akpm@osdl.org> <20040208055921.GA14053@fieldses.org> <20040208203018.GA27482@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: neilb@cse.unsw.edu.au, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Apvr9-0004zl-1z
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:48:43 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1Apvr8-0003J7-3V
	for nfs@lists.sourceforge.net; Sun, 08 Feb 2004 12:48:42 -0800
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20040208203018.GA27482@fieldses.org>
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


NFS won't build w/o CONFIG_PROC_FS.  Looks like typo's (or a C++ programmer)
in stats.h

(From neilb)


 include/linux/sunrpc/stats.h |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff -puN include/linux/sunrpc/stats.h~neil_proc_fs_build_fix include/linux/sunrpc/stats.h
--- linux-2.6.1/include/linux/sunrpc/stats.h~neil_proc_fs_build_fix	2004-02-08 01:53:03.000000000 -0500
+++ linux-2.6.1-bfields/include/linux/sunrpc/stats.h	2004-02-08 01:53:03.000000000 -0500
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
 

_


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
