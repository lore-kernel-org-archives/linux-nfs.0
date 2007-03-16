From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 1/4] Don't leak keytab entries
Date: Fri, 16 Mar 2007 10:27:41 -0400
Message-ID: <20070316142741.6349.9723.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20070316141826.6349.9988.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSDPB-0007E9-UF
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:42 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSDPC-0006Oy-Va
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 07:27:44 -0700
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

Free keytab entries while processing keytab file.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 utils/gssd/krb5_util.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 6af2869..cd777e4 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -485,6 +485,7 @@ gssd_process_krb5_keytab(krb5_context co
 			printerr(0, "WARNING: Skipping keytab entry because "
 				    "we failed to unparse principal name: %s\n",
 				 error_message(code));
+			krb5_kt_free_entry(context, &kte);
 			continue;
 		}
 		printerr(2, "Processing keytab entry for principal '%s'\n",
@@ -510,6 +511,7 @@ #ifdef HAVE_KRB5
 #else
 				free(pname);
 #endif
+				krb5_kt_free_entry(context, &kte);
 				retval = ENOMEM;
 				goto out;
 			}
@@ -533,6 +535,7 @@ #ifdef HAVE_KRB5
 #else
 				free(pname);
 #endif
+				krb5_kt_free_entry(context, &kte);
 				retval = ENOMEM;
 				goto out;
 			}
@@ -546,6 +549,7 @@ #ifdef HAVE_KRB5
 #else
 				free(pname);
 #endif
+				krb5_kt_free_entry(context, &kte);
 				retval = code;
 				goto out;
 			}
@@ -565,6 +569,7 @@ #ifdef HAVE_KRB5
 #else
 		free(pname);
 #endif
+		krb5_kt_free_entry(context, &kte);
 	}
 
 	if ((code = krb5_kt_end_seq_get(context, kt, &cursor))) {

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
