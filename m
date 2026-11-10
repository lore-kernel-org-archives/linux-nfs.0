Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794280190;
	b=PrxgBsHw5eE3aYDN5eCkOa5lnEOEpVryWcYy/ZwpFWoE1kLYWpGx8yiJmE7+ErhFcgG+
	 HrqQFbfpEyUmqk6mH1kh1pQmoLMah0h7gEAbMWyMB8ZpSZ5wbOz6J4IKjlMizhIDW8Zxg
	 8tfjCHrWvkp+3hL65KtN4NpAI7xKCbVXplkbUDPGZnqGaflo43K0ZDLmUQcTBY2GPamiP
	 qZ0MTi0YLCMKBUtDNuk/T3lx9lCfPd4n9RSI1ha61kmo5DUYkYb9BHWhGEWVofYM65ZLj
	 Aq1XulIvNx6TeDmKLxIDumAA19pXNRw8B7UYrB+i8PMcFe3nxjGx+/Q4sqrZ2hFe5RQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794280190;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=VUFq2C59ndwIVjZ+OIzzgnrcXIa9Z5t3JDYw0GWU3SA=;
	b=STYAxu/9ZNsm8Zz1Kr41zGMgGdPkFTB+ixx7Ne7izKIblDrLnMztoM8rGpKW3MxOyLoP
	 O6OPFpBt5nAR8aW+8xYvrZ8B1C6rFEJGFd3rgmaIW2a4tJI8tjmqcPlWwug4+jA0T/yoR
	 gKERU+R9VvbJtn5NSkXplBIn+5NMHyZOuaI7GzDt5O8NoPQ79xc4ZrZ1Zg57a5Tum6FK1
	 iVokQEzMau6FXIO4boNmAdL67sn9rJ+neIwFzafF7mnX2IDZLtlCs/iUDnsPbqj3Hp7r3
	 o+RoS0K+hIY+iV5evskC00jShQ607tJ1LYuQZAbi1qxSzszpmJHqLuI9S9RFbvsg8Vw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BZ8Nkq1L;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63913606A32E;
	Tue, 10 Nov 2026 03:09:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BZ8Nkq1L
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A73281F0089F;
	Tue, 10 Nov 2026 03:09:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794280190;
	bh=VUFq2C59ndwIVjZ+OIzzgnrcXIa9Z5t3JDYw0GWU3SA=;
	h=From:To:Cc:Subject:Date;
	b=BZ8Nkq1Lt8V/1+6mAsxz3mNgJEE8KhFMy/ahrgjs+bLw7FnHeOP2dyas5MdoOxi2y
	 Rchc+Na4uM5QB7y/DAvaqcPRUjBq+5/ZiIBRl0HRrT2mPKON3NVwJKmljuPpkT6tcL
	 iZHU0qwXwBJXP9Xd+MD0Q6hryT5mEq9rCUypDBr+WDXHWh3iF6dV+jo70zeujG6xv7
	 t/wZGIWpSH/3MZYN95tCQd8DFKfbXgmDp+2GjGfCyEv2QgTNyKGAf8fV2ubweNVyiv
	 qdiZq7+rp1HrAk4CqMgVbzzZJug0FUgJnZQaIpZReJKFsIUNhFKhGO/pxfRXPpAqq4
	 GdtT3t2Kj76hA==
From: Sasha Levin <sashal@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"kernelci.org bot" <bot@kernelci.org>
Subject: [PATCH] SUNRPC: Load the GSS module by OID only when the mechanism is missing
Date: Mon,  9 Nov 2026 22:09:47 -0500
Message-ID: <20261110030947.179738-1-sashal@kernel.org>
X-Mailer: git-send-email 2.53.0
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

gss_mech_get_by_OID() calls request_module() before it looks at the
list of registered mechanisms, so every lookup forks a modprobe, even
when the mechanism is already registered or built in.
gss_mech_get_by_name() and gss_mech_get_by_pseudoflavor() only load
the module when the lookup fails.

The read handler of /proc/net/rpc/gss_krb5_enctypes uses this lookup,
so every read() of that file runs modprobe, two per cat. The file is
present in every /proc/<pid>/net/rpc and /proc/<pid>/task/<tid>/net/rpc
directory, and LTP read_all gives each read one second. On a slow board
in KernelCI its workers stall on this file and the test times out.

Look up the mechanism first and call request_module() only when it is
not found, as the other two lookup functions do.

Reported-by: kernelci.org bot <bot@kernelci.org>
Closes: https://d.kernelci.org/test/maestro:6af225865b429d354e253b9b
Fixes: f783288f0cf4 ("SUNRPC: Load GSS kernel module by OID")
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 net/sunrpc/auth_gss/gss_mech_switch.c | 23 +++++++++++++++++------
 1 file changed, 17 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 78eab245f94a7..d8b6ff9505399 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -157,14 +157,9 @@ struct gss_api_mech * gss_mech_get_by_name(const char *name)
 	return gm;
 }
 
-struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
+static struct gss_api_mech *_gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
 {
 	struct gss_api_mech	*pos, *gm = NULL;
-	char buf[32];
-
-	if (sprint_oid(obj->data, obj->len, buf, sizeof(buf)) < 0)
-		return NULL;
-	request_module("rpc-auth-gss-%s", buf);
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(pos, &registered_mechs, gm_list) {
@@ -177,6 +172,22 @@ struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
 		}
 	}
 	rcu_read_unlock();
+	return gm;
+}
+
+struct gss_api_mech *gss_mech_get_by_OID(struct rpcsec_gss_oid *obj)
+{
+	struct gss_api_mech *gm;
+	char buf[32];
+
+	if (sprint_oid(obj->data, obj->len, buf, sizeof(buf)) < 0)
+		return NULL;
+
+	gm = _gss_mech_get_by_OID(obj);
+	if (!gm) {
+		request_module("rpc-auth-gss-%s", buf);
+		gm = _gss_mech_get_by_OID(obj);
+	}
 	if (!gm)
 		trace_rpcgss_oid_to_mech(buf);
 	return gm;
-- 
2.53.0

