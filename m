Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752Ab2EONMi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 May 2012 09:12:38 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q4FDCcFk018573
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 15 May 2012 09:12:38 -0400
From: Simo Sorce <simo@redhat.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS auth
Date: Tue, 15 May 2012 09:12:29 -0400
Message-Id: <1337087550-9821-4-git-send-email-simo@redhat.com>
In-Reply-To: <1337087550-9821-1-git-send-email-simo@redhat.com>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch implements a sunrpc client to use the services of the gssproxy
userspace daemon.

In particular it allows to perform calls in user space using an RPC
call instead of custom hand-coded upcall/downcall messages.

Currently only accept_sec_context is implemented as that is all is needed for
the server case.

File server modules like NFS and CIFS can use full gssapi services this way,
once init_sec_context is also implemented.

For the NFS server case this code allow to lift the limit of max 2k krb5
tickets. This limit is prevents legitimate kerberos deployments from using krb5
authentication with the Linux NFS server as they have normally ticket that are
many kilobytes large.

It will also allow to lift the limitation on the size of the credential set
(uid,gid,gids) passed down from user space for users that have very many groups
associated. Currently the downcall mechanism used by rpc.svcgssd is limited
to around 2k secondary groups of the 65k allowed by kernel structures.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 net/sunrpc/auth_gss/Makefile         |    4 +-
 net/sunrpc/auth_gss/gss_rpc_upcall.c |  341 +++++++++++++
 net/sunrpc/auth_gss/gss_rpc_upcall.h |   43 ++
 net/sunrpc/auth_gss/gss_rpc_xdr.c    |  904 ++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_rpc_xdr.h    |  269 ++++++++++
 5 files changed, 1560 insertions(+), 1 deletions(-)
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_upcall.h
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.c
 create mode 100644 net/sunrpc/auth_gss/gss_rpc_xdr.h

diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
index 9e4cb59ef9f0207bc8edc4629dee18c545599de6..bf9f334529416f496ad32a3d0087964df93ff4ac 100644
--- a/net/sunrpc/auth_gss/Makefile
+++ b/net/sunrpc/auth_gss/Makefile
@@ -5,9 +5,11 @@
 obj-$(CONFIG_SUNRPC_GSS) += auth_rpcgss.o
 
 auth_rpcgss-y := auth_gss.o gss_generic_token.o \
-	gss_mech_switch.o svcauth_gss.o
+	gss_mech_switch.o svcauth_gss.o \
+	gss_rpc_upcall.o gss_rpc_xdr.o
 
 obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 
 rpcsec_gss_krb5-y := gss_krb5_mech.o gss_krb5_seal.o gss_krb5_unseal.o \
 	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
+
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.c b/net/sunrpc/auth_gss/gss_rpc_upcall.c
new file mode 100644
index 0000000000000000000000000000000000000000..75e88519bd1be87aab4a1b195a7d86aedb7ed03a
--- /dev/null
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.c
@@ -0,0 +1,341 @@
+/*
+ *  linux/net/sunrpc/gss_rpc_upcall.c
+ *
+ *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/types.h>
+#include <linux/un.h>
+
+#include <linux/sunrpc/svcauth.h>
+#include "gss_rpc_upcall.h"
+
+#define GSSPROXY_SOCK_PATHNAME	"/var/run/gssproxy.sock"
+
+#define GSSPROXY_PROGRAM	(400112u)
+#define GSSPROXY_VERS_1		(1u)
+
+DEFINE_MUTEX(gssp_clnt_mutex);
+struct rpc_clnt *gssp_clnt;
+
+/*
+ * Encoding/Decoding functions
+ */
+
+enum {
+	GSSX_NULL = 0,	/* Unused */
+        GSSX_INDICATE_MECHS = 1,
+        GSSX_GET_CALL_CONTEXT = 2,
+        GSSX_IMPORT_AND_CANON_NAME = 3,
+        GSSX_EXPORT_CRED = 4,
+        GSSX_IMPORT_CRED = 5,
+        GSSX_ACQUIRE_CRED = 6,
+        GSSX_STORE_CRED = 7,
+        GSSX_INIT_SEC_CONTEXT = 8,
+        GSSX_ACCEPT_SEC_CONTEXT = 9,
+        GSSX_RELEASE_HANDLE = 10,
+        GSSX_GET_MIC = 11,
+        GSSX_VERIFY = 12,
+        GSSX_WRAP = 13,
+        GSSX_UNWRAP = 14,
+        GSSX_WRAP_SIZE_LIMIT = 15,
+};
+
+#define PROC(proc, name)				\
+[GSSX_##proc] = {					\
+	.p_proc   = GSSX_##proc,			\
+	.p_encode = (kxdreproc_t)gssx_enc_##name,	\
+	.p_decode = (kxdrdproc_t)gssx_dec_##name,	\
+	.p_arglen = GSSX_ARG_##name##_sz,		\
+	.p_replen = GSSX_RES_##name##_sz, 		\
+	.p_statidx = GSSX_##proc,			\
+	.p_name   = #proc,				\
+}
+
+struct rpc_procinfo gssp_procedures[] = {
+	PROC(INDICATE_MECHS, indicate_mechs),
+        PROC(GET_CALL_CONTEXT, get_call_context),
+        PROC(IMPORT_AND_CANON_NAME, import_and_canon_name),
+        PROC(EXPORT_CRED, export_cred),
+        PROC(IMPORT_CRED, import_cred),
+        PROC(ACQUIRE_CRED, acquire_cred),
+        PROC(STORE_CRED, store_cred),
+        PROC(INIT_SEC_CONTEXT, init_sec_context),
+        PROC(ACCEPT_SEC_CONTEXT, accept_sec_context),
+        PROC(RELEASE_HANDLE, release_handle),
+        PROC(GET_MIC, get_mic),
+        PROC(VERIFY, verify),
+        PROC(WRAP, wrap),
+        PROC(UNWRAP, unwrap),
+        PROC(WRAP_SIZE_LIMIT, wrap_size_limit),
+};
+
+
+
+/*
+ * Common transport functions
+ */
+
+static const struct rpc_program gssp_program;
+
+static int gssp_rpc_create(struct rpc_clnt **_clnt)
+{
+	static const struct sockaddr_un gssp_localaddr = {
+		.sun_family		= AF_LOCAL,
+		.sun_path		= GSSPROXY_SOCK_PATHNAME,
+	};
+	struct rpc_create_args args = {
+		.net		= &init_net,
+		.protocol	= XPRT_TRANSPORT_LOCAL,
+		.address	= (struct sockaddr *)&gssp_localaddr,
+		.addrsize	= sizeof(gssp_localaddr),
+		.servername	= "localhost",
+		.program	= &gssp_program,
+		.version	= GSSPROXY_VERS_1,
+		.authflavor	= RPC_AUTH_NULL,
+		.flags		= RPC_CLNT_CREATE_NOPING,
+	};
+	struct rpc_clnt *clnt;
+	int result = 0;
+
+	clnt = rpc_create(&args);
+	if (IS_ERR(clnt)) {
+		dprintk("RPC:       failed to create AF_LOCAL gssproxy "
+				"client (errno %ld).\n", PTR_ERR(clnt));
+		result = -PTR_ERR(clnt);
+		*_clnt = NULL;
+		goto out;
+	}
+
+	dprintk("RPC:       created new gssp local client (gssp_local_clnt: "
+			"%p)\n", clnt);
+	*_clnt = clnt;
+
+out:
+	return result;
+}
+
+static struct rpc_clnt *get_clnt(bool global_clnt)
+{
+	struct rpc_clnt *clnt;
+	int err;
+
+	mutex_lock(&gssp_clnt_mutex);
+
+	if (global_clnt && gssp_clnt)
+		return gssp_clnt;
+
+	err = gssp_rpc_create(&clnt);
+	if (err) {
+		mutex_unlock(&gssp_clnt_mutex);
+		return NULL;
+	}
+	if (global_clnt)
+		gssp_clnt = clnt;
+
+	mutex_unlock(&gssp_clnt_mutex);
+	return clnt;
+}
+
+static void kill_clnt(struct rpc_clnt *clnt)
+{
+	BUG_ON(clnt == NULL);
+
+	mutex_lock(&gssp_clnt_mutex);
+
+	rpc_shutdown_client(clnt);
+	if (clnt == gssp_clnt)
+		gssp_clnt = NULL;
+
+	mutex_unlock(&gssp_clnt_mutex);
+}
+
+static int gssp_call(struct rpc_message *msg)
+{
+	struct rpc_clnt *clnt;
+	int status;
+
+	/* for now always create new one */
+	clnt = get_clnt(false);
+
+	status = rpc_call_sync(clnt, msg, 0);
+	if (status < 0) {
+		dprintk("gssp: rpc_call returned error %d\n", -status);
+		switch (status) {
+		case -EPROTONOSUPPORT:
+			status = -EINVAL;
+			break;
+		case -ECONNREFUSED:
+		case -ETIMEDOUT:
+		case -ENOTCONN:
+			status = -EAGAIN;
+			break;
+		case -ERESTARTSYS:
+			if (signalled ())
+				status = -EINTR;
+			break;
+		default:
+			break;
+		}
+	}
+
+	/* always kill connection for now */
+	kill_clnt(clnt);
+
+	return status;
+}
+
+
+/*
+ * Public functions
+ */
+
+/* numbers somewhat arbitrary but large enough for current needs */
+#define GSSX_MAX_OUT_HANDLE	128
+#define GSSX_MAX_MECH_OID	16
+#define GSSX_MAX_SRC_PRINC	256
+#define GSSX_KMEMBUF (GSSX_max_output_handle_sz + \
+			GSSX_max_oid_sz + \
+			GSSX_max_princ_sz + \
+			sizeof(struct svc_cred))
+
+int gssp_accept_sec_context_upcall(struct gssp_upcall_data *data)
+{
+	struct gssx_arg_accept_sec_context arg;
+	struct gssx_res_accept_sec_context res;
+	struct gssx_ctx ctxh;
+	struct gssx_ctx rctxh;
+	struct gssx_cred delegcred;
+	struct rpc_message msg = {
+		.rpc_proc = &gssp_procedures[GSSX_ACCEPT_SEC_CONTEXT],
+		.rpc_argp = &arg,
+		.rpc_resp = &res,
+		.rpc_cred = NULL, /* FIXME ? */
+	};
+	int ret;
+
+	/* fill in arg */
+	memset(&arg, 0, sizeof(arg));
+	if (data->in_handle.len != 0) {
+		memset(&ctxh, 0, sizeof(ctxh));
+		arg.context_handle = &ctxh;
+		ctxh.state = data->in_handle;
+	}
+	arg.input_token = data->in_token;
+
+	/* use nfs/ for targ_name ? */
+
+	/* prepare res */
+	data->kmembuf = kmalloc(GSSX_KMEMBUF, GFP_KERNEL);
+	if (!data->kmembuf) {
+		return -ENOMEM;
+	}
+
+	memset(&res, 0, sizeof(res));
+	memset(&rctxh, 0, sizeof(rctxh));
+	rctxh.exported_context_token.len = GSSX_max_output_handle_sz;
+	rctxh.exported_context_token.data = data->kmembuf;
+	rctxh.mech.len = GSSX_max_oid_sz;
+	rctxh.mech.data = data->kmembuf + GSSX_max_output_handle_sz;
+	rctxh.src_name.display_name.len = GSSX_max_princ_sz;
+	rctxh.src_name.display_name.data = data->kmembuf +
+						GSSX_max_output_handle_sz +
+						GSSX_max_oid_sz;
+	res.context_handle = &rctxh;
+
+	data->creds = data->kmembuf +
+				GSSX_max_output_handle_sz +
+				GSSX_max_oid_sz +
+				GSSX_max_princ_sz;
+	memset(data->creds, 0, sizeof(struct svc_cred));
+
+	res.output_token = &data->out_token;
+	/* tell decoder to allocate the out_token if necessary */
+	res.output_token->len = GSSX_max_output_token_sz;
+
+	/* we are never interested in delegate credentials */
+	memset(&delegcred, 0, sizeof(delegcred));
+	res.delegated_cred_handle = &delegcred;
+
+	/* make upcall */
+	ret = gssp_call(&msg);
+
+	/* we need to fetch all data even in case of error so
+	 * that we can free special strctures is they have been allocated */
+	data->major_status = res.status.major_status;
+	data->minor_status = res.status.minor_status;
+	if (res.context_handle) {
+		data->out_handle = rctxh.exported_context_token;
+		data->mech_oid = rctxh.mech;
+		data->client_name = rctxh.src_name.display_name;
+	}
+
+	if (res.options.count == 1) {
+		gssx_buffer *value = &res.options.data[0].value;
+		/* Currently we only decode CREDS_VALUE, if we add
+		 * anything else we'll have to loop and match on the
+		 * option name */
+		if (value->len)
+			/* copy struct svc_cred and steal groups */
+			*data->creds = *(struct svc_cred *)value->data;
+		else
+			/* not even nobody apparently */
+			data->creds = NULL;
+	} else
+		data->creds = NULL;
+
+	if (res.options.count != 0) {
+		kfree(res.options.data);
+	}
+
+	return ret;
+}
+
+void gssp_free_upcall_data(struct gssp_upcall_data *data)
+{
+	kfree(data->in_handle.data);
+	kfree(data->out_token.data);
+	if (data->creds && data->creds->cr_group_info != NULL)
+		groups_free(data->creds->cr_group_info);
+	kfree(data->kmembuf);
+}
+
+
+/*
+ * Initialization stuff
+ */
+
+static const struct rpc_version gssp_version1 = {
+	.number		= GSSPROXY_VERS_1,
+	.nrprocs	= ARRAY_SIZE(gssp_procedures),
+	.procs		= gssp_procedures,
+};
+
+static const struct rpc_version *gssp_version[] = {
+	NULL,
+	&gssp_version1,
+};
+
+static struct rpc_stat gssp_stats;
+
+static const struct rpc_program gssp_program = {
+	.name		= "gssproxy",
+	.number		= GSSPROXY_PROGRAM,
+	.nrvers		= ARRAY_SIZE(gssp_version),
+	.version	= gssp_version,
+	.stats		= &gssp_stats,
+};
diff --git a/net/sunrpc/auth_gss/gss_rpc_upcall.h b/net/sunrpc/auth_gss/gss_rpc_upcall.h
new file mode 100644
index 0000000000000000000000000000000000000000..b09217740493e83979f8dc690b812d396db6e54c
--- /dev/null
+++ b/net/sunrpc/auth_gss/gss_rpc_upcall.h
@@ -0,0 +1,43 @@
+/*
+ *  linux/net/sunrpc/gss_rpc_upcall.h
+ *
+ *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _GSS_RPC_UPCALL_H
+#define _GSS_RPC_UPCALL_H
+
+#include <linux/sunrpc/auth_gss.h>
+#include "gss_rpc_xdr.h"
+
+struct gssp_upcall_data {
+	void *kmembuf;
+	struct xdr_netobj in_handle;
+	struct gssp_in_token in_token;
+	struct xdr_netobj out_handle;
+	struct xdr_netobj out_token;
+	struct xdr_netobj mech_oid;
+	struct xdr_netobj client_name;
+	struct svc_cred *creds;
+	int major_status;
+	int minor_status;
+};
+
+int gssp_accept_sec_context_upcall(struct gssp_upcall_data *data);
+void gssp_free_upcall_data(struct gssp_upcall_data *data);
+
+#endif /* _GSS_RPC_UPCALL_H */
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.c b/net/sunrpc/auth_gss/gss_rpc_xdr.c
new file mode 100644
index 0000000000000000000000000000000000000000..25600d5a2113cfb0dce64ab89a1b166ee1a089ef
--- /dev/null
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.c
@@ -0,0 +1,904 @@
+/*
+ * GSS Proxy upcall module
+ *
+ *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#include <linux/sunrpc/svcauth.h>
+#include "gss_rpc_xdr.h"
+
+static bool gssx_check_pointer(struct xdr_stream *xdr)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	return *p?true:false;
+}
+
+static int gssx_enc_bool(struct xdr_stream *xdr, int v)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	*p = v ? xdr_one : xdr_zero;
+	return 0;
+}
+
+static int gssx_dec_bool(struct xdr_stream *xdr, u32 *v)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	*v = be32_to_cpu(*p);
+	return 0;
+}
+
+static int gssx_enc_buffer(struct xdr_stream *xdr,
+			   gssx_buffer *buf)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, sizeof(u32) + buf->len);
+	if (!p)
+		return -ENOSPC;
+	xdr_encode_opaque(p, buf->data, buf->len);
+	return 0;
+}
+
+static int gssx_enc_in_token(struct xdr_stream *xdr,
+			     struct gssp_in_token *in)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return -ENOSPC;
+	*p = cpu_to_be32(in->page_len);
+
+	/* all we need to do is to write pages */
+	xdr_write_pages(xdr, in->pages, in->page_base, in->page_len);
+
+	return 0;
+}
+
+
+static int gssx_dec_buffer(struct xdr_stream *xdr,
+			   gssx_buffer *buf)
+{
+	u32 length;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+
+	length = be32_to_cpup(p);
+	p = xdr_inline_decode(xdr, length);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+
+	if (buf->len == 0) {
+		/* we intentionally are not interested in this buffer */
+		return 0;
+	}
+	if (length > buf->len)
+		return -ENOSPC;
+
+	if (!buf->data) {
+		buf->data = kmemdup(p, length, GFP_KERNEL);
+		if (!buf->data)
+			return -ENOMEM;
+	} else {
+		memcpy(buf->data, p, length);
+	}
+	buf->len = length;
+	return 0;
+}
+
+static int gssx_enc_option(struct xdr_stream *xdr,
+			   struct gssx_option *opt)
+{
+	int err;
+
+	err = gssx_enc_buffer(xdr, &opt->option);
+	if (err)
+		return err;
+	err = gssx_enc_buffer(xdr, &opt->value);
+	return err;
+}
+
+static int gssx_dec_option(struct xdr_stream *xdr,
+			   struct gssx_option *opt)
+{
+	int err;
+
+	err = gssx_dec_buffer(xdr, &opt->option);
+	if (err)
+		return err;
+	err = gssx_dec_buffer(xdr, &opt->value);
+	return err;
+}
+
+static int dummy_enc_opt_array(struct xdr_stream *xdr,
+				struct gssx_option_array *oa)
+{
+	__be32 *p;
+
+	if (oa->count != 0)
+		return -EINVAL;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return -ENOSPC;
+	*p = 0;
+
+	return 0;
+}
+
+static int dummy_dec_opt_array(struct xdr_stream *xdr,
+				struct gssx_option_array *oa)
+{
+	struct gssx_option dummy;
+	u32 count, i;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	count = be32_to_cpup(p++);
+	memset(&dummy, 0, sizeof(dummy));
+	for (i = 0; i < count; i++) {
+		gssx_dec_option(xdr, &dummy);
+	}
+
+	oa->count = 0;
+	oa->data = NULL;
+	return 0;
+}
+
+static int get_s32(void **p, void *max, s32 *res)
+{
+	void *base = *p;
+	void *next = (void *)((char *)base + sizeof(s32));
+	if (unlikely(next > max || next < base))
+		return -EINVAL;
+	memcpy(res, base, sizeof(s32));
+	*p = next;
+	return 0;
+}
+
+static int gssx_dec_linux_creds(struct xdr_stream *xdr,
+				struct svc_cred *creds)
+{
+	u32 length;
+	__be32 *p;
+	void *q, *end;
+	s32 tmp;
+	int N, i, err;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+
+	length = be32_to_cpup(p);
+
+	/* FIXME: we do not want to use the scratch buffer for this one
+	 * may need to use functions that allows us to access an io vector
+	 * directly */
+	p = xdr_inline_decode(xdr, length);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+
+	q = p;
+	end = q + length;
+
+	/* uid */
+	err = get_s32(&q, end, &tmp);
+	if (err)
+		return err;
+	creds->cr_uid = tmp;
+
+	/* gid */
+	err = get_s32(&q, end, &tmp);
+	if (err)
+		return err;
+	creds->cr_gid = tmp;
+
+	/* number of additional gid's */
+	err = get_s32(&q, end, &tmp);
+	if (err)
+		return err;
+	N = tmp;
+	creds->cr_group_info = groups_alloc(N);
+	if (creds->cr_group_info == NULL)
+		return -ENOMEM;
+
+	/* gid's */
+	for (i = 0; i < N; i++) {
+		err = get_s32(&q, end, &tmp);
+		if (err) {
+			groups_free(creds->cr_group_info);
+			return err;
+		}
+		GROUP_AT(creds->cr_group_info, i) = tmp;
+	}
+
+	return 0;
+}
+
+static int gssx_dec_option_array(struct xdr_stream *xdr,
+				 struct gssx_option_array *oa)
+{
+	struct svc_cred *creds;
+	u32 count, i;
+	__be32 *p;
+	int err;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	count = be32_to_cpup(p++);
+	if (count != 0) {
+		/* we recognize only 1 currently: CREDS_VALUE */
+		oa->count = 1;
+
+		oa->data = kmalloc(sizeof(struct gssx_option) +
+					sizeof(struct svc_cred), GFP_KERNEL);
+		if (!oa->data)
+			return -ENOMEM;
+
+		creds = (void *)oa->data + sizeof(struct gssx_option);
+
+		oa->data[0].option.data = CREDS_VALUE;
+		oa->data[0].option.len = sizeof(CREDS_VALUE);
+		oa->data[0].value.data = (void *)creds;
+		oa->data[0].value.len = 0;
+	}
+	for (i = 0; i < count; i++) {
+		gssx_buffer dummy = { 0, NULL };
+		u32 length;
+
+		/* option buffer */
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(p == NULL))
+			return -ENOSPC;
+
+		length = be32_to_cpup(p);
+		p = xdr_inline_decode(xdr, length);
+		if (unlikely(p == NULL))
+			return -ENOSPC;
+
+		if (length == sizeof(CREDS_VALUE) &&
+		    memcmp(p, CREDS_VALUE, sizeof(CREDS_VALUE)) == 0) {
+			/* We have creds here. parse them */
+			err = gssx_dec_linux_creds(xdr, creds);
+			if (err)
+				return err;
+			oa->data[0].value.len = 1; /* presence */
+		} else {
+			/* consume uninteresting buffer */
+			err = gssx_dec_buffer(xdr, &dummy);
+			if (err)
+				return err;
+		}
+	}
+	return 0;
+}
+
+static int gssx_dec_status(struct xdr_stream *xdr,
+			   struct gssx_status *status)
+{
+	__be32 *p;
+	int err;
+
+	/* status->major_status */
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	p = xdr_decode_hyper(p, &status->major_status);
+
+	/* status->mech */
+	err = gssx_dec_buffer(xdr, &status->mech);
+	if (err)
+		return err;
+
+	/* status->minor_status */
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	p = xdr_decode_hyper(p, &status->minor_status);
+
+	/* status->major_status_string */
+	err = gssx_dec_buffer(xdr, &status->major_status_string);
+	if (err)
+		return err;
+
+	/* status->minor_status_string */
+	err = gssx_dec_buffer(xdr, &status->minor_status_string);
+	if (err)
+		return err;
+
+	/* status->server_ctx */
+	err = gssx_dec_buffer(xdr, &status->server_ctx);
+	if (err)
+		return err;
+
+	/* we assume we have no options for now, so simply consume them */
+	/* status->options */
+	err = dummy_dec_opt_array(xdr, &status->options);
+
+	return err;
+}
+
+static int gssx_enc_call_ctx(struct xdr_stream *xdr,
+			     struct gssx_call_ctx *ctx)
+{
+	struct gssx_option opt;
+	__be32 *p;
+	int err;
+
+	/* ctx->locale */
+	err = gssx_enc_buffer(xdr, &ctx->locale);
+	if (err)
+		return err;
+
+	/* ctx->server_ctx */
+	err = gssx_enc_buffer(xdr, &ctx->server_ctx);
+	if (err)
+		return err;
+
+	/* we always want to ask for lucid contexts */
+	/* ctx->options */
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(2);
+
+	/* we want a lucid_v1 context */
+	opt.option.data = LUCID_OPTION;
+	opt.option.len = sizeof(LUCID_OPTION);
+	opt.value.data = LUCID_VALUE;
+	opt.value.len = sizeof(LUCID_VALUE);
+	err = gssx_enc_option(xdr, &opt);
+
+	/* ..and user creds */
+	opt.option.data = CREDS_OPTION;
+	opt.option.len = sizeof(CREDS_OPTION);
+	opt.value.data = CREDS_VALUE;
+	opt.value.len = sizeof(CREDS_VALUE);
+	err = gssx_enc_option(xdr, &opt);
+
+	return err;
+}
+
+static int gssx_dec_name_attr(struct xdr_stream *xdr,
+			     struct gssx_name_attr *attr)
+{
+	int err;
+
+	/* attr->attr */
+	err = gssx_dec_buffer(xdr, &attr->attr);
+	if (err)
+		return err;
+
+	/* attr->value */
+	err = gssx_dec_buffer(xdr, &attr->value);
+	if (err)
+		return err;
+
+	/* attr->extensions */
+	err = dummy_dec_opt_array(xdr, &attr->extensions);
+
+	return err;
+}
+
+static int dummy_enc_nameattr_array(struct xdr_stream *xdr,
+				    struct gssx_name_attr_array *naa)
+{
+	__be32 *p;
+
+	if (naa->count != 0)
+		return -EINVAL;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return -ENOSPC;
+	*p = 0;
+
+	return 0;
+}
+
+static int dummy_dec_nameattr_array(struct xdr_stream *xdr,
+				    struct gssx_name_attr_array *naa)
+{
+	struct gssx_name_attr dummy;
+	u32 count, i;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	count = be32_to_cpup(p++);
+	for (i = 0; i < count; i++) {
+		gssx_dec_name_attr(xdr, &dummy);
+	}
+
+	naa->count = 0;
+	naa->data = NULL;
+	return 0;
+}
+
+static int gssx_enc_name(struct xdr_stream *xdr,
+			 struct gssx_name *name)
+{
+	int err;
+
+	/* name->display_name */
+	err = gssx_enc_buffer(xdr, &name->display_name);
+	if (err)
+		return err;
+
+	/* name->name_type */
+	err = gssx_enc_buffer(xdr, &name->name_type);
+	if (err)
+		return err;
+
+	/* name->exported_name */
+	err = gssx_enc_buffer(xdr, &name->exported_name);
+	if (err)
+		return err;
+
+	/* name->exported_composite_name */
+	err = gssx_enc_buffer(xdr, &name->exported_composite_name);
+	if (err)
+		return err;
+
+	/* leave name_attributes empty for now, will add once we have any
+	 * to pass up at all */
+	/* name->name_attributes */
+	err = dummy_enc_nameattr_array(xdr, &name->name_attributes);
+	if (err)
+		return err;
+
+	/* leave options empty for now, will add once we have any options
+	 * to pass up at all */
+	/* name->extensions */
+	err = dummy_enc_opt_array(xdr, &name->extensions);
+
+	return err;
+}
+
+static int gssx_dec_name(struct xdr_stream *xdr,
+			 struct gssx_name *name)
+{
+	int err;
+
+	/* name->display_name */
+	err = gssx_dec_buffer(xdr, &name->display_name);
+	if (err)
+		return err;
+
+	/* name->name_type */
+	err = gssx_dec_buffer(xdr, &name->name_type);
+	if (err)
+		return err;
+
+	/* name->exported_name */
+	err = gssx_dec_buffer(xdr, &name->exported_name);
+	if (err)
+		return err;
+
+	/* name->exported_composite_name */
+	err = gssx_dec_buffer(xdr, &name->exported_composite_name);
+	if (err)
+		return err;
+
+	/* we assume we have no attributes for now, so simply consume them */
+	/* name->name_attributes */
+	err = dummy_dec_nameattr_array(xdr, &name->name_attributes);
+	if (err)
+		return err;
+
+	/* we assume we have no options for now, so simply consume them */
+	/* name->extensions */
+	err = dummy_dec_opt_array(xdr, &name->extensions);
+
+	return err;
+}
+
+static int gssx_dec_cred_element(struct xdr_stream *xdr,
+				 struct gssx_cred_element *el)
+{
+	__be32 *p;
+	int err;
+
+	/* el->MN */
+	err = gssx_dec_name(xdr, &el->MN);
+	if (err)
+		return err;
+
+	/* el->mech */
+	err = gssx_dec_buffer(xdr, &el->mech);
+	if (err)
+		return err;
+
+	/* el->cred_usage */
+	p = xdr_inline_decode(xdr, 4+8+8);
+	if (!p)
+		return -ENOSPC;
+	el->cred_usage = be32_to_cpup(p++);
+
+	/* el->initiator_time_rec */
+	p = xdr_decode_hyper(p, &el->initiator_time_rec);
+
+	/* el->acceptor_time_rec */
+	p = xdr_decode_hyper(p, &el->initiator_time_rec);
+
+	/* we assume we have no options for now, so simply consume them */
+	/* el->options */
+	err = dummy_dec_opt_array(xdr, &el->options);
+
+	return err;
+}
+
+static int dummy_enc_credel_array(struct xdr_stream *xdr,
+				  struct gssx_cred_element_array *cea)
+{
+	__be32 *p;
+
+	if (cea->count != 0)
+		return -EINVAL;
+
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return -ENOSPC;
+	*p = 0;
+
+	return 0;
+}
+
+static int dummy_dec_credel_array(struct xdr_stream *xdr,
+				  struct gssx_cred_element_array *cea)
+{
+	struct gssx_cred_element dummy;
+	u32 count, i;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	count = be32_to_cpup(p++);
+	for (i = 0; i < count; i++) {
+		gssx_dec_cred_element(xdr, &dummy);
+	}
+
+	cea->count = 0;
+	cea->data = NULL;
+	return 0;
+}
+
+static int gssx_enc_cred(struct xdr_stream *xdr,
+			 struct gssx_cred *cred)
+{
+	int err;
+
+	/* cred->desired_name */
+	err = gssx_enc_name(xdr, &cred->desired_name);
+	if (err)
+		return err;
+
+	/* cred->elements */
+	err = dummy_enc_credel_array(xdr, &cred->elements);
+
+	/* cred->cred_handle_reference */
+	err = gssx_enc_buffer(xdr, &cred->cred_handle_reference);
+	if (err)
+		return err;
+
+	/* cred->needs_release */
+	err = gssx_enc_bool(xdr, cred->needs_release);
+
+	return err;
+}
+
+static int gssx_dec_cred(struct xdr_stream *xdr,
+			 struct gssx_cred *cred)
+{
+	int err;
+
+	/* cred->desired_name */
+	err = gssx_dec_name(xdr, &cred->desired_name);
+	if (err)
+		return err;
+
+	/* cred->elements */
+	err = dummy_dec_credel_array(xdr, &cred->elements);
+
+	/* cred->cred_handle_reference */
+	err = gssx_dec_buffer(xdr, &cred->cred_handle_reference);
+	if (err)
+		return err;
+
+	/* cred->needs_release */
+	err = gssx_dec_bool(xdr, &cred->needs_release);
+
+	return err;
+}
+
+static int gssx_enc_ctx(struct xdr_stream *xdr,
+			struct gssx_ctx *ctx)
+{
+	__be32 *p;
+	int err;
+
+	/* ctx->exported_context_token */
+	err = gssx_enc_buffer(xdr, &ctx->exported_context_token);
+	if (err)
+		return err;
+
+	/* ctx->state */
+	err = gssx_enc_buffer(xdr, &ctx->state);
+	if (err)
+		return err;
+
+	/* ctx->need_release */
+	err = gssx_enc_bool(xdr, ctx->need_release);
+	if (err)
+		return err;
+
+	/* ctx->mech */
+	err = gssx_enc_buffer(xdr, &ctx->mech);
+	if (err)
+		return err;
+
+	/* ctx->src_name */
+	err = gssx_enc_name(xdr, &ctx->src_name);
+	if (err)
+		return err;
+
+	/* ctx->targ_name */
+	err = gssx_enc_name(xdr, &ctx->targ_name);
+	if (err)
+		return err;
+
+	/* ctx->lifetime */
+	p = xdr_reserve_space(xdr, 8+8);
+	if (!p)
+		return -ENOSPC;
+	p = xdr_encode_hyper(p, ctx->lifetime);
+
+	/* ctx->ctx_flags */
+	p = xdr_encode_hyper(p, ctx->ctx_flags);
+
+	/* ctx->locally_initiated */
+	err = gssx_enc_bool(xdr, ctx->locally_initiated);
+	if (err)
+		return err;
+
+	/* ctx->open */
+	err = gssx_enc_bool(xdr, ctx->open);
+	if (err)
+		return err;
+
+	/* leave options empty for now, will add once we have any options
+	 * to pass up at all */
+	/* ctx->options */
+	err = dummy_enc_opt_array(xdr, &ctx->options);
+
+	return err;
+}
+
+static int gssx_dec_ctx(struct xdr_stream *xdr,
+			struct gssx_ctx *ctx)
+{
+	__be32 *p;
+	int err;
+
+	/* ctx->exported_context_token */
+	err = gssx_dec_buffer(xdr, &ctx->exported_context_token);
+	if (err)
+		return err;
+
+	/* ctx->state */
+	err = gssx_dec_buffer(xdr, &ctx->state);
+	if (err)
+		return err;
+
+	/* ctx->need_release */
+	err = gssx_dec_bool(xdr, &ctx->need_release);
+	if (err)
+		return err;
+
+	/* ctx->mech */
+	err = gssx_dec_buffer(xdr, &ctx->mech);
+	if (err)
+		return err;
+
+	/* ctx->src_name */
+	err = gssx_dec_name(xdr, &ctx->src_name);
+	if (err)
+		return err;
+
+	/* ctx->targ_name */
+	err = gssx_dec_name(xdr, &ctx->targ_name);
+	if (err)
+		return err;
+
+	/* ctx->lifetime */
+	p = xdr_inline_decode(xdr, 8+8);
+	if (unlikely(p == NULL))
+		return -ENOSPC;
+	p = xdr_decode_hyper(p, &ctx->lifetime);
+
+	/* ctx->ctx_flags */
+	p = xdr_decode_hyper(p, &ctx->ctx_flags);
+
+	/* ctx->locally_initiated */
+	err = gssx_dec_bool(xdr, &ctx->locally_initiated);
+	if (err)
+		return err;
+
+	/* ctx->open */
+	err = gssx_dec_bool(xdr, &ctx->open);
+	if (err)
+		return err;
+
+	/* we assume we have no options for now, so simply consume them */
+	/* ctx->options */
+	err = dummy_dec_opt_array(xdr, &ctx->options);
+
+	return err;
+}
+
+static int gssx_enc_cb(struct xdr_stream *xdr, struct gssx_cb *cb)
+{
+	__be32 *p;
+	int err;
+
+	/* cb->initiator_addrtype */
+	p = xdr_reserve_space(xdr, 8);
+	if (!p)
+		return -ENOSPC;
+	p = xdr_encode_hyper(p, cb->initiator_addrtype);
+
+	/* cb->initiator_address */
+	err = gssx_enc_buffer(xdr, &cb->initiator_address);
+	if (err)
+		return err;
+
+	/* cb->acceptor_addrtype */
+	p = xdr_reserve_space(xdr, 8);
+	if (!p)
+		return -ENOSPC;
+	p = xdr_encode_hyper(p, cb->acceptor_addrtype);
+
+	/* cb->acceptor_address */
+	err = gssx_enc_buffer(xdr, &cb->acceptor_address);
+	if (err)
+		return err;
+
+	/* cb->application_data */
+	err = gssx_enc_buffer(xdr, &cb->application_data);
+
+	return err;
+}
+
+void gssx_enc_accept_sec_context(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 struct gssx_arg_accept_sec_context *arg)
+{
+	int err;
+
+	err = gssx_enc_call_ctx(xdr, &arg->call_ctx);
+	if (err)
+		goto done;
+
+	/* arg->context_handle */
+	if (arg->context_handle) {
+		err = gssx_enc_ctx(xdr, arg->context_handle);
+		if (err)
+			goto done;
+	} else {
+		err = gssx_enc_bool(xdr, 0);
+	}
+
+	/* arg->cred_handle */
+	if (arg->cred_handle) {
+		err = gssx_enc_cred(xdr, arg->cred_handle);
+		if (err)
+			goto done;
+	} else {
+		err = gssx_enc_bool(xdr, 0);
+	}
+
+	/* arg->input_token */
+	err = gssx_enc_in_token(xdr, &arg->input_token);
+	if (err)
+		goto done;
+
+	/* arg->input_cb */
+	if (arg->input_cb) {
+		err = gssx_enc_cb(xdr, arg->input_cb);
+		if (err)
+			goto done;
+	} else {
+		err = gssx_enc_bool(xdr, 0);
+	}
+
+	err = gssx_enc_bool(xdr, arg->ret_deleg_cred);
+	if (err)
+		goto done;
+
+	/* leave options empty for now, will add once we have any options
+	 * to pass up at all */
+	/* arg->options */
+	err = dummy_enc_opt_array(xdr, &arg->options);
+
+done:
+	if (err)
+		dprintk("RPC:       gssx_enc_accept_sec_context: %d\n", err);
+}
+
+int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct gssx_res_accept_sec_context *res)
+{
+	int err;
+
+	/* res->status */
+	err = gssx_dec_status(xdr, &res->status);
+	if (err)
+		return err;
+
+	/* res->context_handle */
+	if (gssx_check_pointer(xdr)) {
+		err = gssx_dec_ctx(xdr, res->context_handle);
+		if (err)
+			return err;
+	} else {
+		res->context_handle = NULL;
+	}
+
+	/* res->output_token */
+	if (gssx_check_pointer(xdr)) {
+		err = gssx_dec_buffer(xdr, res->output_token);
+		if (err)
+			return err;
+	} else {
+		res->output_token = NULL;
+	}
+
+	/* res->delegated_cred_handle */
+	if (gssx_check_pointer(xdr)) {
+		err = gssx_dec_cred(xdr, res->delegated_cred_handle);
+		if (err)
+			return err;
+	} else {
+		res->delegated_cred_handle = NULL;
+	}
+
+	/* we assume we have no options for now, so simply consume them */
+	/* res->options */
+	err = gssx_dec_option_array(xdr, &res->options);
+
+	return err;
+}
+
diff --git a/net/sunrpc/auth_gss/gss_rpc_xdr.h b/net/sunrpc/auth_gss/gss_rpc_xdr.h
new file mode 100644
index 0000000000000000000000000000000000000000..9256a5836474fef952ab12d3b27e03bb4d0f20ea
--- /dev/null
+++ b/net/sunrpc/auth_gss/gss_rpc_xdr.h
@@ -0,0 +1,269 @@
+/*
+ * GSS Proxy upcall module
+ *
+ *  Copyright (C) 2012 Simo Sorce <simo@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ */
+
+#ifndef _LINUX_GSS_RPC_XDR_H
+#define _LINUX_GSS_RPC_XDR_H
+
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/xprtsock.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY	RPCDBG_AUTH
+#endif
+
+#define LUCID_OPTION "exported_context_type"
+#define LUCID_VALUE  "linux_lucid_v1"
+#define CREDS_OPTION "exported_creds_type"
+#define CREDS_VALUE  "linux_creds_v1"
+
+typedef struct xdr_netobj gssx_buffer;
+typedef struct xdr_netobj utf8string;
+typedef struct xdr_netobj gssx_OID;
+
+enum gssx_cred_usage {
+	GSSX_C_INITIATE = 1,
+	GSSX_C_ACCEPT = 2,
+	GSSX_C_BOTH = 3,
+};
+
+struct gssx_option {
+	gssx_buffer option;
+	gssx_buffer value;
+};
+
+struct gssx_option_array {
+	u32 count;
+	struct gssx_option *data;
+};
+
+struct gssx_status {
+	u64 major_status;
+	gssx_OID mech;
+	u64 minor_status;
+	utf8string major_status_string;
+	utf8string minor_status_string;
+	gssx_buffer server_ctx;
+	struct gssx_option_array options;
+};
+
+struct gssx_call_ctx {
+	utf8string locale;
+	gssx_buffer server_ctx;
+	struct gssx_option_array options;
+};
+
+struct gssx_name_attr {
+	gssx_buffer attr;
+	gssx_buffer value;
+	struct gssx_option_array extensions;
+};
+
+struct gssx_name_attr_array {
+	u32 count;
+	struct gssx_name_attr *data;
+};
+
+struct gssx_name {
+	gssx_buffer display_name;
+	gssx_OID name_type;
+	gssx_buffer exported_name;
+	gssx_buffer exported_composite_name;
+	struct gssx_name_attr_array name_attributes;
+	struct gssx_option_array extensions;
+};
+typedef struct gssx_name gssx_name;
+
+struct gssx_cred_element {
+	gssx_name MN;
+	gssx_OID mech;
+	u32 cred_usage;
+	u64 initiator_time_rec;
+	u64 acceptor_time_rec;
+	struct gssx_option_array options;
+};
+
+struct gssx_cred_element_array {
+	u32 count;
+	struct gssx_cred_element *data;
+};
+
+struct gssx_cred {
+	gssx_name desired_name;
+	struct gssx_cred_element_array elements;
+	gssx_buffer cred_handle_reference;
+	u32 needs_release;
+};
+
+struct gssx_ctx {
+	gssx_buffer exported_context_token;
+	gssx_buffer state;
+	u32 need_release;
+	gssx_OID mech;
+	gssx_name src_name;
+	gssx_name targ_name;
+	u64 lifetime;
+	u64 ctx_flags;
+	u32 locally_initiated;
+	u32 open;
+	struct gssx_option_array options;
+};
+
+struct gssx_cb {
+	u64 initiator_addrtype;
+	gssx_buffer initiator_address;
+	u64 acceptor_addrtype;
+	gssx_buffer acceptor_address;
+	gssx_buffer application_data;
+};
+
+
+/* This structure is not defined in the protocol.
+ * It is used in the kernel to carry around a big buffer
+ * as a set of pages */
+struct gssp_in_token {
+	struct page **pages;	/* Array of contiguous pages */
+	unsigned int page_base;	/* Start of page data */
+	unsigned int page_len;	/* Length of page data */
+};
+
+struct gssx_arg_accept_sec_context {
+	struct gssx_call_ctx call_ctx;
+	struct gssx_ctx *context_handle;
+	struct gssx_cred *cred_handle;
+	struct gssp_in_token input_token;
+	struct gssx_cb *input_cb;
+	u32 ret_deleg_cred;
+	struct gssx_option_array options;
+};
+
+struct gssx_res_accept_sec_context {
+	struct gssx_status status;
+	struct gssx_ctx *context_handle;
+	gssx_buffer *output_token;
+	struct gssx_cred *delegated_cred_handle;
+	struct gssx_option_array options;
+};
+
+
+
+#define gssx_enc_indicate_mechs NULL
+#define gssx_dec_indicate_mechs NULL
+#define gssx_enc_get_call_context NULL
+#define gssx_dec_get_call_context NULL
+#define gssx_enc_import_and_canon_name NULL
+#define gssx_dec_import_and_canon_name NULL
+#define gssx_enc_export_cred NULL
+#define gssx_dec_export_cred NULL
+#define gssx_enc_import_cred NULL
+#define gssx_dec_import_cred NULL
+#define gssx_enc_acquire_cred NULL
+#define gssx_dec_acquire_cred NULL
+#define gssx_enc_store_cred NULL
+#define gssx_dec_store_cred NULL
+#define gssx_enc_init_sec_context NULL
+#define gssx_dec_init_sec_context NULL
+void gssx_enc_accept_sec_context(struct rpc_rqst *req,
+				 struct xdr_stream *xdr,
+				 struct gssx_arg_accept_sec_context *args);
+int gssx_dec_accept_sec_context(struct rpc_rqst *rqstp,
+				struct xdr_stream *xdr,
+				struct gssx_res_accept_sec_context *res);
+#define gssx_enc_release_handle NULL
+#define gssx_dec_release_handle NULL
+#define gssx_enc_get_mic NULL
+#define gssx_dec_get_mic NULL
+#define gssx_enc_verify NULL
+#define gssx_dec_verify NULL
+#define gssx_enc_wrap NULL
+#define gssx_dec_wrap NULL
+#define gssx_enc_unwrap NULL
+#define gssx_dec_unwrap NULL
+#define gssx_enc_wrap_size_limit NULL
+#define gssx_dec_wrap_size_limit NULL
+
+/* non implemented calls are set to 0 size */
+#define GSSX_ARG_indicate_mechs_sz 0
+#define GSSX_RES_indicate_mechs_sz 0
+#define GSSX_ARG_get_call_context_sz 0
+#define GSSX_RES_get_call_context_sz 0
+#define GSSX_ARG_import_and_canon_name_sz 0
+#define GSSX_RES_import_and_canon_name_sz 0
+#define GSSX_ARG_export_cred_sz 0
+#define GSSX_RES_export_cred_sz 0
+#define GSSX_ARG_import_cred_sz 0
+#define GSSX_RES_import_cred_sz 0
+#define GSSX_ARG_acquire_cred_sz 0
+#define GSSX_RES_acquire_cred_sz 0
+#define GSSX_ARG_store_cred_sz 0
+#define GSSX_RES_store_cred_sz 0
+#define GSSX_ARG_init_sec_context_sz 0
+#define GSSX_RES_init_sec_context_sz 0
+
+#define GSSX_default_in_call_ctx_sz (4 + 4 + 4 + \
+			8 + sizeof(LUCID_OPTION) + sizeof(LUCID_VALUE) + \
+			8 + sizeof(CREDS_OPTION) + sizeof(CREDS_VALUE))
+#define GSSX_default_in_ctx_hndl_sz (4 + 4+8 + 4 + 4 + 6*4 + 6*4 + 8 + 8 + \
+					4 + 4 + 4)
+#define GSSX_default_in_cred_sz 4 /* we send in no cred_handle */
+#define GSSX_default_in_token_sz 4 /* does *not* include token data */
+#define GSSX_default_in_cb_sz 4 /* we do not use channel bindings */
+#define GSSX_ARG_accept_sec_context_sz (GSSX_default_in_call_ctx_sz + \
+					GSSX_default_in_ctx_hndl_sz + \
+					GSSX_default_in_cred_sz + \
+					GSSX_default_in_token_sz + \
+					GSSX_default_in_cb_sz + \
+					4 /* no deleg creds boolean */ + \
+					4) /* empty options */
+
+/* somewhat arbitrary numbers but large enough (we ignore some of the data
+ * sent down, but it is part of the protocol so we need enough space to take
+ * it in) */
+#define GSSX_default_status_sz 8 + 24 + 8 + 256 + 256 + 16 + 4
+#define GSSX_max_output_handle_sz 128
+#define GSSX_max_oid_sz 16
+#define GSSX_max_princ_sz 256
+#define GSSX_default_ctx_sz (GSSX_max_output_handle_sz + \
+			     16 + 4 + GSSX_max_oid_sz + \
+			     2 * GSSX_max_princ_sz + \
+			     8 + 8 + 4 + 4 + 4)
+#define GSSX_max_output_token_sz 1024
+#define GSSX_max_creds_sz (4 + 4 + 4 + NGROUPS_MAX * 4)
+#define GSSX_RES_accept_sec_context_sz (GSSX_default_status_sz + \
+					GSSX_default_ctx_sz + \
+					GSSX_max_output_token_sz + \
+					4 + GSSX_max_creds_sz)
+
+#define GSSX_ARG_release_handle_sz 0
+#define GSSX_RES_release_handle_sz 0
+#define GSSX_ARG_get_mic_sz 0
+#define GSSX_RES_get_mic_sz 0
+#define GSSX_ARG_verify_sz 0
+#define GSSX_RES_verify_sz 0
+#define GSSX_ARG_wrap_sz 0
+#define GSSX_RES_wrap_sz 0
+#define GSSX_ARG_unwrap_sz 0
+#define GSSX_RES_unwrap_sz 0
+#define GSSX_ARG_wrap_size_limit_sz 0
+#define GSSX_RES_wrap_size_limit_sz 0
+
+
+
+#endif /* _LINUX_GSS_RPC_XDR_H */
-- 
1.7.7.6

