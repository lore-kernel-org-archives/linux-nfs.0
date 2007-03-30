From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 6/8] Clean up gssd_get_single_krb5_cred and its
	debugging messages
Date: Fri, 30 Mar 2007 18:32:17 -0400
Message-ID: <20070330223216.28802.24110.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdo-0000L1-Qc
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:17 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPdp-0006Mi-QW
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:19 -0700
In-Reply-To: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
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

Clean up gssd_get_single_krb5_cred and its debugging messages

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |   20 ++++++++++++--------
 1 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index dee2639..5d433b1 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -334,6 +334,7 @@ gssd_get_single_krb5_cred(krb5_context c
 	int code;
 	time_t now = time(0);
 	char *cache_type;
+	char *pname = NULL;
 
 	memset(&my_creds, 0, sizeof(my_creds));
 
@@ -350,6 +351,9 @@ gssd_get_single_krb5_cred(krb5_context c
 		goto out;
 	}
 
+	if ((krb5_unparse_name(context, ple->princ, &pname)))
+		pname = NULL;
+
 	krb5_get_init_creds_opt_init(&options);
 	krb5_get_init_creds_opt_set_address_list(&options, NULL);
 
@@ -360,15 +364,10 @@ #ifdef TEST_SHORT_LIFETIME
 #endif
 	if ((code = krb5_get_init_creds_keytab(context, &my_creds, ple->princ,
 					       kt, 0, NULL, &options))) {
-		char *pname;
-		if ((krb5_unparse_name(context, ple->princ, &pname))) {
-			pname = NULL;
-		}
 		printerr(0, "WARNING: %s while getting initial ticket for "
-			    "principal '%s' from keytab '%s'\n",
+			 "principal '%s' using keytab '%s'\n",
 			 error_message(code),
 			 pname ? pname : "<unparsable>", kt_name);
-		if (pname) k5_free_unparsed_name(context, pname);
 		goto out;
 	}
 
@@ -385,10 +384,12 @@ #endif
 		GSSD_DEFAULT_CRED_DIR, GSSD_DEFAULT_CRED_PREFIX,
 		GSSD_DEFAULT_MACHINE_CRED_SUFFIX, ple->realm);
 	ple->endtime = my_creds.times.endtime;
+	if (ple->ccname != NULL)
+		free(ple->ccname);
 	ple->ccname = strdup(cc_name);
 	if (ple->ccname == NULL) {
 		printerr(0, "ERROR: no storage to duplicate credentials "
-			    "cache name\n");
+			    "cache name '%s'\n", cc_name);
 		code = ENOMEM;
 		goto out;
 	}
@@ -409,8 +410,11 @@ #endif
 	}
 
 	code = 0;
-	printerr(1, "Using (machine) credentials cache: '%s'\n", cc_name);
+	printerr(2, "Successfully obtained machine credentials for "
+		 "principal '%s' stored in ccache '%s'\n", pname, cc_name);
   out:
+	if (pname)
+		k5_free_unparsed_name(context, pname);
 	if (ccache)
 		krb5_cc_close(context, ccache);
 	krb5_free_cred_contents(context, &my_creds);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
