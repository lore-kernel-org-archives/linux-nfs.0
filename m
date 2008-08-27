From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] NLM: Clean up before introducing new debugging messages
Date: Wed, 27 Aug 2008 16:57:15 -0400
Message-ID: <20080827205714.17837.95227.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:59698 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752834AbYH0U6R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:58:17 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We're about to introduce some extra debugging messages in nlm_lookup_host().
Bring the coding style up to date first so we can cleanly introduce the new
debugging messages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index a17664c..cb26e3d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -103,16 +103,19 @@ static struct nlm_host *nlm_lookup_host(int server,
 		nlm_get_host(host);
 		goto out;
 	}
-	if (nsm)
-		atomic_inc(&nsm->sm_count);
-
-	host = NULL;
 
-	/* Sadly, the host isn't in our hash table yet. See if
-	 * we have an NSM handle for it. If not, create one.
+	/*
+	 * The host wasn't in our hash table.  If we don't
+	 * have an NSM handle for it yet, create one.
 	 */
-	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
-		goto out;
+	if (nsm)
+		atomic_inc(&nsm->sm_count);
+	else {
+		host = NULL;
+		nsm = nsm_find(sin, hostname, hostname_len);
+		if (!nsm)
+			goto out;
+	}
 
 	host = kzalloc(sizeof(*host), GFP_KERNEL);
 	if (!host) {

