From: NeilBrown <neilb@suse.de>
Subject: [PATCH 005 of 8] knfsd: nfsd: store export path in export
Date: Fri, 29 Sep 2006 13:09:04 +1000
Message-ID: <1060929030904.24096@suse.de>
References: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8kV-0007tn-BQ
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:09:15 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8kU-0005EL-F1
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:09:16 -0700
To: Andrew Morton <akpm@osdl.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: J.Bruce Fields <bfields@fieldses.org>

Store the export path in the svc_export structure instead of storing only
the dentry.  This will prevent the need for additional d_path calls to
provide NFSv4 fs_locations support.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/export.c            |   10 ++++++++++
 ./include/linux/nfsd/export.h |    1 +
 2 files changed, 11 insertions(+)

diff .prev/fs/nfsd/export.c ./fs/nfsd/export.c
--- .prev/fs/nfsd/export.c	2006-09-29 12:57:30.000000000 +1000
+++ ./fs/nfsd/export.c	2006-09-29 12:57:47.000000000 +1000
@@ -325,6 +325,7 @@ static void svc_export_put(struct kref *
 	dput(exp->ex_dentry);
 	mntput(exp->ex_mnt);
 	auth_domain_put(exp->ex_client);
+	kfree(exp->ex_path);
 	kfree(exp);
 }
 
@@ -398,6 +399,7 @@ static int svc_export_parse(struct cache
 	int an_int;
 
 	nd.dentry = NULL;
+	exp.ex_path = NULL;
 
 	if (mesg[mlen-1] != '\n')
 		return -EINVAL;
@@ -428,6 +430,10 @@ static int svc_export_parse(struct cache
 	exp.ex_client = dom;
 	exp.ex_mnt = nd.mnt;
 	exp.ex_dentry = nd.dentry;
+	exp.ex_path = kstrdup(buf, GFP_KERNEL);
+	err = -ENOMEM;
+	if (!exp.ex_path)
+		goto out;
 
 	/* expiry */
 	err = -EINVAL;
@@ -473,6 +479,7 @@ static int svc_export_parse(struct cache
 	else
 		exp_put(expp);
  out:
+ 	kfree(exp.ex_path);
 	if (nd.dentry)
 		path_release(&nd);
  out_no_path:
@@ -524,6 +531,7 @@ static void svc_export_init(struct cache
 	new->ex_client = item->ex_client;
 	new->ex_dentry = dget(item->ex_dentry);
 	new->ex_mnt = mntget(item->ex_mnt);
+	new->ex_path = NULL;
 }
 
 static void export_update(struct cache_head *cnew, struct cache_head *citem)
@@ -535,6 +543,8 @@ static void export_update(struct cache_h
 	new->ex_anon_uid = item->ex_anon_uid;
 	new->ex_anon_gid = item->ex_anon_gid;
 	new->ex_fsid = item->ex_fsid;
+	new->ex_path = item->ex_path;
+	item->ex_path = NULL;
 }
 
 static struct cache_head *svc_export_alloc(void)

diff .prev/include/linux/nfsd/export.h ./include/linux/nfsd/export.h
--- .prev/include/linux/nfsd/export.h	2006-09-29 12:57:30.000000000 +1000
+++ ./include/linux/nfsd/export.h	2006-09-29 12:57:47.000000000 +1000
@@ -51,6 +51,7 @@ struct svc_export {
 	int			ex_flags;
 	struct vfsmount *	ex_mnt;
 	struct dentry *		ex_dentry;
+	char *			ex_path;
 	uid_t			ex_anon_uid;
 	gid_t			ex_anon_gid;
 	int			ex_fsid;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
