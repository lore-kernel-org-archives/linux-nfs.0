From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 5 of 8 - Define cache_show methods for export and filehandle cache in nfsd.
Date: Tue, 24 Jun 2003 16:54:53 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19Uhhd-0001qX-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Uhhx-0007S2-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Jun 2003 23:55:14 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Tue, 24 Jun 2003 16:55:01 +1000
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

### Comments for ChangeSet

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+)

diff ./fs/nfsd/export.c~current~ ./fs/nfsd/export.c
--- ./fs/nfsd/export.c~current~	2003-06-24 13:44:56.000000000 +1000
+++ ./fs/nfsd/export.c	2003-06-24 14:09:05.000000000 +1000
@@ -193,6 +193,31 @@ int expkey_parse(struct cache_detail *cd
 	return err;
 }
 
+static int expkey_show(struct seq_file *m,
+		       struct cache_detail *cd,
+		       struct cache_head *h,
+		       char *pbuf)
+{
+	struct svc_expkey *ek ;
+
+	if (h ==NULL) {
+		seq_puts(m, "#domain fsidtype fsid [path]\n");
+		return 0;
+	}
+	ek = container_of(h, struct svc_expkey, h);
+	seq_printf(m, "%s %d 0x%08x", ek->ek_client->name,
+		   ek->ek_fsidtype, ek->ek_fsid[0]);
+	if (ek->ek_fsid == 0)
+		seq_printf(m, "%08x", ek->ek_fsid[0]);
+	if (test_bit(CACHE_VALID, &h->flags) && 
+	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
+		seq_printf(m, " ");
+		seq_path(m, ek->ek_export->ex_mnt, ek->ek_export->ex_dentry, "\\ \t\n");
+	}
+	seq_printf(m, "\n");
+	return 0;
+}
+	
 struct cache_detail svc_expkey_cache = {
 	.hash_size	= EXPKEY_HASHMAX,
 	.hash_table	= expkey_table,
@@ -200,6 +225,7 @@ struct cache_detail svc_expkey_cache = {
 	.cache_put	= expkey_put,
 	.cache_request	= expkey_request,
 	.cache_parse	= expkey_parse,
+	.cache_show	= expkey_show,
 };
 
 static inline int svc_expkey_match (struct svc_expkey *a, struct svc_expkey *b)
@@ -407,6 +433,31 @@ int svc_export_parse(struct cache_detail
 	return err;
 }
 
+static void exp_flags(struct seq_file *m, int flag, int fsid, uid_t anonu, uid_t anong);
+
+static int svc_export_show(struct seq_file *m,
+		       struct cache_detail *cd,
+		       struct cache_head *h,
+		       char *pbuf)
+{
+	struct svc_export *exp ;
+
+	if (h ==NULL) {
+		seq_puts(m, "#path domain(flags)\n");
+		return 0;
+	}
+	exp = container_of(h, struct svc_export, h);
+	seq_path(m, exp->ex_mnt, exp->ex_dentry, " \t\n\\");
+	seq_putc(m, '\t');
+	seq_escape(m, exp->ex_client->name, " \t\n\\");
+	seq_putc(m, '(');
+	if (test_bit(CACHE_VALID, &h->flags) && 
+	    !test_bit(CACHE_NEGATIVE, &h->flags))
+		exp_flags(m, exp->ex_flags, exp->ex_fsid, 
+			  exp->ex_anon_uid, exp->ex_anon_gid);
+	seq_puts(m, ")\n");
+	return 0;
+}
 struct cache_detail svc_export_cache = {
 	.hash_size	= EXPORT_HASHMAX,
 	.hash_table	= export_table,
@@ -414,6 +465,7 @@ struct cache_detail svc_export_cache = {
 	.cache_put	= svc_export_put,
 	.cache_request	= svc_export_request,
 	.cache_parse	= svc_export_parse,
+	.cache_show	= svc_export_show,
 };
 
 static inline int svc_export_match(struct svc_export *a, struct svc_export *b)


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
