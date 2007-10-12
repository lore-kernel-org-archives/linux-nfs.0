From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 2/9] Make print_hexl function write to stdout rather
	than	using printerr
Date: Fri, 12 Oct 2007 16:34:49 -0400
Message-ID: <20071012203449.24796.96254.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRDZ-00089Y-BG
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:45 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRDe-0002fr-Db
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:50 -0700
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

print_hexl() currently uses printerr, but is really only necessary
for local debugging and should simply write to stdout.
Also change it to print the description internally.
Wrap it and its use in #ifdef DEBUG.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/svcgssd_proc.c |   33 ++++++++++++++++++---------------
 1 files changed, 18 insertions(+), 15 deletions(-)

diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 7c58f7b..52c3aaf 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -250,42 +250,43 @@ out:
 	return res;
 }
 
+#ifdef DEBUG
 void
-print_hexl(int pri, unsigned char *cp, int length)
+print_hexl(const char *description, unsigned char *cp, int length)
 {
 	int i, j, jm;
 	unsigned char c;
 
-	printerr(pri, "length %d\n",length);
-	printerr(pri, "\n");
+	printf("%s (length %d)\n", description, length);
 
 	for (i = 0; i < length; i += 0x10) {
-		printerr(pri, "  %04x: ", (u_int)i);
+		printf("  %04x: ", (u_int)i);
 		jm = length - i;
 		jm = jm > 16 ? 16 : jm;
 
 		for (j = 0; j < jm; j++) {
 			if ((j % 2) == 1)
-				printerr(pri,"%02x ", (u_int)cp[i+j]);
+				printf("%02x ", (u_int)cp[i+j]);
 			else
-				printerr(pri,"%02x", (u_int)cp[i+j]);
+				printf("%02x", (u_int)cp[i+j]);
 		}
 		for (; j < 16; j++) {
 			if ((j % 2) == 1)
-				printerr(pri,"   ");
+				printf("   ");
 			else
-				printerr(pri,"  ");
+				printf("  ");
 		}
-		printerr(pri," ");
+		printf(" ");
 
 		for (j = 0; j < jm; j++) {
 			c = cp[i+j];
 			c = isprint(c) ? c : '.';
-			printerr(pri,"%c", c);
+			printf("%c", c);
 		}
-		printerr(pri,"\n");
+		printf("\n");
 	}
 }
+#endif
 
 void
 handle_nullreq(FILE *f) {
@@ -326,13 +327,15 @@ handle_nullreq(FILE *f) {
 
 	in_handle.length = (size_t) qword_get(&cp, in_handle.value,
 					      sizeof(in_handle_buf));
-	printerr(2, "in_handle: \n");
-	print_hexl(2, in_handle.value, in_handle.length);
+#ifdef DEBUG
+	print_hexl("in_handle", in_handle.value, in_handle.length);
+#endif
 
 	in_tok.length = (size_t) qword_get(&cp, in_tok.value,
 					   sizeof(in_tok_buf));
-	printerr(2, "in_tok: \n");
-	print_hexl(2, in_tok.value, in_tok.length);
+#ifdef DEBUG
+	print_hexl("in_tok", in_tok.value, in_tok.length);
+#endif
 
 	if (in_tok.length < 0) {
 		printerr(0, "WARNING: handle_nullreq: "


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
