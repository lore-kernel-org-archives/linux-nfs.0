Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795056470;
	b=WEDo9iw39KiHkl0mJcb6Frwuzh5GX7PNSeXwCrw7nR7CmI9Z3lcKiDgY/gyJHNCx30IT
	 3d30xlKcz2gr0dcsN4jC5XMaLvglufQGGe2JnZ92e+p2ThLBNYiPfhrx3qC/SXs3nz4Dp
	 ezEtrIETcp1KeUYdKjy3cBwFn6xZTB1/m2O5zDg2krErWnT4jHF/4M8rJbvXA5gpCroqw
	 T9UAHT6MnbbZdsDqKzOJ1uPgVPYpIBXCK+YtoXBKBf21Uact7TVTrJ/nCHkYLwBCp4t/R
	 hGQUhbTlPNVNnSQTVx3eXzpyLxoirmOZojvHNNGHtCTz2++nRHJ8WTBO2sDkNPlp84w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795056470;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist;
	bh=C2oTDrUAloUPLb9R3L1FV5EoIyNwUSlSwZoggaW6Y5s=;
	b=GM1nLNmyp13yk5+knYB8E173nIBY3GzD5uQdIWT6hjzufIR5xTkjUKnW/ZWVncJqSASn
	 DhTELXuJ74qm0KC0tY0lCa8lBLi/kste6B2/JHOp0R9vDGuwo9tGaeLaUeTCR3jsFpVqP
	 Lii7XfjFeeFhNd9zlCF8OLFavEaeZzMwnIHsIkK9AVNizqYrA8moRtwdbLGK65zNo2JDA
	 k1twwIEAIBLDS+SjEteU5MAssiVlNRZuihHQ6+yfNAS3i4hNKNL5E09dIhwAoM0Da0OGc
	 k27pZsCagINPM+uVMrUF0P6tT71rFotnTfskB26pGKJinrbfnDKcOKEExas18Dd+rDw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=cxxvUuXU;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F493606A325;
	Thu, 19 Nov 2026 02:47:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4F493606A325
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=cxxvUuXU
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1795056468;
	bh=C8FYOrq1/N2X6ndUQiRxC8Lu0JM0VQ3FC8k8ab2MGrA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=cxxvUuXUweCPtmcsvbROVekq0nddHOk1RVUthN90r538qz8aBeCjCrBxoUvXVQT94
	 MCp2uFFQEBzHIzcrAEh/uFbr/i4guGRASpHz4cXUo75mpYcdFRz31n/FH52h4ZvwR9
	 t6KGOqORNN8vUP6B+x+yexXa6/XRtEPBXl9ifJnxfU9YUT2UaFV5Cd0X7yZlQgblIZ
	 Y6OQ3vGyBg7UvOyJD+HtpK68GBYGiPpy6swb6vbdRy6SfuTrRK4SW5KlSNCmCYxDU/
	 W9fIazSKnhOBFfKZn/9CEAtAJL1zsK0YbHkYv5t5jviIafiNodgMt5CsOmZksVmnkS
	 UmsSLjhCfmKmQ==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id 2ACF810A47D28;
	Thu, 19 Nov 2026 02:47:47 +0000 (UTC)
Received: from phl-compute-11.internal (phl-compute-11.internal [10.202.2.51])
	by mailfauth.phl.internal (Postfix) with ESMTP id D6C7FF40066;
	Wed, 18 Nov 2026 21:47:45 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-11.internal (MEProxy); Wed, 18 Nov 2026 21:47:45 -0500
X-ME-Sender: <xms:UWP-alB1BrDOxn5i_rh2Sz9O9vgAhzrp7PG-CCNvGVW8zI1D79yC0g>
    <xme:UWP-arGid5weEz3rUFF6EakJlLDGfixGQ2w_9MeYzjpyuTXKYk8QIjLGP6tY3hdRt
    zEKfRi1KzVH_w2aNipGHdeqTDarPHT4ahCx6zXwP3Z6K36fw8VvvisU>
X-ME-Received: <xmr:UWP-agNW8q695JX80FEkV9jnwlDcbeXhYfWvCjMyDNgevIauNkwxlnUBTjVYPMT3sGUhJcsHPFmE_9VQr4NU5p9khEWaAhTMjQya52_nCnEWfHS3qBD8DP1EEG-1>
X-ME-Proxy-Cause: dmFkZTEwpsQHC9Tj7Tz09TkJGL7qYNNHrIq0C5ACydSwY+TvPVL6v5ayL12XNqrkxqXTG+
    /bG6qVSvFmLAm6e8L3ktA8BXWVbs398GKZF6//9vw7ujDbG+VaUWRuCR1Tb/51WdEqNw0q
    Ocdncv6gRQKblwe7OMQ6c+lNAYCsA/pubayqAUUpYF2RbLJI2eH3tn5aa22WAnBGC6qKjk
    VSs7Zhox35Ta58Q2TiNoGabmPtjiX3etHwBQIsVoP6z+XQFhIBvZ4QZfHUFt184A3GPUGi
    pnJxf41TPiIJssg5WvrdjlpLxdXSRz/rhoe5U0KN/3HazjQCEO614gp8q7Qy0KZ9CeMIRj
    EVRanag64aMLeCA63It9NMBN5ri5tsecXVns9S+CNoKSyv75JQ71Eb+EFXwJRHoU1rhHAH
    TNnNfG5L9AGQIQgQBsfEuuiXSFVisXs6JkT4nLCRQXEV3zVy+kZpJaSlIpsivCHIK8y+Pn
    DEDb7WtcoUYTn5IxyM/enCZUo0tlRohk/5rh4kfnl25HoGnwswuofZmemA4cUHtwvjo1M4
    phxWw+5p7wvbrlWEquSSTevFtgTCfuHtu4EmPUDjWuji2FqzqWiKsTsqcbwT1m1Du83yo1
    Bz28DWe/V3QtMea50HQ+OIEXg/s8BUJTOEwSdaLEMaCJwx6bJ42mlggvEWbg
X-ME-Proxy: <xmx:UWP-asiw7M6vfBb4FtEollw8SVLUzpGso1VCkMv3eSc4kWLifghjuA>
    <xmx:UWP-ag19TD6yflF7cL6yR_bFJ0l5l5CP_z61l7RBArBaMvPEb0kCWA>
    <xmx:UWP-apkqbazigEcVAc9ek0QDCZedma5lkFicNaj3feOtt2t-jSLPQA>
    <xmx:UWP-avu0yOckxpe6pBfXHBM_Aa4J8sIG23lKAXIgNJ-keZHlPGTcGA>
    <xmx:UWP-ap3c2FUwHGjGDGEALzfjwWEzFRJVEVhSRrrVhr_LmVZzsfcjKZlf>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 18 Nov 2026 21:47:41 -0500 (EST)
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
Subject: [PATCH v3 3/3] SUNRPC: reconnect client transports after resuming from hibernation
Date: Thu, 19 Nov 2026 13:47:18 +1100
Message-ID: <20261119024719.311474-4-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261119024719.311474-1-andrew@sericyb.com.au>
References: <20261119024719.311474-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Thu, 19 Nov 2026 02:47:48 +0000 (UTC)

With rpciod and xprtiod frozen across hibernation, no RPC is sent after
the snapshot. TCP can still acknowledge data the server sends then,
though: typically a reply that was in flight when the snapshot was
taken. The restored image has not seen that data, and the server, which
saw it acknowledged, will not send it again. The client then waits
indefinitely for replies that never arrive.

After resuming, disconnect every client transport. Requests in flight
are retransmitted on the new connection, and the server answers any it
has already executed from its reply cache. Because nothing was sent
after the snapshot, NFSv4.1 session slot sequence ids still agree on
both sides.

The disconnect is done from a PM notifier at PM_POST_HIBERNATION, which
runs in the restored kernel once everything has thawed. It is also sent
when hibernation fails, where the reconnect is unnecessary but harmless.
The notifier walks each client's transport switch under its xps_lock.
Every transport on the switch's list holds a reference that is dropped
only after it has been removed under that lock, so the transports stay
valid while it is held. xprt_force_disconnect() does not sleep, so no
references need to be taken and nothing is allocated.

Drafted with an AI coding assistant (Claude).

Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
---
 net/sunrpc/clnt.c        | 61 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sunrpc.h      |  2 ++
 net/sunrpc/sunrpc_syms.c |  7 +++++
 3 files changed, 70 insertions(+)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 2f076b4bfd54..89afd2d0a47e 100644
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
@@ -881,6 +883,65 @@ int rpc_clnt_iterate_for_each_xprt(struct rpc_clnt *clnt,
 }
 EXPORT_SYMBOL_GPL(rpc_clnt_iterate_for_each_xprt);
 
+/*
+ * TCP may have acknowledged data from the server after the hibernation
+ * snapshot was taken, which the restored kernel has never seen. Disconnect
+ * every client transport after resume, so that outstanding requests are
+ * retransmitted on a new connection.
+ *
+ * Each transport on a switch's list holds a reference that is dropped only
+ * after it is removed under xps_lock, and xprt_force_disconnect() does not
+ * sleep.
+ */
+static int rpc_pm_notify(struct notifier_block *nb, unsigned long action,
+			 void *data)
+{
+	struct net *net;
+
+	if (action != PM_POST_HIBERNATION)
+		return NOTIFY_DONE;
+
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
+			spin_lock(&xps->xps_lock);
+			list_for_each_entry(xprt, &xps->xps_xprt_list,
+					    xprt_switch)
+				xprt_force_disconnect(xprt);
+			spin_unlock(&xps->xps_lock);
+		}
+		rcu_read_unlock();
+		spin_unlock(&sn->rpc_client_lock);
+	}
+	up_read(&net_rwsem);
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

