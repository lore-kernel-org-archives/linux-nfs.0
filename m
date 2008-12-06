From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/27] NSM: Generate NSMPROC_MON's "priv" argument when
	nsm_handle is created
Date: Fri, 05 Dec 2008 19:03:16 -0500
Message-ID: <20081206000316.24075.50096.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:16722 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223AbYLFAE3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:29 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce a new data type, used by both the in-kernel NLM and NSM
implementations, that is used to manage the opaque "priv" argument
for the NSMPROC_MON and NLMPROC_SM_NOTIFY calls.

Construct the "priv" cookie when the nsm_handle is created.

The nsm_init_private() function may look a little strange, but it is
roughly equivalent to how the XDR encoder formed the "priv" argument.
It's going to go away soon.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c                 |   16 ++++++++++++++++
 include/linux/lockd/lockd.h    |    1 +
 include/linux/lockd/sm_inter.h |    1 -
 include/linux/lockd/xdr.h      |    6 ++++++
 4 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index c2f4607..a6504f4 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -202,6 +202,21 @@ void nsm_unmonitor(const struct nlm_host *host)
 	}
 }
 
+/*
+ * Construct a unique cookie to match this nsm_handle to this monitored
+ * host.  It is passed to the local rpc.statd via NSMPROC_MON, and
+ * returned via NLMPROC_SM_NOTIFY, in the "priv" field of these
+ * requests.
+ *
+ * Linux provides the raw IP address of the monitored host,
+ * left in network byte order.
+ */
+static void nsm_init_private(struct nsm_handle *nsm)
+{
+	__be32 *p = (__be32 *)&nsm->sm_priv.data;
+	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
+}
+
 /**
  * nsm_find - Find or create a cached nsm_handle
  * @sap: pointer to socket address of handle to find
@@ -275,6 +290,7 @@ retry:
 	nsm->sm_name = (char *) (nsm + 1);
 	memcpy(nsm->sm_name, hostname, hostname_len);
 	nsm->sm_name[hostname_len] = '\0';
+	nsm_init_private(nsm);
 	nsm_display_address((struct sockaddr *)&nsm->sm_addr,
 				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
 	atomic_set(&nsm->sm_count, 1);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 8d71536..194fa8a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -85,6 +85,7 @@ struct nsm_handle {
 	size_t			sm_addrlen;
 	unsigned int		sm_monitored : 1,
 				sm_sticky : 1;	/* don't unmonitor */
+	struct nsm_private	sm_priv;
 	char			sm_addrbuf[NSM_ADDRBUF];
 };
 
diff --git a/include/linux/lockd/sm_inter.h b/include/linux/lockd/sm_inter.h
index 116bf38..5cef5a7 100644
--- a/include/linux/lockd/sm_inter.h
+++ b/include/linux/lockd/sm_inter.h
@@ -10,7 +10,6 @@
 #define LINUX_LOCKD_SM_INTER_H
 
 #define SM_MAXSTRLEN	1024
-#define SM_PRIV_SIZE	16
 
 extern int	nsm_local_state;
 
diff --git a/include/linux/lockd/xdr.h b/include/linux/lockd/xdr.h
index d6b3a80..6b51992 100644
--- a/include/linux/lockd/xdr.h
+++ b/include/linux/lockd/xdr.h
@@ -13,6 +13,12 @@
 #include <linux/nfs.h>
 #include <linux/sunrpc/xdr.h>
 
+#define SM_PRIV_SIZE		16
+
+struct nsm_private {
+	unsigned char		data[SM_PRIV_SIZE];
+};
+
 struct svc_rqst;
 
 #define NLM_MAXCOOKIELEN    	32

