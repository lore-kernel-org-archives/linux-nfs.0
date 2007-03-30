From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 3/8] Hide differences between MIT and Heimdal in macros
Date: Fri, 30 Mar 2007 18:32:10 -0400
Message-ID: <20070330223210.28802.5513.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070330222511.28802.38147.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HXPdi-0000Ka-1a
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:10 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HXPdj-0006GN-5f
	for nfs@lists.sourceforge.net; Fri, 30 Mar 2007 15:32:11 -0700
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

Clean up a lot of #ifdef'd code using macros, masking
the differences between MIT and Heimdal implementations.
The currently unused macros will be used in later patches.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |   30 +++++-------------------------
 utils/gssd/krb5_util.h |   15 +++++++++++++++
 2 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index a0ee110..7ef690b 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -364,11 +364,7 @@ #endif
 			    "principal '%s' from keytab '%s'\n",
 			 error_message(code),
 			 pname ? pname : "<unparsable>", kt_name);
-#ifdef HAVE_KRB5
-		if (pname) krb5_free_unparsed_name(context, pname);
-#else
-		if (pname) free(pname);
-#endif
+		if (pname) k5_free_unparsed_name(context, pname);
 		goto out;
 	}
 
@@ -497,11 +493,7 @@ gssd_process_krb5_keytab(krb5_context co
 			if (ple == NULL) {
 				printerr(0, "ERROR: could not allocate storage "
 					    "for principal list entry\n");
-#ifdef HAVE_KRB5
-				krb5_free_unparsed_name(context, pname);
-#else
-				free(pname);
-#endif
+				k5_free_unparsed_name(context, pname);
 				krb5_kt_free_entry(context, &kte);
 				retval = ENOMEM;
 				goto out;
@@ -521,11 +513,7 @@ #endif
 				printerr(0, "ERROR: %s while copying realm to "
 					    "principal list entry\n",
 					 "not enough memory");
-#ifdef HAVE_KRB5
-				krb5_free_unparsed_name(context, pname);
-#else
-				free(pname);
-#endif
+				k5_free_unparsed_name(context, pname);
 				krb5_kt_free_entry(context, &kte);
 				retval = ENOMEM;
 				goto out;
@@ -535,11 +523,7 @@ #endif
 				printerr(0, "ERROR: %s while copying principal "
 					    "to principal list entry\n",
 					error_message(code));
-#ifdef HAVE_KRB5
-				krb5_free_unparsed_name(context, pname);
-#else
-				free(pname);
-#endif
+				k5_free_unparsed_name(context, pname);
 				krb5_kt_free_entry(context, &kte);
 				retval = code;
 				goto out;
@@ -555,11 +539,7 @@ #endif
 			printerr(2, "We will NOT use this entry (%s)\n",
 				pname);
 		}
-#ifdef HAVE_KRB5
-		krb5_free_unparsed_name(context, pname);
-#else
-		free(pname);
-#endif
+		k5_free_unparsed_name(context, pname);
 		krb5_kt_free_entry(context, &kte);
 	}
 
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index da04530..36dfcc8 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -27,4 +27,19 @@ #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
 int limit_krb5_enctypes(struct rpc_gss_sec *sec, uid_t uid);
 #endif
 
+/*
+ * Hide away some of the MIT vs. Heimdal differences
+ * here with macros...
+ */
+
+#ifdef HAVE_KRB5
+#define k5_free_unparsed_name(ctx, name)	krb5_free_unparsed_name((ctx), (name))
+#define k5_free_default_realm(ctx, realm)	krb5_free_default_realm((ctx), (realm))
+#define k5_free_kt_entry(ctx, kte)		krb5_free_keytab_entry_contents((ctx),(kte))
+#else	/* Heimdal */
+#define k5_free_unparsed_name(ctx, name)	free(name)
+#define k5_free_default_realm(ctx, realm)	free(realm)
+#define k5_free_kt_entry(ctx, kte)		krb5_kt_free_entry((ctx),(kte))
+#endif
+
 #endif /* KRB5_UTIL_H */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
