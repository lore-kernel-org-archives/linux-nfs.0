From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 16 - Expose anon uid and gid in /proc/fs/nfs/exports
Date: Thu, 12 Sep 2002 12:34:56 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023456.19584@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJp2-0002Eh-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:35:12 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

Don't print if default, which should be "-2", but
is currently 65534..  We really need a 32bit uid interface for 2.6.




 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

--- ./fs/nfsd/export.c	2002/09/11 01:33:52	1.5
+++ ./fs/nfsd/export.c	2002/09/11 01:34:31	1.6
@@ -613,7 +613,7 @@ struct flags {
 	{ 0, {"", ""}}
 };
 
-static void exp_flags(struct seq_file *m, int flag, int fsid)
+static void exp_flags(struct seq_file *m, int flag, int fsid, uid_t anonu, uid_t anong)
 {
 	int first = 0;
 	struct flags *flg;
@@ -625,6 +625,10 @@ static void exp_flags(struct seq_file *m
 	}
 	if (flag & NFSEXP_FSID)
 		seq_printf(m, "%sfsid=%d", first++?",":"", fsid);
+	if (anonu != (uid_t)-2 && anonu != (0x10000-2))
+		seq_printf(m, "%sanonuid=%d", first++?",":"", anonu);
+	if (anong != (gid_t)-2 && anong != (0x10000-2))
+		seq_printf(m, "%sanongid=%d", first++?",":"", anong);
 }
 
 static inline void mangle(struct seq_file *m, const char *s)
@@ -650,7 +654,8 @@ static int e_show(struct seq_file *m, vo
 	seq_putc(m, '\t');
 	mangle(m, clp->cl_ident);
 	seq_putc(m, '(');
-	exp_flags(m, exp->ex_flags, exp->ex_fsid);
+	exp_flags(m, exp->ex_flags, exp->ex_fsid, 
+		  exp->ex_anon_uid, exp->ex_anon_gid);
 	seq_puts(m, ") # ");
 	for (j = 0; j < clp->cl_naddr; j++) {
 		struct svc_clnthash **hp, **head, *tmp;


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
