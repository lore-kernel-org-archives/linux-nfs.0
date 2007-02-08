From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 04/12] Treat GSSAPI error codes as unsigned.
Date: Thu, 08 Feb 2007 17:27:09 -0500
Message-ID: <20070208222709.23464.99504.stgit@rock.citi.umich.edu>
References: <20070208222606.23464.71348.stgit@rock.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFHk4-0006sR-Q9
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:48 -0800
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFHk6-0004Pa-Gz
	for nfs@lists.sourceforge.net; Thu, 08 Feb 2007 14:27:50 -0800
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

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>

GSSAPI error codes (major and minor) are defined as unsigned values.
However, we treat them as signed while passing them down to the
kernel where conversion fails if they include the minus sign.
Convert them as unsigned.
---

 utils/gssd/cacheio.c      |   11 +++++++++++
 utils/gssd/cacheio.h      |    1 +
 utils/gssd/svcgssd_proc.c |    4 ++--
 3 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/cacheio.c b/utils/gssd/cacheio.c
index f2f2960..e24ef56 100644
--- a/utils/gssd/cacheio.c
+++ b/utils/gssd/cacheio.c
@@ -132,6 +132,17 @@ void qword_addint(char **bpp, int *lp, i
 	*lp -= len;
 }
 
+void qword_adduint(char **bpp, int *lp, unsigned int n)
+{
+	int len;
+
+	len = snprintf(*bpp, *lp, "%u ", n);
+	if (len > *lp)
+		len = *lp;
+	*bpp += len;
+	*lp -= len;
+}
+
 void qword_addeol(char **bpp, int *lp)
 {
 	if (*lp <= 0)
diff --git a/utils/gssd/cacheio.h b/utils/gssd/cacheio.h
index dfff258..6585fc7 100644
--- a/utils/gssd/cacheio.h
+++ b/utils/gssd/cacheio.h
@@ -36,6 +36,7 @@ #include <stdio.h>
 void qword_add(char **bpp, int *lp, char *str);
 void qword_addhex(char **bpp, int *lp, char *buf, int blen);
 void qword_addint(char **bpp, int *lp, int n);
+void qword_adduint(char **bpp, int *lp, unsigned int n);
 void qword_addeol(char **bpp, int *lp);
 void qword_print(FILE *f, char *str);
 void qword_printhex(FILE *f, char *str, int slen);
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 4037159..7c58f7b 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -125,8 +125,8 @@ send_response(FILE *f, gss_buffer_desc *
 	qword_addhex(&bp, &blen, in_handle->value, in_handle->length);
 	qword_addhex(&bp, &blen, in_token->value, in_token->length);
 	qword_addint(&bp, &blen, 0x7fffffff); /*XXX need a better timeout */
-	qword_addint(&bp, &blen, maj_stat);
-	qword_addint(&bp, &blen, min_stat);
+	qword_adduint(&bp, &blen, maj_stat);
+	qword_adduint(&bp, &blen, min_stat);
 	qword_addhex(&bp, &blen, out_handle->value, out_handle->length);
 	qword_addhex(&bp, &blen, out_token->value, out_token->length);
 	qword_addeol(&bp, &blen);

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
