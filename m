From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/17] NLM: Remove address eye-catcher buffers from nlm_host
Date: Thu, 04 Dec 2008 14:19:53 -0500
Message-ID: <20081204191953.8039.74447.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:16517 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205AbYLDTUP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:20:15 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The h_name field in struct nlm_host is a just copy of
h_nsmhandle->sm_name.  Likewise, the contents of the h_addrbuf field
should be identical to the sm_addrbuf field.

The h_srcaddrbuf field is used only in one place for debugging.  We can
live without this until we get %pI formatting for printk().

Currently these buffers are 48 bytes, but we need to support scope IDs
in IPv6 presentation addresses, which means making the buffers even
larger.  Instead, let's find ways to eliminate them to save space.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   10 +++-------
 include/linux/lockd/lockd.h |    4 +---
 2 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index acc2aa5..9bc61f4 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -206,6 +206,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 		goto out;
 	}
 	host->h_name	   = nsm->sm_name;
+	host->h_addrbuf    = nsm->sm_addrbuf;
 	memcpy(nlm_addr(host), ni->sap, ni->salen);
 	host->h_addrlen = ni->salen;
 	nlm_clear_port(nlm_addr(host));
@@ -232,11 +233,6 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 
 	nrhosts++;
 
-	nlm_display_address((struct sockaddr *)&host->h_addr,
-				host->h_addrbuf, sizeof(host->h_addrbuf));
-	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
-				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
-
 	dprintk("lockd: nlm_lookup_host created host %s\n",
 			host->h_name);
 
@@ -378,8 +374,8 @@ nlm_bind_host(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 
-	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
-			host->h_name, host->h_addrbuf, host->h_srcaddrbuf);
+	dprintk("lockd: nlm_bind_host %s (%s)\n",
+			host->h_name, host->h_addrbuf);
 
 	/* Lock host handle */
 	mutex_lock(&host->h_mutex);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 3dbdd35..dae22cb 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -65,9 +65,7 @@ struct nlm_host {
 	struct list_head	h_granted;	/* Locks in GRANTED state */
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
 	struct nsm_handle	*h_nsmhandle;	/* NSM status handle */
-
-	char			h_addrbuf[48],	/* address eyecatchers */
-				h_srcaddrbuf[48];
+	char			*h_addrbuf;	/* address eyecatcher */
 };
 
 struct nsm_handle {

