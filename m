Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794495162;
	b=pIgIEyCBE+h/Nl08OHHQG8wrtuB5brNSO0GJfRjIjgEpomSeEDitSms01RvBOF3FTDls
	 JRPv0rrOGdEszkWMmPQCYSFab5looEZPYhk8SlpFzWF7i+rinDwkICSL4Qm4UjMILfXwP
	 O8CXl2ZAUTBCdQo8piUq599oLPFNTK91ORN6tGYid53WUC4Ep3bX8Ussxn4VgHiO5RRXV
	 KOQoFf7ettKwOkDMi/NyXuNuJyUcoNKIslBJ2qyObfqb8NpCMVKWkaaWzWSrMyMavhXrG
	 FrCLuepwrh+nVHsavrU3V95CG8VALTGGgSLTZzYqfQZWlee9FJeMla3vY+9eJ3RyX0g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794495162;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=RgPD4OQ0VIwFLjVpzU4jwshZ0Rn4d7nmzZHYkYgPTBc=;
	b=F6j2NchoWaBJE0MGd1HrMb+A1Dx6xJ3kMdVQBUj6wooXGAAk3ZOqwkFrIMFrufqC5deH
	 E2dlBCqsHvrWEdjvPaaLtzRD0bslO7leQMvBKQRlrhHsyG5EWs/5MT4jHJNJsLApTK8QD
	 uPn/lwSzhiTwrkfYTLUcD30Vbyutqu8MZG1pzipQVCDnrjx7EB1UI/oQv4rreu72zG+Pt
	 t0hasN/YcG39PQrtSPKMLGCa+E9EvmMM0p+WJKVRAPAU+9Rf/WHvEsneFnHwYrsmHaNFA
	 1O2DY7h6fzG7hfk0NOP1FkUztLmEZb/aDqT9Ed1fmDVCXfeTADGwdUSkeOs2KahEb/Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HDa9gE5w;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB04C606A895;
	Thu, 12 Nov 2026 14:52:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HDa9gE5w
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6CD031F00A06;
	Thu, 12 Nov 2026 14:52:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794495161;
	bh=RgPD4OQ0VIwFLjVpzU4jwshZ0Rn4d7nmzZHYkYgPTBc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HDa9gE5wh+pONBArsZMBpC3QxxOXRdbDvuTv9S9+prJOG9IUi6M6z2irPSKCjQeBD
	 jw7v7cI/LlCO1x7cQpiK1XMpGSL4+YHxdLPZeWnZqwRSpARCHnppFtkzkhSHWTpDe8
	 esT/bbPkYZ8hr3Za8uCNfI0yAHfWOJ+gL6ECq4DlLuH37H3jNSjNu1AFsrEPAABA8e
	 aEFlr4qW5PThoGnNFk254If29r22H60JhatEsT/maBuvp6Xm1yDpON7Q+EmWXXL4Lt
	 rtCPW6BWIInV9XyZO8TroEL5AiH9E1u6q9RRjis6uSgT2l00bkH3u/AnLrLIkqUsfr
	 86NHdYRADSpOg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 09:52:13 -0500
Subject: [PATCH net-next v2 09/10] NFSD: Implement export tagging
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
Message-Id: <20261112-tls-session-tags-v2-9-a587a50de7fc@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=11644; i=cel@kernel.org;
 h=from:subject:message-id; bh=ZbgQHTZbR+fr4+HJz4bY9byXDfAr2X24S5KTZ3oigec=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9dKg8120Prl0caUboBCD6RgmVpU5FTDIhluEo
 P/NBUHKXcaJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavXSoAAKCRAzarMzb2Z/
 l97ZD/4xgV3PFPqzWgwtmbha9iJmMoKZtU2/XQHprJtubj/jTZQpPGzv2TIhEkJ7NZkhzBsuYay
 0JN/2+khNuwmiiUuEOPhY6/rblP0So/7BEL9JDtCYewr0zJ345Vw5kOzT2CvKrEfLZ/XNQU9xBa
 DqxS2FcEduIGMw6GvFaqTgRCE7uqUurUnGZQGhs4wQ6Qpj+tbJ3NYGlCLXigYQQamOPoqRRg81e
 OAC2HpYMI28Textl+Y7599e1SkYafxxmy7ytfb8BvPuF1GG2s8AhNKSkIA3JoWZK43hoK1KG1u3
 3lUSpA0uAld3p8dztSIfgqy8SM99Qt9dxJB8021qOADMBd+l9Ulx0dgVNiyYMWNoX2BKCC+IHKc
 RKVhcwo9jyOfzTXnqLL4bEs6USW7UfoeKeYc6aFhaIe1mWfmQm/Bpj8nCVhb5Rh/1u5zpkzFP9r
 x1ZHQe7ArGleYuOtJA3s1X7Rm+J2mQMfGBt/bFUoWDFid035oGd4PbTszp8N+6xTWyrqMOhTz7v
 gzktyQkPulTfdrQhWVekU/5LJVONrxZgpfRBKrmBY5YZPM6vXZdwYKXYuEUDvydvMsy0xXqdVyR
 MOoSLitGIiywvpeBu+DJniEcCDmtLVuITZrYmas7yPiML6Z4xe/q9LSirgQt9gGu4h08W5rJjC5
 Yyh0d9L2MvzEVTQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

NFSD treats TLS peer identity as a boolean: a peer is authenticated
or it is not. Some deployments need finer authorization. A single
certificate may authenticate several distinct actors, and an
administrator may wish to grant each a different level of access.

Once a TLS handshake completes, tlshd hands the kernel a list of
tags for the session. When an export configures an allow_tags list,
grant access only when the session carries at least one matching
tag. An export with no allow_tags list continues to admit any
authenticated peer. Report each denial through the
nfsd_export_tags_denied tracepoint, with the client's address and
the request's XID.

tlshd issues session tags only for an mTLS handshake. Reject an
allow_tags list paired with any xprtsec mode other than mtls. The
administrator then states the combination explicitly, where a
default xprtsec setting would expose the export to plaintext or
anonymous-TLS peers.

A kernel that predates this patch ignores allow_tags and exports
the filesystem without the restriction. List an export's tags in
/proc/fs/nfsd/exports so user space can confirm the restriction
took effect.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/Kconfig         |   1 +
 fs/nfsd/export.c        | 114 +++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfsd/export.h        |   9 ++++
 fs/nfsd/trace.h         |  27 ++++++++++++
 include/net/handshake.h |   5 +++
 5 files changed, 151 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index ffb76761d6a8..14f694323dcb 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -12,6 +12,7 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_COMMON
+	select STRINGSET
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
 	select NFS_ACL_SUPPORT if NFSD_V3_ACL
 	depends on MULTIUSER
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index e5a0f1ababe6..68f8c570ab0d 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -18,6 +18,7 @@
 #include <linux/exportfs.h>
 #include <linux/sunrpc/svc_xprt.h>
 #include <net/genetlink.h>
+#include <net/handshake.h>
 #include <uapi/linux/nfsd_netlink.h>
 
 #include "nfsd.h"
@@ -629,6 +630,7 @@ static void svc_export_release(struct rcu_head *rcu_head)
 	struct svc_export *exp = container_of(rcu_head, struct svc_export,
 			ex_rcu);
 
+	stringset_destroy(&exp->ex_allow_tags);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	export_stats_destroy(exp->ex_stats);
 	kfree(exp->ex_stats);
@@ -1287,6 +1289,52 @@ static int xprtsec_parse(char **mesg, char *buf, struct svc_export *exp)
 	return 0;
 }
 
+static int tags_parse(char **mesg, char *buf, struct stringset *tags)
+{
+	unsigned int i, listsize;
+	int err;
+
+	/* more than one allow_tags */
+	if (tags->ss_finalized)
+		return -EINVAL;
+
+	err = get_uint(mesg, &listsize);
+	if (err)
+		return -EINVAL;
+	if (listsize == 0 || listsize > NFSD_MAX_ALLOW_TAGS)
+		return -EINVAL;
+	if (!stringset_alloc(tags, listsize, GFP_KERNEL))
+		return -ENOMEM;
+
+	for (i = 0; i < listsize; i++) {
+		int len;
+
+		len = qword_get(mesg, buf, PAGE_SIZE);
+		if (len <= 0 || len > HANDSHAKE_SESSION_TAG_MAX_LEN)
+			return -EINVAL;
+		if (strlen(buf) != len)
+			return -EINVAL;
+		if (!stringset_add_dup(tags, buf, GFP_KERNEL))
+			return -ENOMEM;
+	}
+	stringset_finalize(tags);
+
+	return 0;
+}
+
+/*
+ * tlshd issues session tags only for an mTLS handshake, so an
+ * allow_tags list is valid only with xprtsec=mtls alone.
+ * check_xprtsec_policy() enforces the same invariant at access time.
+ */
+static int check_allow_tags(const struct svc_export *exp)
+{
+	if (!stringset_is_empty(&exp->ex_allow_tags) &&
+	    exp->ex_xprtsec_modes != NFSEXP_XPRTSEC_MTLS)
+		return -EINVAL;
+	return 0;
+}
+
 static inline int
 nfsd_uuid_parse(char **mesg, char *buf, unsigned char **puuid)
 {
@@ -1348,6 +1396,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 	exp.cd = cd;
 	exp.ex_devid_map = NULL;
 	exp.ex_xprtsec_modes = NFSEXP_XPRTSEC_ALL;
+	stringset_init(&exp.ex_allow_tags);
 
 	/* expiry */
 	err = get_expiry(&mesg, &exp.h.expiry_time);
@@ -1382,6 +1431,11 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 			goto out3;
 		exp.ex_fsid = an_int;
 
+		/*
+		 * A kernel that does not recognize "allow_tags" breaks
+		 * out of this loop when it reaches that word, exporting
+		 * the filesystem without the tag restriction.
+		 */
 		while (qword_get(&mesg, buf, PAGE_SIZE) > 0) {
 			if (strcmp(buf, "fsloc") == 0)
 				err = fsloc_parse(&mesg, buf, &exp.ex_fslocs);
@@ -1391,6 +1445,8 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 				err = secinfo_parse(&mesg, buf, &exp);
 			else if (strcmp(buf, "xprtsec") == 0)
 				err = xprtsec_parse(&mesg, buf, &exp);
+			else if (strcmp(buf, "allow_tags") == 0)
+				err = tags_parse(&mesg, buf, &exp.ex_allow_tags);
 			else
 				/* quietly ignore unknown words and anything
 				 * following. Newer user-space can try to set
@@ -1401,6 +1457,10 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 				goto out4;
 		}
 
+		err = check_allow_tags(&exp);
+		if (err)
+			goto out4;
+
 		err = check_export(&exp.ex_path, &exp.ex_flags, exp.ex_uuid);
 		if (err)
 			goto out4;
@@ -1443,6 +1503,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 	} else
 		err = -ENOMEM;
 out4:
+	stringset_destroy(&exp.ex_allow_tags);
 	nfsd4_fslocs_free(&exp.ex_fslocs);
 	kfree(exp.ex_uuid);
 out3:
@@ -1468,6 +1529,22 @@ static int is_export_stats_file(struct seq_file *m)
 	return !strcmp(m->file->f_path.dentry->d_name.name, "export_stats");
 }
 
+static void show_allow_tags(struct seq_file *m,
+			    const struct stringset *tags)
+{
+	unsigned int i;
+	char *tag;
+
+	if (stringset_is_empty(tags))
+		return;
+	seq_puts(m, ",allow_tags=");
+	stringset_for_each(tags, i, tag) {
+		if (i)
+			seq_putc(m, ':');
+		seq_escape(m, tag, ",:() \t\n\\");
+	}
+}
+
 static int svc_export_show(struct seq_file *m,
 			   struct cache_detail *cd,
 			   struct cache_head *h)
@@ -1514,6 +1591,7 @@ static int svc_export_show(struct seq_file *m,
 			}
 		}
 		show_secinfo(m, exp);
+		show_allow_tags(m, &exp->ex_allow_tags);
 	}
 	seq_puts(m, ")\n");
 	return 0;
@@ -1570,6 +1648,9 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 		new->ex_flavors[i] = item->ex_flavors[i];
 	}
 	new->ex_xprtsec_modes = item->ex_xprtsec_modes;
+	new->ex_allow_tags = item->ex_allow_tags;
+	/* Shallow move: @item is released once the update completes. */
+	stringset_init(&item->ex_allow_tags);
 }
 
 static struct cache_head *svc_export_alloc(void)
@@ -1590,6 +1671,8 @@ static struct cache_head *svc_export_alloc(void)
 		return NULL;
 	}
 
+	stringset_init(&i->ex_allow_tags);
+
 	return &i->h;
 }
 
@@ -1798,6 +1881,9 @@ static struct svc_export *exp_find(struct cache_detail *cd,
  * one exception is __fh_verify() since it has logic that may result in one
  * or both of the helpers being skipped.
  *
+ * When @exp carries an allow_tags list, the session's tags must
+ * intersect it.
+ *
  * Return values:
  *   %nfs_ok if access is granted, or
  *   %nfserr_wrongsec if access is denied
@@ -1806,19 +1892,37 @@ __be32 check_xprtsec_policy(struct svc_export *exp, struct svc_rqst *rqstp)
 {
 	struct svc_xprt *xprt = rqstp->rq_xprt;
 
+	/*
+	 * A tagged export is satisfiable only by a matching mTLS
+	 * session, so the plaintext and anonymous-TLS arms grant
+	 * access only when the allow_tags list is empty.
+	 */
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_NONE) {
-		if (!test_bit(XPT_TLS_SESSION, &xprt->xpt_flags))
+		if (!test_bit(XPT_TLS_SESSION, &xprt->xpt_flags) &&
+		    stringset_is_empty(&exp->ex_allow_tags))
 			return nfs_ok;
 	}
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_TLS) {
 		if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags) &&
-		    !test_bit(XPT_PEER_AUTH, &xprt->xpt_flags))
+		    !test_bit(XPT_PEER_AUTH, &xprt->xpt_flags) &&
+		    stringset_is_empty(&exp->ex_allow_tags))
 			return nfs_ok;
 	}
 	if (exp->ex_xprtsec_modes & NFSEXP_XPRTSEC_MTLS) {
-		if (test_bit(XPT_TLS_SESSION, &xprt->xpt_flags) &&
-		    test_bit(XPT_PEER_AUTH, &xprt->xpt_flags))
-			return nfs_ok;
+		/*
+		 * test_bit_acquire() pairs with the smp_wmb() in
+		 * svc_tcp_handshake_done(): a set XPT_TLS_SESSION
+		 * guarantees the handshake tag stores are visible here.
+		 */
+		if (test_bit_acquire(XPT_TLS_SESSION, &xprt->xpt_flags) &&
+		    test_bit(XPT_PEER_AUTH, &xprt->xpt_flags)) {
+			if (stringset_is_empty(&exp->ex_allow_tags))
+				return nfs_ok;
+			if (stringset_intersection(&xprt->xpt_handshake_tags,
+						&exp->ex_allow_tags))
+				return nfs_ok;
+			trace_nfsd_export_tags_denied(rqstp, exp);
+		}
 	}
 	return nfserr_wrongsec;
 }
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 117fb28db1e0..e7ebf5abc594 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -7,6 +7,7 @@
 
 #include <linux/sunrpc/cache.h>
 #include <linux/percpu_counter.h>
+#include <linux/stringset.h>
 #include <uapi/linux/nfsd/export.h>
 #include <linux/nfs4.h>
 
@@ -47,6 +48,13 @@ struct exp_flavor_info {
 	u32	flags;
 };
 
+/*
+ * Bounds the per-request cost of the stringset_intersection() in
+ * check_xprtsec_policy(). Independent of the per-handshake session
+ * tag cap, HANDSHAKE_MAX_SESSIONTAGS.
+ */
+#define NFSD_MAX_ALLOW_TAGS	64
+
 /* Per-export stats */
 enum {
 	EXP_STATS_FH_STALE,
@@ -78,6 +86,7 @@ struct svc_export {
 	struct rcu_head		ex_rcu;
 	unsigned long		ex_xprtsec_modes;
 	struct export_stats	*ex_stats;
+	struct stringset	ex_allow_tags;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 2ae7f150a72c..e5c179fe28f8 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -467,6 +467,33 @@ TRACE_EVENT(nfsd_export_update,
 	)
 );
 
+TRACE_EVENT(nfsd_export_tags_denied,
+	TP_PROTO(
+		const struct svc_rqst *rqstp,
+		const struct svc_export *exp
+	),
+	TP_ARGS(rqstp, exp),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__sockaddr(client, rqstp->rq_xprt->xpt_remotelen)
+		__string(path, exp->ex_path.dentry->d_name.name)
+		__string(auth_domain, exp->ex_client->name)
+	),
+	TP_fast_assign(
+		const struct svc_xprt *xprt = rqstp->rq_xprt;
+
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__assign_sockaddr(client, &xprt->xpt_remote,
+				  xprt->xpt_remotelen);
+		__assign_str(path);
+		__assign_str(auth_domain);
+	),
+	TP_printk("xid=0x%08x client=%pISpc path=%s domain=%s",
+		__entry->xid, __get_sockaddr(client),
+		__get_str(path), __get_str(auth_domain)
+	)
+);
+
 DECLARE_EVENT_CLASS(nfsd_io_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,
diff --git a/include/net/handshake.h b/include/net/handshake.h
index ad96e92af04d..d04f0c0b9cba 100644
--- a/include/net/handshake.h
+++ b/include/net/handshake.h
@@ -12,10 +12,15 @@
 
 #include <linux/errno.h>
 #include <linux/stringset.h>
+#include <uapi/linux/handshake.h>
 
 /*
  * Bounds the cost of stringset_intersection() in consumer
  * authorization checks.
+ *
+ * The per-tag byte limit, HANDSHAKE_SESSION_TAG_MAX_LEN, is
+ * enforced by the netlink policy generated from
+ * Documentation/netlink/specs/handshake.yaml.
  */
 #define HANDSHAKE_MAX_SESSIONTAGS	64
 

-- 
2.56.0

