From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 3/4] Allow any credential to be used for machine
	credentials
Date: Fri, 16 Mar 2007 10:27:46 -0400
Message-ID: <20070316142746.6349.7837.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSDPG-0007EK-3K
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:46 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HSDPH-0007xq-14
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:48 -0700
In-Reply-To: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
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

Don't restrict machine credentials to be "nfs/<machine.name>".
Use any usable credentials contained in the keytab file.
[We actually attempt to use the first entry found for each
realm, not every entry, in the keytab.]

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/gssd.man    |   12 ++++++++++--
 utils/gssd/krb5_util.c |   22 ++++++----------------
 2 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 1a30d69..f2ecd69 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -41,10 +41,18 @@ authentication.
 .B -k keytab
 Tells
 .B rpc.gssd
-to use the keys for principals nfs/hostname in
+to use the keys found in
 .I keytab
-to obtain machine credentials.
+to obtain "machine credentials".
 The default value is "/etc/krb5.keytab".
+Previous versions of
+.B rpc.gssd
+used only "nfs/*" keys found within the keytab.
+Now, the first keytab entry for each distinct Kerberos realm
+within the keytab is used.  This means that an NFS client
+no longer needs an "nfs/hostname" principal and keytab entry,
+but can instead use a "host/hostname" (or any other) keytab
+entry that is available.
 .TP
 .B -p path
 Tells
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index cd777e4..f1682b8 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -448,7 +448,7 @@ #endif
 
 /*
  * Process the given keytab file and create a list of principals we
- * might use to perform mount operations.
+ * might use as machine credentials.
  *
  * Returns:
  *	0 => Sucess
@@ -465,9 +465,8 @@ gssd_process_krb5_keytab(krb5_context co
 
 	/*
 	 * Look through each entry in the keytab file and determine
-	 * if we might want to use it later to do a mount.  If so,
-	 * save info in the global principal list
-	 * (gssd_k5_kt_princ_list).
+	 * if we might want to use it as machine credentials.  If so,
+	 * save info in the global principal list (gssd_k5_kt_princ_list).
 	 * Note: (ple == principal list entry)
 	 */
 	if ((code = krb5_kt_start_seq_get(context, kt, &cursor))) {
@@ -490,18 +489,9 @@ gssd_process_krb5_keytab(krb5_context co
 		}
 		printerr(2, "Processing keytab entry for principal '%s'\n",
 			 pname);
-#ifdef HAVE_KRB5
-		if ( (kte.principal->data[0].length == GSSD_SERVICE_NAME_LEN) &&
-		     (strncmp(kte.principal->data[0].data, GSSD_SERVICE_NAME,
-			      GSSD_SERVICE_NAME_LEN) == 0) &&
-#else
-		if ( (strlen(kte.principal->name.name_string.val[0]) == GSSD_SERVICE_NAME_LEN) &&
-		     (strncmp(kte.principal->name.name_string.val[0], GSSD_SERVICE_NAME,
-			      GSSD_SERVICE_NAME_LEN) == 0) &&
-			      
-#endif
-		     (!gssd_have_realm_ple((void *)&kte.principal->realm)) ) {
-			printerr(2, "We will use this entry (%s)\n", pname);
+		/* Just use the first keytab entry found for each realm */
+	        if ((!gssd_have_realm_ple((void *)&kte.principal->realm)) ) {
+			printerr(2, "We WILL use this entry (%s)\n", pname);
 			ple = malloc(sizeof(struct gssd_k5_kt_princ));
 			if (ple == NULL) {
 				printerr(0, "ERROR: could not allocate storage "

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
