From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 11/12] Remove duplicated code.
Date: Thu, 08 Feb 2007 17:27:45 -0500
Message-ID: <20070208222745.23464.37061.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk7-0006ss-Dp
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:51 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HFHk9-0006oE-2t
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:53 -0800
In-Reply-To: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

Remove duplicated code.
---

 utils/mountd/cache.c |   41 +++++++++++++++++++++--------------------
 1 files changed, 21 insertions(+), 20 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 89dc642..1da13db 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -260,6 +260,21 @@ static void write_fsloc(FILE *f, struct 
 	release_replicas(servers);
 }
 
+static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *exp)
+{
+	qword_print(f, domain);
+	qword_print(f, path);
+	qword_printint(f, time(0)+30*60);
+	if (exp) {
+		qword_printint(f, exp->e_flags);
+		qword_printint(f, exp->e_anonuid);
+		qword_printint(f, exp->e_anongid);
+		qword_printint(f, exp->e_fsid);
+		write_fsloc(f, exp, exp->e_path);
+	}
+	return qword_eol(f);
+}
+
 void nfsd_export(FILE *f)
 {
 	/* requests are:
@@ -308,18 +323,13 @@ void nfsd_export(FILE *f)
 		}
 	}
 
-	qword_print(f, dom);
-	qword_print(f, path);
-	qword_printint(f, time(0)+30*60);
 	if (found) {
-		qword_printint(f, found->m_export.e_flags);
-		qword_printint(f, found->m_export.e_anonuid);
-		qword_printint(f, found->m_export.e_anongid);
-		qword_printint(f, found->m_export.e_fsid);
-		write_fsloc(f, &found->m_export, path);
+		dump_to_cache(f, dom, path, &found->m_export);
 		mountlist_add(dom, path);
 	}
-	qword_eol(f);
+	else {
+		dump_to_cache(f, dom, path, NULL);
+	}
  out:
 	if (dom) free(dom);
 	if (path) free(path);
@@ -385,18 +395,9 @@ int cache_export_ent(char *domain, struc
 	if (!f)
 		return -1;
 
-	qword_print(f, domain);
-	qword_print(f, exp->e_path);
-	qword_printint(f, time(0)+30*60);
-	qword_printint(f, exp->e_flags);
-	qword_printint(f, exp->e_anonuid);
-	qword_printint(f, exp->e_anongid);
-	qword_printint(f, exp->e_fsid);
-	write_fsloc(f, exp, exp->e_path);
-	mountlist_add(domain, exp->e_path);
-	qword_eol(f);
-
+	err = dump_to_cache(f, domain, exp->e_path, exp);
 	fclose(f);
+	mountlist_add(domain, exp->e_path);
 	return err;
 }
 

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
