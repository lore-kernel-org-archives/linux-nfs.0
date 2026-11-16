Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834907;
	b=TGQHl2KZxX95v8xOhy9rUuAr6E5+pQC1k2XoSuCLv6z0lAQ01IpJeuw2mG+ONXcZ0M9T
	 JQKkI7yKClAQzKV6NXC0Ru0ZbyNOOtBYRc7O09SCpELvmxckDvNufXIsEAZ9HACkjJ0qS
	 KQMIoTYxjR733Are9erKZWRz8WECgIeyYJzmfruEIkbEM3YJb3UFWME0xePkBCXZ/7dtu
	 14nQ8DWyR2LyCRePDkeTmvCicN36QGIlVWbVBfU+cTxpzaLpUAdcP0F4jRYyTLj3zCQcb
	 r6JbL23F2j2vlysWhUa+5vix11fIvkQw6uIJwC1LWU9+YLuyii8X8Vhc7Hn6x0wPMYQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834907;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=WxfM2W3yJoegA0A54w/p6TSB74SnU7+AkVfL2vqvnH8=;
	b=tVqwmxYWO4+35JwHKC3kUkAOM6oh7HetyURMibhho4oej9woieRU9kBaeRzqTPTJL3JU
	 fsXa0BiWoaOrl+94Kh5vEbOsJgIZsQrRHuyLVFLO03tjzjV53yt+cSteMMTMb9puIZ34G
	 Zemk45mMbEk262JOm+Mo4ZkXTIThIvb9QVcfFlK0Y2FG6C5We4ki2MfKixLY5yeUVBRMo
	 tNxkI8ZoVCZip9QXOZEU/Y4mCnKrRv5Npt3bHyiBORZtTlJ2h7URKIPgAnpUn3nYFYWBB
	 1ScJnqLkRtVcjOSlHKlj4EmRf4qtwLKgabwXBepgrq4LM2eCTvtmquwqAopVdavjEHA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=rYOS7HPm;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C909C606A339;
	Mon, 16 Nov 2026 13:15:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C909C606A339
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=rYOS7HPm
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1794834904;
	bh=cOsaoAG+SpAN5cuntCulvdve1KkB0aRe78VicZODR98=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=rYOS7HPm6ACm1ZVXD0ChAndupZUCrBR50vSonjbNK8wZlqGD5WYExuZ5nlPiBAO/t
	 LryLAOqPaA6nO2nWQTjyzZvNnDsXfrM/OQC2HWf9ZULs3To2jZMQX0PXiYPODHNQDX
	 fwq/cVpAxZmbA1v4X2KKu/ecWhoFaQP6i+bsCWAe+CWw6qC3Gg5mIWNI4K7kI/9Gck
	 /byp4+QC+GKn27SPvG9MIfOcs2PJqs12g4ESldJpeBvTw5bAlOulasJl68BKujlPxW
	 C69altTyy/YlLe+drFGakPOjFl8AfUQASvL2mt9Sil/Z/TTxP0Io4cnQKJLdRmAr7G
	 E9ycN5k1D50gw==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id 55102109F9871;
	Mon, 16 Nov 2026 13:15:03 +0000 (UTC)
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0C6ACF40068;
	Mon, 16 Nov 2026 08:15:02 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-11.internal (MEProxy); Mon, 16 Nov 2026 08:15:02 -0500
X-ME-Sender: <xms:1gH7aoMqcAIxFbiR3RqWHCvyPmkMahth78853j468JPuT21efq6a2Q>
    <xme:1gH7amibSfHujPTowksudMQ5bx9t91kNn3datVIAvanL7aVUyefgHV6YhZFBoZZMs
    ntv0vXzCah7fWhj-g5YJ2UCWf6iYLu8pPXw6vvgAtAppIt87MEYUq3k4w>
X-ME-Received: <xmr:1gH7au6lgWymGm3sAXpScZa-PIWWGpUTYPUTnVZoQBobHaRwKgB6CnR_ut6rEfiJdcYdH_-nbxu7zbZiLYzZq38l0a5E1BV8soIJwk_CzzA>
X-ME-Proxy-Cause: dmFkZTGmvlV8o6tTz5AZYkKQRzteI9TVjKztZwk1AxfWHAAW3IvbWRQid/0DC6DJW1xAx4
    7iI2QWYdqhZi+4AoLoFsqd/NOoCGiIYgpMCmkpRZknF2t5soFxl4LH8DEK1qmg8g76OwNF
    sR9aCniT9pUY7IsYm9746Jk9twf87zV1ynYzHh0riMcBkoVqmNun3FuLNJXWxKbdQWWuSR
    C4ou3faNJ7AR00BCLoqv+p4UNiStkAeTWgi7wyFCJmHAVWNtgapnU0130EVtHKlaIgt+s7
    Jst2loF8582z2Gzc3V04mmNZBiFe8eJT2jfCElCFZn+KMRgoL1IBs+QHKkxUwUen5AyAoh
    z1fOvqql3wyrs2OTmEmJr3/McK40rYLheiuLJGVGdPTrEpDrt5xws9pVW/Bz/CYGjpKZY/
    +uhJ2ktnOAG50NSIVte1h+RUAO7tobVzLhZ/t7pxGcJo3oOUa4W0v0Qs5V5Pay4u5BN8cR
    GUmB7pLW1ewB5XBFywevfTCslmxV5HTU7DTIHw8H/oTJI6xuh8IWBYE851d4MoB7j9T76K
    xSNjg8lMyAqn/AyLV+k8aMfzRhHYacISfFsppTIEwj9v5MDtSboE2qC6l7RAQXJjKxstUe
    DMqNUJF1OqY/M7Vus7rI8nekX9gmYn9oFnUyIJW9gOJdlIzuhthFzpRE1Znw
X-ME-Proxy: <xmx:1gH7atfZYr07yST5mCE4wI4zyEdXFzxV_R0ljR7oM5TDRTaxaFpaRQ>
    <xmx:1gH7anByU8s3ftRLDbDLII4DUpyWfiwetO6h5bls-2Gm0KDjtEYD6Q>
    <xmx:1gH7asCXHgpXvaNP7lExHC1FeB5opZhXsm1IlGanMLUiRUobIdGTfA>
    <xmx:1gH7apY4WaZIr31wMg2bDcM8A-rHYinhfdPVbUair5PS5p9QOzT7OA>
    <xmx:1gH7apwnggyeTplGcxo8ooUZ4CGGdbnjXVuSWUYwqrezN6JjD1DiPZiN>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 08:14:57 -0500 (EST)
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
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 3/3] SUNRPC: reconnect client transports after resuming from hibernation
Date: Tue, 17 Nov 2026 00:14:27 +1100
Message-ID: <20261116131428.1024230-4-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261116131428.1024230-1-andrew@sericyb.com.au>
References: <20261116131428.1024230-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Mon, 16 Nov 2026 13:15:04 +0000 (UTC)
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
xprt_put() may sleep, so references to the transports are taken under
the client list lock and RCU into an array, and released afterwards. The
array is sized by a counting pass first, so it is allocated with
GFP_KERNEL rather than under the locks, and the walk is repeated if
transports were added in between: one left out would stay stalled.

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
 net/sunrpc/clnt.c        | 112 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc.h      |   2 +
 net/sunrpc/sunrpc_syms.c |   7 +++
 3 files changed, 121 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2f076b4bfd54..f9c31c49dc0b 100644
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
@@ -881,6 +883,116 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
 
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
+/*
+ * Take a reference to each client transport in every network namespace and
+ * store it in @xprts, up to @max of them. Returns the number of transports
+ * found, which exceeds @max if the array was too small. Called with
+ * net_rwsem held for reading.
+ */
+static unsigned int rpc_pm_get_xprts(struct rpc_xprt **xprts,
+				     unsigned int max)
+{
+	unsigned int n = 0;
+	struct net *net;
+
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
+				if (n < max) {
+					xprts[n] = xprt_get(xprt);
+					if (!xprts[n])
+						continue;
+				}
+				n++;
+			}
+		}
+		rcu_read_unlock();
+		spin_unlock(&sn->rpc_client_lock);
+	}
+	return n;
+}
+
+static int rpc_pm_notify(struct notifier_block *nb, unsigned long action,
+			 void *data)
+{
+	struct rpc_xprt **xprts = NULL;
+	unsigned int i, n, max = 0;
+
+	if (action != PM_POST_HIBERNATION)
+		return NOTIFY_DONE;
+
+	/*
+	 * The references are taken under spinlocks, but xprt_put() may sleep,
+	 * so collect them in an array and disconnect after the locks are
+	 * dropped. Count first so that the array can be allocated without
+	 * GFP_ATOMIC, and recount if transports were added in the meantime:
+	 * a transport left out would keep the stalled connection.
+	 */
+	for (;;) {
+		down_read(&net_rwsem);
+		n = rpc_pm_get_xprts(xprts, max);
+		up_read(&net_rwsem);
+		if (n <= max)
+			break;
+
+		for (i = 0; i < max; i++)
+			xprt_put(xprts[i]);
+		kfree(xprts);
+		max = n + 8;
+		xprts = kmalloc_objs(*xprts, max);
+		if (!xprts) {
+			pr_warn("RPC: no memory to reset transports after resume\n");
+			return NOTIFY_DONE;
+		}
+	}
+
+	for (i = 0; i < n; i++) {
+		xprt_force_disconnect(xprts[i]);
+		xprt_put(xprts[i]);
+	}
+	kfree(xprts);
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
index 11b9e5cead8e..1833b167616c 100644
--- a/net/sunrpc/sunrpc.h
+++ b/net/sunrpc/sunrpc.h
@@ -43,6 +43,8 @@ struct rpc_task;
 struct rpc_xprt;
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

