From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 1 of 34 - Add minimal server-side support for rpcsec_gss.
Date: Tue, 24 Feb 2004 10:49:41 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1AvPpV-0006Gr-00@notabene>
References: <20040224104820.23884.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvPq8-0006rz-1h
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:50:20 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1AvPe8-0002Jk-Et
	for nfs@lists.sourceforge.net; Mon, 23 Feb 2004 15:37:56 -0800
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Tue, 24 Feb 2004 10:49:41 +1100
To: Andrew Morton <akpm@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


From: "J. Bruce Fields" <bfields@fieldses.org>


Note that the user (or exportfs, on the user's behalf) allows a gss
pseudoflavor to be used to access an export by exporting to a special
client named "gss/pseudoflavor-name", e.g., "gss/krb5" or "gss/lipkey-i".

 ----------- Diffstat output ------------
 ./include/linux/sunrpc/auth_gss.h       |    2 
 ./include/linux/sunrpc/gss_api.h        |    3 
 ./include/linux/sunrpc/svc.h            |    1 
 ./include/linux/sunrpc/svcauth.h        |    5 
 ./include/linux/sunrpc/svcauth_gss.h    |   35 +
 ./net/sunrpc/auth_gss/Makefile          |    2 
 ./net/sunrpc/auth_gss/auth_gss.c        |   10 
 ./net/sunrpc/auth_gss/gss_krb5_mech.c   |    4 
 ./net/sunrpc/auth_gss/gss_mech_switch.c |   17 
 ./net/sunrpc/auth_gss/sunrpcgss_syms.c  |    2 
 ./net/sunrpc/auth_gss/svcauth_gss.c     |  885 ++++++++++++++++++++++++++++++++
 ./net/sunrpc/sunrpc_syms.c              |    2 
 ./net/sunrpc/svc.c                      |    4 
 13 files changed, 969 insertions(+), 3 deletions(-)

diff ./include/linux/sunrpc/auth_gss.h~current~ ./include/linux/sunrpc/auth_gss.h
--- ./include/linux/sunrpc/auth_gss.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/sunrpc/auth_gss.h	2004-02-24 10:40:29.000000000 +1100
@@ -62,8 +62,6 @@ struct rpc_gss_init_res {
 	struct xdr_netobj	gr_token;	/* token */
 };
 
-#define GSS_SEQ_WIN	5
-
 /* The gss_cl_ctx struct holds all the information the rpcsec_gss client
  * code needs to know about a single security context.  In particular,
  * gc_gss_ctx is the context handle that is used to do gss-api calls, while

diff ./include/linux/sunrpc/gss_api.h~current~ ./include/linux/sunrpc/gss_api.h
--- ./include/linux/sunrpc/gss_api.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/sunrpc/gss_api.h	2004-02-24 10:40:29.000000000 +1100
@@ -120,6 +120,9 @@ int gss_mech_unregister_all(void);
  * reference count. */
 struct gss_api_mech * gss_mech_get_by_OID(struct xdr_netobj *);
 
+/* Similar, but get by name like "krb5", "spkm", etc., instead of OID. */
+struct gss_api_mech *gss_mech_get_by_name(char *);
+
 /* Just increments the mechanism's reference count and returns its input: */
 struct gss_api_mech * gss_mech_get(struct gss_api_mech *);
 

diff ./include/linux/sunrpc/svc.h~current~ ./include/linux/sunrpc/svc.h
--- ./include/linux/sunrpc/svc.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/sunrpc/svc.h	2004-02-24 10:40:29.000000000 +1100
@@ -135,6 +135,7 @@ struct svc_rqst {
 
 	void *			rq_argp;	/* decoded arguments */
 	void *			rq_resp;	/* xdr'd results */
+	void *			rq_auth_data;	/* flavor-specific data */
 
 	int			rq_reserved;	/* space on socket outq
 						 * reserved for this request

diff ./include/linux/sunrpc/svcauth.h~current~ ./include/linux/sunrpc/svcauth.h
--- ./include/linux/sunrpc/svcauth.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/sunrpc/svcauth.h	2004-02-24 10:40:29.000000000 +1100
@@ -66,6 +66,10 @@ struct auth_domain {
  *      GARBAGE - rpc garbage_args error
  *      SYSERR - rpc system_err error
  *      DENIED - authp holds reason for denial.
+ *      COMPLETE - the reply is encoded already and ready to be sent; no
+ *		further processing is necessary.  (This is used for processing
+ *		null procedure calls which are used to set up encryption
+ *		contexts.)
  *
  *   accept is passed the proc number so that it can accept NULL rpc requests
  *   even if it cannot authenticate the client (as is sometimes appropriate).
@@ -98,6 +102,7 @@ extern struct auth_ops	*authtab[RPC_AUTH
 #define	SVC_DROP	6
 #define	SVC_DENIED	7
 #define	SVC_PENDING	8
+#define	SVC_COMPLETE	9
 
 
 extern int	svc_authenticate(struct svc_rqst *rqstp, u32 *authp);

diff ./include/linux/sunrpc/svcauth_gss.h~current~ ./include/linux/sunrpc/svcauth_gss.h
--- ./include/linux/sunrpc/svcauth_gss.h~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./include/linux/sunrpc/svcauth_gss.h	2004-02-24 10:40:29.000000000 +1100
@@ -0,0 +1,35 @@
+/*
+ * linux/include/linux/svcauth_gss.h
+ *
+ * Bruce Fields <bfields@umich.edu>
+ * Copyright (c) 2002 The Regents of the Unviersity of Michigan
+ *
+ * $Id$
+ *
+ */
+
+#ifndef _LINUX_SUNRPC_SVCAUTH_GSS_H
+#define _LINUX_SUNRPC_SVCAUTH_GSS_H
+
+#ifdef __KERNEL__
+#include <linux/sched.h>
+#include <linux/sunrpc/types.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/sunrpc/svcauth.h>
+#include <linux/sunrpc/svcsock.h>
+#include <linux/sunrpc/auth_gss.h>
+
+int gss_svc_init(void);
+int svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name);
+
+
+struct gss_svc_data {
+	/* decoded gss client cred: */
+	struct rpc_gss_wire_cred	clcred;
+	/* pointer to the beginning of the procedure-specific results, which
+	 * may be encrypted/checksummed in svcauth_gss_release: */
+	u32				*body_start;
+};
+
+#endif /* __KERNEL__ */
+#endif /* _LINUX_SUNRPC_SVCAUTH_GSS_H */

diff ./net/sunrpc/auth_gss/Makefile~current~ ./net/sunrpc/auth_gss/Makefile
--- ./net/sunrpc/auth_gss/Makefile~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/Makefile	2004-02-24 10:40:29.000000000 +1100
@@ -5,7 +5,7 @@
 obj-$(CONFIG_SUNRPC_GSS) += auth_rpcgss.o
 
 auth_rpcgss-objs := auth_gss.o gss_pseudoflavors.o gss_generic_token.o \
-	sunrpcgss_syms.o gss_mech_switch.o
+	sunrpcgss_syms.o gss_mech_switch.o svcauth_gss.o
 
 obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 

diff ./net/sunrpc/auth_gss/auth_gss.c~current~ ./net/sunrpc/auth_gss/auth_gss.c
--- ./net/sunrpc/auth_gss/auth_gss.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/auth_gss.c	2004-02-24 10:40:29.000000000 +1100
@@ -48,6 +48,7 @@
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/auth_gss.h>
+#include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/gss_err.h>
 #include <linux/workqueue.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
@@ -972,6 +973,15 @@ static int __init init_rpcsec_gss(void)
 	int err = 0;
 
 	err = rpcauth_register(&authgss_ops);
+	if (err)
+		goto out;
+	err = gss_svc_init();
+	if (err)
+		goto out_unregister;
+	return 0;
+out_unregister:
+	rpcauth_unregister(&authgss_ops);
+out:
 	return err;
 }
 

diff ./net/sunrpc/auth_gss/gss_krb5_mech.c~current~ ./net/sunrpc/auth_gss/gss_krb5_mech.c
--- ./net/sunrpc/auth_gss/gss_krb5_mech.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/gss_krb5_mech.c	2004-02-24 10:40:29.000000000 +1100
@@ -39,6 +39,8 @@
 #include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/sunrpc/auth.h>
+#include <linux/in.h>
+#include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/gss_krb5.h>
 #include <linux/sunrpc/xdr.h>
 #include <linux/crypto.h>
@@ -232,6 +234,8 @@ static int __init init_kerberos_module(v
 	gm = gss_mech_get_by_OID(&gss_mech_krb5_oid);
 	gss_register_triple(RPC_AUTH_GSS_KRB5 , gm, 0, RPC_GSS_SVC_NONE);
 	gss_register_triple(RPC_AUTH_GSS_KRB5I, gm, 0, RPC_GSS_SVC_INTEGRITY);
+	if (svcauth_gss_register_pseudoflavor(RPC_AUTH_GSS_KRB5, "krb5"))
+		printk("Failed to register %s with server!\n", "krb5");
 	gss_mech_put(gm);
 	return 0;
 }

diff ./net/sunrpc/auth_gss/gss_mech_switch.c~current~ ./net/sunrpc/auth_gss/gss_mech_switch.c
--- ./net/sunrpc/auth_gss/gss_mech_switch.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/gss_mech_switch.c	2004-02-24 10:40:29.000000000 +1100
@@ -162,6 +162,23 @@ gss_mech_get_by_OID(struct xdr_netobj *m
 	return gm;
 }
 
+struct gss_api_mech *
+gss_mech_get_by_name(char *name)
+{
+	struct gss_api_mech	*pos, *gm = NULL;
+
+	spin_lock(&registered_mechs_lock);
+	list_for_each_entry(pos, &registered_mechs, gm_list) {
+		if (0 == strcmp(name, pos->gm_ops->name)) {
+			gm = gss_mech_get(pos);
+			break;
+		}
+	}
+	spin_unlock(&registered_mechs_lock);
+	return gm;
+
+}
+
 int
 gss_mech_put(struct gss_api_mech * gm)
 {

diff ./net/sunrpc/auth_gss/sunrpcgss_syms.c~current~ ./net/sunrpc/auth_gss/sunrpcgss_syms.c
--- ./net/sunrpc/auth_gss/sunrpcgss_syms.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/sunrpcgss_syms.c	2004-02-24 10:40:29.000000000 +1100
@@ -8,6 +8,7 @@
 #include <linux/unistd.h>
 
 #include <linux/sunrpc/auth_gss.h>
+#include <linux/sunrpc/svcauth_gss.h>
 #include <linux/sunrpc/gss_asn1.h>
 
 /* sec_triples: */
@@ -17,6 +18,7 @@ EXPORT_SYMBOL(gss_cmp_triples);
 EXPORT_SYMBOL(gss_pseudoflavor_to_mechOID);
 EXPORT_SYMBOL(gss_pseudoflavor_supported);
 EXPORT_SYMBOL(gss_pseudoflavor_to_service);
+EXPORT_SYMBOL(svcauth_gss_register_pseudoflavor);
 
 /* registering gss mechanisms to the mech switching code: */
 EXPORT_SYMBOL(gss_mech_register);

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2004-02-24 10:40:29.000000000 +1100
@@ -0,0 +1,885 @@
+/*
+ * Neil Brown <neilb@cse.unsw.edu.au>
+ * J. Bruce Fields <bfields@umich.edu>
+ * Andy Adamson <andros@umich.edu>
+ * Dug Song <dugsong@monkey.org>
+ * 
+ * RPCSEC_GSS server authentication.
+ * This implements RPCSEC_GSS as defined in rfc2203 (rpcsec_gss) and rfc2078
+ * (gssapi)
+ * 
+ * The RPCSEC_GSS involves three stages:
+ *  1/ context creation
+ *  2/ data exchange
+ *  3/ context destruction
+ *
+ * Context creation is handled largely by upcalls to user-space.
+ *  In particular, GSS_Accept_sec_context is handled by an upcall
+ * Data exchange is handled entirely within the kernel
+ *  In particular, GSS_GetMIC, GSS_VerifyMIC, GSS_Seal, GSS_Unseal are in-kernel.
+ * Context destruction is handled in-kernel
+ *  GSS_Delete_sec_context is in-kernel
+ *
+ * Context creation is initiated by a RPCSEC_GSS_INIT request arriving.
+ * The context handle and gss_token are used as a key into the rpcsec_init cache.
+ * The content of this cache includes some of the outputs of GSS_Accept_sec_context,
+ * being major_status, minor_status, context_handle, reply_token.
+ * These are sent back to the client.
+ * Sequence window management is handled by the kernel.  The window size if currently
+ * a compile time constant.
+ *
+ * When user-space is happy that a context is established, it places an entry
+ * in the rpcsec_context cache. The key for this cache is the context_handle.
+ * The content includes:
+ *   uid/gidlist - for determining access rights
+ *   mechanism type
+ *   mechanism specific information, such as a key
+ *
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/pagemap.h>
+
+#include <linux/sunrpc/auth_gss.h>
+#include <linux/sunrpc/svcauth.h>
+#include <linux/sunrpc/gss_err.h>
+#include <linux/sunrpc/svcauth.h>
+#include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/cache.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY	RPCDBG_AUTH
+#endif
+
+/* The rpcsec_init cache is used for mapping RPCSEC_GSS_{,CONT_}INIT requests
+ * into replies.
+ *
+ * Key is context handle (\x if empty) and gss_token.
+ * Content is major_status minor_status (integers) context_handle, reply_token.
+ *
+ */
+
+static int netobj_equal(struct xdr_netobj *a, struct xdr_netobj *b)
+{
+	return a->len == b->len && 0 == memcmp(a->data, b->data, a->len);
+}
+
+#define	RSI_HASHBITS	6
+#define	RSI_HASHMAX	(1<<RSI_HASHBITS)
+#define	RSI_HASHMASK	(RSI_HASHMAX-1)
+
+struct rsi {
+	struct cache_head	h;
+	struct xdr_netobj	in_handle, in_token;
+	struct xdr_netobj	out_handle, out_token;
+	int			major_status, minor_status;
+};
+
+static struct cache_head *rsi_table[RSI_HASHMAX];
+static struct cache_detail rsi_cache;
+static struct rsi *rsi_lookup(struct rsi *item, int set);
+
+static void rsi_free(struct rsi *rsii)
+{
+	kfree(rsii->in_handle.data);
+	kfree(rsii->in_token.data);
+	kfree(rsii->out_handle.data);
+	kfree(rsii->out_token.data);
+}
+
+static void rsi_put(struct cache_head *item, struct cache_detail *cd)
+{
+	struct rsi *rsii = container_of(item, struct rsi, h);
+	if (cache_put(item, cd)) {
+		rsi_free(rsii);
+		kfree(rsii);
+	}
+}
+
+static inline int rsi_hash(struct rsi *item)
+{
+	return hash_mem(item->in_handle.data, item->in_handle.len, RSI_HASHBITS)
+	     ^ hash_mem(item->in_token.data, item->in_token.len, RSI_HASHBITS);
+}
+
+static inline int rsi_match(struct rsi *item, struct rsi *tmp)
+{
+	return netobj_equal(&item->in_handle, &tmp->in_handle)
+		&& netobj_equal(&item->in_token, &tmp->in_token);
+}
+
+static int dup_to_netobj(struct xdr_netobj *dst, char *src, int len)
+{
+	dst->len = len;
+	dst->data = (len ? kmalloc(len, GFP_KERNEL) : NULL);
+	if (dst->data)
+		memcpy(dst->data, src, len);
+	if (len && !dst->data)
+		return -ENOMEM;
+	return 0;
+}
+
+static inline int dup_netobj(struct xdr_netobj *dst, struct xdr_netobj *src)
+{
+	return dup_to_netobj(dst, src->data, src->len);
+}
+
+static inline void rsi_init(struct rsi *new, struct rsi *item)
+{
+	new->out_handle.data = NULL;
+	new->out_handle.len = 0;
+	new->out_token.data = NULL;
+	new->out_token.len = 0;
+	new->in_handle.len = item->in_handle.len;
+	item->in_handle.len = 0;
+	new->in_token.len = item->in_token.len;
+	item->in_token.len = 0;
+	new->in_handle.data = item->in_handle.data;
+	item->in_handle.data = NULL;
+	new->in_token.data = item->in_token.data;
+	item->in_token.data = NULL;
+}
+
+static inline void rsi_update(struct rsi *new, struct rsi *item)
+{
+	BUG_ON(new->out_handle.data || new->out_token.data);
+	new->out_handle.len = item->out_handle.len;
+	item->out_handle.len = 0;
+	new->out_token.len = item->out_token.len;
+	item->out_token.len = 0;
+	new->out_handle.data = item->out_handle.data;
+	item->out_handle.data = NULL;
+	new->out_token.data = item->out_token.data;
+	item->out_token.data = NULL;
+
+	new->major_status = item->major_status;
+	new->minor_status = item->minor_status;
+}
+
+static void rsi_request(struct cache_detail *cd,
+                       struct cache_head *h,
+                       char **bpp, int *blen)
+{
+	struct rsi *rsii = container_of(h, struct rsi, h);
+
+	qword_addhex(bpp, blen, rsii->in_handle.data, rsii->in_handle.len);
+	qword_addhex(bpp, blen, rsii->in_token.data, rsii->in_token.len);
+	(*bpp)[-1] = '\n';
+}
+
+
+static int rsi_parse(struct cache_detail *cd,
+                    char *mesg, int mlen)
+{
+	/* context token expiry major minor context token */
+	char *buf = mesg;
+	char *ep;
+	int len;
+	struct rsi rsii, *rsip = NULL;
+	time_t expiry;
+	int status = -EINVAL;
+
+	memset(&rsii, 0, sizeof(rsii));
+	/* handle */
+	len = qword_get(&mesg, buf, mlen);
+	if (len < 0)
+		goto out;
+	status = -ENOMEM;
+	if (dup_to_netobj(&rsii.in_handle, buf, len))
+		goto out;
+
+	/* token */
+	len = qword_get(&mesg, buf, mlen);
+	status = -EINVAL;
+	if (len < 0)
+		goto out;;
+	status = -ENOMEM;
+	if (dup_to_netobj(&rsii.in_token, buf, len))
+		goto out;
+
+	rsii.h.flags = 0;
+	/* expiry */
+	expiry = get_expiry(&mesg);
+	status = -EINVAL;
+	if (expiry == 0)
+		goto out;
+
+	/* major/minor */
+	len = qword_get(&mesg, buf, mlen);
+	if (len < 0)
+		goto out;
+	if (len == 0) {
+		goto out;
+	} else {
+		rsii.major_status = simple_strtoul(buf, &ep, 10);
+		if (*ep)
+			goto out;
+		len = qword_get(&mesg, buf, mlen);
+		if (len <= 0)
+			goto out;
+		rsii.minor_status = simple_strtoul(buf, &ep, 10);
+		if (*ep)
+			goto out;
+
+		/* out_handle */
+		len = qword_get(&mesg, buf, mlen);
+		if (len < 0)
+			goto out;
+		status = -ENOMEM;
+		if (dup_to_netobj(&rsii.out_handle, buf, len))
+			goto out;
+
+		/* out_token */
+		len = qword_get(&mesg, buf, mlen);
+		status = -EINVAL;
+		if (len < 0)
+			goto out;
+		status = -ENOMEM;
+		if (dup_to_netobj(&rsii.out_token, buf, len))
+			goto out;
+	}
+	rsii.h.expiry_time = expiry;
+	rsip = rsi_lookup(&rsii, 1);
+	status = 0;
+out:
+	rsi_free(&rsii);
+	if (rsip)
+		rsi_put(&rsip->h, &rsi_cache);
+	return status;
+}
+
+static struct cache_detail rsi_cache = {
+	.hash_size	= RSI_HASHMAX,
+	.hash_table     = rsi_table,
+	.name           = "auth.rpcsec.init",
+	.cache_put      = rsi_put,
+	.cache_request  = rsi_request,
+	.cache_parse    = rsi_parse,
+};
+
+static DefineSimpleCacheLookup(rsi, 0)
+
+/*
+ * The rpcsec_context cache is used to store a context that is
+ * used in data exchange.
+ * The key is a context handle. The content is:
+ *  uid, gidlist, mechanism, service-set, mech-specific-data
+ */
+
+#define	RSC_HASHBITS	10
+#define	RSC_HASHMAX	(1<<RSC_HASHBITS)
+#define	RSC_HASHMASK	(RSC_HASHMAX-1)
+
+#define GSS_SEQ_WIN	128
+
+struct gss_svc_seq_data {
+	/* highest seq number seen so far: */
+	int			sd_max;
+	/* for i such that sd_max-GSS_SEQ_WIN < i <= sd_max, the i-th bit of
+	 * sd_win is nonzero iff sequence number i has been seen already: */
+	unsigned long		sd_win[GSS_SEQ_WIN/BITS_PER_LONG];
+	spinlock_t		sd_lock;
+};
+
+struct rsc {
+	struct cache_head	h;
+	struct xdr_netobj	handle;
+	struct svc_cred		cred;
+	struct gss_svc_seq_data	seqdata;
+	struct gss_ctx		*mechctx;
+};
+
+static struct cache_head *rsc_table[RSC_HASHMAX];
+static struct cache_detail rsc_cache;
+static struct rsc *rsc_lookup(struct rsc *item, int set);
+
+static void rsc_free(struct rsc *rsci)
+{
+	kfree(rsci->handle.data);
+	if (rsci->mechctx)
+		gss_delete_sec_context(&rsci->mechctx);
+}
+
+static void rsc_put(struct cache_head *item, struct cache_detail *cd)
+{
+	struct rsc *rsci = container_of(item, struct rsc, h);
+
+	if (cache_put(item, cd)) {
+		rsc_free(rsci);
+		kfree(rsci);
+	}
+}
+
+static inline int
+rsc_hash(struct rsc *rsci)
+{
+	return hash_mem(rsci->handle.data, rsci->handle.len, RSC_HASHBITS);
+}
+
+static inline int
+rsc_match(struct rsc *new, struct rsc *tmp)
+{
+	return netobj_equal(&new->handle, &tmp->handle);
+}
+
+static inline void
+rsc_init(struct rsc *new, struct rsc *tmp)
+{
+	new->handle.len = tmp->handle.len;
+	tmp->handle.len = 0;
+	new->handle.data = tmp->handle.data;
+	tmp->handle.data = NULL;
+	new->mechctx = NULL;
+}
+
+static inline void
+rsc_update(struct rsc *new, struct rsc *tmp)
+{
+	new->mechctx = tmp->mechctx;
+	tmp->mechctx = NULL;
+	memset(&new->seqdata, 0, sizeof(new->seqdata));
+	spin_lock_init(&new->seqdata.sd_lock);
+	new->cred = tmp->cred;
+}
+
+static int rsc_parse(struct cache_detail *cd,
+		     char *mesg, int mlen)
+{
+	/* contexthandle expiry [ uid gid N <n gids> mechname ...mechdata... ] */
+	char *buf = mesg;
+	int len, rv;
+	struct rsc rsci, *rscp = NULL;
+	time_t expiry;
+	int status = -EINVAL;
+
+	memset(&rsci, 0, sizeof(rsci));
+	/* context handle */
+	len = qword_get(&mesg, buf, mlen);
+	if (len < 0) goto out;
+	status = -ENOMEM;
+	if (dup_to_netobj(&rsci.handle, buf, len))
+		goto out;
+
+	rsci.h.flags = 0;
+	/* expiry */
+	expiry = get_expiry(&mesg);
+	status = -EINVAL;
+	if (expiry == 0)
+		goto out;
+
+	/* uid, or NEGATIVE */
+	rv = get_int(&mesg, &rsci.cred.cr_uid);
+	if (rv == -EINVAL)
+		goto out;
+	if (rv == -ENOENT)
+		set_bit(CACHE_NEGATIVE, &rsci.h.flags);
+	else {
+		int N, i;
+		struct gss_api_mech *gm;
+		struct xdr_netobj tmp_buf;
+
+		/* gid */
+		if (get_int(&mesg, &rsci.cred.cr_gid))
+			goto out;
+
+		/* number of additional gid's */
+		if (get_int(&mesg, &N))
+			goto out;
+		if (N > NGROUPS)
+			goto out;
+
+		/* gid's */
+		for (i=0; i<N; i++) {
+			if (get_int(&mesg, &rsci.cred.cr_groups[i]))
+				goto out;
+		}
+		if (N < NGROUPS)
+			rsci.cred.cr_groups[N] = NOGROUP;
+
+		/* mech name */
+		len = qword_get(&mesg, buf, mlen);
+		if (len < 0)
+			goto out;
+		gm = gss_mech_get_by_name(buf);
+
+		/* mech-specific data: */
+		len = qword_get(&mesg, buf, mlen);
+		if (len < 0) {
+			gss_mech_put(gm);
+			goto out;
+		}
+		tmp_buf.len = len;
+		tmp_buf.data = buf;
+		if (gss_import_sec_context(&tmp_buf, gm, &rsci.mechctx)) {
+			gss_mech_put(gm);
+			goto out;
+		}
+		gss_mech_put(gm);
+	}
+	rsci.h.expiry_time = expiry;
+	rscp = rsc_lookup(&rsci, 1);
+	status = 0;
+out:
+	rsc_free(&rsci);
+	if (rscp)
+		rsc_put(&rscp->h, &rsc_cache);
+	return status;
+}
+
+static struct cache_detail rsc_cache = {
+	.hash_size	= RSC_HASHMAX,
+	.hash_table	= rsc_table,
+	.name		= "auth.rpcsec.context",
+	.cache_put	= rsc_put,
+	.cache_parse	= rsc_parse,
+};
+
+static DefineSimpleCacheLookup(rsc, 0);
+
+struct rsc *
+gss_svc_searchbyctx(struct xdr_netobj *handle)
+{
+	struct rsc rsci;
+	struct rsc *found;
+
+	rsci.handle = *handle;
+	found = rsc_lookup(&rsci, 0);
+	if (!found)
+		return NULL;
+	if (cache_check(&rsc_cache, &found->h, NULL))
+		return NULL;
+	return found;
+}
+
+/* Implements sequence number algorithm as specified in RFC 2203. */
+static int
+gss_check_seq_num(struct rsc *rsci, int seq_num)
+{
+	struct gss_svc_seq_data *sd = &rsci->seqdata;
+
+	spin_lock(&sd->sd_lock);
+	if (seq_num > sd->sd_max) {
+		if (seq_num >= sd->sd_max + GSS_SEQ_WIN) {
+			memset(sd->sd_win,0,sizeof(sd->sd_win));
+			sd->sd_max = seq_num;
+		} else while (sd->sd_max < seq_num) {
+			sd->sd_max++;
+			__clear_bit(sd->sd_max % GSS_SEQ_WIN, sd->sd_win);
+		}
+		__set_bit(seq_num % GSS_SEQ_WIN, sd->sd_win);
+		goto ok;
+	} else if (seq_num <= sd->sd_max - GSS_SEQ_WIN) {
+		goto drop;
+	}
+	/* sd_max - GSS_SEQ_WIN < seq_num <= sd_max */
+	if (__test_and_set_bit(seq_num % GSS_SEQ_WIN, sd->sd_win))
+		goto drop;
+ok:
+	spin_unlock(&sd->sd_lock);
+	return 1;
+drop:
+	spin_unlock(&sd->sd_lock);
+	return 0;
+}
+
+static inline u32 round_up_to_quad(u32 i)
+{
+	return (i + 3 ) & ~3;
+}
+
+static inline int
+svc_safe_getnetobj(struct iovec *argv, struct xdr_netobj *o)
+{
+	int l;
+
+	if (argv->iov_len < 4)
+		return -1;
+	o->len = ntohl(svc_getu32(argv));
+	l = round_up_to_quad(o->len);
+	if (argv->iov_len < l)
+		return -1;
+	o->data = argv->iov_base;
+	argv->iov_base += l;
+	argv->iov_len -= l;
+	return 0;
+}
+
+static inline int
+svc_safe_putnetobj(struct iovec *resv, struct xdr_netobj *o)
+{
+	u32 *p;
+
+	if (resv->iov_len + 4 > PAGE_SIZE)
+		return -1;
+	svc_putu32(resv, htonl(o->len));
+	p = resv->iov_base + resv->iov_len;
+	resv->iov_len += round_up_to_quad(o->len);
+	if (resv->iov_len > PAGE_SIZE)
+		return -1;
+	memcpy(p, o->data, o->len);
+	memset((u8 *)p + o->len, 0, round_up_to_quad(o->len) - o->len);
+	return 0;
+}
+
+/* Verify the checksum on the header and return SVC_OK on success.
+ * Otherwise, return SVC_DROP (in the case of a bad sequence number)
+ * or return SVC_DENIED and indicate error in authp.
+ */
+static int
+gss_verify_header(struct svc_rqst *rqstp, struct rsc *rsci,
+		  u32 *rpcstart, struct rpc_gss_wire_cred *gc, u32 *authp)
+{
+	struct gss_ctx		*ctx_id = rsci->mechctx;
+	struct xdr_netobj	rpchdr;
+	struct xdr_netobj	checksum;
+	u32			flavor = 0;
+	struct iovec		*argv = &rqstp->rq_arg.head[0];
+
+	/* data to compute the checksum over: */
+	rpchdr.data = (u8 *)rpcstart;
+	rpchdr.len = (u8 *)argv->iov_base - (u8 *)rpcstart;
+
+	*authp = rpc_autherr_badverf;
+	if (argv->iov_len < 4)
+		return SVC_DENIED;
+	flavor = ntohl(svc_getu32(argv));
+	if (flavor != RPC_AUTH_GSS)
+		return SVC_DENIED;
+	if (svc_safe_getnetobj(argv, &checksum))
+		return SVC_DENIED;
+
+	if (rqstp->rq_deferred) /* skip verification of revisited request */
+		return SVC_OK;
+	if (gss_verify_mic(ctx_id, &rpchdr, &checksum, NULL)
+							!= GSS_S_COMPLETE) {
+		*authp = rpcsec_gsserr_credproblem;
+		return SVC_DENIED;
+	}
+
+	if (gc->gc_seq > MAXSEQ) {
+		dprintk("svcauth_gss: discarding request with large"
+			" sequence number %d\n", gc->gc_seq);
+		*authp = rpcsec_gsserr_ctxproblem;
+		return SVC_DENIED;
+	}
+	if (!gss_check_seq_num(rsci, gc->gc_seq)) {
+		dprintk("svcauth_gss: discarding request with old"
+				" sequence number %d\n", gc->gc_seq);
+		return SVC_DROP;
+	}
+	return SVC_OK;
+}
+
+static int
+gss_write_verf(struct svc_rqst *rqstp, struct gss_ctx *ctx_id, u32 seq)
+{
+	u32			xdr_seq;
+	u32			maj_stat;
+	struct xdr_netobj	verf_data;
+	struct xdr_netobj	mic;
+	u32			*p;
+
+	svc_putu32(rqstp->rq_res.head, htonl(RPC_AUTH_GSS));
+	xdr_seq = htonl(seq);
+
+	verf_data.data = (u8 *)&xdr_seq;
+	verf_data.len = sizeof(xdr_seq);
+	p = rqstp->rq_res.head->iov_base + rqstp->rq_res.head->iov_len;
+	maj_stat = gss_get_mic(ctx_id, 0, &verf_data, &mic);
+	if (maj_stat != GSS_S_COMPLETE)
+		return -1;
+	p = xdr_encode_netobj(rqstp->rq_res.head->iov_base
+				+ rqstp->rq_res.head->iov_len, &mic);
+	kfree(mic.data);
+	if (!xdr_ressize_check(rqstp, p))
+		return -1;
+	return 0;
+}
+
+struct gss_domain {
+	struct auth_domain	h;
+	u32			pseudoflavor;
+};
+
+/* XXX this should be done in gss_pseudoflavors, and shouldn't be hardcoded: */
+static struct auth_domain *
+find_gss_auth_domain(struct gss_ctx *ctx, u32 svc)
+{
+	switch(gss_get_pseudoflavor(ctx, 0, svc)) {
+		case RPC_AUTH_GSS_KRB5:
+			return auth_domain_find("gss/krb5");
+		case RPC_AUTH_GSS_KRB5I:
+			return auth_domain_find("gss/krb5i");
+		case RPC_AUTH_GSS_KRB5P:
+			return auth_domain_find("gss/krb5p");
+	}
+	return NULL;
+}
+
+int
+svcauth_gss_register_pseudoflavor(u32 pseudoflavor, char * name)
+{
+	struct gss_domain	*new;
+	struct auth_domain	*test;
+	static char		*prefix = "gss/";
+	int			stat = -1;
+
+	new = kmalloc(sizeof(*new), GFP_KERNEL);
+	if (!new)
+		goto out;
+	cache_init(&new->h.h);
+	atomic_inc(&new->h.h.refcnt);
+	new->h.name = kmalloc(strlen(name) + strlen(prefix) + 1, GFP_KERNEL);
+	if (!new->h.name)
+		goto out_free_dom;
+	strcpy(new->h.name, prefix);
+	strcat(new->h.name, name);
+	new->h.flavour = RPC_AUTH_GSS;
+	new->pseudoflavor = pseudoflavor;
+	new->h.h.expiry_time = NEVER;
+	new->h.h.flags = 0;
+
+	test = auth_domain_lookup(&new->h, 1);
+	if (test == &new->h) {
+		BUG_ON(atomic_dec_and_test(&new->h.h.refcnt));
+	} else { /* XXX Duplicate registration? */
+		auth_domain_put(&new->h);
+		goto out;
+	}
+	return 0;
+
+out_free_dom:
+	kfree(new);
+out:
+	return stat;
+}
+
+/*
+ * Accept an rpcsec packet.
+ * If context establishment, punt to user space
+ * If data exchange, verify/decrypt
+ * If context destruction, handle here
+ * In the context establishment and destruction case we encode
+ * response here and return SVC_COMPLETE.
+ */
+static int
+svcauth_gss_accept(struct svc_rqst *rqstp, u32 *authp)
+{
+	struct iovec	*argv = &rqstp->rq_arg.head[0];
+	struct iovec	*resv = &rqstp->rq_res.head[0];
+	u32		crlen;
+	struct xdr_netobj tmpobj;
+	struct gss_svc_data *svcdata = rqstp->rq_auth_data;
+	struct rpc_gss_wire_cred *gc;
+	struct rsc	*rsci = NULL;
+	struct rsi	*rsip, rsikey;
+	u32		*rpcstart;
+	u32		*reject_stat = resv->iov_base;
+	int		ret;
+
+	dprintk("RPC: svcauth_gss: argv->iov_len = %d\n",argv->iov_len);
+
+	*authp = rpc_autherr_badcred;
+	if (!svcdata)
+		svcdata = kmalloc(sizeof(*svcdata), GFP_KERNEL);
+	if (!svcdata)
+		goto auth_err;
+	rqstp->rq_auth_data = svcdata;
+	gc = &svcdata->clcred;
+	
+	/* start of rpc packet is 7 u32's back from here:
+	 * xid direction rpcversion prog vers proc flavour
+	 */
+	rpcstart = argv->iov_base;
+	rpcstart -= 7;
+
+	/* credential is:
+	 *   version(==1), proc(0,1,2,3), seq, service (1,2,3), handle
+	 * at least 5 u32s, and is preceeded by length, so that makes 6.
+	 */
+
+	if (argv->iov_len < 5 * 4)
+		goto auth_err;
+	crlen = ntohl(svc_getu32(argv));
+	if (ntohl(svc_getu32(argv)) != RPC_GSS_VERSION)
+		goto auth_err;
+	gc->gc_proc = ntohl(svc_getu32(argv));
+	gc->gc_seq = ntohl(svc_getu32(argv));
+	gc->gc_svc = ntohl(svc_getu32(argv));
+	if (svc_safe_getnetobj(argv, &gc->gc_ctx))
+		goto auth_err;
+	if (crlen != round_up_to_quad(gc->gc_ctx.len) + 5 * 4)
+		goto auth_err;
+
+	if ((gc->gc_proc != RPC_GSS_PROC_DATA) && (rqstp->rq_proc != 0))
+		goto auth_err;
+
+	/*
+	 * We've successfully parsed the credential. Let's check out the
+	 * verifier.  An AUTH_NULL verifier is allowed (and required) for
+	 * INIT and CONTINUE_INIT requests. AUTH_RPCSEC_GSS is required for
+	 * PROC_DATA and PROC_DESTROY.
+	 *
+	 * AUTH_NULL verifier is 0 (AUTH_NULL), 0 (length).
+	 * AUTH_RPCSEC_GSS verifier is:
+	 *   6 (AUTH_RPCSEC_GSS), length, checksum.
+	 * checksum is calculated over rpcheader from xid up to here.
+	 */
+	*authp = rpc_autherr_badverf;
+	switch (gc->gc_proc) {
+	case RPC_GSS_PROC_INIT:
+	case RPC_GSS_PROC_CONTINUE_INIT:
+		if (argv->iov_len < 2 * 4)
+			goto auth_err;
+		if (ntohl(svc_getu32(argv)) != RPC_AUTH_NULL)
+			goto auth_err;
+		if (ntohl(svc_getu32(argv)) != 0)
+			goto auth_err;
+		break;
+	case RPC_GSS_PROC_DATA:
+	case RPC_GSS_PROC_DESTROY:
+		/* integrity and privacy unsupported: */
+		if (gc->gc_svc != RPC_GSS_SVC_NONE)
+			goto auth_err;
+		*authp = rpcsec_gsserr_credproblem;
+		rsci = gss_svc_searchbyctx(&gc->gc_ctx);
+		if (!rsci)
+			goto auth_err;
+		switch (gss_verify_header(rqstp, rsci, rpcstart, gc, authp)) {
+		case SVC_OK:
+			break;
+		case SVC_DENIED:
+			goto auth_err;
+		case SVC_DROP:
+			goto drop;
+		}
+		break;
+	default:
+		*authp = rpc_autherr_rejectedcred;
+		goto auth_err;
+	}
+
+	/* now act upon the command: */
+	switch (gc->gc_proc) {
+	case RPC_GSS_PROC_INIT:
+	case RPC_GSS_PROC_CONTINUE_INIT:
+		*authp = rpc_autherr_badcred;
+		if (gc->gc_proc == RPC_GSS_PROC_INIT && gc->gc_ctx.len != 0)
+			goto auth_err;
+		memset(&rsikey, 0, sizeof(rsikey));
+		if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
+			goto drop;
+		*authp = rpc_autherr_badverf;
+		if (svc_safe_getnetobj(argv, &tmpobj)) {
+			kfree(rsikey.in_handle.data);
+			goto auth_err;
+		}
+		if (dup_netobj(&rsikey.in_token, &tmpobj)) {
+			kfree(rsikey.in_handle.data);
+			goto drop;
+		}
+
+		rsip = rsi_lookup(&rsikey, 0);
+		rsi_free(&rsikey);
+		if (!rsip) {
+			goto drop;
+		}
+		switch(cache_check(&rsi_cache, &rsip->h, &rqstp->rq_chandle)) {
+		case -EAGAIN:
+			goto drop;
+		case -ENOENT:
+			goto drop;
+		case 0:
+			rsci = gss_svc_searchbyctx(&rsip->out_handle);
+			if (!rsci) {
+				goto drop;
+			}
+			if (gss_write_verf(rqstp, rsci->mechctx, GSS_SEQ_WIN))
+				goto drop;
+			if (resv->iov_len + 4 > PAGE_SIZE)
+				goto drop;
+			svc_putu32(resv, rpc_success);
+			if (svc_safe_putnetobj(resv, &rsip->out_handle))
+				goto drop;
+			if (resv->iov_len + 3 * 4 > PAGE_SIZE)
+				goto drop;
+			svc_putu32(resv, htonl(rsip->major_status));
+			svc_putu32(resv, htonl(rsip->minor_status));
+			svc_putu32(resv, htonl(GSS_SEQ_WIN));
+			if (svc_safe_putnetobj(resv, &rsip->out_token))
+				goto drop;
+			rqstp->rq_client = NULL;
+		}
+		goto complete;
+	case RPC_GSS_PROC_DESTROY:
+		set_bit(CACHE_NEGATIVE, &rsci->h.flags);
+		if (resv->iov_len + 4 > PAGE_SIZE)
+			goto drop;
+		svc_putu32(resv, rpc_success);
+		goto complete;
+	case RPC_GSS_PROC_DATA:
+		rqstp->rq_client =
+			find_gss_auth_domain(rsci->mechctx, gc->gc_svc);
+		if (rqstp->rq_client == NULL)
+			goto auth_err;
+		*authp = rpcsec_gsserr_ctxproblem;
+		if (gss_write_verf(rqstp, rsci->mechctx, gc->gc_seq))
+			goto auth_err;
+		/* For use when wrapping: */
+		svcdata->body_start = resv->iov_base + 1;
+		rqstp->rq_cred = rsci->cred;
+		ret = SVC_OK;
+		goto out;
+	}
+auth_err:
+	/* Restore write pointer to original value: */
+	xdr_ressize_check(rqstp, reject_stat);
+	ret = SVC_DENIED;
+	goto out;
+complete:
+	ret = SVC_COMPLETE;
+	goto out;
+drop:
+	ret = SVC_DROP;
+out:
+	if (rsci)
+		rsc_put(&rsci->h, &rsc_cache);
+	return ret;
+}
+
+static int
+svcauth_gss_release(struct svc_rqst *rqstp)
+{
+	if (rqstp->rq_client)
+		auth_domain_put(rqstp->rq_client);
+	rqstp->rq_client = NULL;
+
+	return 0;
+}
+
+static void
+svcauth_gss_domain_release(struct auth_domain *dom)
+{
+	struct gss_domain *gd = container_of(dom, struct gss_domain, h);
+
+	kfree(dom->name);
+	kfree(gd);
+}
+
+struct auth_ops svcauthops_gss = {
+	.name		= "rpcsec_gss",
+	.flavour	= RPC_AUTH_GSS,
+	.accept		= svcauth_gss_accept,
+	.release	= svcauth_gss_release,
+	.domain_release = svcauth_gss_domain_release,
+};
+
+int
+gss_svc_init(void)
+{
+	cache_register(&rsc_cache);
+	cache_register(&rsi_cache);
+	svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
+	return 0;
+}

diff ./net/sunrpc/sunrpc_syms.c~current~ ./net/sunrpc/sunrpc_syms.c
--- ./net/sunrpc/sunrpc_syms.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/sunrpc_syms.c	2004-02-24 10:40:29.000000000 +1100
@@ -85,6 +85,8 @@ EXPORT_SYMBOL(svc_recv);
 EXPORT_SYMBOL(svc_wake_up);
 EXPORT_SYMBOL(svc_makesock);
 EXPORT_SYMBOL(svc_reserve);
+EXPORT_SYMBOL(svc_auth_register);
+EXPORT_SYMBOL(auth_domain_lookup);
 
 /* RPC statistics */
 #ifdef CONFIG_PROC_FS

diff ./net/sunrpc/svc.c~current~ ./net/sunrpc/svc.c
--- ./net/sunrpc/svc.c~current~	2004-02-24 10:40:23.000000000 +1100
+++ ./net/sunrpc/svc.c	2004-02-24 10:40:29.000000000 +1100
@@ -200,6 +200,8 @@ svc_exit_thread(struct svc_rqst *rqstp)
 		kfree(rqstp->rq_resp);
 	if (rqstp->rq_argp)
 		kfree(rqstp->rq_argp);
+	if (rqstp->rq_auth_data)
+		kfree(rqstp->rq_auth_data);
 	kfree(rqstp);
 
 	/* Release the server */
@@ -322,6 +324,8 @@ svc_process(struct svc_serv *serv, struc
 		goto err_bad_auth;
 	case SVC_DROP:
 		goto dropit;
+	case SVC_COMPLETE:
+		goto sendit;
 	}
 		
 	progp = serv->sv_program;


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
