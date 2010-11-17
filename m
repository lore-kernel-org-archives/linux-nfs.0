Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35298 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934828Ab0KQRo5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 12:44:57 -0500
Received: by mail-iw0-f174.google.com with SMTP id 35so2372245iwn.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 09:44:57 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/17] lockd: Introduce new-style XDR functions for NLMv3
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 12:44:52 -0500
Message-ID: <20101117174452.29177.32757.stgit@matisse.1015granger.net>
In-Reply-To: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
References: <20101117174112.29177.69734.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

We'd like to prevent local buffer overflows caused by malicious or
broken servers.  New xdr_stream style decoders can do that.

For efficiency, we also eventually want to be able to pass xdr_streams
from call_encode() and call_decode() to all XDR encoding functions,
rather than building an xdr_stream in every XDR encoding and decoding
function in the kernel.

To do all of this, rewrite the XDR encoding and decoding functions in
fs/lockd/xdr.c to use xdr_streams.  This makes them more or less
incompatible with server-side XDR helper functions, so break them out
into a separate source file.

Static helper functions are left without the "inline" directive.  This
allows the compiler to choose automatically how to optimize these for
size or speed.

SHARE-related functionality doesn't seem to be used, as those
functions are hiding behind a #define that isn't set anywhere that I
can find.  And, they've been in there forever (at least as far back as
the kernel's git history goes), yet remain unused.  Let's take the
opportunity to bin them.  It should be easy enough for someone to
introduce proper XDR functions if at some point SHARE-related NLM
functionality is desired.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/lockd/Makefile  |    4 
 fs/lockd/clntxdr.c |  643 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/lockd/xdr.c     |  258 ---------------------
 3 files changed, 645 insertions(+), 260 deletions(-)
 create mode 100644 fs/lockd/clntxdr.c

diff --git a/fs/lockd/Makefile b/fs/lockd/Makefile
index cd123e0..e2e973f 100644
--- a/fs/lockd/Makefile
+++ b/fs/lockd/Makefile
@@ -7,7 +7,7 @@ EXTRA_CFLAGS = -W -Wall -Wextra -Wsign-compare \
 
 obj-$(CONFIG_LOCKD) += lockd.o
 
-lockd-objs-y := clntlock.o clntproc.o host.o svc.o svclock.o svcshare.o \
-	        svcproc.o svcsubs.o mon.o xdr.o grace.o
+lockd-objs-y := clntlock.o clntproc.o clntxdr.o host.o svc.o svclock.o \
+	        svcshare.o svcproc.o svcsubs.o mon.o xdr.o grace.o
 lockd-objs-$(CONFIG_LOCKD_V4) += xdr4.o svc4proc.o
 lockd-objs		      := $(lockd-objs-y)
diff --git a/fs/lockd/clntxdr.c b/fs/lockd/clntxdr.c
new file mode 100644
index 0000000..d93d6e9
--- /dev/null
+++ b/fs/lockd/clntxdr.c
@@ -0,0 +1,643 @@
+/*
+ * linux/fs/lockd/clntxdr.c
+ *
+ * XDR functions to encode/decode NLM version 3 RPC arguments and results.
+ * NLM version 3 is backwards compatible with NLM versions 1 and 2.
+ *
+ * NLM client-side only.
+ *
+ * Copyright (C) 2010, Oracle.  All rights reserved.
+ */
+
+#include <linux/types.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/clnt.h>
+#include <linux/sunrpc/stats.h>
+#include <linux/lockd/lockd.h>
+
+#define NLMDBG_FACILITY		NLMDBG_XDR
+
+#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
+#  error "NLM host name cannot be larger than XDR_MAX_NETOBJ!"
+#endif
+
+/*
+ * Declare the space requirements for NLM arguments and replies as
+ * number of 32bit-words
+ */
+#define NLM_cookie_sz		(1+(NLM_MAXCOOKIELEN>>2))
+#define NLM_caller_sz		(1+(NLMCLNT_OHSIZE>>2))
+#define NLM_owner_sz		(1+(NLMCLNT_OHSIZE>>2))
+#define NLM_fhandle_sz		(1+(NFS2_FHSIZE>>2))
+#define NLM_lock_sz		(3+NLM_caller_sz+NLM_owner_sz+NLM_fhandle_sz)
+#define NLM_holder_sz		(4+NLM_owner_sz)
+
+#define NLM_testargs_sz		(NLM_cookie_sz+1+NLM_lock_sz)
+#define NLM_lockargs_sz		(NLM_cookie_sz+4+NLM_lock_sz)
+#define NLM_cancargs_sz		(NLM_cookie_sz+2+NLM_lock_sz)
+#define NLM_unlockargs_sz	(NLM_cookie_sz+NLM_lock_sz)
+
+#define NLM_testres_sz		(NLM_cookie_sz+1+NLM_holder_sz)
+#define NLM_res_sz		(NLM_cookie_sz+1)
+#define NLM_norep_sz		(0)
+
+
+static s32 loff_t_to_s32(loff_t offset)
+{
+	s32 res;
+
+	if (offset >= NLM_OFFSET_MAX)
+		res = NLM_OFFSET_MAX;
+	else if (offset <= -NLM_OFFSET_MAX)
+		res = -NLM_OFFSET_MAX;
+	else
+		res = offset;
+	return res;
+}
+
+static void nlm_compute_offsets(const struct nlm_lock *lock,
+				u32 *l_offset, u32 *l_len)
+{
+	const struct file_lock *fl = &lock->fl;
+
+	BUG_ON(fl->fl_start > NLM_OFFSET_MAX);
+	BUG_ON(fl->fl_end > NLM_OFFSET_MAX &&
+				fl->fl_end != OFFSET_MAX);
+
+	*l_offset = loff_t_to_s32(fl->fl_start);
+	if (fl->fl_end == OFFSET_MAX)
+		*l_len = 0;
+	else
+		*l_len = loff_t_to_s32(fl->fl_end - fl->fl_start + 1);
+}
+
+/*
+ * Handle decode buffer overflows out-of-line.
+ */
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("lockd: %s prematurely hit the end of our receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
+}
+
+
+/*
+ * Encode/decode NLMv3 basic data types
+ *
+ * Basic NLMv3 data types are not defined in an IETF standards
+ * document.  X/Open has a description of these data types that
+ * is useful.  See Chapter 10 of "Protocols for Interworking:
+ * XNFS, Version 3W".
+ *
+ * Not all basic data types have their own encoding and decoding
+ * functions.  For run-time efficiency, some data types are encoded
+ * or decoded inline.
+ */
+
+static void encode_bool(struct xdr_stream *xdr, const int value)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	*p = value ? xdr_one : xdr_zero;
+}
+
+static void encode_int32(struct xdr_stream *xdr, const s32 value)
+{
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	*p = cpu_to_be32(value);
+}
+
+/*
+ *	typedef opaque netobj<MAXNETOBJ_SZ>
+ */
+static void encode_netobj(struct xdr_stream *xdr,
+			  const u8 *data, const unsigned int length)
+{
+	__be32 *p;
+
+	BUG_ON(length > XDR_MAX_NETOBJ);
+	p = xdr_reserve_space(xdr, 4 + length);
+	xdr_encode_opaque(p, data, length);
+}
+
+static int decode_netobj(struct xdr_stream *xdr,
+			 struct xdr_netobj *obj)
+{
+	u32 length;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	length = be32_to_cpup(p++);
+	if (unlikely(length > XDR_MAX_NETOBJ))
+		goto out_size;
+	obj->len = length;
+	obj->data = (u8 *)p;
+	return 0;
+out_size:
+	dprintk("NFS: returned netobj was too long: %u\n", length);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ *	netobj cookie;
+ */
+static void encode_cookie(struct xdr_stream *xdr,
+			  const struct nlm_cookie *cookie)
+{
+	BUG_ON(cookie->len > NLM_MAXCOOKIELEN);
+	encode_netobj(xdr, (u8 *)&cookie->data, cookie->len);
+}
+
+static int decode_cookie(struct xdr_stream *xdr,
+			 struct nlm_cookie *cookie)
+{
+	u32 length;
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	length = be32_to_cpup(p++);
+	/* apparently HPUX can return empty cookies */
+	if (length == 0)
+		goto out_hpux;
+	if (length > NLM_MAXCOOKIELEN)
+		goto out_size;
+	p = xdr_inline_decode(xdr, length);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	cookie->len = length;
+	memcpy(cookie->data, p, length);
+	return 0;
+out_hpux:
+	cookie->len = 4;
+	memset(cookie->data, 0, 4);
+	return 0;
+out_size:
+	dprintk("NFS: returned cookie was too long: %u\n", length);
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ *	netobj fh;
+ */
+static void encode_fh(struct xdr_stream *xdr, const struct nfs_fh *fh)
+{
+	BUG_ON(fh->size != NFS2_FHSIZE);
+	encode_netobj(xdr, (u8 *)&fh->data, NFS2_FHSIZE);
+}
+
+/*
+ *	enum nlm_stats {
+ *		LCK_GRANTED = 0,
+ *		LCK_DENIED = 1,
+ *		LCK_DENIED_NOLOCKS = 2,
+ *		LCK_BLOCKED = 3,
+ *		LCK_DENIED_GRACE_PERIOD = 4
+ *	};
+ *
+ *
+ *	struct nlm_stat {
+ *		nlm_stats stat;
+ *	};
+ *
+ * NB: we don't swap bytes for the NLM status values.  The upper
+ * layers deal directly with the status value in network byte
+ * order.
+ */
+
+static void encode_nlm_stat(struct xdr_stream *xdr,
+			    const __be32 stat)
+{
+	__be32 *p;
+
+	BUG_ON(be32_to_cpu(stat) > NLM_LCK_DENIED_GRACE_PERIOD);
+	p = xdr_reserve_space(xdr, 4);
+	*p = stat;
+}
+
+static int decode_nlm_stat(struct xdr_stream *xdr,
+			   __be32 *stat)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	if (unlikely(*p > nlm_lck_denied_grace_period))
+		goto out_enum;
+	*stat = *p;
+	return 0;
+out_enum:
+	dprintk("%s: server returned invalid nlm_stats value: %u\n",
+		__func__, be32_to_cpup(p));
+	return -EIO;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ *	struct nlm_holder {
+ *		bool exclusive;
+ *		int uppid;
+ *		netobj oh;
+ *		unsigned l_offset;
+ *		unsigned l_len;
+ *	};
+ */
+static void encode_nlm_holder(struct xdr_stream *xdr,
+			      const struct nlm_res *result)
+{
+	const struct nlm_lock *lock = &result->lock;
+	u32 l_offset, l_len;
+	__be32 *p;
+
+	encode_bool(xdr, lock->fl.fl_type == F_RDLCK);
+	encode_int32(xdr, lock->svid);
+	encode_netobj(xdr, lock->oh.data, lock->oh.len);
+
+	p = xdr_reserve_space(xdr, 4 + 4);
+	nlm_compute_offsets(lock, &l_offset, &l_len);
+	*p++ = cpu_to_be32(l_offset);
+	*p   = cpu_to_be32(l_len);
+}
+
+static int decode_nlm_holder(struct xdr_stream *xdr, struct nlm_res *result)
+{
+	struct nlm_lock *lock = &result->lock;
+	struct file_lock *fl = &lock->fl;
+	u32 exclusive, l_offset, l_len;
+	int error;
+	__be32 *p;
+	s32 end;
+
+	memset(lock, 0, sizeof(*lock));
+	locks_init_lock(fl);
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+	exclusive = be32_to_cpup(p++);
+	lock->svid = be32_to_cpup(p);
+	fl->fl_pid = (pid_t)lock->svid;
+
+	error = decode_netobj(xdr, &lock->oh);
+	if (unlikely(error))
+		goto out;
+
+	p = xdr_inline_decode(xdr, 4 + 4);
+	if (unlikely(p == NULL))
+		goto out_overflow;
+
+	fl->fl_flags = FL_POSIX;
+	fl->fl_type  = exclusive != 0 ? F_WRLCK : F_RDLCK;
+	l_offset = be32_to_cpup(p++);
+	l_len = be32_to_cpup(p);
+	end = l_offset + l_len - 1;
+
+	fl->fl_start = (loff_t)l_offset;
+	if (l_len == 0 || end < 0)
+		fl->fl_end = OFFSET_MAX;
+	else
+		fl->fl_end = (loff_t)end;
+	error = 0;
+out:
+	return error;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return -EIO;
+}
+
+/*
+ *	string caller_name<LM_MAXSTRLEN>;
+ */
+static void encode_caller_name(struct xdr_stream *xdr, const char *name)
+{
+	/* NB: client-side does not set lock->len */
+	u32 length = strlen(name);
+	__be32 *p;
+
+	BUG_ON(length > NLM_MAXSTRLEN);
+	p = xdr_reserve_space(xdr, 4 + length);
+	xdr_encode_opaque(p, name, length);
+}
+
+/*
+ *	struct nlm_lock {
+ *		string caller_name<LM_MAXSTRLEN>;
+ *		netobj fh;
+ *		netobj oh;
+ *		int uppid;
+ *		unsigned l_offset;
+ *		unsigned l_len;
+ *	};
+ */
+static void encode_nlm_lock(struct xdr_stream *xdr,
+			    const struct nlm_lock *lock)
+{
+	u32 l_offset, l_len;
+	__be32 *p;
+
+	encode_caller_name(xdr, lock->caller);
+	encode_fh(xdr, &lock->fh);
+	encode_netobj(xdr, lock->oh.data, lock->oh.len);
+
+	p = xdr_reserve_space(xdr, 4 + 4 + 4);
+	*p++ = cpu_to_be32(lock->svid);
+
+	nlm_compute_offsets(lock, &l_offset, &l_len);
+	*p++ = cpu_to_be32(l_offset);
+	*p   = cpu_to_be32(l_len);
+}
+
+
+/*
+ * NLMv3 XDR encode functions
+ *
+ * NLMv3 argument types are defined in Chapter 10 of The Open Group's
+ * "Protocols for Interworking: XNFS, Version 3W".
+ */
+
+/*
+ *	struct nlm_testargs {
+ *		netobj cookie;
+ *		bool exclusive;
+ *		struct nlm_lock alock;
+ *	};
+ */
+static int nlm_xdr_enc_testargs(struct rpc_rqst *req, __be32 *p,
+				const struct nlm_args *args)
+{
+	const struct nlm_lock *lock = &args->lock;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &args->cookie);
+	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(&xdr, lock);
+	return 0;
+}
+
+/*
+ *	struct nlm_lockargs {
+ *		netobj cookie;
+ *		bool block;
+ *		bool exclusive;
+ *		struct nlm_lock alock;
+ *		bool reclaim;
+ *		int state;
+ *	};
+ */
+static int nlm_xdr_enc_lockargs(struct rpc_rqst *req, __be32 *p,
+				const struct nlm_args *args)
+{
+	const struct nlm_lock *lock = &args->lock;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &args->cookie);
+	encode_bool(&xdr, args->block);
+	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(&xdr, lock);
+	encode_bool(&xdr, args->reclaim);
+	encode_int32(&xdr, args->state);
+	return 0;
+}
+
+/*
+ *	struct nlm_cancargs {
+ *		netobj cookie;
+ *		bool block;
+ *		bool exclusive;
+ *		struct nlm_lock alock;
+ *	};
+ */
+static int nlm_xdr_enc_cancargs(struct rpc_rqst *req, __be32 *p,
+				const struct nlm_args *args)
+{
+	const struct nlm_lock *lock = &args->lock;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &args->cookie);
+	encode_bool(&xdr, args->block);
+	encode_bool(&xdr, lock->fl.fl_type == F_WRLCK);
+	encode_nlm_lock(&xdr, lock);
+	return 0;
+}
+
+/*
+ *	struct nlm_unlockargs {
+ *		netobj cookie;
+ *		struct nlm_lock alock;
+ *	};
+ */
+static int nlm_xdr_enc_unlockargs(struct rpc_rqst *req, __be32 *p,
+				  const struct nlm_args *args)
+{
+	const struct nlm_lock *lock = &args->lock;
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &args->cookie);
+	encode_nlm_lock(&xdr, lock);
+	return 0;
+}
+
+/*
+ *	struct nlm_res {
+ *		netobj cookie;
+ *		nlm_stat stat;
+ *	};
+ */
+static int nlm_xdr_enc_res(struct rpc_rqst *req, __be32 *p,
+			   const struct nlm_res *result)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &result->cookie);
+	encode_nlm_stat(&xdr, result->status);
+	return 0;
+}
+
+/*
+ *	union nlm_testrply switch (nlm_stats stat) {
+ *	case LCK_DENIED:
+ *		struct nlm_holder holder;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	struct nlm_testres {
+ *		netobj cookie;
+ *		nlm_testrply test_stat;
+ *	};
+ */
+static void encode_nlm_testrply(struct xdr_stream *xdr,
+				const struct nlm_res *result)
+{
+	if (result->status == nlm_lck_denied)
+		encode_nlm_holder(xdr, result);
+}
+
+static int nlm_xdr_enc_testres(struct rpc_rqst *req, __be32 *p,
+			       const struct nlm_res *result)
+{
+	struct xdr_stream xdr;
+
+	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
+	encode_cookie(&xdr, &result->cookie);
+	encode_nlm_stat(&xdr, result->status);
+	encode_nlm_testrply(&xdr, result);
+	return 0;
+}
+
+
+/*
+ * NLMv3 XDR decode functions
+ *
+ * NLMv3 result types are defined in Chapter 10 of The Open Group's
+ * "Protocols for Interworking: XNFS, Version 3W".
+ */
+
+/*
+ *	union nlm_testrply switch (nlm_stats stat) {
+ *	case LCK_DENIED:
+ *		struct nlm_holder holder;
+ *	default:
+ *		void;
+ *	};
+ *
+ *	struct nlm_testres {
+ *		netobj cookie;
+ *		nlm_testrply test_stat;
+ *	};
+ */
+static int decode_nlm_testrply(struct xdr_stream *xdr,
+			       struct nlm_res *result)
+{
+	int error;
+
+	error = decode_nlm_stat(xdr, &result->status);
+	if (unlikely(error))
+		goto out;
+	if (result->status == nlm_lck_denied)
+		error = decode_nlm_holder(xdr, result);
+out:
+	return error;
+}
+
+static int nlm_xdr_dec_testres(struct rpc_rqst *req, __be32 *p,
+			       struct nlm_res *result)
+{
+	struct xdr_stream xdr;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_cookie(&xdr, &result->cookie);
+	if (unlikely(error))
+		goto out;
+	error = decode_nlm_testrply(&xdr, result);
+out:
+	return error;
+}
+
+/*
+ *	struct nlm_res {
+ *		netobj cookie;
+ *		nlm_stat stat;
+ *	};
+ */
+static int nlm_xdr_dec_res(struct rpc_rqst *req, __be32 *p,
+			   struct nlm_res *result)
+{
+	struct xdr_stream xdr;
+	int error;
+
+	xdr_init_decode(&xdr, &req->rq_rcv_buf, p);
+	error = decode_cookie(&xdr, &result->cookie);
+	if (unlikely(error))
+		goto out;
+	error = decode_nlm_stat(&xdr, &result->status);
+out:
+	return error;
+}
+
+
+/*
+ * For NLM, a void procedure really returns nothing
+ */
+#define nlm_xdr_dec_norep	NULL
+
+#define PROC(proc, argtype, restype)	\
+[NLMPROC_##proc] = {							\
+	.p_proc      = NLMPROC_##proc,					\
+	.p_encode    = (kxdrproc_t)nlm_xdr_enc_##argtype,		\
+	.p_decode    = (kxdrproc_t)nlm_xdr_dec_##restype,		\
+	.p_arglen    = NLM_##argtype##_sz,				\
+	.p_replen    = NLM_##restype##_sz,				\
+	.p_statidx   = NLMPROC_##proc,					\
+	.p_name      = #proc,						\
+	}
+
+static struct rpc_procinfo	nlm_procedures[] = {
+	PROC(TEST,		testargs,	testres),
+	PROC(LOCK,		lockargs,	res),
+	PROC(CANCEL,		cancargs,	res),
+	PROC(UNLOCK,		unlockargs,	res),
+	PROC(GRANTED,		testargs,	res),
+	PROC(TEST_MSG,		testargs,	norep),
+	PROC(LOCK_MSG,		lockargs,	norep),
+	PROC(CANCEL_MSG,	cancargs,	norep),
+	PROC(UNLOCK_MSG,	unlockargs,	norep),
+	PROC(GRANTED_MSG,	testargs,	norep),
+	PROC(TEST_RES,		testres,	norep),
+	PROC(LOCK_RES,		res,		norep),
+	PROC(CANCEL_RES,	res,		norep),
+	PROC(UNLOCK_RES,	res,		norep),
+	PROC(GRANTED_RES,	res,		norep),
+};
+
+static struct rpc_version	nlm_version1 = {
+		.number		= 1,
+		.nrprocs	= 16,
+		.procs		= nlm_procedures,
+};
+
+static struct rpc_version	nlm_version3 = {
+		.number		= 3,
+		.nrprocs	= 24,
+		.procs		= nlm_procedures,
+};
+
+static struct rpc_version	*nlm_versions[] = {
+	[1] = &nlm_version1,
+	[3] = &nlm_version3,
+#ifdef CONFIG_LOCKD_V4
+	[4] = &nlm_version4,
+#endif
+};
+
+static struct rpc_stat		nlm_rpc_stats;
+
+struct rpc_program		nlm_program = {
+		.name		= "lockd",
+		.number		= NLM_PROGRAM,
+		.nrvers		= ARRAY_SIZE(nlm_versions),
+		.version	= nlm_versions,
+		.stats		= &nlm_rpc_stats,
+};
diff --git a/fs/lockd/xdr.c b/fs/lockd/xdr.c
index b583ab0..0eb694d 100644
--- a/fs/lockd/xdr.c
+++ b/fs/lockd/xdr.c
@@ -149,37 +149,6 @@ nlm_decode_lock(__be32 *p, struct nlm_lock *lock)
 }
 
 /*
- * Encode a lock as part of an NLM call
- */
-static __be32 *
-nlm_encode_lock(__be32 *p, struct nlm_lock *lock)
-{
-	struct file_lock	*fl = &lock->fl;
-	__s32			start, len;
-
-	if (!(p = xdr_encode_string(p, lock->caller))
-	 || !(p = nlm_encode_fh(p, &lock->fh))
-	 || !(p = nlm_encode_oh(p, &lock->oh)))
-		return NULL;
-
-	if (fl->fl_start > NLM_OFFSET_MAX
-	 || (fl->fl_end > NLM_OFFSET_MAX && fl->fl_end != OFFSET_MAX))
-		return NULL;
-
-	start = loff_t_to_s32(fl->fl_start);
-	if (fl->fl_end == OFFSET_MAX)
-		len = 0;
-	else
-		len = loff_t_to_s32(fl->fl_end - fl->fl_start + 1);
-
-	*p++ = htonl(lock->svid);
-	*p++ = htonl(start);
-	*p++ = htonl(len);
-
-	return p;
-}
-
-/*
  * Encode result of a TEST/TEST_MSG call
  */
 static __be32 *
@@ -373,233 +342,6 @@ nlmsvc_encode_void(struct svc_rqst *rqstp, __be32 *p, void *dummy)
 	return xdr_ressize_check(rqstp, p);
 }
 
-/*
- * Now, the client side XDR functions
- */
-#ifdef NLMCLNT_SUPPORT_SHARES
-static int
-nlmclt_decode_void(struct rpc_rqst *req, u32 *p, void *ptr)
-{
-	return 0;
-}
-#endif
-
-static int
-nlmclt_encode_testargs(struct rpc_rqst *req, __be32 *p, nlm_args *argp)
-{
-	struct nlm_lock	*lock = &argp->lock;
-
-	if (!(p = nlm_encode_cookie(p, &argp->cookie)))
-		return -EIO;
-	*p++ = (lock->fl.fl_type == F_WRLCK)? xdr_one : xdr_zero;
-	if (!(p = nlm_encode_lock(p, lock)))
-		return -EIO;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_decode_testres(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
-{
-	if (!(p = nlm_decode_cookie(p, &resp->cookie)))
-		return -EIO;
-	resp->status = *p++;
-	if (resp->status == nlm_lck_denied) {
-		struct file_lock	*fl = &resp->lock.fl;
-		u32			excl;
-		s32			start, len, end;
-
-		memset(&resp->lock, 0, sizeof(resp->lock));
-		locks_init_lock(fl);
-		excl = ntohl(*p++);
-		resp->lock.svid = ntohl(*p++);
-		fl->fl_pid = (pid_t)resp->lock.svid;
-		if (!(p = nlm_decode_oh(p, &resp->lock.oh)))
-			return -EIO;
-
-		fl->fl_flags = FL_POSIX;
-		fl->fl_type  = excl? F_WRLCK : F_RDLCK;
-		start = ntohl(*p++);
-		len = ntohl(*p++);
-		end = start + len - 1;
-
-		fl->fl_start = s32_to_loff_t(start);
-		if (len == 0 || end < 0)
-			fl->fl_end = OFFSET_MAX;
-		else
-			fl->fl_end = s32_to_loff_t(end);
-	}
-	return 0;
-}
-
-
-static int
-nlmclt_encode_lockargs(struct rpc_rqst *req, __be32 *p, nlm_args *argp)
-{
-	struct nlm_lock	*lock = &argp->lock;
-
-	if (!(p = nlm_encode_cookie(p, &argp->cookie)))
-		return -EIO;
-	*p++ = argp->block? xdr_one : xdr_zero;
-	*p++ = (lock->fl.fl_type == F_WRLCK)? xdr_one : xdr_zero;
-	if (!(p = nlm_encode_lock(p, lock)))
-		return -EIO;
-	*p++ = argp->reclaim? xdr_one : xdr_zero;
-	*p++ = htonl(argp->state);
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_encode_cancargs(struct rpc_rqst *req, __be32 *p, nlm_args *argp)
-{
-	struct nlm_lock	*lock = &argp->lock;
-
-	if (!(p = nlm_encode_cookie(p, &argp->cookie)))
-		return -EIO;
-	*p++ = argp->block? xdr_one : xdr_zero;
-	*p++ = (lock->fl.fl_type == F_WRLCK)? xdr_one : xdr_zero;
-	if (!(p = nlm_encode_lock(p, lock)))
-		return -EIO;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_encode_unlockargs(struct rpc_rqst *req, __be32 *p, nlm_args *argp)
-{
-	struct nlm_lock	*lock = &argp->lock;
-
-	if (!(p = nlm_encode_cookie(p, &argp->cookie)))
-		return -EIO;
-	if (!(p = nlm_encode_lock(p, lock)))
-		return -EIO;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_encode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
-{
-	if (!(p = nlm_encode_cookie(p, &resp->cookie)))
-		return -EIO;
-	*p++ = resp->status;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_encode_testres(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
-{
-	if (!(p = nlm_encode_testres(p, resp)))
-		return -EIO;
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-static int
-nlmclt_decode_res(struct rpc_rqst *req, __be32 *p, struct nlm_res *resp)
-{
-	if (!(p = nlm_decode_cookie(p, &resp->cookie)))
-		return -EIO;
-	resp->status = *p++;
-	return 0;
-}
-
-#if (NLMCLNT_OHSIZE > XDR_MAX_NETOBJ)
-#  error "NLM host name cannot be larger than XDR_MAX_NETOBJ!"
-#endif
-
-/*
- * Buffer requirements for NLM
- */
-#define NLM_void_sz		0
-#define NLM_cookie_sz		1+XDR_QUADLEN(NLM_MAXCOOKIELEN)
-#define NLM_caller_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
-#define NLM_owner_sz		1+XDR_QUADLEN(NLMCLNT_OHSIZE)
-#define NLM_fhandle_sz		1+XDR_QUADLEN(NFS2_FHSIZE)
-#define NLM_lock_sz		3+NLM_caller_sz+NLM_owner_sz+NLM_fhandle_sz
-#define NLM_holder_sz		4+NLM_owner_sz
-
-#define NLM_testargs_sz		NLM_cookie_sz+1+NLM_lock_sz
-#define NLM_lockargs_sz		NLM_cookie_sz+4+NLM_lock_sz
-#define NLM_cancargs_sz		NLM_cookie_sz+2+NLM_lock_sz
-#define NLM_unlockargs_sz	NLM_cookie_sz+NLM_lock_sz
-
-#define NLM_testres_sz		NLM_cookie_sz+1+NLM_holder_sz
-#define NLM_res_sz		NLM_cookie_sz+1
-#define NLM_norep_sz		0
-
-/*
- * For NLM, a void procedure really returns nothing
- */
-#define nlmclt_decode_norep	NULL
-
-#define PROC(proc, argtype, restype)	\
-[NLMPROC_##proc] = {							\
-	.p_proc      = NLMPROC_##proc,					\
-	.p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
-	.p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
-	.p_arglen    = NLM_##argtype##_sz,				\
-	.p_replen    = NLM_##restype##_sz,				\
-	.p_statidx   = NLMPROC_##proc,					\
-	.p_name      = #proc,						\
-	}
-
-static struct rpc_procinfo	nlm_procedures[] = {
-    PROC(TEST,		testargs,	testres),
-    PROC(LOCK,		lockargs,	res),
-    PROC(CANCEL,	cancargs,	res),
-    PROC(UNLOCK,	unlockargs,	res),
-    PROC(GRANTED,	testargs,	res),
-    PROC(TEST_MSG,	testargs,	norep),
-    PROC(LOCK_MSG,	lockargs,	norep),
-    PROC(CANCEL_MSG,	cancargs,	norep),
-    PROC(UNLOCK_MSG,	unlockargs,	norep),
-    PROC(GRANTED_MSG,	testargs,	norep),
-    PROC(TEST_RES,	testres,	norep),
-    PROC(LOCK_RES,	res,		norep),
-    PROC(CANCEL_RES,	res,		norep),
-    PROC(UNLOCK_RES,	res,		norep),
-    PROC(GRANTED_RES,	res,		norep),
-#ifdef NLMCLNT_SUPPORT_SHARES
-    PROC(SHARE,		shareargs,	shareres),
-    PROC(UNSHARE,	shareargs,	shareres),
-    PROC(NM_LOCK,	lockargs,	res),
-    PROC(FREE_ALL,	notify,		void),
-#endif
-};
-
-static struct rpc_version	nlm_version1 = {
-		.number		= 1,
-		.nrprocs	= 16,
-		.procs		= nlm_procedures,
-};
-
-static struct rpc_version	nlm_version3 = {
-		.number		= 3,
-		.nrprocs	= 24,
-		.procs		= nlm_procedures,
-};
-
-static struct rpc_version *	nlm_versions[] = {
-	[1] = &nlm_version1,
-	[3] = &nlm_version3,
-#ifdef 	CONFIG_LOCKD_V4
-	[4] = &nlm_version4,
-#endif
-};
-
-static struct rpc_stat		nlm_stats;
-
-struct rpc_program		nlm_program = {
-		.name		= "lockd",
-		.number		= NLM_PROGRAM,
-		.nrvers		= ARRAY_SIZE(nlm_versions),
-		.version	= nlm_versions,
-		.stats		= &nlm_stats,
-};
-
 #ifdef RPC_DEBUG
 const char *nlmdbg_cookie2a(const struct nlm_cookie *cookie)
 {

