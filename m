Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794597757;
	b=n/MUMD62vbvzK4nrqKS7dEUxAfZUyLxqyIThBS+TQ/mFCb0esE9Kh7H9sv7J7FNrm6l/
	 ZUek/s2bExH0/5OtSpWSAM9LWcXyUVPGHkaMzTW3kNKdYWvuv25vW615P/yT2Q6OaXsJ0
	 4DSO6McMcHmvFfEvy+yzYcEA5+vMCIga3Wsn4ReprMbN79xgjTlJ2mC8L11rQFOR0XYoS
	 A5CrKCnz5wI7CDJyWnh22a3ezpanU5yhIoGU1Bxhq5RjQXaKOvbdEGrrCMwU05kluNJYC
	 DBeuAtOl9etRH+3xCunTX6W/nxq1+hH7B8DrJWipsAjXpAsf03bgPrnXXmGaXTAyFAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794597757;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=ivXzKAle8MpKCkWQ2FPghpCXwOpwQ+oVT26uSC48aG0=;
	b=LqJAVmncJ4MiqWEjLiC9Jp7iiAy/JDIKplkoArFEibe5VN2FOv26vRf0CFv8Kj8MQ9Yc
	 jXig5fAue0trtFuUXkFUVNugma/zE4aCZ+Jn7kpXRdFf018f4OOHhHs08FLUbv00ATqgy
	 Lc3Lvb+EAR9sxqOOPctbuH8zeOKJbwumRYnVj+JruduhZfYK6StSwQ4v7Ie1s3DzQRIot
	 YqBEmi4UwJlVN9m3JwvqqtfOvqBnM1QhjQ132c9IR4oK58pCC88a7YZ4SR/gpLkXBYIGx
	 TynVCOYijhr/jgeCIYoKBvKAV0eYgiHLgbxW/4tsPrs0f5UgIBKZM2p+NKNrGPeW7jQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MEEHnpaM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8D868606A332;
	Fri, 13 Nov 2026 19:22:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=MEEHnpaM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0ED2C1F000CD;
	Fri, 13 Nov 2026 19:22:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794597757;
	bh=ivXzKAle8MpKCkWQ2FPghpCXwOpwQ+oVT26uSC48aG0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=MEEHnpaMJNIZkXHI+U3VCbeJP+MuWkJU2qTi+xVfFMaCqoDoBLousIZnxUw34sfF9
	 UDBlMIEiqVFI2Sa7oV/y9sJfwmaemaZZV/WyWhdLjN/uXELeDhwaEeJHKqQzNvx6Nn
	 ULiNA2t8DnD4AOplRvNPpJvKLvxDGxcGZbxlf43AU9xucvSWpNOCiI61np5c0a1Sbe
	 RLVYpPqp8WKNrZrVthtgp7fkE5f/bWoXRiULvSdxZSvgTqJaON6Gegt0tKj8joDwDJ
	 tPFxQTvf8aU1VsG6Tk8B4WGAw6HFkyDjfRDp5tOkqjwVg9rj8L+xiYq9O0uDozyKz/
	 DkyPRLfYCA8vQ==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 13 Nov 2026 14:22:08 -0500
Subject: [PATCH net-next v3 10/10] NFSD: Add allow_tags to the netlink
 export interface
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
Message-Id: <20261113-tls-session-tags-v3-10-91271964cdb0@kernel.org>
References: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
In-Reply-To: <20261113-tls-session-tags-v3-0-91271964cdb0@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Keith Busch <kbusch@kernel.org>, 
 Jens Axboe <axboe@kernel.dk>, Christoph Hellwig <hch@lst.de>, 
 Sagi Grimberg <sagi@grimberg.me>, Chaitanya Kulkarni <kch@nvidia.com>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Eric Dumazet <edumazet@kernel.org>
Cc: kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-nvme@lists.infradead.org, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=10334; i=cel@kernel.org;
 h=from:subject:message-id; bh=3QyBVcf9+cXJfqpKxn86TKoD6fAHPxiohvVUkDvnJG0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92Nfd0jwiaq8/lcrDOwHwjeTzAOSDiGahTWrQ
 EY3FkjneLSJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdjXwAKCRAzarMzb2Z/
 l7mJD/9WYLq81Tqfi2Zqhn6jFF7nIPB1LihW4XlJgEzGgaOxD1DsIzqbBnhs76WAEu5mizLSWS/
 Imm1XgpXhocq/7pTx/sFev/M2lA/5XKKsRdyZr0vLjgiud2Eujx8qg7xe2xEACRvWJ7Y3sSOcjO
 xsfLGTcm+jMrhH2nHYQuA8Zqb5ZfhAqlPStmBFFFYAeoG0Taj0arYxC6PNuStt/V/tMi62538pO
 ccyFYtRY8hm/Ylxd/vL5o3CFL92xAD7hv3xsp74MYwYQhpGUfa92A256VVGwoMtd1VdVoK5UufZ
 URIeVvRtnz+pw/bfYBhGeZX3vf3W/p6desTuB3V5rk/rWfv4Nkv/QiDtpncP6W81iJjIb8b7/S7
 soOaWymuFu+5z9fdB46/Uahyvon1WALTcq2QFh8acuT67uqAPP3qYoAziuCiiyqrLVjkqhVT5Gd
 UE7toL9tXr6EDU80kGgKt5n3xEBqq9WtqrzZ118e/l8uvv8+Tco6xZ5PNHXvGZ1PJhw5Tfx8Hmw
 wUAcPiu0qjfwEHDoqO5mO0gFL8AiZ4Md71tSbCzMS+qyNbX/oQzwsetl8T/pFqoIADKKVfycJiK
 qXV9RTGcW8nUl2HRpCb651xiellCtj69uHAR8x3O28g74mU3KHZN4nmGbtCdKwmRRnbbiugdl1V
 iiBC5OCo+p6ON6g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The legacy exportfs cache path accepts an allow_tags clause that
restricts an export to mTLS sessions carrying at least one matching
session tag. The netlink-based svc_export interface had no such
attribute, so administrators configuring exports via netlink could
not request tag enforcement. nfsd_nl_parse_one_export() left
ex_allow_tags empty, and check_xprtsec_policy() then granted access
to any authenticated peer.

Extend the svc-export attribute set with allow-tags and parse it in
nfsd_nl_parse_one_export(). Apply the same xprtsec=mtls consistency
check as svc_export_parse() so the netlink path rejects a
contradictory security policy with an explicit error at
configuration time rather than caching an export that can never
grant access.

A bare -EINVAL does not tell an administrator which tag in a
request was malformed, or that the export's xprtsec setting
conflicts with allow-tags. Pass the request's extended ACK into
nfsd_nl_parse_one_export(). The parser reports a malformed tag as the
bad attribute, and too many tags or an xprtsec setting other than mtls
alone as an error message.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/netlink/specs/nfsd.yaml | 10 +++++
 fs/nfsd/export.c                      | 80 +++++++++++++++++++++++++++++++++--
 fs/nfsd/netlink.c                     |  4 +-
 fs/nfsd/netlink.h                     |  3 +-
 include/uapi/linux/nfsd_netlink.h     |  1 +
 tools/net/ynl/Makefile.deps           |  3 +-
 6 files changed, 94 insertions(+), 7 deletions(-)

diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlink/specs/nfsd.yaml
index 9ae37bf3ea71..e58856b34b02 100644
--- a/Documentation/netlink/specs/nfsd.yaml
+++ b/Documentation/netlink/specs/nfsd.yaml
@@ -7,6 +7,10 @@ uapi-header: linux/nfsd_netlink.h
 doc: NFSD configuration over generic netlink.
 
 definitions:
+  -
+    name: handshake-session-tag-max-len
+    type: const
+    header: linux/handshake.h
   -
     type: flags
     name: cache-type
@@ -297,6 +301,12 @@ attribute-sets:
       -
         name: fsid
         type: s32
+      -
+        name: allow-tags
+        type: string
+        checks:
+          max-len: handshake-session-tag-max-len
+        multi-attr: true
   -
     name: svc-export-reqs
     attributes:
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b171cc625c9a..c4ecf884157e 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -832,11 +832,66 @@ static struct svc_export *svc_export_update(struct svc_export *new,
 static struct svc_export *svc_export_lookup(struct svc_export *);
 static int check_export(const struct path *path, int *flags,
 			unsigned char *uuid);
+static int check_allow_tags(const struct svc_export *exp);
+
+/**
+ * nfsd_nl_parse_allow_tags - parse allow-tags from netlink
+ * @exp: svc_export to fill in
+ * @attr: nested svc-export attribute holding the allow-tags entries
+ * @extack: extended ACK that reports the rejected attribute, or NULL
+ *
+ * On success @exp->ex_allow_tags is populated and finalized; on
+ * failure it can hold a partial set. The caller releases it with
+ * stringset_destroy() either way.
+ *
+ * Return: 0 on success or a negative errno.
+ */
+static int nfsd_nl_parse_allow_tags(struct svc_export *exp,
+				    struct nlattr *attr,
+				    struct netlink_ext_ack *extack)
+{
+	struct nlattr *tag_attr;
+	unsigned int count = 0;
+	int rem;
+
+	nla_for_each_nested_type(tag_attr, NFSD_A_SVC_EXPORT_ALLOW_TAGS,
+				 attr, rem) {
+		if (handshake_session_tag_len(nla_data(tag_attr),
+					      nla_len(tag_attr)) < 0) {
+			NL_SET_BAD_ATTR(extack, tag_attr);
+			return -EINVAL;
+		}
+		count++;
+	}
+	if (count > NFSD_MAX_ALLOW_TAGS) {
+		NL_SET_ERR_MSG(extack, "too many allow-tags");
+		return -EINVAL;
+	}
+	if (!stringset_alloc(&exp->ex_allow_tags, count, GFP_KERNEL))
+		return -ENOMEM;
+
+	nla_for_each_nested_type(tag_attr, NFSD_A_SVC_EXPORT_ALLOW_TAGS,
+				 attr, rem) {
+		char *tag;
+
+		tag = nla_strdup(tag_attr, GFP_KERNEL);
+		if (!tag)
+			return -ENOMEM;
+		if (!stringset_add(&exp->ex_allow_tags, tag)) {
+			kfree(tag);
+			return -ENOMEM;
+		}
+	}
+	stringset_finalize(&exp->ex_allow_tags);
+
+	return 0;
+}
 
 /**
  * nfsd_nl_parse_one_export - parse one svc_export entry from a netlink message
  * @cd: cache_detail for the svc_export cache
  * @attr: nested attribute containing svc-export fields
+ * @extack: extended ACK for error reporting, or NULL
  *
  * Parses one svc-export entry from a netlink message and updates the
  * cache. Mirrors the logic in svc_export_parse().
@@ -844,16 +899,17 @@ static int check_export(const struct path *path, int *flags,
  * Returns 0 on success or a negative errno.
  */
 static int nfsd_nl_parse_one_export(struct cache_detail *cd,
-				    struct nlattr *attr)
+				    struct nlattr *attr,
+				    struct netlink_ext_ack *extack)
 {
-	struct nlattr *tb[NFSD_A_SVC_EXPORT_FSID + 1];
+	struct nlattr *tb[NFSD_A_SVC_EXPORT_ALLOW_TAGS + 1];
 	struct auth_domain *dom = NULL;
 	struct svc_export exp = {}, *expp;
 	struct nlattr *secinfo_attr;
 	struct timespec64 boot;
 	int err, rem;
 
-	err = nla_parse_nested(tb, NFSD_A_SVC_EXPORT_FSID, attr,
+	err = nla_parse_nested(tb, NFSD_A_SVC_EXPORT_ALLOW_TAGS, attr,
 			       nfsd_svc_export_nl_policy, NULL);
 	if (err)
 		return err;
@@ -994,6 +1050,20 @@ static int nfsd_nl_parse_one_export(struct cache_detail *cd,
 			}
 		}
 
+		/* allow-tags (multi-attr string) */
+		if (tb[NFSD_A_SVC_EXPORT_ALLOW_TAGS]) {
+			err = nfsd_nl_parse_allow_tags(&exp, attr, extack);
+			if (err)
+				goto out_uuid;
+		}
+
+		err = check_allow_tags(&exp);
+		if (err) {
+			NL_SET_ERR_MSG(extack,
+				       "allow-tags needs xprtsec=mtls only");
+			goto out_uuid;
+		}
+
 		err = check_export(&exp.ex_path, &exp.ex_flags,
 				   exp.ex_uuid);
 		if (err)
@@ -1028,6 +1098,7 @@ static int nfsd_nl_parse_one_export(struct cache_detail *cd,
 	}
 
 out_uuid:
+	stringset_destroy(&exp.ex_allow_tags);
 	kfree(exp.ex_uuid);
 out_fslocs:
 	nfsd4_fslocs_free(&exp.ex_fslocs);
@@ -1068,7 +1139,8 @@ int nfsd_nl_svc_export_set_reqs_doit(struct sk_buff *skb,
 
 	nlmsg_for_each_attr_type(attr, NFSD_A_SVC_EXPORT_REQS_REQUESTS,
 				 info->nlhdr, GENL_HDRLEN, rem) {
-		ret = nfsd_nl_parse_one_export(cd, (struct nlattr *)attr);
+		ret = nfsd_nl_parse_one_export(cd, (struct nlattr *)attr,
+					       info->extack);
 		if (ret)
 			break;
 	}
diff --git a/fs/nfsd/netlink.c b/fs/nfsd/netlink.c
index 88a4a4ffcb7f..146c65575741 100644
--- a/fs/nfsd/netlink.c
+++ b/fs/nfsd/netlink.c
@@ -10,6 +10,7 @@
 #include "netlink.h"
 
 #include <uapi/linux/nfsd_netlink.h>
+#include <linux/handshake.h>
 
 /* Common nested types */
 const struct nla_policy nfsd_auth_flavor_nl_policy[NFSD_A_AUTH_FLAVOR_FLAGS + 1] = {
@@ -41,7 +42,7 @@ const struct nla_policy nfsd_sock_nl_policy[NFSD_A_SOCK_TRANSPORT_NAME + 1] = {
 	[NFSD_A_SOCK_TRANSPORT_NAME] = { .type = NLA_NUL_STRING, },
 };
 
-const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1] = {
+const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_ALLOW_TAGS + 1] = {
 	[NFSD_A_SVC_EXPORT_SEQNO] = { .type = NLA_U64, },
 	[NFSD_A_SVC_EXPORT_CLIENT] = { .type = NLA_NUL_STRING, },
 	[NFSD_A_SVC_EXPORT_PATH] = { .type = NLA_NUL_STRING, },
@@ -55,6 +56,7 @@ const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1] =
 	[NFSD_A_SVC_EXPORT_XPRTSEC] = NLA_POLICY_MASK(NLA_U32, 0x7),
 	[NFSD_A_SVC_EXPORT_FLAGS] = NLA_POLICY_MASK(NLA_U32, 0x3ffff),
 	[NFSD_A_SVC_EXPORT_FSID] = { .type = NLA_S32, },
+	[NFSD_A_SVC_EXPORT_ALLOW_TAGS] = { .type = NLA_STRING, .len = HANDSHAKE_SESSION_TAG_MAX_LEN, },
 };
 
 const struct nla_policy nfsd_version_nl_policy[NFSD_A_VERSION_ENABLED + 1] = {
diff --git a/fs/nfsd/netlink.h b/fs/nfsd/netlink.h
index 027e2953db26..098514e7d1bf 100644
--- a/fs/nfsd/netlink.h
+++ b/fs/nfsd/netlink.h
@@ -11,6 +11,7 @@
 #include <net/genetlink.h>
 
 #include <uapi/linux/nfsd_netlink.h>
+#include <linux/handshake.h>
 
 /* Common nested types */
 extern const struct nla_policy nfsd_auth_flavor_nl_policy[NFSD_A_AUTH_FLAVOR_FLAGS + 1];
@@ -18,7 +19,7 @@ extern const struct nla_policy nfsd_expkey_nl_policy[NFSD_A_EXPKEY_PATH + 1];
 extern const struct nla_policy nfsd_fslocation_nl_policy[NFSD_A_FSLOCATION_PATH + 1];
 extern const struct nla_policy nfsd_fslocations_nl_policy[NFSD_A_FSLOCATIONS_LOCATION + 1];
 extern const struct nla_policy nfsd_sock_nl_policy[NFSD_A_SOCK_TRANSPORT_NAME + 1];
-extern const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_FSID + 1];
+extern const struct nla_policy nfsd_svc_export_nl_policy[NFSD_A_SVC_EXPORT_ALLOW_TAGS + 1];
 extern const struct nla_policy nfsd_version_nl_policy[NFSD_A_VERSION_ENABLED + 1];
 
 int nfsd_nl_rpc_status_get_dumpit(struct sk_buff *skb,
diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_netlink.h
index c125af0cc6a5..e4bd1fe69fff 100644
--- a/include/uapi/linux/nfsd_netlink.h
+++ b/include/uapi/linux/nfsd_netlink.h
@@ -185,6 +185,7 @@ enum {
 	NFSD_A_SVC_EXPORT_XPRTSEC,
 	NFSD_A_SVC_EXPORT_FLAGS,
 	NFSD_A_SVC_EXPORT_FSID,
+	NFSD_A_SVC_EXPORT_ALLOW_TAGS,
 
 	__NFSD_A_SVC_EXPORT_MAX,
 	NFSD_A_SVC_EXPORT_MAX = (__NFSD_A_SVC_EXPORT_MAX - 1)
diff --git a/tools/net/ynl/Makefile.deps b/tools/net/ynl/Makefile.deps
index f8850444d240..3a3fc10a77d6 100644
--- a/tools/net/ynl/Makefile.deps
+++ b/tools/net/ynl/Makefile.deps
@@ -33,7 +33,8 @@ CFLAGS_netdev:=$(call get_hdr_inc,_LINUX_NETDEV_H,netdev.h)
 CFLAGS_nl80211:=$(call get_hdr_inc,__LINUX_NL802121_H,nl80211.h)
 CFLAGS_nlctrl:=$(call get_hdr_inc,__LINUX_GENERIC_NETLINK_H,genetlink.h) \
 	$(call get_hdr_inc,__LINUX_NETLINK_H,netlink.h)
-CFLAGS_nfsd:=$(call get_hdr_inc,_LINUX_NFSD_NETLINK_H,nfsd_netlink.h)
+CFLAGS_nfsd:=$(call get_hdr_inc,_LINUX_NFSD_NETLINK_H,nfsd_netlink.h) \
+	$(call get_hdr_inc,_LINUX_HANDSHAKE_H,handshake.h)
 CFLAGS_ovpn:=$(call get_hdr_inc,_LINUX_OVPN_H,ovpn.h)
 CFLAGS_ovs_datapath:=$(call get_hdr_inc,__LINUX_OPENVSWITCH_H,openvswitch.h)
 CFLAGS_ovs_flow:=$(call get_hdr_inc,__LINUX_OPENVSWITCH_H,openvswitch.h)

-- 
2.56.0

