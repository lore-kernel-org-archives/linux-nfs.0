From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/17] NLM: Use modern style for pointer fields in nlm_host
Date: Thu, 04 Dec 2008 14:19:45 -0500
Message-ID: <20081204191944.8039.37301.stgit@ingres.1015granger.net>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:21692 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754496AbYLDTVZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Dec 2008 14:21:25 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: I'm about to add another "char *" field to the nlm_host
structure.  The h_name field, for example, uses an older style of
declaring a "char *" field.  If I match that style for the new field,
checkpatch.pl will complain.

So, fix pointer fields to use the new style.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/lockd/lockd.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 23da3fa..3dbdd35 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -43,8 +43,8 @@ struct nlm_host {
 	struct sockaddr_storage	h_addr;		/* peer address */
 	size_t			h_addrlen;
 	struct sockaddr_storage	h_srcaddr;	/* our address (optional) */
-	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
-	char *			h_name;		/* remote hostname */
+	struct rpc_clnt		*h_rpcclnt;	/* RPC client to talk to peer */
+	char			*h_name;		/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_reclaiming : 1,
@@ -64,7 +64,7 @@ struct nlm_host {
 	spinlock_t		h_lock;
 	struct list_head	h_granted;	/* Locks in GRANTED state */
 	struct list_head	h_reclaim;	/* Locks in RECLAIM state */
-	struct nsm_handle *	h_nsmhandle;	/* NSM status handle */
+	struct nsm_handle	*h_nsmhandle;	/* NSM status handle */
 
 	char			h_addrbuf[48],	/* address eyecatchers */
 				h_srcaddrbuf[48];

