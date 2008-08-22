From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] NLM: Clean up before introducing new debugging messages
Date: Fri, 22 Aug 2008 12:42:10 -0400
Message-ID: <20080822164209.20488.91980.stgit@manray.1015granger.net>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:33022 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbYHVQmj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 12:42:39 -0400
In-Reply-To: <20080822163939.20488.92983.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

