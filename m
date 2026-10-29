Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275539;
	b=I6QP7ctOTveKF03F0fkmyG7Ffx1wjakXLCFichSvFs1LaQh/UIPOVbZFd7ZmR4nI1Dj5
	 xkTbC7y4wf4iNuMyt6JLj5HHJBqJRGg5U3hk0iDqXgeLippAWclpAYQTX9Rw2CfAf6874
	 1AQl3o9DpVz3imi66nL6LVBuJgRNFVQlOEzilprjGeO3v4R3hSDlFhy97OJ6Qlc9EL1IZ
	 HrkQkG51rWsJj9bLHpu5fimwIN8whqhgDwmeY5XCzfd45K/hXTprth7db7SfwXGJ12kyV
	 9GY5/UJjQSv6X7NOComA0OFMQHDb4C05oRWaDRu4hno6MyRPLK1ShoSMQOS4LZeLPQg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275539;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DDpQS/2MouLyeQ5PB0RjcwYLaSPokQqoMqh62edPMfA=;
	b=jb/2N/EQx9Rgd6rbQkJJEqIZopNB+vAQZpo0CVL+IWeqStaDxt9L546vlPGHUvLF6zaV
	 w6tr15XUWsUqhKE0JMp6J3M5LQy8kQ/oSN39kfPSrQkkUCZr6qGBcflQuaTttnB6Iupkc
	 5/LB0MoDqawlSinWC9FpcaypwoIfLKx57WMRwEzEnkVci1jvGva7VO34x7cnyCWkbhbXM
	 Kl+WkQkdPvlaWGMvKYH8T41B6ZIxEkNXFzIVWQbXN3QHwxTuId/xyLtfndxF6z6QAXYx7
	 85yatf4A101HmAYB47G7LhCDgK2DoW7weXTXhqsmqSALjgFRB/QjAMXDQxC6cu+cQLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSTRaE1D;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D2277606A323;
	Thu, 29 Oct 2026 12:05:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSTRaE1D
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D9C451F031E0;
	Thu, 29 Oct 2026 12:05:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275538;
	bh=DDpQS/2MouLyeQ5PB0RjcwYLaSPokQqoMqh62edPMfA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BSTRaE1DEDYjoQj4tEV8n2EptOntABflL8S6y9je/tl4O0SdxJFIaaYZryK1ynEO2
	 xcOT8f8n5cwysH8xbDJWmqHOi9tMu0V1YKvw0RE1J6RNgExeh7t6FAZ69Zv4MHCodb
	 mgrZ8dYXf+GG5RFlmNIp8ZLdqntUbrnTTJMQtGPzgr4wVKPdBwUjb9Fe/QCrKyD08N
	 UPcihVHroNzGK5V3HdHUuT1cD/s/0N65PkftTf/bRg3DPl7e4sWr0qx4tm+EaMIWmU
	 rLxNGB9iXWf4buBbCuxLNcJmgI9a8t8GCwqgPa76A6pWK/pwbd213RiTWDqPZnGgpO
	 VL+AhbMtfEwhg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:05:14 -0400
Subject: [PATCH v2 1/6] NFSD: Add per-export read/write I/O mode settings
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261029-export-iomode-v2-1-fe8ec6251a36@kernel.org>
References: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
In-Reply-To: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=9776; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=rrkH0txb+eAU3x/Py2Gct7FNqaAD512XFVMEQpiIZqg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zaNf2IcIDCkyJLJ7qvVenos+H01jZy3XAib6
 P3n5SmtZMWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM2jQAKCRAADmhBGVaC
 FWXIEAC0hoZznwPAYrdv13ADl4F2+nJwogAO93SWUYmEiVG0JyHK5Fnpwf95Fnik1YJT2nzz8fn
 50WbpA+AHBd8KhkF8QHB1wLUQ+zkSO7QsCyJzx2nOchJ/j0vyK1E7RDh2za/7fpIW7gmmAezpc1
 rCRvjdVorPzrEHBwOtLl6d8hSzsgsgfCBRmVHRrVB9gTjcIC3bXRSiwB1gUPEDLF4AlzpV1Vta8
 koyVb6h4XWrHOqAdRdexXgYhJC0EdMZhXJGSryqdgROjy2xoBPEoW1wFl1GYz/9oTrwOvc++FRn
 b3MTPRDKepESb/DzQLZRXHX3y/7yo/tMDi48pEhiqyV88HgdZ16dYaMYGeJIJmsYzI4iqefUhR8
 0Xxh6VtXu6/E+8X6pmF+OXltmyZTeiMovcLEEp7D9Ue9m99YzuBdc7GctwFghjdY9N0dtbL6jlx
 hRVS0ht3EKuyf//6zptin92YL1SILj7exHO+TKYLIxLe1r+0Fqd4m6MuxHjSC8ANsVpXDDhNv2L
 kS+oW3WAKZLr8OAutKmtpHxrbgXL46V25UEvpn8gFC1gtxSwHDg+E3DmuRJHAPzeH1ywWCg84C0
 s62grW4euIEErDzn8DGtXuQ7dik0vq1g5GBFIJ5jWPPhXqsYLU8O3wsL/NtVDrHxj0gzdcS50nl
 t7lk2N17ZbZTJlg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Add ex_read_io/ex_write_io to struct svc_export along with a
kernel-internal NFSD_IO_DEFAULT value meaning "follow the global debugfs
knob".

Add an io-mode enum to the nfsd netlink spec so the mode values are
uAPI (NFSD_IO_MODE_*), and define NFSD_IO_BUFFERED/DONTCACHE/DIRECT in
terms of it. The generated NLA_POLICY_MAX policy range-checks the new
read-io/write-io attributes.

Parse those attributes, copy the settings on cache update, and report
them in nfsd.export/content. The new options are netlink-only.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 Documentation/netlink/specs/nfsd.yaml | 24 ++++++++++++++++++++++++
 fs/nfsd/export.c                      | 28 ++++++++++++++++++++++++++--
 fs/nfsd/export.h                      |  2 ++
 fs/nfsd/netlink.c                     |  4 +++-
 fs/nfsd/netlink.h                     |  2 +-
 fs/nfsd/nfsd.h                        | 17 +++++++++++++----
 include/uapi/linux/nfsd_netlink.h     | 12 ++++++++++++
 7 files changed, 81 insertions(+), 8 deletions(-)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index a4991206b45e..8b11bda24f89 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -56,6 +56,16 @@ definitions:
     name: nfsclnt-idmax
     value: 1024
     header: linux/nfsd/export.h
+  -
+    type: enum
+    name: io-mode
+    doc: >-
+      NFS READ/WRITE I/O mode. These values match the global io_cache_read
+      and io_cache_write debugfs settings.
+    entries:
+      - buffered
+      - dontcache
+      - direct
 
 attribute-sets:
   -
@@ -302,6 +312,20 @@ attribute-sets:
       -
         name: fsid
         type: s32
+      -
+        name: read-io
+        type: u32
+        enum: io-mode
+        doc: >-
+          Per-export NFS READ I/O mode. When absent, the export follows
+          the global io_cache_read setting.
+      -
+        name: write-io
+        type: u32
+        enum: io-mode
+        doc: >-
+          Per-export NFS WRITE I/O mode. When absent, the export follows
+          the global io_cache_write setting.
   -
     name: svc-export-reqs
     attributes:
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 265ea8fd31c6..a85aedc0c4c8 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -838,14 +838,14 @@ static int check_export(const struct path *path, int *flags,
 static int nfsd_nl_parse_one_export(struct cache_detail *cd,
 				    struct nlattr *attr)
 {
-	struct nlattr *tb[NFSD_A_SVC_EXPORT_FSID + 1];
+	struct nlattr *tb[NFSD_A_SVC_EXPORT_WRITE_IO + 1];
 	struct auth_domain *dom = NULL;
 	struct svc_export exp = {}, *expp;
 	struct nlattr *secinfo_attr;
 	struct timespec64 boot;
 	int err, rem;
 
-	err = nla_parse_nested(tb, NFSD_A_SVC_EXPORT_FSID, attr,
+	err = nla_parse_nested(tb, NFSD_A_SVC_EXPORT_WRITE_IO, attr,
 			       nfsd_svc_export_nl_policy, NULL);
 	if (err)
 		return err;
@@ -873,6 +873,8 @@ static int nfsd_nl_parse_one_export(struct cache_detail *cd,
 	exp.cd = cd;
 	exp.ex_devid_map = NULL;
 	exp.ex_xprtsec_modes = NFSEXP_XPRTSEC_ALL;
+	exp.ex_read_io = NFSD_IO_DEFAULT;
+	exp.ex_write_io = NFSD_IO_DEFAULT;
 
 	/* expiry (required, wallclock seconds) */
 	if (!tb[NFSD_A_SVC_EXPORT_EXPIRY]) {
@@ -986,6 +988,12 @@ static int nfsd_nl_parse_one_export(struct cache_detail *cd,
 			}
 		}
 
+		/* read-io / write-io (optional u32) */
+		if (tb[NFSD_A_SVC_EXPORT_READ_IO])
+			exp.ex_read_io = nla_get_u32(tb[NFSD_A_SVC_EXPORT_READ_IO]);
+		if (tb[NFSD_A_SVC_EXPORT_WRITE_IO])
+			exp.ex_write_io = nla_get_u32(tb[NFSD_A_SVC_EXPORT_WRITE_IO]);
+
 		err = check_export(&exp.ex_path, &exp.ex_flags,
 				   exp.ex_uuid);
 		if (err)
@@ -1342,6 +1350,8 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 	exp.cd = cd;
 	exp.ex_devid_map = NULL;
 	exp.ex_xprtsec_modes = NFSEXP_XPRTSEC_ALL;
+	exp.ex_read_io = NFSD_IO_DEFAULT;
+	exp.ex_write_io = NFSD_IO_DEFAULT;
 
 	/* expiry */
 	err = get_expiry(&mesg, &exp.h.expiry_time);
@@ -1462,6 +1472,12 @@ static int is_export_stats_file(struct seq_file *m)
 	return !strcmp(m->file->f_path.dentry->d_name.name, "export_stats");
 }
 
+static const char * const nfsd_io_mode_names[] = {
+	[NFSD_IO_BUFFERED]	= "buffered",
+	[NFSD_IO_DONTCACHE]	= "dontcache",
+	[NFSD_IO_DIRECT]	= "direct",
+};
+
 static int svc_export_show(struct seq_file *m,
 			   struct cache_detail *cd,
 			   struct cache_head *h)
@@ -1498,6 +1514,12 @@ static int svc_export_show(struct seq_file *m,
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		exp_flags(m, exp->ex_flags, exp->ex_fsid,
 			  exp->ex_anon_uid, exp->ex_anon_gid, &exp->ex_fslocs);
+		if (exp->ex_read_io != NFSD_IO_DEFAULT)
+			seq_printf(m, ",read_io=%s",
+				   nfsd_io_mode_names[exp->ex_read_io]);
+		if (exp->ex_write_io != NFSD_IO_DEFAULT)
+			seq_printf(m, ",write_io=%s",
+				   nfsd_io_mode_names[exp->ex_write_io]);
 		if (exp->ex_uuid) {
 			int i;
 			seq_puts(m, ",uuid=");
@@ -1564,6 +1586,8 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 		new->ex_flavors[i] = item->ex_flavors[i];
 	}
 	new->ex_xprtsec_modes = item->ex_xprtsec_modes;
+	new->ex_read_io = item->ex_read_io;
+	new->ex_write_io = item->ex_write_io;
 }
 
 static struct cache_head *svc_export_alloc(void)
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 117fb28db1e0..1c020b53fd74 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -77,6 +77,8 @@ struct svc_export {
 	struct cache_detail	*cd;
 	struct rcu_head		ex_rcu;
 	unsigned long		ex_xprtsec_modes;
+	s8			ex_read_io;
+	s8			ex_write_io;
 	struct export_stats	*ex_stats;
 };
 
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index 4ea6a7c1ce7f..0e60cab823eb 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -42,7 +42,7 @@ const struct nla_policy nfsd_sock_nl_policy[NFSD_A_SOCK_TRANSPORT_NAME + 1] = {
 	[NFSD_A_SOCK_TRANSPORT_NAME] = { .type = NLA_NUL_STRING, },
 };
 
-const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1] = {
+const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_WRITE_IO + 1] = {
 	[NFSD_A_SVC_EXPORT_SEQNO] = { .type = NLA_U64, },
 	[NFSD_A_SVC_EXPORT_CLIENT] = { .type = NLA_NUL_STRING, },
 	[NFSD_A_SVC_EXPORT_PATH] = { .type = NLA_NUL_STRING, },
@@ -56,6 +56,8 @@ const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1] =
 	[NFSD_A_SVC_EXPORT_XPRTSEC] = NLA_POLICY_MASK(NLA_U32, 0x7),
 	[NFSD_A_SVC_EXPORT_FLAGS] = NLA_POLICY_MASK(NLA_U32, 0x3ffff),
 	[NFSD_A_SVC_EXPORT_FSID] = { .type = NLA_S32, },
+	[NFSD_A_SVC_EXPORT_READ_IO] = NLA_POLICY_MAX(NLA_U32, 2),
+	[NFSD_A_SVC_EXPORT_WRITE_IO] = NLA_POLICY_MAX(NLA_U32, 2),
 };
 
 const struct nla_policy nfsd_version_nl_policy[NFSD_A_VERSION_ENABLED + 1] = {
diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
index 57fc86c63b1d..b4b04f7777a9 100644
--- a/fs/nfsd/netlink.h
+++ b/fs/nfsd/netlink.h
@@ -19,7 +19,7 @@ extern const struct nla_policy nfsd_expkey_nl_policy[NFSD_A_EXPKEY_PATH + 1];
 extern const struct nla_policy nfsd_fslocation_nl_policy[NFSD_A_FSLOCATION_PATH + 1];
 extern const struct nla_policy nfsd_fslocations_nl_policy[NFSD_A_FSLOCATIONS_LOCATION + 1];
 extern const struct nla_policy nfsd_sock_nl_policy[NFSD_A_SOCK_TRANSPORT_NAME + 1];
-extern const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1];
+extern const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_WRITE_IO + 1];
 extern const struct nla_policy nfsd_version_nl_policy[NFSD_A_VERSION_ENABLED + 1];
 
 int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index b520b51692b0..8b4bed37b46b 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/svc_xprt.h>
 
 #include <uapi/linux/nfsd/debug.h>
+#include <uapi/linux/nfsd_netlink.h>
 
 #undef ifdebug
 #ifdef CONFIG_SUNRPC_DEBUG
@@ -134,10 +135,18 @@ extern bool nfsd_disable_splice_read __read_mostly;
 extern bool nfsd_delegts_enabled __read_mostly;
 
 enum {
-	/* Any new NFSD_IO enum value must be added at the end */
-	NFSD_IO_BUFFERED,
-	NFSD_IO_DONTCACHE,
-	NFSD_IO_DIRECT,
+	/* Values are uAPI: per-export modes are sent over netlink */
+	NFSD_IO_BUFFERED	= NFSD_IO_MODE_BUFFERED,
+	NFSD_IO_DONTCACHE	= NFSD_IO_MODE_DONTCACHE,
+	NFSD_IO_DIRECT		= NFSD_IO_MODE_DIRECT,
+	/*
+	 * Kernel-internal only: a per-export mode of NFSD_IO_DEFAULT
+	 * means "follow the global nfsd_io_cache_read/write knob".
+	 * It is never sent across the kernel-userspace interface.
+	 * It is -1 so that it stays distinct from all present and
+	 * future mode values.
+	 */
+	NFSD_IO_DEFAULT = -1,
 };
 
 extern u64 nfsd_io_cache_read __read_mostly;
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index dcd2126d848b..f67efa23997f 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -59,6 +59,16 @@ enum nfsd_rpcbind_flags {
 	NFSD_RPCBIND_FLAGS_NO_UDP = 1,
 };
 
+/*
+ * NFS READ/WRITE I/O mode. These values match the global io_cache_read and
+ * io_cache_write debugfs settings.
+ */
+enum nfsd_io_mode {
+	NFSD_IO_MODE_BUFFERED,
+	NFSD_IO_MODE_DONTCACHE,
+	NFSD_IO_MODE_DIRECT,
+};
+
 enum {
 	NFSD_A_CACHE_NOTIFY_CACHE_TYPE = 1,
 
@@ -185,6 +195,8 @@ enum {
 	NFSD_A_SVC_EXPORT_XPRTSEC,
 	NFSD_A_SVC_EXPORT_FLAGS,
 	NFSD_A_SVC_EXPORT_FSID,
+	NFSD_A_SVC_EXPORT_READ_IO,
+	NFSD_A_SVC_EXPORT_WRITE_IO,
 
 	__NFSD_A_SVC_EXPORT_MAX,
 	NFSD_A_SVC_EXPORT_MAX = (__NFSD_A_SVC_EXPORT_MAX - 1)

-- 
2.56.0

