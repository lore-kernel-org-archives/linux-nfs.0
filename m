From: NeilBrown <neilb@suse.de>
Subject: [PATCH 013 of 20] knfsd: nfsd: factor out code from
	show_expflags
Date: Tue, 10 Jul 2007 12:27:37 +1000
Message-ID: <1070710022737.13509@suse.de>
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
	id 1I85S0-00056o-8A
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:41 -0700
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I85S2-0001Ye-15
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 19:27:43 -0700
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

Factor out some code to be shared by secinfo display code.  Remove some
unnecessary conditional printing of commas where we know the condition
is true.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c |   23 +++++++++++++++--------
 1 file changed, 15 insertions(+), 8 deletions(-)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2007-07-10 11:39:34.000000000 +1000
+++ ./fs/nfsd/export.c	2007-07-10 11:46:05.000000000 +1000
@@ -1453,28 +1453,35 @@ static struct flags {
 	{ 0, {"", ""}}
 };
 
-static void exp_flags(struct seq_file *m, int flag, int fsid,
-		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fsloc)
+static void show_expflags(struct seq_file *m, int flags, int mask)
 {
-	int first = 0;
 	struct flags *flg;
+	int state, first = 0;
 
 	for (flg = expflags; flg->flag; flg++) {
-		int state = (flg->flag & flag)?0:1;
+		if (flg->flag & ~mask)
+			continue;
+		state = (flg->flag & flags) ? 0 : 1;
 		if (*flg->name[state])
 			seq_printf(m, "%s%s", first++?",":"", flg->name[state]);
 	}
+}
+
+static void exp_flags(struct seq_file *m, int flag, int fsid,
+		uid_t anonu, uid_t anong, struct nfsd4_fs_locations *fsloc)
+{
+	show_expflags(m, flag, NFSEXP_ALLFLAGS);
 	if (flag & NFSEXP_FSID)
-		seq_printf(m, "%sfsid=%d", first++?",":"", fsid);
+		seq_printf(m, ",fsid=%d", fsid);
 	if (anonu != (uid_t)-2 && anonu != (0x10000-2))
-		seq_printf(m, "%sanonuid=%d", first++?",":"", anonu);
+		seq_printf(m, ",sanonuid=%d", anonu);
 	if (anong != (gid_t)-2 && anong != (0x10000-2))
-		seq_printf(m, "%sanongid=%d", first++?",":"", anong);
+		seq_printf(m, ",sanongid=%d", anong);
 	if (fsloc && fsloc->locations_count > 0) {
 		char *loctype = (fsloc->migrated) ? "refer" : "replicas";
 		int i;
 
-		seq_printf(m, "%s%s=", first++?",":"", loctype);
+		seq_printf(m, ",%s=", loctype);
 		seq_escape(m, fsloc->locations[0].path, ",;@ \t\n\\");
 		seq_putc(m, '@');
 		seq_escape(m, fsloc->locations[0].hosts, ",;@ \t\n\\");

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
