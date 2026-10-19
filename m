Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 737C14E2F38
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410403; cv=none; b=A1eLVO16+ZkzDLAIlzsFOsPp6qs1gK/9ngnaaYmVQwFKJNuV9alHjYxxObhdpcCq3/e3MDX027byARdRERURp5MDoEGbd8QwF9Gt1KlqNRRKledDdRPymVv5W81VeFzHLjYakY/5wR3oKM27d6BQav+IMIttQXZhXd2ns2YMr6Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410403; c=relaxed/simple;
	bh=kUIAWMm+e2EPm+qtHGt6Se1rt3LMeqSsz+b8lHnvtqU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=eiPEJAQEpFB94wh6sZhajvosyQW3MiEwf5Ye2UR0CUj7MJzUgIbmPNhSblgolpQl10GUm47dSFQl9niWsz4QFeTsMvKWL7u+MifNdIwYYcWEL1blY8/ABPVLXsMGTi9+HU/gJW3tLC3IT3dO7+R3LPpqni/uBIHPP73Na3vCf3s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jpVeF7qu; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jpVeF7qu"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B54B81F000C4;
	Mon, 19 Oct 2026 11:46:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410401;
	bh=5t2oTltC8c9B0xExNawjC/2FVvOKBBiDPlOxpQ88P/g=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=jpVeF7qug0QGHQAdnn/sIYBO+htwLMNrpe5rcMm2yowobUGjdKgVHKZkrs+a2RxvE
	 lliqEKijWrVxC3qkUAX+4Iep0BmJf+pk57C5K4EQ6CALGw33mmk3OImgK7FzSKZHmV
	 a4wqxOk9ChWc3x9MADZdWJU6Xx0kF1dY5MaZwq+eC6N6nMMG0u6yaPgeleebEMweKZ
	 616zUEUfIM0ZxNLWQJS0CDijPgEij9dUgXO+JmkZUj/717Wzf/xLo4t7jPdw4mFa7P
	 K0xlTYIv6HgHJIDfa9ANrmJ3nKiMpMbFHmmnaaMwOudRLX9l40CqlD1lvHAgrnparv
	 bZdUIDfTQiM2w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:24 -0400
Subject: [PATCH nfs-utils v2 4/7] exportfs/mountd/exportd: get export
 features from the netlink policy
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-4-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=14281; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=kUIAWMm+e2EPm+qtHGt6Se1rt3LMeqSsz+b8lHnvtqU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMdXxfs45IdqrmzaQltQqQ9veorijyQXmwT/
 WUlFPV78AKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHQAKCRAADmhBGVaC
 Fd+hD/0aWcOAq8Uen4ORZsAQqrR4IwElp/Jzhs9To6SVrjZV+U7bRuL8kIYJMZL5QXCqE8EufaH
 3ez2PXkhND+B9H7abjrT89c1jr4UWoY83b2fzVe+3liZ6/D/Foj67wV1TwYPS1aSDQb3Tftdwuu
 c/p0XL1sxj8i/20Rqge8+4KSi5DABAFGFFzWWj4NVMKSZSFpFN2+L7MKIuApL1/KznAKiHjnSbK
 0PD0t0MoqJQXYS2YjZ3P+sNvfb8ojUHWOnoOqEP/0XqxOr3SSu/ahaKTMSl1984nr40GG5WE18q
 IwlDBIji/s+B5EHB2mTAaJLlKcHnDxpcyrXaPFe6ASxTjy7hygvDxFKDLxaWeT624ggTrpyNa/0
 JP/OYkieh1V+H6uQUuoI4GhPcEzCv80kqT6yanOjOq0upY0cKEPYKlm+aNFuLmrd6XBzuxm48AM
 EsRTJzBLUj4ybFQnqfnxGUYSNo6Dc5ygxtaDqVX9a9y97Qs8tCKt+hD5NviTWYDo+ojmvvYbS5t
 OwSTrAGCQbqAMxXl31vKMSpSfxrYUhQn7SdbIZp0Gv9rJVWCjOFxwT8ntAUlFRXhVxvus74IdCR
 3oMUu2m5EWUNU9eEoxBKIhtKxgxbLKMX5TRscpVIsBCSDGiFGNhBa4Mr2AQf2CaKoJLiCTNC31/
 aiZuuxA0cQEwTgA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

get_export_features() reads /proc/fs/nfsd/export_features. The nfsd
SET_REQS policy already says which export flags the kernel takes:
NFSD_A_SVC_EXPORT_FLAGS is masked to exactly that set.

- Add nfsd_export_policy_query() in a new export_policy.c (so
  cache_flush.o stays free of exports.o): a CTRL_CMD_GETPOLICY dump of
  SET_REQS, following the op policy -> REQUESTS -> svc_export nest. It
  fills struct nfsd_export_policy. A good answer is cached.
- The policy cannot give the per-flavor flags (the auth-flavor FLAGS
  mask is the full set), so use NFSEXP_SECINFO_FLAGS; it is the same on
  every kernel with the netlink export interface.
- Add set_export_features(), and nfsd_nl_load_export_features() to
  seed it from the policy. exportfs calls it at startup, and
  mountd/exportd once the nfsd netlink socket opens.
- If netlink cannot answer, get_export_features() still reads /proc.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 configure.ac                   |  24 ++++
 support/export/Makefile.am     |   4 +-
 support/export/cache.c         |  11 +-
 support/export/export_policy.c | 258 +++++++++++++++++++++++++++++++++++++++++
 support/include/exportfs.h     |   4 +
 support/include/nfs/export.h   |   5 +
 support/nfs/exports.c          |  33 ++++--
 utils/exportfs/exportfs.c      |   2 +
 8 files changed, 326 insertions(+), 15 deletions(-)

diff --git a/configure.ac b/configure.ac
index 71ec1841d5b0..76d7b72fa9d4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -255,6 +255,30 @@ AC_ARG_ENABLE(nfsdcltrack,
 PKG_CHECK_MODULES(LIBNL3, libnl-3.0 >= 3.1)
 PKG_CHECK_MODULES(LIBNLGENL3, libnl-genl-3.0 >= 3.1)
 
+AC_CACHE_CHECK([for generic netlink policy dump support],
+		[nfsutils_cv_have_genl_policy_dump],
+	[AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[
+#include <linux/genetlink.h>
+#include <linux/netlink.h>
+	]], [[
+		int policy[] = {
+			CTRL_CMD_GETPOLICY,
+			CTRL_ATTR_OP_POLICY,
+			CTRL_ATTR_POLICY,
+			CTRL_ATTR_OP,
+			CTRL_ATTR_POLICY_DO,
+			NL_POLICY_TYPE_ATTR_POLICY_IDX,
+			NL_POLICY_TYPE_ATTR_MASK,
+		};
+
+		return policy[0];
+	]])],
+	[nfsutils_cv_have_genl_policy_dump=yes],
+	[nfsutils_cv_have_genl_policy_dump=no])])
+AS_IF([test "x$nfsutils_cv_have_genl_policy_dump" = "xyes"],
+	[AC_DEFINE([HAVE_GENL_POLICY_DUMP], 1,
+		[Define to 1 if generic netlink policy dumps are supported])])
+
 AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
diff --git a/support/export/Makefile.am b/support/export/Makefile.am
index 33416176c41e..ab8708abd19b 100644
--- a/support/export/Makefile.am
+++ b/support/export/Makefile.am
@@ -12,8 +12,8 @@ EXTRA_DIST	= mount.x
 noinst_LIBRARIES = libexport.a
 libexport_a_SOURCES = client.c export.c hostname.c \
 		      xtab.c mount_clnt.c mount_xdr.c \
-		      cache.c cache_flush.c auth.c v4root.c fsloc.c \
-		      v4clients.c
+		      cache.c cache_flush.c export_policy.c auth.c v4root.c \
+		      fsloc.c v4clients.c
 libexport_a_CPPFLAGS = $(AM_CPPFLAGS) $(CPPFLAGS) -I$(top_srcdir)/support/reexport \
 		       $(LIBNL3_CFLAGS) $(LIBNLGENL3_CFLAGS)
 
diff --git a/support/export/cache.c b/support/export/cache.c
index d9540ef7fcfb..2724dd3befbb 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1375,9 +1375,14 @@ out_free_cmd:
 
 static int cache_nfsd_nl_open(void)
 {
-	return cache_genl_open(NFSD_FAMILY_NAME, NFSD_MCGRP_EXPORTD,
-			       &nfsd_nl_cmd_sock, &nfsd_nl_notify_sock,
-			       &nfsd_nl_family);
+	int ret;
+
+	ret = cache_genl_open(NFSD_FAMILY_NAME, NFSD_MCGRP_EXPORTD,
+			      &nfsd_nl_cmd_sock, &nfsd_nl_notify_sock,
+			      &nfsd_nl_family);
+	if (ret == 0)
+		nfsd_nl_load_export_features();
+	return ret;
 }
 
 static int nl_seq_check_handler(struct nl_msg *UNUSED(msg), void *UNUSED(arg))
diff --git a/support/export/export_policy.c b/support/export/export_policy.c
new file mode 100644
index 000000000000..9c0a099fb0c2
--- /dev/null
+++ b/support/export/export_policy.c
@@ -0,0 +1,258 @@
+/*
+ * support/export/export_policy.c
+ *
+ * Ask the kernel's nfsd netlink policy what a svc_export entry may carry.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <errno.h>
+#include <stdbool.h>
+#include <stdint.h>
+
+#include "nfslib.h"
+#include "exportfs.h"
+#include "xlog.h"
+
+extern int no_netlink;
+
+#include <netlink/genl/genl.h>
+#include <netlink/genl/ctrl.h>
+#include <netlink/msg.h>
+
+#ifdef USE_SYSTEM_NFSD_NETLINK_H
+#include <linux/nfsd_netlink.h>
+#else
+#include "nfsd_netlink.h"
+#endif
+
+#ifdef HAVE_GENL_POLICY_DUMP
+
+/*
+ * A SET_REQS policy dump covers the op's own policy, the svc_export policy
+ * it nests, and the policies svc_export nests in turn.
+ */
+#define NL_POLICY_SLOTS	8
+
+struct export_policy_dump {
+	int		done;
+	int		do_idx;		/* the op's own policy */
+	/* per policy: */
+	int		reqs_idx[NL_POLICY_SLOTS];	/* REQUESTS nests this */
+	uint64_t	flags_mask[NL_POLICY_SLOTS];	/* mask of FLAGS */
+};
+
+static int nl_policy_done_cb(struct nl_msg *UNUSED(msg), void *arg)
+{
+	struct export_policy_dump *d = arg;
+
+	d->done = 1;
+	return NL_STOP;
+}
+
+static int nl_policy_error_cb(struct sockaddr_nl *UNUSED(nla),
+			      struct nlmsgerr *UNUSED(nlerr), void *arg)
+{
+	struct export_policy_dump *d = arg;
+
+	d->done = 1;
+	return NL_STOP;
+}
+
+/* Note what one NL_POLICY_TYPE_ATTR_* says about attribute @type of @idx */
+static void nl_policy_type_attr(struct export_policy_dump *d, int idx,
+				int type, struct nlattr *p)
+{
+	switch (nla_type(p)) {
+	case NL_POLICY_TYPE_ATTR_POLICY_IDX:
+		if (type == NFSD_A_SVC_EXPORT_REQS_REQUESTS &&
+		    nla_len(p) >= (int)sizeof(uint32_t))
+			d->reqs_idx[idx] = nla_get_u32(p);
+		break;
+	case NL_POLICY_TYPE_ATTR_MASK:
+		if (type == NFSD_A_SVC_EXPORT_FLAGS &&
+		    nla_len(p) >= (int)sizeof(uint64_t))
+			d->flags_mask[idx] = nla_get_u64(p);
+		break;
+	}
+}
+
+static void nl_policy_op(struct export_policy_dump *d, struct nlattr *attr)
+{
+	struct nlattr *op, *a;
+	int orem, arem;
+
+	nla_for_each_nested(op, attr, orem) {
+		nla_for_each_nested(a, op, arem) {
+			if (nla_type(a) == CTRL_ATTR_POLICY_DO &&
+			    nla_len(a) >= (int)sizeof(uint32_t))
+				d->do_idx = nla_get_u32(a);
+		}
+	}
+}
+
+static void nl_policy_attrs(struct export_policy_dump *d, struct nlattr *attr)
+{
+	struct nlattr *pol, *a, *p;
+	int prem, arem, rem;
+
+	nla_for_each_nested(pol, attr, prem) {
+		int idx = nla_type(pol);
+
+		if (idx >= NL_POLICY_SLOTS)
+			continue;
+		nla_for_each_nested(a, pol, arem) {
+			int type = nla_type(a);
+
+			nla_for_each_nested(p, a, rem)
+				nl_policy_type_attr(d, idx, type, p);
+		}
+	}
+}
+
+static int nl_policy_valid_cb(struct nl_msg *msg, void *arg)
+{
+	struct genlmsghdr *gnlh = nlmsg_data(nlmsg_hdr(msg));
+	struct nlattr *attr;
+	int rem;
+
+	nla_for_each_attr(attr, genlmsg_attrdata(gnlh, 0),
+			  genlmsg_attrlen(gnlh, 0), rem) {
+		switch (nla_type(attr)) {
+		case CTRL_ATTR_OP_POLICY:
+			nl_policy_op(arg, attr);
+			break;
+		case CTRL_ATTR_POLICY:
+			nl_policy_attrs(arg, attr);
+			break;
+		}
+	}
+	return NL_OK;
+}
+
+/**
+ * nfsd_export_policy_query - what does the kernel's svc_export policy accept?
+ * @pol: filled in on success
+ *
+ * The kernel refuses a whole svc_export entry over one attribute or flag it
+ * does not know, so ask its SET_REQS policy.  A successful answer is cached.
+ *
+ * Returns 0, -ENOENT if the nfsd netlink family is not registered, as when
+ * nfsd is not loaded, or another negative errno if the policy could not be
+ * read.
+ */
+int nfsd_export_policy_query(struct nfsd_export_policy *pol)
+{
+	static struct nfsd_export_policy cached;
+	static bool have_cached;
+	struct export_policy_dump d = { .do_idx = 0 };
+	struct nl_msg *msg = NULL;
+	struct nl_cb *cb = NULL;
+	struct nl_sock *sock;
+	int family, ret, svc, i;
+
+	if (have_cached) {
+		*pol = cached;
+		return 0;
+	}
+
+	for (i = 0; i < NL_POLICY_SLOTS; i++)
+		d.reqs_idx[i] = -1;
+
+	sock = nl_socket_alloc();
+	if (!sock)
+		return -ENOMEM;
+
+	ret = -ECONNREFUSED;
+	if (genl_connect(sock))
+		goto out;
+
+	ret = -ENOENT;
+	family = genl_ctrl_resolve(sock, NFSD_FAMILY_NAME);
+	if (family < 0)
+		goto out;
+
+	ret = -ENOMEM;
+	msg = nlmsg_alloc();
+	if (!msg ||
+	    !genlmsg_put(msg, NL_AUTO_PID, NL_AUTO_SEQ, GENL_ID_CTRL, 0,
+			 NLM_F_DUMP, CTRL_CMD_GETPOLICY, 0) ||
+	    nla_put_u16(msg, CTRL_ATTR_FAMILY_ID, family) < 0 ||
+	    nla_put_u32(msg, CTRL_ATTR_OP, NFSD_CMD_SVC_EXPORT_SET_REQS) < 0)
+		goto out;
+
+	cb = nl_cb_alloc(NL_CB_DEFAULT);
+	if (!cb)
+		goto out;
+
+	nl_cb_set(cb, NL_CB_VALID, NL_CB_CUSTOM, nl_policy_valid_cb, &d);
+	nl_cb_set(cb, NL_CB_FINISH, NL_CB_CUSTOM, nl_policy_done_cb, &d);
+	nl_cb_err(cb, NL_CB_CUSTOM, nl_policy_error_cb, &d);
+
+	ret = nl_send_auto(sock, msg);
+	while (ret >= 0 && !d.done)
+		ret = nl_recvmsgs(sock, cb);
+
+	/* An error mid-dump leaves the tables partial: trust only a full one */
+	if (ret < 0) {
+		xlog(D_NETLINK, "nfsd policy query failed: %s",
+		     nl_geterror(ret));
+		ret = -EPROTO;
+		goto out;
+	}
+
+	svc = -1;
+	if (d.do_idx >= 0 && d.do_idx < NL_POLICY_SLOTS)
+		svc = d.reqs_idx[d.do_idx];
+	if (svc < 0 || svc >= NL_POLICY_SLOTS) {
+		xlog(D_NETLINK, "nfsd policy query: no svc_export policy");
+		ret = -EPROTO;
+		goto out;
+	}
+
+	cached.flags = d.flags_mask[svc];
+	/*
+	 * The auth-flavor FLAGS mask is the full set too, so the policy
+	 * cannot say which flags may vary per flavor.  These are the same on
+	 * every kernel with the netlink export interface.
+	 */
+	cached.secinfo_flags = NFSEXP_SECINFO_FLAGS;
+	have_cached = true;
+	xlog(D_NETLINK, "svc_export policy: flags 0x%x", cached.flags);
+	*pol = cached;
+	ret = 0;
+out:
+	nl_cb_put(cb);
+	nlmsg_free(msg);
+	nl_socket_free(sock);
+	return ret;
+}
+
+#else /* HAVE_GENL_POLICY_DUMP */
+
+int nfsd_export_policy_query(struct nfsd_export_policy *UNUSED(pol))
+{
+	return -EOPNOTSUPP;
+}
+
+#endif /* HAVE_GENL_POLICY_DUMP */
+
+/**
+ * nfsd_nl_load_export_features - learn the kernel's export flags over netlink
+ *
+ * The svc_export policy masks NFSD_A_SVC_EXPORT_FLAGS to the flags the kernel
+ * knows, which is what /proc/fs/nfsd/export_features reports.  Hand that to
+ * get_export_features(), so that it need not read /proc.  If netlink cannot
+ * say, get_export_features() falls back to /proc as before.
+ */
+void nfsd_nl_load_export_features(void)
+{
+	struct nfsd_export_policy pol;
+
+	if (no_netlink || nfsd_export_policy_query(&pol) < 0 || !pol.flags)
+		return;
+
+	set_export_features(&pol);
+}
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 97d62ff4b157..d762e4533560 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -173,6 +173,10 @@ struct nfsd_export_policy {
 };
 
 struct nfsd_export_policy *get_export_features(void);
+void set_export_features(const struct nfsd_export_policy *pol);
+int nfsd_export_policy_query(struct nfsd_export_policy *pol);
+void nfsd_nl_load_export_features(void);
+
 void fix_pseudoflavor_flags(struct exportent *ep);
 char *exportent_realpath(struct exportent *eep);
 int export_test(struct exportent *eep, int with_fsid);
diff --git a/support/include/nfs/export.h b/support/include/nfs/export.h
index ef3f3e7ea684..9bf09b643311 100644
--- a/support/include/nfs/export.h
+++ b/support/include/nfs/export.h
@@ -39,6 +39,11 @@
  */
 #define NFSEXP_OLD_SECINFO_FLAGS (NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
 					| NFSEXP_ALLSQUASH)
+/*
+ * Flags that can vary per flavor on every kernel with the netlink export
+ * interface:
+ */
+#define NFSEXP_SECINFO_FLAGS	(NFSEXP_OLD_SECINFO_FLAGS | NFSEXP_INSECURE_PORT)
 
 /*
  * Transport layer security policies that are permitted to access
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 2266d5073d4c..5ccc4ca0582f 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -962,20 +962,33 @@ syntaxerr(char *msg)
 	xlog(L_ERROR, "%s:%d: syntax error: %s",
 			efname, efp?efp->x_line:0, msg);
 }
+
+static struct nfsd_export_policy kernel_policy;
+static int kernel_policy_cached;
+
+/*
+ * A program that can ask the kernel over netlink hands its answer in here,
+ * so that get_export_features() need not read /proc.
+ */
+void set_export_features(const struct nfsd_export_policy *pol)
+{
+	kernel_policy = *pol;
+	kernel_policy_cached = 1;
+}
+
 struct nfsd_export_policy *get_export_features(void)
 {
 	static char *path = "/proc/fs/nfsd/export_features";
-	static struct nfsd_export_policy pol;
-	static int cached = 0;
+	struct nfsd_export_policy *pol = &kernel_policy;
 	char buf[50];
 	int c;
 	int fd;
 
-	if (cached)
-		return &pol;
+	if (kernel_policy_cached)
+		return pol;
 
-	pol.flags = NFSEXP_OLDFLAGS;
-	pol.secinfo_flags = NFSEXP_OLD_SECINFO_FLAGS;
+	pol->flags = NFSEXP_OLDFLAGS;
+	pol->secinfo_flags = NFSEXP_OLD_SECINFO_FLAGS;
 
 	fd = open(path, O_RDONLY);
 	if (fd == -1)
@@ -985,13 +998,13 @@ struct nfsd_export_policy *get_export_features(void)
 	if (c == -1)
 		goto err;
 	buf[c] = 0;
-	c = sscanf(buf, "%x %x", &pol.flags, &pol.secinfo_flags);
+	c = sscanf(buf, "%x %x", &pol->flags, &pol->secinfo_flags);
 	if (c != 2)
 		goto err;
 good:
-	cached = 1;
-	return &pol;
+	kernel_policy_cached = 1;
+	return pol;
 err:
 	xlog(L_WARNING, "unexpected error reading %s", path);
-	return &pol;
+	return pol;
 }
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 768d2db7ea8f..ecf66fd07fd1 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -218,6 +218,8 @@ main(int argc, char **argv)
 	if (!setup_state_path_names(progname, ETAB, ETABTMP, ETABLCK, &etab))
 		return 1;
 
+	nfsd_nl_load_export_features();
+
 	if (optind == argc && ! f_all) {
 		if (force_flush) {
 			cache_flush();

-- 
2.56.0

