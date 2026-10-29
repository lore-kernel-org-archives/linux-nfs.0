Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275827;
	b=bH7N6XhWmQ4tX9dgM1b7y2XqsHXYCHJ0ZAfl+g6cfQKT+1kf6uXMtCZhPISQhoA0omY4
	 Emyd+vCFEnipZDIapr9SlnP6PsCLD5/H4+aOTgSet3JwODZWB+jFyaIS1glUsnp4IhOJE
	 Z8wIBsx/D3e/Z6jSnsg+5rzkw/wMWfK9ZJXZEXzjagDfNI97AS2+zLfhFHj7Ag39pE4L2
	 1xcrgJ3dRjqWiDamJSyVHgx2+eAcqEvVupPdvv2RGSEqE22l0WRQQWO80XvgdKK2qHxCk
	 BALifxPCf9iYL1rUEwI2urM+WCapWLSKUG425VHCi9b9xiItXAUacu7BEYbgV17Bzww==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275827;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vW01mcjwlct6V0g3RoD7meCmPVlqLvG0XqJKSfR1UnI=;
	b=HWgSw2fcZx+7HgQCGGtLL/ZNEiZrrZzcOOwO60SBk0YcCT2XgMPbUt5CE/wSEsH88HQV
	 18y2L5ssPQSaeY/m03yAebX2XTfAXi3r/TyEJ7Q8clJHz40VI7S4Ie6SAvVEAEJsGxiRu
	 DyWij7IHm1bKqZojgXUU0f4eKsrfWYQ5kVil1Czuwkx/3Y/Ca3ScLRDo3+kxC/Q0HEyw2
	 7ru2oUmLsDgf6+6wMe55vOJCJbCTICQXhMmoVx/657OQNez8T5uNCT7E5Y3lGmhFuEu5O
	 j76KsWhijXxycSatSg9oRnovVRVlRd7AhPdwAL5syDxgNh9rmR5Xdupg+1s6172KdOw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cHLSRN2S;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42A61606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:10:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cHLSRN2S
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4AC0F1F031E3;
	Thu, 29 Oct 2026 12:10:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275827;
	bh=vW01mcjwlct6V0g3RoD7meCmPVlqLvG0XqJKSfR1UnI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cHLSRN2SaWhrHc9TW5yAc1wszWhTWYtK/oOV9+ByNVM5nMGNckCoadhZQv2Dw/lR0
	 JPfunIymHH/jh8JsgTrHcHaX/dVleo3hwvR1FvO0Ni+wVjFO/56qaJ9HCQ8EwhITcF
	 1DXGeftTzQlIrh8Q0hEUpwibHlYriKD5fTsNT3cIkOKZOsmv3o+CWofwsXnNj6N+Bt
	 qdkWj7b3N/Mx1cmU+AXdpDjedRB83wIQr4hm4rKr3HfhRBJbNvPZkFwfZtD4g0Zbte
	 JyXdVO5xtULMeqT58RaLuwA/+sLl9meBV1EkHJPnEy8UTsMrLvlQI47CkJ4Fkzfldc
	 GCrxZlaGOg/Jg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:10:09 -0400
Subject: [PATCH nfs-utils v2 2/4] exports: Add read_io= and write_io=
 export options
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
Message-Id: <20261029-master-v2-2-32bfc6ac16da@kernel.org>
References: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
In-Reply-To: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11770; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=wbS4PAspWrbdL74mD5c+3OC6QlWXNUcyDhD5949QVfQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zeveawbB56L1Kbq+694232dxamiXeRKh7NOZ
 j6ijjsE35uJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM3rwAKCRAADmhBGVaC
 FRobD/9fH4crft56TmtJ6P8v1voJ895TSs+J0dKfknpRDQv/rKt0y1XXH/c6EdL9ipq0ABN2S/c
 d7iU/x9rdqQpOJiQx0LFKSgRwvkelMpvlEGE8z7TDQH9PvFy89WjL2Pa6CI3UqJMDJi3m02p5/5
 EYV8IAX1D4YZT5WaucGlw3m0bCyQLp7zIXaa06Tf1eGSl1ZpogbrkQyMjWOAhojMUvrrOogBp6f
 U65Lb/qn+MSeMMKG5EIP/TFyZBuiFLjmKX6d0v3l5sYHhZCyhrE20X4tkr20bAVyRatMq7WBATm
 SgLFN3wjLT5Uh/TB2zU+EVG0XjIgEi4yQUAaAtqMtqo7HYdtLXNiDj68K52GBqaUPGoJXr4NdYP
 dlYvr/u3U399GL/ji/b1AYPq0G9XFXKWHWdi5COBHrDds6WO2pfBF/0xPmxzkKv+sbEJTBLaaHD
 3ZgvyMdNOvsNv9k/LstNftcXj5ZsjDNHEjkItQUvT2D6O79rm/1eELQtFSdDVFnT+U6ymRCBUgo
 EFyjuQn616zqLHDja637/JWwKBnPC82mZjqYdbWZCOhvxvCnFTbn4uSoY2e6RkVH472mexoyUGm
 bt91ceGngN6ul1rKle2mrojbDnrL3LKTgg4KsjKplu3pWwwye2dqhHjjBTBDXY68G7dtcKSgc7Y
 BJspgG3lK9IYAFA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Parse read_io=/write_io= (buffered/dontcache/direct) into new
e_read_io/e_write_io exportent fields, defaulting to unset, and pass
explicitly-set values to the kernel over the netlink svc_export
interface.

- Kernels without the I/O mode attributes (e.g. v7.2) reject the whole
  entry. Add nfsd_export_iomode_supported(), which checks the
  svc_export policy's highest attribute via nfsd_export_policy_query(),
  and have mountd drop the options with a warning on such kernels
  instead of leaving the export unmountable.
- The /proc channel cannot carry them either; warn there too.
- Resync nfsd_netlink.h and bump the configure probe to
  NFSD_A_SVC_EXPORT_WRITE_IO.

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
index 2c13292961bf..73230a2a637e 100644
--- a/configure.ac
+++ b/configure.ac
@@ -283,7 +283,7 @@ AC_CHECK_HEADERS(linux/nfsd_netlink.h)
 
 # ensure the system netlink headers have the latest features
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/nfsd_netlink.h>]],
-			                   [[int foo = NFSD_CMD_FILEHANDLE_GET;]])],
+			                   [[int foo = NFSD_A_SVC_EXPORT_WRITE_IO;]])],
 			   [AC_DEFINE([USE_SYSTEM_NFSD_NETLINK_H], 1,
 				      ["Use system's linux/nfsd_netlink.h"])])
 AC_COMPILE_IFELSE([AC_LANG_PROGRAM([[#include <linux/lockd_netlink.h>]],
diff --git a/support/export/cache.c b/support/export/cache.c
index 3c7ee9f90ac1..1ee94996948a 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1287,6 +1287,9 @@ static struct nl_sock *nfsd_nl_notify_sock;	/* multicast notifications */
 static struct nl_sock *nfsd_nl_cmd_sock;	/* GET_REQS / SET_REQS commands */
 static int nfsd_nl_family;
 
+/* Does the running kernel accept read_io/write_io in SET_REQS? */
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
+	if (ep->e_read_io == NFSD_IO_UNSET && ep->e_write_io == NFSD_IO_UNSET)
+		return 0;
+
+	/*
+	 * A kernel without per-export I/O modes would refuse the entry,
+	 * leaving the export unmountable.  Export it with the server's
+	 * global I/O modes instead.
+	 */
+	if (!nfsd_nl_iomode_ok) {
+		if (!warned) {
+			xlog(L_WARNING, "%s: kernel does not support read_io= "
+			     "or write_io=, ignoring", ep->e_path);
+			warned = true;
+		}
+		return 0;
+	}
+
+	if (ep->e_read_io != NFSD_IO_UNSET &&
+	    nla_put_u32(msg, NFSD_A_SVC_EXPORT_READ_IO,
+			ep->e_read_io) < 0)
+		return -1;
+
+	if (ep->e_write_io != NFSD_IO_UNSET &&
+	    nla_put_u32(msg, NFSD_A_SVC_EXPORT_WRITE_IO,
+			ep->e_write_io) < 0)
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
+	if (warned || (exp->e_read_io == NFSD_IO_UNSET &&
+		       exp->e_write_io == NFSD_IO_UNSET))
+		return;
+
+	xlog(L_WARNING, "%s: read_io= and write_io= need the netlink "
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
index a0170cb87f91..fce999a4f823 100644
--- a/support/export/export_policy.c
+++ b/support/export/export_policy.c
@@ -244,6 +244,28 @@ int nfsd_export_policy_query(struct nfsd_export_policy *UNUSED(pol))
 
 #endif /* HAVE_GENL_POLICY_DUMP */
 
+/**
+ * nfsd_export_iomode_supported - does the kernel take per-export I/O modes?
+ *
+ * A kernel without them refuses any svc_export entry that carries one.
+ *
+ * Returns 1 if it accepts read_io/write_io, 0 if not or if that cannot be
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
+	return pol.max_attr >= NFSD_A_SVC_EXPORT_WRITE_IO;
+}
+
 /**
  * nfsd_nl_load_export_features - learn the kernel's export flags over netlink
  *
diff --git a/support/export/v4root.c b/support/export/v4root.c
index 38286b91ede0..f7f1ca38c9a9 100644
--- a/support/export/v4root.c
+++ b/support/export/v4root.c
@@ -47,6 +47,8 @@ static nfs_export pseudo_root = {
 		.e_fsid = 0,
 		.e_mountpoint = NULL,
 		.e_ttl = 0,
+		.e_read_io = NFSD_IO_UNSET,
+		.e_write_io = NFSD_IO_UNSET,
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
index dcd2126d848b..f67efa23997f 100644
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
+	NFSD_A_SVC_EXPORT_READ_IO,
+	NFSD_A_SVC_EXPORT_WRITE_IO,
 
 	__NFSD_A_SVC_EXPORT_MAX,
 	NFSD_A_SVC_EXPORT_MAX = (__NFSD_A_SVC_EXPORT_MAX - 1)
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index c8601a156cba..7d7aadaed159 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -75,6 +75,16 @@ struct xprtsec_entry {
 	int			flags;
 };
 
+/*
+ * Per-export I/O modes for read_io=/write_io=. Values must match the
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
+	int		e_read_io;
+	int		e_write_io;
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
index 5ccc4ca0582f..ef2eb7b766ad 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -107,6 +107,8 @@ static void init_exportent (struct exportent *ee, int fromkernel)
 	ee->e_uuid = NULL;
 	ee->e_ttl = default_ttl;
 	ee->e_reexport = REEXP_NONE;
+	ee->e_read_io = NFSD_IO_UNSET;
+	ee->e_write_io = NFSD_IO_UNSET;
 }
 
 struct exportent *
@@ -313,6 +315,10 @@ putexportent(struct exportent *ep)
 	if (ep->e_flags & NFSEXP_SIGN_FH)
 		fprintf(fp, "sign_fh,");
 	fprintf(fp, "%spnfs,", (ep->e_flags & NFSEXP_PNFS)? "" : "no_");
+	if (ep->e_read_io != NFSD_IO_UNSET)
+		fprintf(fp, "read_io=%s,", iomode_name(ep->e_read_io));
+	if (ep->e_write_io != NFSD_IO_UNSET)
+		fprintf(fp, "write_io=%s,", iomode_name(ep->e_write_io));
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -586,6 +592,45 @@ static unsigned int parse_xprtsec(char *str, struct exportent *ep)
 	return out;
 }
 
+/*
+ * Parse the value of a read_io= or write_io= option into @mode.
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
+		} else if (strncmp(opt, "read_io=", 8) == 0) {
+			if (!parse_iomode(opt + 8, &ep->e_read_io))
+				goto bad_option;
+		} else if (strncmp(opt, "write_io=", 9) == 0) {
+			if (!parse_iomode(opt + 9, &ep->e_write_io))
+				goto bad_option;
 		} else if (strncmp(opt, "reexport=", 9) == 0) {
 			char *strategy = strchr(opt, '=');
 

-- 
2.56.0

