From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/6] NLM: Remove address eye-catcher buffers from nlm_host
Date: Mon, 01 Dec 2008 13:57:34 -0500
Message-ID: <20081201185734.10600.88841.stgit@ingres.1015granger.net>
References: <20081201185108.10600.21700.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:30903 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751291AbYLAS6k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2008 13:58:40 -0500
In-Reply-To: <20081201185108.10600.21700.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

Finally, AF_UNSPEC support is no longer needed in nlm_display_address()
now that it is not used for the h_srcaddr field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   14 +++-----------
 include/linux/lockd/lockd.h |    3 ---
 2 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index acc2aa5..68e00c0 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -112,9 +112,6 @@ static void nlm_display_address(const struct sockaddr *sap,
 	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
 
 	switch (sap->sa_family) {
-	case AF_UNSPEC:
-		snprintf(buf, len, "unspecified");
-		break;
 	case AF_INET:
 		snprintf(buf, len, NIPQUAD_FMT, NIPQUAD(sin->sin_addr.s_addr));
 		break;
@@ -178,7 +175,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 
 		nlm_get_host(host);
 		dprintk("lockd: nlm_lookup_host found host %s (%s)\n",
-				host->h_name, host->h_addrbuf);
+				host->h_name, nsm->sm_addrbuf);
 		goto out;
 	}
 
@@ -232,11 +229,6 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 
 	nrhosts++;
 
-	nlm_display_address((struct sockaddr *)&host->h_addr,
-				host->h_addrbuf, sizeof(host->h_addrbuf));
-	nlm_display_address((struct sockaddr *)&host->h_srcaddr,
-				host->h_srcaddrbuf, sizeof(host->h_srcaddrbuf));
-
 	dprintk("lockd: nlm_lookup_host created host %s\n",
 			host->h_name);
 
@@ -378,8 +370,8 @@ nlm_bind_host(struct nlm_host *host)
 {
 	struct rpc_clnt	*clnt;
 
-	dprintk("lockd: nlm_bind_host %s (%s), my addr=%s\n",
-			host->h_name, host->h_addrbuf, host->h_srcaddrbuf);
+	dprintk("lockd: nlm_bind_host %s (%s)\n",
+			host->h_name, host->h_nsmhandle->sm_addrbuf);
 
 	/* Lock host handle */
 	mutex_lock(&host->h_mutex);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 23da3fa..4467b83 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -65,9 +65,6 @@ struct nlm_host {
 	struct list_head	h_granted;	/* Locks in GRANTED state */
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
 	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
-
-	char			h_addrbuf[48],	/* address eyecatchers */
-				h_srcaddrbuf[48];
 };
 
 struct nsm_handle {

