From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 3/9] Use printerr to print svcgssd downcall debugging
	info
Date: Fri, 12 Oct 2007 16:34:54 -0400
Message-ID: <20071012203454.24796.7255.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRDf-00089e-3X
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:51 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRDk-0007S1-7k
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:56 -0700
In-Reply-To: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
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

From: Kevin Coffman <kwc@citi.umich.edu>

Rather than depending on modified qword_* functions to print
svcgssd debugging information, use printerr in the downcall
function.

And while we're at it, label things so we know what we're looking at!

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/cacheio.c      |   11 -----------
 utils/gssd/svcgssd_proc.c |    8 +++++++-
 2 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/utils/gssd/cacheio.c b/utils/gssd/cacheio.c
index e24ef56..f47f1fa 100644
--- a/utils/gssd/cacheio.c
+++ b/utils/gssd/cacheio.c
@@ -153,17 +153,12 @@ void qword_addeol(char **bpp, int *lp)
 }
 
 static char qword_buf[8192];
-static char tmp_buf[8192];
 void qword_print(FILE *f, char *str)
 {
 	char *bp = qword_buf;
 	int len = sizeof(qword_buf);
 	qword_add(&bp, &len, str);
 	fwrite(qword_buf, bp-qword_buf, 1, f);
-	/* XXX: */
-	memcpy(tmp_buf, qword_buf, bp-qword_buf);
-	tmp_buf[bp-qword_buf] = '\0';
-	printerr(2, "%s", tmp_buf);
 }
 
 void qword_printhex(FILE *f, char *str, int slen)
@@ -172,16 +167,11 @@ void qword_printhex(FILE *f, char *str, int slen)
 	int len = sizeof(qword_buf);
 	qword_addhex(&bp, &len, str, slen);
 	fwrite(qword_buf, bp-qword_buf, 1, f);
-	/* XXX: */
-	memcpy(tmp_buf, qword_buf, bp-qword_buf);
-	tmp_buf[bp-qword_buf] = '\0';
-	printerr(2, "%s", tmp_buf);
 }
 
 void qword_printint(FILE *f, int num)
 {
 	fprintf(f, "%d ", num);
-	printerr(2, "%d ", num);
 }
 
 int qword_eol(FILE *f)
@@ -189,7 +179,6 @@ int qword_eol(FILE *f)
 	int err;
 	fprintf(f,"\n");
 	err = fflush(f);
-	printerr(2, "\n");
 	return err;
 }
 
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 52c3aaf..2dffa83 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -90,8 +90,14 @@ do_svc_downcall(gss_buffer_desc *out_handle, struct svc_cred *cred,
 	qword_printint(f, cred->cr_uid);
 	qword_printint(f, cred->cr_gid);
 	qword_printint(f, cred->cr_ngroups);
-	for (i=0; i < cred->cr_ngroups; i++)
+	printerr(2, "mech: %s, hndl len: %d, ctx len %d, timeout: %d, "
+		 "uid: %d, gid: %d, num aux grps: %d:\n",
+		 fname, out_handle->length, context_token->length, 0x7fffffff,
+		 cred->cr_uid, cred->cr_gid, cred->cr_ngroups);
+	for (i=0; i < cred->cr_ngroups; i++) {
 		qword_printint(f, cred->cr_groups[i]);
+		printerr(2, "  (%4d) %d\n", i+1, cred->cr_groups[i]);
+	}
 	qword_print(f, fname);
 	qword_printhex(f, context_token->value, context_token->length);
 	err = qword_eol(f);


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
