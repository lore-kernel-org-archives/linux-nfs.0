Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495164;
	b=bpDDDE6K6FfXmVJwXrBL3UwF50xGjKxT7Vq87yd1xxXvGFFV7T9wZytXBb2XtCCxRnfY
	 Qlrp8Z2Zvw7wUxhh6sVJuqhYOmKuU1M2OsX5wScispvKhUIhAAUTyY7MZQYmlC3Dral+v
	 dkSMeybTUMlji53Vz8gGEUa/kWBTaALc32DafmM95yBiM06vErTZ/3cOYYzxuqIxe3aZM
	 XveGG8FnwWaJHXblRNJF7C/3KAH+ec4dxE4JZRX08UwcxHdu/wde+lUon8grry1p6K9T1
	 Y01ChVJcX96pcsnMf8R9yTltl+6b1KSh9XxygaD+t9sPDzFSPx0FZ+gnEryX567rTDw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495164;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TPKwD9z5yeOqihsAQOnyVod7I2riz8mOyXKg0YmLi/c=;
	b=eDvrbG2fh4VxeHNG4crRt+2UQXcM6wTWOpe/KwKfH52cybkrT4WUFwPxMLHqsY9sp0lf
	 KdG8LRytFs8LefjRCxoJx/z3j9nQxYjxDwDUKL2ZnBcmANwNooL6C8vfgdH3P0cdIQby/
	 TTgUDL1JwvbXF9E3y5o9llC0lW4oe6UFl8fxYhZlSK8LEmM78mtxappv43NuViSwJwNQ9
	 PE9uS2qNK5Glnqm0y8A9aN5z9TtVjl+c7BxyTE937b2KPoBB4HKIQ/lazF80mv6Y9qOY7
	 QH1C6mLepoTtHocksVRbLUjOjJvjod9YzAVV7TrFwPEk7f0tHzxZO3/M9yEef455W2A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="M0S4/LCs";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 56E92606A336;
	Thu, 12 Nov 2026 14:52:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=M0S4/LCs
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BEB81F00A0D;
	Thu, 12 Nov 2026 14:52:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495164;
	bh=TPKwD9z5yeOqihsAQOnyVod7I2riz8mOyXKg0YmLi/c=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=M0S4/LCsMw5sTSGT8sm7gtBO42+t8O0ilcEhhPbcXjQMZ78WbcvwywoF7y+BKSGW6
	 xYvM2tl5RebO7TSTOX/0ZiJIkNOzB+2+jzqFbpo7eQdq80EFgmJBYSdGF5rQqPleuZ
	 gQJrjwMRcEIto3MvV3ImqjtvC/JHQMW+NN8xn3SUaPAsIr8yLRPOzVdIlAjN5XVi9b
	 YoQMfWC8/eIZcRjLgv2KaISf6nVu8b4h/W09cUpDsRERjR3xca1ljEdi7FlRC3GfRA
	 QurOQ/AdNmmE8OFB4AL8E7gLFTpim0rguv9SZjD95PtTSUcY3y6rM4zU2R0m4HLhHX
	 uuerFmBpfrJ/A==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:14 -0500
Subject: [PATCH net-next v2 10/10] NFSD: Add allow_tags to the netlink
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
Message-Id: <20261112-tls-session-tags-v2-10-a587a50de7fc@kernel.org>
References: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
In-Reply-To: <20261112-tls-session-tags-v2-0-a587a50de7fc@kernel.org>
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
 h=from:subject:message-id; bh=YjxiEA95fvpLC6EkiYG2GPdKBpD58uCNnCFOATO26IQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKgQUmkFb3iBKvPtM95anJdtEvah45rqYyrE
 kaTCU94a9iJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l9c5EACh002SaAEVKPLFZFA/3g/1DJyZuHiZOgOBg4O3rthW2LnwdKa12duOKN7Rmjbw0CKPTNA
 8aJZ2S9LLKn2XiweJmswuflqHWJ07a98KqhUwM3pOviHHbKCkWDUScvsI8yHjo4DecKk0TUc4S6
 QVxkziR/19ihj5KQtK82tjbgGwQ4uBr2FdEhVtOUaezmfJlnCQ3HPQfKZHX/rKzkgB8pUs11jS9
 wiaaSDTIHpaL/0oEYKUQM4Iy2wiJ82StDyfMA6uWHKYki/pXWNCrsEaRVv5EHK9LxTwwC3/FgCz
 HgNzk1tI46gcJ8DmL7x/Vu6e3HGlBnOV3FFRjYcyocKE5fP3R1JwPVvkgpLgc9MlrLgs4sHpyt2
 mWpQUkvEy7dGFX2eB11IEGDKph0gHB/T7gyEVWrDG4kXbEqOZtFCkfHPkSzKujzHizxTt+HYCWJ
 dP6p0dw18ESTQx20oReHRn+1jj4pbB7gDefFEjqBVn7gQK1cNRY+hWSBDWEOeTcS75v6U5iQxLQ
 8najhF4zwd4iOBnO3XCXfO5R2us3L3vvxukjkZtohFdUypU5EvT08RIzAEpuqsSits+IvwNKGNK
 8ktiA4ssABv2XwouUfp5GPV6IUaEGY5+TDEk9lKljmuwto5QBSv2knRki+d9nts43FTtSBMjojH
 nreHUwB3Xhsjfjw==
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
index 68f8c570ab0d..72b159769539 100644
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

