Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0601D490BE9;
	Mon, 14 Sep 2026 15:21:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789399271; cv=none; b=OvqND3WIr9isPAHy39+QQc1+YGAL3h23IoTotfC4+3H4HdFJ+RQ/KzET/mwsOVqqpI+Kd22vDGETm33VxDmvji4GpkfV/IPLJ8ky5wLIi4HQYGbzGK77EXQ1G+DqvwoLSWgfWC/2bPPXbo5XWUYPiu4zzVCBIf8BBKGtcgKQ57A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789399271; c=relaxed/simple;
	bh=UoWQHbkr2M9okG7sxUiZYcmC9RgSw9SeU8siqAcbPag=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AwSHS3vLqf/a/E4yHcIHZoVuWw2BNy3HxkvxI4LQopmriqscBrP6b/izS0IWtKJnxHWIS43Y9MIm6bTSm9HzhIee0DikKxO3pNzfNUdmVIcp30zCOX9tvtD2HGMGw5I3wPiI15FKIHRSG+qWX3vSn+JwN/FdXBMvhxzX/3R8tek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lnNrWhZ2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lnNrWhZ2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D8AE91F0089F;
	Mon, 14 Sep 2026 15:21:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789399268;
	bh=OeeQ+ZrmuUedsYcXYwL4tkTD/pZRXUuRAVVdzvyPLKE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=lnNrWhZ28CuylTJyN5bYvqCwqo/0a0ufkmdTmGdyKzJPg1WhDP6Wuyboed9SDok39
	 SMKV79uy78e/SqgJrUosQF0r/m0ojQQGijB2JXNJ0Yx240MgvtuOY2UuFlCjEKFQmA
	 xJPS2nsHr+rW2fQKTpRghlGEnxaIiFCBkHydSB4Br7/vh/O1fhVXg4eMwwTJDocpsC
	 vhEVtpcOEeBkhnChmyF4wpTkJS33jiI+pd5BFCw77N39emNsOpxKElUZF7BICv+yHR
	 iYmrzyTXDjIjbyPFxPpphe2slGtXEJCkzVAIszKG/QLr/EkicWQkQDf8Hs4Y89w+BZ
	 aFuZqPvXwT7Zg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 11:20:38 -0400
Subject: [PATCH v2 1/5] SUNRPC: allow a service to opt out of rpcbind
 registration
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsd-norpcb-v2-1-38263c6f59b2@kernel.org>
References: <20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org>
In-Reply-To: <20260914-nfsd-norpcb-v2-0-38263c6f59b2@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Donald Hunter <donald.hunter@gmail.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2210; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=UoWQHbkr2M9okG7sxUiZYcmC9RgSw9SeU8siqAcbPag=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBDgCdE5t0AWiC+tq/DyK1aJ5REgQTN6jRD2C
 NjM5M7n4RqJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgQ4AAKCRAADmhBGVaC
 FaBjD/44+zsXz4dbKODxBQbZ2FWifPWxGWn65dwbJTJfjeW1rxt0qCA0J/rbF5w/VoGcW5p1BSz
 ww9P9L4w2uDXp95VDuAYy6S22iixCkx2bK+6q4TSsmZsH/2Edn2Jlz4hJ2LooNtS9R2W5SgORqt
 tVlJFF2pK9OAbKYco6OkXyzihphqFP6j0nlO+uysqqBMgAoflBmXTACpOfdKjBl1kbcuJQ9XVsD
 LuslB+yursfZpHetF/M9q8ZTEtGt7OKP8cww8+vlrJgP5SWNvietEq3cbti5T07mlRfW3nE8Mur
 88sJhCW7/e0kroegjcBtk7+G/oRBL8UskrjMXoMZCnuGbCvfmudMs2GFTYM5I2FR4JvAy8xpaZZ
 ZaHbNfv5iU1GblFsC+gEac3esA6prPDCNNK/sEB1WCPMXfZ1dlfH7AMhVYeGmBK0Fg/KiEgieCW
 txn+wUlS7AmDHvXV+0dmX019vzTgzhIjYa/vkbTCQqOAFWrp38wBEAq1sN9Rvsz7l8poK+ps2l/
 vNEcKFnUTXjro1OtTP5d8MExtnTBXx1BEbyu47vt6eA5EHRfE/UY/OwWimXiSUwFN98ZaOvz63F
 twe6PPMV55LZz49A8ILpUHc5vjjBIkqwipJZ/8qJKRgdHmklnx8E7B0l7MudZvS5xOA8SK/caMM
 sZVagqTcLf5zRQA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_bind() creates the local rpcbind client, and svc_register() then
makes one synchronous call for each program and version. Both run under
the caller's mutex. A caller that registers from userland needs neither.

Add sv_no_rpcbind to struct svc_serv, and fix up the code to honor it.
No caller sets the flag yet, so behaviour does not change.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/sunrpc/svc.h | 2 ++
 net/sunrpc/svc.c           | 5 +++++
 net/sunrpc/svc_xprt.c      | 2 +-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 24698856eb40..cfb5ab17dabd 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -87,6 +87,8 @@ struct svc_serv {
 	char *			sv_name;	/* service name */
 
 	bool			sv_is_pooled;	/* is this a pooled service? */
+	/* Caller registers with rpcbind itself. Set before svc_bind(). */
+	bool			sv_no_rpcbind;
 	struct svc_pool *	sv_pools;	/* array of thread pools */
 	int			(*sv_threadfn)(void *data);
 
diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index f73412e123a1..7e23af94a719 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -337,6 +337,8 @@ static int svc_uses_rpcbind(struct svc_serv *serv)
 
 int svc_bind(struct svc_serv *serv, struct net *net)
 {
+	if (serv->sv_no_rpcbind)
+		return 0;
 	if (!svc_uses_rpcbind(serv))
 		return 0;
 	return svc_rpcb_setup(serv, net);
@@ -1235,6 +1237,9 @@ int svc_register(struct svc_serv *serv, struct net *net,
 	if (proto == 0 && port == 0)
 		return -EINVAL;
 
+	if (serv->sv_no_rpcbind)
+		return 0;
+
 	for (p = 0; p < serv->sv_nprogs; p++) {
 		struct svc_program *progp = &serv->sv_programs[p];
 
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5e210bc68422..08cfe8a31189 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1266,7 +1266,7 @@ void svc_xprt_destroy_all(struct svc_serv *serv, struct net *net,
 		msleep(delay++);
 	}
 
-	if (unregister)
+	if (unregister && !serv->sv_no_rpcbind)
 		svc_rpcb_cleanup(serv, net);
 }
 EXPORT_SYMBOL_GPL(svc_xprt_destroy_all);

-- 
2.55.0

