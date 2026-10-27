Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119843;
	b=UIXR+zFzeDaWMCuUqpeaSZUnL8Vs57EXBvlVtWFF5s55LOsGhvgoDe2BEbgGC5Rakutp
	 BS8DIWqayKg3X4xOF0peF6oOsPqP/3uAa8ajDyjn1bwx0mgkGjvXI89zpvxcWKduvcO8L
	 dExmdebmrnnhtcGeWKLlG2Q6eJsLkBWkofwrq8gpqkAa67xvZYj7OHQdalahIZ/N13V3z
	 JvDBATbQRjN//c5+VU/OJ8T9ZJstYedHCc2E9LC+V0LFPSHDBNgnmtpJeDfdneTf2+fJ7
	 tn4FlAWAzuNIVbvkbX5MkJZGqy2+cubbDbukQtoH6MJToCazo5H/yDjjAcSFy5fqf4Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119843;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=j5ktTKqXMntQ44FkS0jG8LefIdplhTzMVWjiifnHYSg=;
	b=Kk93Kf65PZ1n3mnUmmn4mXVaTAH99dK2aUCyT7CR6FtKoYtWHzHViLyc2u0i9sCA9KT3
	 8M5Q+FLeDObWp2UKXwfd/A1jS5Yvl6eInCfsrVBZrY/1lo0o+hrvyxj1dTEzNzDaFj+IC
	 S+S5cRvD9TLR4I/OLpqMWJJHYhy6QHOev8RTQai9zWc9o/J1AyNoiYpwitl5xwaKowXIJ
	 Ay9lYTLQXZAukcRS1+EjmL32k7W+pMpjuCO3LOsF0HOqXGEetwWXe2U3PAU2XVlqbYHgv
	 ClZZfJ0+KQ8o1/jFdCdqE3zogwtIA9eqqOjj/bQgZMlcqthE7+KCYS1phEonxAbzKJA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n2QToUYr;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCF49606A31F
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 16:50:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=n2QToUYr
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C87971F031E1;
	Tue, 27 Oct 2026 16:50:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119842;
	bh=j5ktTKqXMntQ44FkS0jG8LefIdplhTzMVWjiifnHYSg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=n2QToUYrFnRkvkejO840I13RuqOItIDw9KpOsgOh/oD7t3h9tIuU/rso7Bxxx9WZZ
	 mPdJ9xPT3ze+RtJsuHKac13z6BEU0fVfBw5W3B9AU1z1ktwV27HUDpS7OUwSs9oY+P
	 ay1inqBidO8f3TRJDI2TwHkgQggXuXlUvflD/mT61XaUu/EqBtC4YEW0/5SSz2zIJY
	 rXvFK+m74hVA4o3MwtxNGqmPWDVptC0yW0vADZyt8/gsmCrp3SbAYyknIZSQ2y7A5k
	 VVsDXpT9uY15svvuduYcpK1zU5kdGHwv4TMLp7Vc4mrnb3o0MalRZaIVrq7CPHroaI
	 4bqagsEKH9xyw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:50:24 -0400
Subject: [PATCH nfs-utils 2/4] exports: Add riomode= and wiomode= export
 options
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
Message-Id: <20261027-master-v1-2-6f1f7a35a83b@kernel.org>
References: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
In-Reply-To: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11776; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=UugBQDw6AU7a9gEVsCdXl/EgK7AkedbQ2xbzc/fRRP4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NZeE1NeZCfrYLaxLz7zAPUzlv0OiMHYNAk1n
 FXae3GpAUSJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDWXgAKCRAADmhBGVaC
 FUPtEADQG7dsyQ8pUsf0K9G/i5sxWZ5SrY7equkZerV+KiNl8FwRJD6WMD9yrjexX61Xw5/AsMi
 UsdyXZ2Js1Ej3TVVq1AxY+AFtQutnh8JT/ZorM18dPc05llTuyK5nd+VLd3bcvh8t3MZtSOFhJO
 Y0sWKgDgJrthi8xq0ho64P01ds4O+AQGTr6S5dZX3lnNaGxbBiUS8b1gHXp4DqLOMr7FV74dau2
 zFOjEbTPGKUaB+ImfIN+W7+vCsw4z1PQcX0RxsUFxFxisntK51i22zFQcdswsq8GMk+Zbd4RLFQ
 hSUfEPERDQR0gRbNDsfoQdeBl5tEWZJB4BTwtSeG9OMii9tP0uPB2rYmXgO0oKYK4lIgj+BF09f
 BUrUz4+6vxnh5x7fArgXGXnEMe0zW8vGj9usTgZvYnxYuh3J0bvYTqS34uk5CJXPEz10+Fl6erg
 6dqFuMltFFFLr18riKjt9i8BqRnV3r0K4ljHH04afxLRlQd+xAIfQ9Vg4kMbEEOtW1rTjF88Fx/
 1diILML+iO9/cuXTPbDx0r8oPLlX+S0SS2cPicsEnp8wQXKvzapOE7TmYkhNp8ldatOxOgzVlSq
 HZQ1f2CxIgzvi9VNEZUEvQhyx3g6YQMpWt4HM0f36zwmRZFJZHii4ny9fkGQj9WazHnlNoa/Gfv
 vGAy5zrqQngnpJQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Parse riomode=/wiomode= (buffered/dontcache/direct) into new
e_riomode/e_wiomode exportent fields, defaulting to unset, and pass
explicitly-set values to the kernel over the netlink svc_export
interface.

- Kernels without the iomode attributes (e.g. v7.2) reject the whole
  entry. Add nfsd_export_iomode_supported(), which checks the
  svc_export policy's highest attribute via nfsd_export_policy_query(),
  and have mountd drop the options with a warning on such kernels
  instead of leaving the export unmountable.
- The /proc channel cannot carry them either; warn there too.
- Resync nfsd_netlink.h and bump the configure probe to
  NFSD_A_SVC_EXPORT_WRITE_IOMODE.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 configure.ac                   |  2 +-
 support/export/cache.c         | 59 +++++++++++++++++++++++++++++++++++++++++-
 support/export/export_policy.c | 22 ++++++++++++++++
 support/export/v4root.c        |  2 ++
 support/include/exportfs.h     |  1 +
 support/include/nfsd_netlink.h | 12 +++++++++
 support/include/nfslib.h       | 13 ++++++++++
 support/nfs/exports.c          | 51 ++++++++++++++++++++++++++++++++++++
 8 files changed, 160 insertions(+), 2 deletions(-)

diff --git a/configure.ac b/configure.ac
index 2c13292961bf..ff752b8bd17f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -283,7 +283,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_FILEHANDLE_GET;]])],
+			                   [[int foo = NFSD_A_SVC_EXPORT_WRITE_IOMODE;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/export/cache.c b/support/export/cache.c
index 3c7ee9f90ac1..86b8da135837 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1287,6 +1287,9 @@ static struct nl_sock *nfsd_nl_notify_sock;	/* multicast notifications */
 static struct nl_sock *nfsd_nl_cmd_sock;	/* GET_REQS / SET_REQS commands */
 static int nfsd_nl_family;
 
+/* Does the running kernel accept riomode/wiomode in SET_REQS? */
+static bool nfsd_nl_iomode_ok;
+
 #define NL_BUFFER_SIZE	65536
 
 struct export_req {
@@ -1380,8 +1383,10 @@ static int cache_nfsd_nl_open(void)
 	ret = cache_genl_open(NFSD_FAMILY_NAME, NFSD_MCGRP_EXPORTD,
 			      &nfsd_nl_cmd_sock, &nfsd_nl_notify_sock,
 			      &nfsd_nl_family);
-	if (ret == 0)
+	if (ret == 0) {
 		nfsd_nl_load_export_features();
+		nfsd_nl_iomode_ok = nfsd_export_iomode_supported() > 0;
+	}
 	return ret;
 }
 
@@ -1648,6 +1653,40 @@ static int nfsd_nl_add_xprtsec(struct nl_msg *msg, struct exportent *ep)
 	return 0;
 }
 
+static int nfsd_nl_add_iomode(struct nl_msg *msg, struct exportent *ep)
+{
+	static bool warned;
+
+	if (ep->e_riomode == NFSD_IO_UNSET && ep->e_wiomode == NFSD_IO_UNSET)
+		return 0;
+
+	/*
+	 * A kernel without per-export I/O modes would refuse the entry,
+	 * leaving the export unmountable.  Export it with the server's
+	 * global I/O modes instead.
+	 */
+	if (!nfsd_nl_iomode_ok) {
+		if (!warned) {
+			xlog(L_WARNING, "%s: kernel does not support riomode= "
+			     "or wiomode=, ignoring", ep->e_path);
+			warned = true;
+		}
+		return 0;
+	}
+
+	if (ep->e_riomode != NFSD_IO_UNSET &&
+	    nla_put_u32(msg, NFSD_A_SVC_EXPORT_READ_IOMODE,
+			ep->e_riomode) < 0)
+		return -1;
+
+	if (ep->e_wiomode != NFSD_IO_UNSET &&
+	    nla_put_u32(msg, NFSD_A_SVC_EXPORT_WRITE_IOMODE,
+			ep->e_wiomode) < 0)
+		return -1;
+
+	return 0;
+}
+
 /*
  * Add one svc_export response.  @ea must be the attributes computed by
  * export_attrs_build() for (@path, @exp), and is ignored when @exp is NULL.
@@ -1704,6 +1743,9 @@ static int nfsd_nl_add_export(struct nl_msg *msg, char *domain, char *path,
 
 		if (nfsd_nl_add_xprtsec(msg, exp))
 			goto nla_failure;
+
+		if (nfsd_nl_add_iomode(msg, exp))
+			goto nla_failure;
 	}
 
 	nla_nest_end(msg, nest);
@@ -3261,6 +3303,20 @@ static void cache_sunrpc_nl_process(void)
 		cache_nl_process_unix_gid();
 }
 
+/* The kernel takes per-export I/O modes only over netlink */
+static void warn_iomode_unsupported(struct exportent *exp)
+{
+	static bool warned;
+
+	if (warned || (exp->e_riomode == NFSD_IO_UNSET &&
+		       exp->e_wiomode == NFSD_IO_UNSET))
+		return;
+
+	xlog(L_WARNING, "%s: riomode= and wiomode= need the netlink "
+	     "export interface, ignoring", exp->e_path);
+	warned = true;
+}
+
 static int dump_to_cache(int f, char *buf, int blen, char *domain,
 			 char *path, struct exportent *exp, int ttl)
 {
@@ -3293,6 +3349,7 @@ static int dump_to_cache(int f, char *buf, int blen, char *domain,
 			qword_addhex(&bp, &blen, ea.uuid, 16);
 		}
 		write_xprtsec(&bp, &blen, exp);
+		warn_iomode_unsupported(exp);
 		xlog(D_AUTH, "granted access to %s for %s",
 		     path, *domain == '$' ? domain+1 : domain);
 	} else {
diff --git a/support/export/export_policy.c b/support/export/export_policy.c
index a0170cb87f91..797a8459e3c0 100644
--- a/support/export/export_policy.c
+++ b/support/export/export_policy.c
@@ -244,6 +244,28 @@ int nfsd_export_policy_query(struct nfsd_export_policy *UNUSED(pol))
 
 #endif /* HAVE_GENL_POLICY_DUMP */
 
+/**
+ * nfsd_export_iomode_supported - does the kernel take per-export I/O modes?
+ *
+ * A kernel without them refuses any svc_export entry that carries one.
+ *
+ * Returns 1 if it accepts riomode/wiomode, 0 if not or if that cannot be
+ * found out, or -1 if the nfsd netlink family is not registered, as when
+ * nfsd is not loaded.
+ */
+int nfsd_export_iomode_supported(void)
+{
+	struct nfsd_export_policy pol;
+	int ret;
+
+	ret = nfsd_export_policy_query(&pol);
+	if (ret == -ENOENT)
+		return -1;
+	if (ret < 0)
+		return 0;
+	return pol.max_attr >= NFSD_A_SVC_EXPORT_WRITE_IOMODE;
+}
+
 /**
  * nfsd_nl_load_export_features - learn the kernel's export flags over netlink
  *
diff --git a/support/export/v4root.c b/support/export/v4root.c
index 38286b91ede0..4075b9ef2fef 100644
--- a/support/export/v4root.c
+++ b/support/export/v4root.c
@@ -47,6 +47,8 @@ static nfs_export pseudo_root = {
 		.e_fsid = 0,
 		.e_mountpoint = NULL,
 		.e_ttl = 0,
+		.e_riomode = NFSD_IO_UNSET,
+		.e_wiomode = NFSD_IO_UNSET,
 	},
 	.m_exported = 0,
 	.m_xtabent = 1,
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index a7c145543075..9096db37a6ee 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -177,6 +177,7 @@ struct nfsd_export_policy {
 struct nfsd_export_policy *get_export_features(void);
 void set_export_features(const struct nfsd_export_policy *pol);
 int nfsd_export_policy_query(struct nfsd_export_policy *pol);
+int nfsd_export_iomode_supported(void);
 void nfsd_nl_load_export_features(void);
 
 void fix_pseudoflavor_flags(struct exportent *ep);
diff --git a/support/include/nfsd_netlink.h b/support/include/nfsd_netlink.h
index dcd2126d848b..6628ed7c0922 100644
--- a/support/include/nfsd_netlink.h
+++ b/support/include/nfsd_netlink.h
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
+	NFSD_A_SVC_EXPORT_READ_IOMODE,
+	NFSD_A_SVC_EXPORT_WRITE_IOMODE,
 
 	__NFSD_A_SVC_EXPORT_MAX,
 	NFSD_A_SVC_EXPORT_MAX = (__NFSD_A_SVC_EXPORT_MAX - 1)
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index c8601a156cba..f2be65b55f8c 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -75,6 +75,16 @@ struct xprtsec_entry {
 	int			flags;
 };
 
+/*
+ * Per-export I/O modes for riomode=/wiomode=. Values must match the
+ * kernel's NFSD_IO_* enum (fs/nfsd/nfsd.h). NFSD_IO_UNSET means no
+ * option was given; the export follows the server's global setting.
+ */
+#define NFSD_IO_BUFFERED	0
+#define NFSD_IO_DONTCACHE	1
+#define NFSD_IO_DIRECT		2
+#define NFSD_IO_UNSET		(-1)
+
 /*
  * Data related to a single exports entry as returned by getexportent.
  * FIXME: export options should probably be parsed at a later time to
@@ -100,6 +110,8 @@ struct exportent {
 	unsigned int	e_ttl;
 	char *		e_realpath;
 	int		e_reexport;
+	int		e_riomode;
+	int		e_wiomode;
 };
 
 struct rmtabent {
@@ -115,6 +127,7 @@ void			setexportent(char *fname, char *type);
 struct exportent *	getexportent(int);
 void 			secinfo_show(FILE *fp, struct exportent *ep);
 void			xprtsecinfo_show(FILE *fp, struct exportent *ep);
+const char *		iomode_name(int mode);
 void			putexportent(struct exportent *xep);
 void			endexportent(void);
 struct exportent *	mkexportent(char *hname, char *path, char *opts);
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 5ccc4ca0582f..94fa50ecefa3 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -107,6 +107,8 @@ static void init_exportent (struct exportent *ee, int fromkernel)
 	ee->e_uuid = NULL;
 	ee->e_ttl = default_ttl;
 	ee->e_reexport = REEXP_NONE;
+	ee->e_riomode = NFSD_IO_UNSET;
+	ee->e_wiomode = NFSD_IO_UNSET;
 }
 
 struct exportent *
@@ -313,6 +315,10 @@ putexportent(struct exportent *ep)
 	if (ep->e_flags & NFSEXP_SIGN_FH)
 		fprintf(fp, "sign_fh,");
 	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
+	if (ep->e_riomode != NFSD_IO_UNSET)
+		fprintf(fp, "riomode=%s,", iomode_name(ep->e_riomode));
+	if (ep->e_wiomode != NFSD_IO_UNSET)
+		fprintf(fp, "wiomode=%s,", iomode_name(ep->e_wiomode));
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -586,6 +592,45 @@ static unsigned int parse_xprtsec(char *str, struct exportent *ep)
 	return out;
 }
 
+/*
+ * Parse the value of a riomode= or wiomode= option into @mode.
+ *
+ * A zero return indicates an error.
+ */
+static int parse_iomode(char *str, int *mode)
+{
+	char *flname = efname ? efname : "command line";
+	int flline = efp ? efp->x_line : 0;
+
+	if (!strcmp(str, "buffered"))
+		*mode = NFSD_IO_BUFFERED;
+	else if (!strcmp(str, "dontcache"))
+		*mode = NFSD_IO_DONTCACHE;
+	else if (!strcmp(str, "direct"))
+		*mode = NFSD_IO_DIRECT;
+	else {
+		xlog(L_ERROR, "%s:%d: bad iomode \"%s\"\n",
+		     flname, flline, str);
+		return 0;
+	}
+	return 1;
+}
+
+const char *
+iomode_name(int mode)
+{
+	switch (mode) {
+	case NFSD_IO_BUFFERED:
+		return "buffered";
+	case NFSD_IO_DONTCACHE:
+		return "dontcache";
+	case NFSD_IO_DIRECT:
+		return "direct";
+	default:
+		return "unknown";
+	}
+}
+
 /* Sets the bits in @mask for the appropriate security flavor flags. */
 static void setflags(int mask, unsigned int active, struct exportent *ep)
 {
@@ -804,6 +849,12 @@ bad_option:
 		} else if (strncmp(opt, "xprtsec=", 8) == 0) {
 			if (!parse_xprtsec(opt + 8, ep))
 				goto bad_option;
+		} else if (strncmp(opt, "riomode=", 8) == 0) {
+			if (!parse_iomode(opt + 8, &ep->e_riomode))
+				goto bad_option;
+		} else if (strncmp(opt, "wiomode=", 8) == 0) {
+			if (!parse_iomode(opt + 8, &ep->e_wiomode))
+				goto bad_option;
 		} else if (strncmp(opt, "reexport=", 9) == 0) {
 			char *strategy = strchr(opt, '=');
 

-- 
2.56.0

