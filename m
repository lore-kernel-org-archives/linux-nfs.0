From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/4] libexport.a: Allow m_hostname allocation to fail instead
	of exit
Date: Mon, 19 Apr 2010 16:21:32 -0400
Message-ID: <20100419202131.3567.12042.stgit@matisse.1015granger.net>
References: <20100419201855.3567.9644.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:64741 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0DSUVf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Apr 2010 16:21:35 -0400
Received: by mail-vw0-f46.google.com with SMTP id 5so2418494vws.19
        for <linux-nfs@vger.kernel.org>; Mon, 19 Apr 2010 13:21:34 -0700 (PDT)
In-Reply-To: <20100419201855.3567.9644.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Replace xstrdup() with strdup(3) in client_init(), to
prevent the process from exiting if the memory allocation fails.

Note that both of client_init()'s callers set m_hostname equal to NULL
before calling, thus the extra free(3) at the top of client_init() is
unneeded.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 8f83da3..fc1ade9 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -55,7 +55,7 @@ init_addrlist(nfs_client *clp, const struct hostent *hp)
 static void
 client_free(nfs_client *clp)
 {
-	xfree(clp->m_hostname);
+	free(clp->m_hostname);
 	xfree(clp);
 }
 
@@ -154,11 +154,9 @@ client_dup(nfs_client *clp, struct hostent *hp)
 static int
 client_init(nfs_client *clp, const char *hname, struct hostent *hp)
 {
-	xfree(clp->m_hostname);
-	if (hp)
-		clp->m_hostname = xstrdup(hp->h_name);
-	else
-		clp->m_hostname = xstrdup(hname);
+	clp->m_hostname = strdup(hname);
+	if (clp->m_hostname == NULL)
+		return false;
 
 	clp->m_exported = 0;
 	clp->m_count = 0;

