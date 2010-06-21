From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/7] exportfs: Add a common exit label in exportfs()
Date: Mon, 21 Jun 2010 12:54:28 -0400
Message-ID: <20100621165428.4771.31564.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757288Ab0FUQyb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:54:31 -0400
Received: by mail-iw0-f174.google.com with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:54:31 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Reduce code duplication by introducing a goto label for
freeing hp and exiting.  This will make replacing "struct hostent *"
with "struct addrinfo *" more straightforward in this code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/exportfs/exportfs.c |   14 ++++++--------
 1 files changed, 6 insertions(+), 8 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 83d00a0..50f1e34 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -263,14 +263,10 @@ exportfs(char *arg, char *options, int verbose)
 
 	if (!exp) {
 		if (!(eep = mkexportent(hname, path, options)) ||
-		    !(exp = export_create(eep, 0))) {
-			if (hp) free (hp);
-			return;
-		}
-	} else if (!updateexportent(&exp->m_export, options)) {
-		if (hp) free (hp);
-		return;
-	}
+		    !(exp = export_create(eep, 0)))
+			goto out;
+	} else if (!updateexportent(&exp->m_export, options))
+		goto out;
 
 	if (verbose)
 		printf("exporting %s:%s\n", exp->m_client->m_hostname, 
@@ -280,6 +276,8 @@ exportfs(char *arg, char *options, int verbose)
 	exp->m_changed = 1;
 	exp->m_warned = 0;
 	validate_export(exp);
+
+out:
 	if (hp) free (hp);
 }
 

