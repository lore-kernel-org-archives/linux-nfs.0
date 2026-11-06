Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793945284;
	b=s/tEIf2+wbNc8V2MdaVECUBwQCYpGPM57kQRExJL0wNc0+A6leolb8Ga8I02CD/IQeyz
	 SDyqsEbzPk7wbyUZtjexDewJQTHo/hc3nH+C5aw6GHUpgn321cASwoFa8tBoShB7bWNFg
	 JVXSP1QtQgnco24BP1svQRkLl9W6C7AJ5322i53kzMTd1Y0R3HYVc2Gds03+5x852Ryz1
	 XnQE8867p3BPOlt3w9N+RrDtYSNRC9q+gzAyox0ZMmMTyc7GVshN8YkZZj/UOBF5FipsU
	 G4nWJOZrLYQkKV4h/G/Pivjm2gd+DJ6L4hPk/p0GlhhX9cUOFHLBxRxZWwNUH4uhvNQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793945284;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=a0zKFNSY5sEaJFF+2VZL4C671DXRma89VItapdXQj3I=;
	b=IXxwhFAD7+ApucIrZftYBWCqK8WgkJmCJhJ5KZj/uZSXJFvQTkgkDMQhlzH6RkJOvhD7
	 vmbb1Y2qZVHPJgpYnbryVSRzBYzkjmFLmWdEeRv0fTskuRm0K5UWj3Z9Ks53O+Wv7mrTb
	 ruNrJlmhHnBq4zzC5CAMRLjAsp5IJtj0I9iejJEvCy4ZCeyeCbnEUFjLBP6QieGPMbZol
	 zEIq8+p7juyQGYhpggx909hyd69+ydQsdJ3x5L3tQjlAZd+HOQgezrk7MTkvLK3lO4wZ7
	 rP6yI7qYDG5XPq/WjkrnEw/Bd/FmIxuni/UDcKDspPGoPD5v2vWHheDYdEV9cMi5Qdg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b="Q/8Uck+A";
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3A73606A333;
	Fri,  6 Nov 2026 06:08:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A3A73606A333
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=Q/8Uck+A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1793945282;
	bh=Ymh5l37azzUz/iuGx3AJgxSfhjkIPytOYWVOy/hm0Yc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Q/8Uck+AlWNdUpZn0KeIrjOwP9Up7ItaWFVWReBYQscviBvQSTBDt5RzBpSb0xUEH
	 ty5nnJhq0C8ATu6Gcmo93Gs1/oKB7lWUAHnSQjcPaQYW6PrydvT2Gt6zQwCdeOyy0X
	 Df9ToEGmdsz9bMozU3kf2Yx9EAWSjmzvwtNoBpf/md/TTT4Fkz+cMnz2jc62UyjtTI
	 qXY4YZS0ji1P3N/0HiwGILeYAi7hK/ybi4sWE85dx07pLbVsU8Awwa/YA5jBsn+ElG
	 Mt5zDLC69UzzRCxU8DAAz4pKRrtpPo0MMwbb4cpu6YETnA+5Rw2wtAJ1jd9OcunKdo
	 5dbPJJ96UYnaA==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id C818910924141;
	Fri,  6 Nov 2026 06:08:00 +0000 (UTC)
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfauth.phl.internal (Postfix) with ESMTP id AAFFCF40066;
	Fri,  6 Nov 2026 01:07:59 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Fri, 06 Nov 2026 01:07:59 -0500
X-ME-Sender: <xms:v27tag_tQ6kpPoh49D3nayd77LQbNCI73cB8iUSKlPlW-5--A_BkQg>
    <xme:v27tajF-8Ctjr2qz8ttG8eDD7ehAWfOeJr9DeOOSvj2mSQTst6fFs4V6MKfqjPY1m
    vI7OOQz9lloNvGo0SxagW383CqYH8xQgOUuGtOVfjcoLXZbDk35w-3C>
X-ME-Received: <xmr:v27tasJguEZ_kfGlp_OMNwgx2CY8RTRw86fqYthaXgIdyc-2WJ3GttPOffzwOTHKTbDMsDTs_srdC8SoCZLFA4fC-TUK624VU5OQMkYnmHc>
X-ME-Proxy-Cause: dmFkZTGJt3n1PQXC/FQG1+B4dDYdd7jzhZlyl3cBdgxPjc5MzKuIVzENiuR0E8tXhVCYot
    oOxwUXQVpp6VAEFUg+Uag3+jV3NxxQBqkuwqHRpa3avIMsMf5rLSrLvoU9/YiPtVmmw1Nh
    zLPLiGNoLWEom9MXOxTuny0wuIwJj+YnwLd3gmlT78BD8tHIS3uMrtPiOeTkzb/BpfqHcJ
    ZJYCN1MdLe92Bp5QjUXsKpkDjC+xSg0gfYGGYkLbuDh5Mj+BFcqCO2KyQpU99GhnUhksCQ
    Jqp321gTZQ359Pfjg6F4oa2enLz7ZLclUfrma4OACrOvjp2Zeu6dpHGkjEpDMo+QrHIVMT
    Y5NLUAZ7xttUV8yw2L/EAfMFcEtjUl8AVZ87rWCSUT7yFwClTc3zmQF126lj8Ob8X7Qp5X
    yM4rnV27L+2vdh3HVpI6fHvASta3yTp7rhh3u2AyVtaPnrpsg230CZIdDdBo9Z2LNhpIXR
    JHHmxVMbAA4iZpdKWtP9VrGXobnkYD93sPOofRYuGNpzZ2vMTvuJqvpVibkUvcGd7E6hO6
    9wQv2QEQG6sgrRhi21IYcj9/7tQZH3rMRxQCmIbDNwGessANy1lOY++zusKFNpZfjrK2ay
    DlBmUKXvr2qLRdeIwOHNXYXeso+IvJw5NIXkcWmgbjo7pGQfmnWtblnYPHWQ
X-ME-Proxy: <xmx:v27tarmirk35R3bGqtQ1tb52nfv2PAUVt2WZtEwXhls1hCODcDGlDw>
    <xmx:v27tatyDRP7PMqhVEOK9DOHeUWMfvrCcrGmlTFS_znC49FIVYSrjDQ>
    <xmx:v27tats_HlyWNLUj_GFTmOH6FXL2G_kCKFbf1v5BBLcLTzdwey_Jvw>
    <xmx:v27tanFiB48yJdQrQU_KzuH71hg_9bOqSlKqMZsKkSlh91kyypFEwg>
    <xmx:v27tar4_VJ31TJ8MXHl2UUJiMNnaTOvqPRywI4V8O9A1p_ZNlWcv3W7k>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 6 Nov 2026 01:07:55 -0500 (EST)
From: Andrew Pam <andrew@sericyb.com.au>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Andrew Pam <andrew@sericyb.com.au>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 3/3] SUNRPC: reconnect client transports after resuming from hibernation
Date: Fri,  6 Nov 2026 17:07:31 +1100
Message-ID: <20261106060735.637295-4-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261106060735.637295-1-andrew@sericyb.com.au>
References: <20261106060735.637295-1-andrew@sericyb.com.au>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Fri, 06 Nov 2026 06:08:02 +0000 (UTC)
X-Virus-Scanned: clamav-milter 1.4.6 at shining
X-Virus-Status: Clean

With rpciod and xprtiod frozen across hibernation, no RPC is sent after
the snapshot. TCP can still acknowledge data the server sends then,
though: typically a reply that was in flight when the snapshot was
taken. The restored image has not seen that data, and the server, which
saw it acknowledged, will not send it again. The client then waits
indefinitely for replies that never arrive.

Captured in a QEMU test (below): on the one cycle of six that hung, the
client's TCP acknowledgement went backwards by 200 bytes after the
restore, and the requests outstanding (WRITE, COMMIT, GETATTR) stayed
queued on xprt_pending with no further progress.

After resuming, disconnect every client transport. Requests in flight
are retransmitted on the new connection, and the server answers any it
has already executed from its reply cache. Because nothing was sent
after the snapshot, NFSv4.1 session slot sequence ids still agree on
both sides.

The disconnect is done from a PM notifier at PM_POST_HIBERNATION, which
runs in the restored kernel once everything has thawed. It is also sent
when hibernation fails, where the reconnect is unnecessary but harmless.
xprt_put() may sleep, so references to the transports are collected
under the client list lock and RCU, and released afterwards.

Tested in the QEMU setup described in the first patch of this series,
with 20 hibernations in test_resume mode back to back while NFS writes
(8 MB, fsync) and reads ran continuously. Without the series the client
hung on the first cycle; with only the first two patches, on the sixth.
With this patch all 20 cycles completed and I/O progressed on every
one. The capture shows the client's acknowledgement going backwards on
two of the old connections, and the client reconnecting and carrying on
both times. The single-hibernation test is unchanged apart from one
extra connection per resume: nothing reached the server during the
image write, and the client resumed without errors.

Drafted with an AI coding assistant (Claude), which also ran the tests.

Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
---
 net/sunrpc/clnt.c        | 85 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc.h      |  2 +
 net/sunrpc/sunrpc_syms.c |  7 ++++
 3 files changed, 94 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 6cedc824cf82..a488be2891be 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -32,6 +32,8 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/un.h>
+#include <linux/suspend.h>
+#include <net/net_namespace.h>
 
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/addr.h>
@@ -878,6 +880,89 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
 
+struct rpc_pm_xprt {
+	struct list_head	list;
+	struct rpc_xprt		*xprt;
+};
+
+/*
+ * After hibernation takes its snapshot, the kernel keeps running with the
+ * network up while it writes the image. rpciod and xprtiod are frozen by
+ * then, so no RPC is sent, but TCP still acknowledges anything the server
+ * sends, such as a reply that was in flight when the snapshot was taken.
+ * The restored image has not seen that data, and the server will not send
+ * it again, so the connection cannot make progress.
+ *
+ * Once the system has resumed, disconnect every client transport. Requests
+ * in flight are retransmitted on a new connection, and the server answers
+ * any it has already executed from its reply cache. Because nothing was
+ * sent after the snapshot, NFSv4.1 session slot sequence ids still agree.
+ */
+static int rpc_pm_notify(struct notifier_block *nb, unsigned long action,
+			 void *data)
+{
+	struct rpc_pm_xprt *entry, *tmp;
+	LIST_HEAD(xprts);
+	struct net *net;
+
+	if (action != PM_POST_HIBERNATION)
+		return NOTIFY_DONE;
+
+	/* xprt_put() may sleep, so collect references first */
+	down_read(&net_rwsem);
+	for_each_net(net) {
+		struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
+		struct rpc_clnt *clnt;
+
+		spin_lock(&sn->rpc_client_lock);
+		rcu_read_lock();
+		list_for_each_entry(clnt, &sn->all_clients, cl_clients) {
+			struct rpc_xprt_switch *xps;
+			struct rpc_xprt *xprt;
+
+			xps = rcu_dereference(clnt->cl_xpi.xpi_xpswitch);
+			if (!xps)
+				continue;
+			list_for_each_entry_rcu(xprt, &xps->xps_xprt_list,
+						xprt_switch) {
+				entry = kmalloc_obj(*entry, GFP_ATOMIC);
+				if (!entry)
+					break;
+				entry->xprt = xprt_get(xprt);
+				if (!entry->xprt) {
+					kfree(entry);
+					continue;
+				}
+				list_add(&entry->list, &xprts);
+			}
+		}
+		rcu_read_unlock();
+		spin_unlock(&sn->rpc_client_lock);
+	}
+	up_read(&net_rwsem);
+
+	list_for_each_entry_safe(entry, tmp, &xprts, list) {
+		xprt_force_disconnect(entry->xprt);
+		xprt_put(entry->xprt);
+		kfree(entry);
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block rpc_pm_nb = {
+	.notifier_call = rpc_pm_notify,
+};
+
+int rpc_pm_notifier_register(void)
+{
+	return register_pm_notifier(&rpc_pm_nb);
+}
+
+void rpc_pm_notifier_unregister(void)
+{
+	unregister_pm_notifier(&rpc_pm_nb);
+}
+
 /*
  * Kill all tasks for the given client.
  * XXX: kill their descendants as well?
diff --git a/net/sunrpc/sunrpc.h b/net/sunrpc/sunrpc.h
index e3c6e3b63f0b..6d7581a115ce 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -40,6 +40,8 @@ struct svc_serv;
 struct svc_rqst;
 int rpc_clients_notifier_register(void);
 void rpc_clients_notifier_unregister(void);
+int rpc_pm_notifier_register(void);
+void rpc_pm_notifier_unregister(void);
 void auth_domain_cleanup(void);
 void svc_sock_update_bufs(struct svc_serv *serv);
 enum svc_auth_status svc_authenticate(struct svc_rqst *rqstp);
diff --git a/net/sunrpc/sunrpc_syms.c b/net/sunrpc/sunrpc_syms.c
index 1a3884a0376a..d32786f51ae5 100644
--- a/net/sunrpc/sunrpc_syms.c
+++ b/net/sunrpc/sunrpc_syms.c
@@ -116,6 +116,10 @@ init_sunrpc(void)
 	if (err)
 		goto out6;
 
+	err = rpc_pm_notifier_register();
+	if (err)
+		goto out7;
+
 	sunrpc_debugfs_init();
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 	rpc_register_sysctl();
@@ -124,6 +128,8 @@ init_sunrpc(void)
 	init_socket_xprt();	/* clnt sock transport */
 	return 0;
 
+out7:
+	genl_unregister_family(&sunrpc_nl_family);
 out6:
 	rpc_sysfs_exit();
 out5:
@@ -141,6 +147,7 @@ init_sunrpc(void)
 static void __exit
 cleanup_sunrpc(void)
 {
+	rpc_pm_notifier_unregister();
 	genl_unregister_family(&sunrpc_nl_family);
 	rpc_sysfs_exit();
 	rpc_cleanup_clids();
-- 
2.53.0

