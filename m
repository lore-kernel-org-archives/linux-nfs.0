From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] libexport.a: Add client_free()
Date: Mon, 19 Apr 2010 16:21:12 -0400
Message-ID: <20100419202111.3567.97747.stgit@matisse.1015granger.net>
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:50362 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767Ab0DSUVP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 16:21:15 -0400
Received: by mail-qy0-f179.google.com with SMTP id 9so6081157qyk.1
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 13:21:15 -0700 (PDT)
In-Reply-To: <20100419201855.3567.9644.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Introduce a helper to free a nfs_client record.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 6a25928..859dcf1 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -52,6 +52,13 @@ init_addrlist(nfs_client *clp, const struct hostent *hp)
 	clp->m_naddr = i;
 }
 
+static void
+client_free(nfs_client *clp)
+{
+	xfree(clp->m_hostname);
+	xfree(clp);
+}
+
 /* if canonical is set, then we *know* this is already a canonical name
  * so hostname lookup is avoided.
  * This is used when reading /proc/fs/nfs/exports
@@ -209,8 +216,7 @@ client_freeall(void)
 		head = clientlist + i;
 		while (*head) {
 			*head = (clp = *head)->m_next;
-			xfree(clp->m_hostname);
-			xfree(clp);
+			client_free(clp);
 		}
 	}
 }

