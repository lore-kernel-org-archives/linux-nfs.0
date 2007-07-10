From: NeilBrown <neilb@suse.de>
Subject: [PATCH 014 of 20] knfsd: nfsd: display export secinfo
	information
Date: Tue, 10 Jul 2007 12:27:43 +1000
Message-ID: <1070710022743.13524@suse.de>
References: <20070710121949.12548.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J . Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I85S7-000579-2w
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:47 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85S8-0001aB-5y
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:48 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J. Bruce Fields <bfields@citi.umich.edu>

Add secinfo information to the display in proc/net/sunrpc/nfsd.export/content.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |   29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-07-10 11:46:05.000000000 +1000
+++ ./fs/nfsd/export.c	2007-07-10 11:48:23.000000000 +1000
@@ -641,6 +641,7 @@ static int svc_export_parse(struct cache
 
 static void exp_flags(struct seq_file *m, int flag, int fsid,
 		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fslocs);
+static void show_secinfo(struct seq_file *m, struct svc_export *exp);
 
 static int svc_export_show(struct seq_file *m,
 			   struct cache_detail *cd,
@@ -670,6 +671,7 @@ static int svc_export_show(struct seq_fi
 				seq_printf(m, "%02x", exp->ex_uuid[i]);
 			}
 		}
+		show_secinfo(m, exp);
 	}
 	seq_puts(m, ")\n");
 	return 0;
@@ -1467,6 +1469,33 @@ static void show_expflags(struct seq_fil
 	}
 }
 
+static void show_secinfo_flags(struct seq_file *m, int flags)
+{
+	seq_printf(m, ",");
+	show_expflags(m, flags, NFSEXP_SECINFO_FLAGS);
+}
+
+static void show_secinfo(struct seq_file *m, struct svc_export *exp)
+{
+	struct exp_flavor_info *f;
+	struct exp_flavor_info *end = exp->ex_flavors + exp->ex_nflavors;
+	int lastflags = 0, first = 0;
+
+	if (exp->ex_nflavors == 0)
+		return;
+	for (f = exp->ex_flavors; f < end; f++) {
+		if (first || f->flags != lastflags) {
+			if (!first)
+				show_secinfo_flags(m, lastflags);
+			seq_printf(m, ",sec=%d", f->pseudoflavor);
+			lastflags = f->flags;
+		} else {
+			seq_printf(m, ":%d", f->pseudoflavor);
+		}
+	}
+	show_secinfo_flags(m, lastflags);
+}
+
 static void exp_flags(struct seq_file *m, int flag, int fsid,
 		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fsloc)
 {

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
