From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Kerberos 5 security framework for RPCSEC_GSS
Date: Thu, 31 Oct 2002 22:14:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.40224.656565.713815@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Mdq-0004Z1-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 13:14:14 -0800
To: Linus Torvalds <torvalds@transmeta.com>,
    NFS maillist <nfs@lists.sourceforge.net>,nfsv4-wg@citi.umich.edu
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The following patch applys on top of the RPCSEC_GSS patches, and adds
the client side framework needed in order to authenticate users to
servers running NFSv2, NFSv3, or NFSv4 with RPCSEC_GSS + Kerberos 5.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/fs/Kconfig linux-2.5.45-08-krb5/fs/Kconfig
--- linux-2.5.45-07-auth_upcall2/fs/Kconfig	2002-10-31 12:44:13.000000000 -0500
+++ linux-2.5.45-08-krb5/fs/Kconfig	2002-10-31 15:45:10.000000000 -0500
@@ -1266,6 +1266,10 @@
 	tristate "Provide RPCSEC_GSS authentication (EXPERIMENTAL)"
 	depends on SUNRPC && EXPERIMENTAL
 
+config RPCSEC_GSS_KRB5
+	tristate "Kerberos mechanism for RPCSEC_GSS (EXPERIMENTAL)"
+	depends on SUNRPC_GSS
+
 config LOCKD
 	tristate
 	default m if NFS_FS!=y && NFSD!=y && (NFS_FS=m || NFSD=m)
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/include/linux/sunrpc/gss_krb5_types.h linux-2.5.45-08-krb5/include/linux/sunrpc/gss_krb5_types.h
--- linux-2.5.45-07-auth_upcall2/include/linux/sunrpc/gss_krb5_types.h	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/include/linux/sunrpc/gss_krb5_types.h	2002-10-31 15:50:28.000000000 -0500
@@ -0,0 +1,383 @@
+/*
+ *  linux/include/linux/sunrpc/gss_krb5_types.h
+ *
+ *  krb5 types mapped to linux kernel types
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/include/krb5.h,
+ *  lib/gssapi/krb5/gssapiP_krb5.h, and others
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright 1995 by the Massachusetts Institute of Technology.
+ * All Rights Reserved.
+ *
+ * Export of this software from the United States of America may
+ *   require a specific license from the United States Government.
+ *   It is the responsibility of any person or organization contemplating
+ *   export to obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of M.I.T. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  Furthermore if you modify this software you must label
+ * your software as modified software and not distribute it in such a
+ * fashion that it might be confused with the original M.I.T. software.
+ * M.I.T. makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ */
+
+
+#include <linux/sunrpc/auth_gss.h>
+#include <linux/sunrpc/gss_err.h>
+#include <linux/sunrpc/gss_asn1.h>
+
+typedef struct _krb5_data {
+	s32 magic;
+	int length;
+	char *data;
+} krb5_data;
+
+/* krb5 principal (krb5.h) */
+typedef struct krb5_principal_data {
+	s32 magic;
+	krb5_data realm;
+	krb5_data *data;	/* An array of strings */
+	s32 length;
+	s32 type;
+} krb5_principal_data;
+
+typedef krb5_principal_data *krb5_principal;
+
+/* krb5 keyblock */
+
+typedef struct _krb5_keyblock {
+	s32 magic;
+	s32 enctype;
+	int length;
+	unsigned char *contents;
+} krb5_keyblock;
+
+struct krb5_keyhash_provider {
+	void (*hash_size)
+	 (size_t * output);
+
+	 s32(*hash)
+	 (krb5_keyblock * key, krb5_data * ivec,
+	  krb5_data * input, krb5_data * output);
+
+	 s32(*verify)
+	 (krb5_keyblock * key, krb5_data * ivec,
+	  krb5_data * input, krb5_data * hash, unsigned int *valid);
+};
+
+struct krb5_hash_provider {
+	void (*hash_size)
+	 (size_t * output);
+
+	void (*block_size)
+	 (size_t * output);
+
+	/* this takes multiple inputs to avoid lots of copying. */
+	 s32(*hash)
+	 (unsigned int icount, krb5_data * input, krb5_data * output);
+};
+
+typedef struct _krb5_2_linux_digest {
+	s32 ctype;
+	char *digest_name;
+	struct krb5_hash_provider *hash;
+	struct krb5_keyhash_provider *keyhash;
+} krb5_2_linux_digest;
+
+typedef struct _krb5_2_linux_keytypes {
+	s32 enctype;
+	char *seal_name;
+	unsigned int seal_mode;
+	char *sign_name;
+} krb5_2_linux_keytypes;
+
+/* structure for address */
+typedef struct _krb5_address {
+	s32 magic;
+	s32 addrtype;
+	int length;
+	unsigned char *contents;
+} krb5_address;
+
+/* structure for auth data */
+typedef struct _krb5_authdata {
+	s32 magic;
+	s32 ad_type;
+	int length;
+	unsigned char *contents;
+} krb5_authdata;
+
+typedef struct _krb5_checksum {
+	s32 magic;
+	s32 checksum_type;	/* checksum type */
+	int length;
+	unsigned char *contents;
+} krb5_checksum;
+
+
+/* the unencrypted version */
+typedef struct _krb5_authenticator {
+	s32 magic;
+	krb5_principal client;	/* client name/realm */
+	krb5_checksum *checksum;	/* checksum, includes type, optional */
+	s32 cusec;		/* client usec portion */
+	s32 ctime;		/* client sec portion */
+	krb5_keyblock *subkey;	/* true session key, optional */
+	s32 seq_number;		/* sequence #, optional */
+	krb5_authdata **authorization_data;	/* New add by Ari, auth data */
+} krb5_authenticator;
+
+
+typedef struct krb5_rc_st {
+	s32 magic;
+	struct _krb5_rc_ops *ops;
+	void *data;
+} *krb5_rcache;
+
+
+/* from auth_con.h */
+struct _krb5_auth_context {
+	s32 magic;
+	krb5_address *remote_addr;
+	krb5_address *remote_port;
+	krb5_address *local_addr;
+	krb5_address *local_port;
+	krb5_keyblock *keyblock;
+	krb5_keyblock *local_subkey;
+	krb5_keyblock *remote_subkey;
+
+	s32 auth_context_flags;
+	s32 remote_seq_number;
+	s32 local_seq_number;
+	krb5_authenticator *authentp;	/* mk_req, rd_req, mk_rep, ... */
+	s32 req_cksumtype;	/* mk_safe, ... */
+	s32 safe_cksumtype;	/* mk_safe, ... */
+	void *i_vector;		/* mk_priv, rd_priv only */
+	krb5_rcache rcache;
+	s32 *permitted_etypes;	/* rd_req */
+};
+typedef struct _krb5_auth_context *krb5_auth_context;
+
+
+/* the krb5 gss context that is stored in userland */
+typedef struct _krb5_gss_ctx_id_rec {
+	int initiate;		/* nonzero if initiating, zero if accepting */
+	u32 gss_flags;
+	int seed_init;
+	unsigned char seed[16];
+	krb5_principal here;
+	krb5_principal there;
+	krb5_keyblock *subkey;
+	int signalg;
+	int cksum_size;
+	int sealalg;
+	krb5_keyblock *enc;
+	krb5_keyblock *seq;
+	s32 endtime;
+	s32 krb_flags;
+	/* XXX these used to be signed.  the old spec is inspecific, and
+	   the new spec specifies unsigned.  I don't believe that the change
+	   affects the wire encoding. */
+	u32 seq_send;
+	u32 seq_recv;
+	int big_endian;
+	krb5_auth_context auth_context;
+	GSS_OID *mech_used;
+	int nctypes;
+	s32 *ctypes;
+} krb5_gss_ctx_id_rec, *krb5_gss_ctx_id_t;
+
+#define KG_TOK_SIGN_MSG   0x0101
+#define KG_TOK_SEAL_MSG   0x0201
+#define KG_TOK_MIC_MSG    0x0101
+#define KG_TOK_WRAP_MSG   0x0201
+
+enum sgn_alg {
+	SGN_ALG_DES_MAC_MD5 = 0x0000,
+	SGN_ALG_MD2_5 = 0x0001,
+	SGN_ALG_DES_MAC = 0x0002,
+	SGN_ALG_3 = 0x0003,	/* not published */
+	SGN_ALG_HMAC_MD5 = 0x0011,	/* microsoft w2k; no support */
+	SGN_ALG_HMAC_SHA1_DES3_KD = 0x0004
+};
+enum seal_alg {
+	SEAL_ALG_NONE = 0xffff,
+	SEAL_ALG_DES = 0x0000,
+	SEAL_ALG_1 = 0x0001,	/* not published */
+	SEAL_ALG_MICROSOFT_RC4 = 0x0010,	/* microsoft w2k; no support */
+	SEAL_ALG_DES3KD = 0x0002
+};
+
+#define RSA_MD5_CKSUM_LENGTH 16
+
+/* rsa-md4-des-k */
+#define CKSUMTYPE_RSA_MD5 0x0007
+#define CKSUMTYPE_RSA_MD5_DES 0x0008
+#define CKSUMTYPE_NIST_SHA  0x0009
+#define CKSUMTYPE_HMAC_SHA1_DES3  0x000c
+
+#define KG_USAGE_SEAL 22
+#define KG_USAGE_SIGN 23
+#define KG_USAGE_SEQ  24
+
+/* from gssapi_err_krb5.h */
+#define KG_CCACHE_NOMATCH                        (39756032L)
+#define KG_KEYTAB_NOMATCH                        (39756033L)
+#define KG_TGT_MISSING                           (39756034L)
+#define KG_NO_SUBKEY                             (39756035L)
+#define KG_CONTEXT_ESTABLISHED                   (39756036L)
+#define KG_BAD_SIGN_TYPE                         (39756037L)
+#define KG_BAD_LENGTH                            (39756038L)
+#define KG_CTX_INCOMPLETE                        (39756039L)
+#define KG_CONTEXT                               (39756040L)
+#define KG_CRED                                  (39756041L)
+#define KG_ENC_DESC                              (39756042L)
+#define KG_BAD_SEQ                               (39756043L)
+#define KG_EMPTY_CCACHE                          (39756044L)
+#define KG_NO_CTYPES                             (39756045L)
+
+#define KV5M_PRINCIPAL                           (-1760647423L)
+#define KV5M_KEYBLOCK                            (-1760647421L)
+#define KV5M_CHECKSUM                            (-1760647420L)
+#define KV5M_ADDRESS                             (-1760647390L)
+#define KV5M_AUTHENTICATOR                       (-1760647410L)
+#define KV5M_AUTH_CONTEXT                        (-1760647383L)
+#define KV5M_AUTHDATA                            (-1760647414L)
+#define KV5M_GSS_OID                             (-1760647372L)
+#define KV5M_GSS_QUEUE                           (-1760647371L)
+
+#define krb5_princ_realm(context, princ) (&(princ)->realm)
+#define krb5_princ_size(context, princ) (princ)->length
+#define krb5_princ_component(context, princ,i) ((princ)->data + i)
+
+ /* per Kerberos v5 protocol spec crypto types from the wire. 
+  * these get mapped to linux kernel crypto routines.  
+  */
+#define ENCTYPE_NULL            0x0000
+#define ENCTYPE_DES_CBC_CRC     0x0001	/* DES cbc mode with CRC-32 */
+#define ENCTYPE_DES_CBC_MD4     0x0002	/* DES cbc mode with RSA-MD4 */
+#define ENCTYPE_DES_CBC_MD5     0x0003	/* DES cbc mode with RSA-MD5 */
+#define ENCTYPE_DES_CBC_RAW     0x0004	/* DES cbc mode raw */
+/* XXX deprecated? */
+#define ENCTYPE_DES3_CBC_SHA    0x0005	/* DES-3 cbc mode with NIST-SHA */
+#define ENCTYPE_DES3_CBC_RAW    0x0006	/* DES-3 cbc mode raw */
+#define ENCTYPE_DES_HMAC_SHA1   0x0008
+#define ENCTYPE_DES3_CBC_SHA1   0x0010
+#define ENCTYPE_UNKNOWN         0x01ff
+/* local crud */
+/* marc's DES-3 with 32-bit length */
+#define ENCTYPE_LOCAL_DES3_HMAC_SHA1 0x7007
+
+#define CKSUMTYPE_CRC32         0x0001
+#define CKSUMTYPE_RSA_MD4       0x0002
+#define CKSUMTYPE_RSA_MD4_DES   0x0003
+#define CKSUMTYPE_DESCBC        0x0004
+/* des-mac-k */
+/* rsa-md4-des-k */
+
+s32
+krb5_ser_pack_bytes(unsigned char *ostring,
+		    size_t osize, unsigned char **bufp, size_t * remainp);
+
+s32
+krb5_ser_unpack_bytes(unsigned char *istring,
+		      size_t isize,
+		      unsigned char **bufp, size_t * remainp);
+
+s32 krb5_ser_pack_int32(s32 iarg, unsigned char **bufp, size_t * remainp);
+
+s32
+krb5_ser_unpack_int32(s32 * intp, unsigned char **bufp, size_t * remainp);
+
+u32
+g_queue_internalize(void **vqueue,
+		    unsigned char **buf, size_t * lenremain);
+
+s32 krb5_principal_skip(unsigned char **buffer, size_t * lenremain);
+
+s32 krb5_principal_size(void *arg, size_t * sizep);
+
+s32 krb5_keyblock_size(void *arg, size_t * sizep);
+
+s32
+krb5_keyblock_internalize(void **argp,
+			  unsigned char **buffer, size_t * lenremain);
+
+void krb5_free_keyblock(register krb5_keyblock * key);
+
+s32
+kg_oid_internalize(void **argp,
+		   unsigned char **buffer, size_t * lenremain);
+
+s32
+kg_queue_internalize(void **argp,
+		     unsigned char **buffer, size_t * lenremain);
+
+s32
+kg_ctx_internalize(void **argp,
+		   unsigned char **buffer, size_t * lenremain);
+
+void print_krb5_gss_ctx_id_rec(krb5_gss_ctx_id_t ctx);
+
+u32
+k5_gss_import_sec_context(GSS_BUFFER_T * inbuf, void **ctx_handle);
+
+int k5_get_blocksize(s32 enctype, size_t * blocksize);
+
+int k5_get_checksum_length(s32 cksmtype, size_t * length);
+
+int find_digest(s32 type);
+
+int find_enctype(s32 enctype);
+
+s32
+krb5_c_make_checksum(s32 cksumtype,
+		     krb5_keyblock * key,
+		     s32 usage, krb5_data * input, krb5_checksum * cksum);
+
+u32
+kg_seal(GSS_CTX_ID_T context_handle,
+	int conf_req_flag,
+	int qop_req,
+	GSS_BUFFER_T * input_message_buffer,
+	int *conf_state,
+	GSS_BUFFER_T * output_message_buffer, int toktype);
+
+u32
+kg_unseal(GSS_CTX_ID_T context_handle,
+	  GSS_BUFFER_T * input_token_buffer,
+	  GSS_BUFFER_T * message_buffer,
+	  int *conf_state, int *qop_state, int toktype);
+
+u32
+gss_k5encrypt(krb5_keyblock * key,
+	      int usage, void *iv, void *in, void *out, int length);
+
+u32
+gss_k5decrypt(krb5_keyblock * key,
+	      int usage, void *iv, void *in, void *out, int length);
+
+s32
+kg_make_seq_num(krb5_keyblock * key,
+		int direction,
+		s32 seqnum, unsigned char *cksum, unsigned char *buf);
+
+s32 kg_get_seq_num(krb5_keyblock * key,
+		   unsigned char *cksum,
+		   unsigned char *buf, int *direction, s32 * seqnum);
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/Makefile linux-2.5.45-08-krb5/net/sunrpc/Makefile
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/Makefile	2002-10-31 10:23:24.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/Makefile	2002-10-31 15:45:10.000000000 -0500
@@ -19,4 +19,10 @@
 auth_rpcgss-objs := auth_gss.o gss_pseudoflavors.o gss_generic_token.o \
 	    sunrpcgss_syms.o gss_mech_switch.o gss_delete_sec_context.o
 
+rpcsec_gss_krb5-objs := gss_krb5_mech.o gss_krb5_cksum.o gss_krb5_md5.o \
+                        gss_krb5_seal.o gss_krb5_unseal.o gss_krb5_encrypt.o \
+			gss_krb5_seqnum.o gss_krb5_decrypt.o \
+			gss_krb5_crypto_utils.o
+obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
+
 include $(TOPDIR)/Rules.make
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_cksum.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_cksum.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_cksum.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_cksum.c	2002-10-31 15:45:10.000000000 -0500
@@ -0,0 +1,106 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_cksum.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/k5seal.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ * 
+ * All rights reserved.
+ * 
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ * 
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ * 
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+extern const krb5_2_linux_digest digest_list[];
+
+s32
+krb5_c_make_checksum(s32 cksumtype,
+		     krb5_keyblock * key,
+		     s32 usage,
+		     krb5_data * input, krb5_checksum * cksum)
+{
+	int i;
+	krb5_data data;
+	s32 ret = 0;
+	size_t cksumlen;
+
+	/* the checksum length was just set in make_seal_token_v1
+	 * so, either we remove that code, or remove this code....*/
+
+	if ((i = find_digest(cksumtype)) == -1)
+		return (-EINVAL);
+
+	if (digest_list[i].keyhash)
+		(*(digest_list[i].keyhash->hash_size)) (&cksumlen);
+	else if (digest_list[i].hash)
+		(*(digest_list[i].hash->hash_size)) (&cksumlen);
+	else
+		return (-EINVAL);
+
+	cksum->length = cksumlen;
+
+	if ((cksum->contents =
+	     (unsigned char *) rpc_allocate(0, cksum->length)) == NULL)
+		return (ENOMEM);
+
+	data.length = cksum->length;
+	data.data = cksum->contents;
+
+
+	dprintk
+	    ("RPC:   krb5_c_make_checksum cksum->length %d input->length %d\n",
+	     cksum->length, input->length);
+
+	if (digest_list[i].keyhash)
+		ret =
+		    (*(digest_list[i].keyhash->hash)) (key, 0, input,
+						       &data);
+	else if (digest_list[i].hash)
+		ret = (*(digest_list[i].hash->hash)) (1, input, &data);
+
+	if (!ret) {
+		cksum->magic = KV5M_CHECKSUM;
+		cksum->checksum_type = cksumtype;
+	}
+	if (ret) {
+		memset(cksum->contents, 0, cksum->length);
+		rpc_free(cksum->contents);
+	}
+
+	dprintk("RPC: gss_k5cksum: returning %d\n", ret);
+	return (ret);
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_crypto_utils.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_crypto_utils.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_crypto_utils.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_crypto_utils.c	2002-10-31 15:45:10.000000000 -0500
@@ -0,0 +1,148 @@
+/*
+ *  linux/net/sunrpc/gss_util_crypto.c
+ *
+ *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/auth.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/crypto.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+/* from crypto/api.c */
+extern struct crypto_alg *crypto_alg_lookup(char *name);
+                                      
+/* linux crypto framework uses names to lookup supported ciphers and 
+ * digests. these structures map the kerberos5 digest and cipher types
+ * to the linux crypto specific names.
+ */
+
+extern struct krb5_hash_provider krb5_hash_md5;
+
+/* name mapping for digests */
+const krb5_2_linux_digest digest_list[] = {
+	{ CKSUMTYPE_RSA_MD5,
+	"md5",
+	&krb5_hash_md5,
+	(struct krb5_keyhash_provider *)NULL}
+};
+const int digest_list_length =
+	sizeof(digest_list)/sizeof(krb5_2_linux_digest);
+
+/* name mapping for encryption algorithms */
+const krb5_2_linux_keytypes cipher_list[] = {
+	{ ENCTYPE_DES_CBC_RAW, "des", CRYPTO_TFM_MODE_CBC ,"NULL"}
+};
+const int keytype_length =
+	sizeof(cipher_list)/sizeof(krb5_2_linux_keytypes);
+
+int
+find_digest(s32 type)
+{
+	int i;
+
+	dprintk("RPC:find_digest type %d\n",type);
+	for(i=0;i<digest_list_length;i++){
+		if(digest_list[i].ctype == type){
+			dprintk("RPC:find_digest loop i %d ctype %d\n",i,
+		                digest_list[i].ctype);
+			break;
+		}
+	}
+	if(i == digest_list_length) 
+		return -1;
+	return i;
+}
+
+int
+find_enctype(s32 enctype)
+{
+int i;
+
+	dprintk("RPC:find_enctype type %d\n",enctype);
+	for(i=0;i<keytype_length;i++){
+		if(cipher_list[i].enctype == enctype)
+			break;
+	}
+	if(i == keytype_length) 
+		return -1;
+	return i;
+}
+
+int
+k5_get_blocksize(s32 enctype, size_t *blocksize)
+{
+	int i;
+	struct crypto_alg  *alg = NULL;
+
+	dprintk("RPC: k5_get_blocksize type %d \n",enctype); 
+	i = find_enctype(enctype);
+	if(i < 0)
+		return(-EINVAL);
+
+	if(cipher_list[i].seal_name) 
+		alg = crypto_alg_lookup(cipher_list[i].seal_name); 
+	if(!alg)
+		return(-EINVAL);
+
+	*blocksize = alg->cra_blocksize;	    
+	dprintk("RPC: k5_get_blocksize blocksize %d\n",*blocksize); 
+	return 0;
+}
+
+int
+k5_get_checksum_length(s32 cksmtype, size_t *length)
+{
+	int i;
+	struct crypto_alg *alg = NULL;
+
+	dprintk("RPC: k5_get_checksum_length type %d\n",cksmtype);
+	i = find_digest(cksmtype);
+	if(i < 0)
+		return(-EINVAL);
+
+	dprintk("RPC: k5_get_checksum_length calling crypto_alg_lookup on %s\n",
+	digest_list[i].digest_name);
+	if(digest_list[i].digest_name) 
+		alg = crypto_alg_lookup(digest_list[i].digest_name);
+	if(!alg)
+		return(-EINVAL);
+	*length = alg->cra_blocksize;
+	dprintk("RPC: k5_get_checksum_length length %d\n",*length);
+	return 0;
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_decrypt.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_decrypt.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_decrypt.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_decrypt.c	2002-10-31 15:45:11.000000000 -0500
@@ -0,0 +1,149 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_decrypt.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/crypto/raw/raw_decrypt.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ *
+ * All rights reserved.
+ *
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+
+/* combines functionality of kg_decrypt(), krb5_c_decrypt(), and 
+ * krb5_raw_decrypt()
+ */
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <asm/scatterlist.h>
+#include <linux/highmem.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/crypto.h>
+
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+extern const krb5_2_linux_keytypes cipher_list[];
+
+u32
+gss_k5decrypt(
+     krb5_keyblock *key,
+     int usage,
+     void * iv,
+     void * in,
+     void * out,
+     int length)
+{
+	u32 ret = 0;
+	int i = -1;
+	char *p;
+	struct crypto_tfm *tfm;
+	struct scatterlist sg[1];  /* XXX will need to dynamically allocate */
+	u32 local_iv[4] = {0,0,0,0};
+
+	dprintk("gss_k5decrypt: TOP in %p out %p\n",in,out);
+	dprintk("gss_k5decrypt: in data:\n");
+	print_hexl((u32 *)in,length,0);
+
+	/* key->enctype was checked by the caller */
+
+	if (key->length != 8)
+		return(-EINVAL);            /*KRB5_BAD_KEYSIZE*/
+	if ((length%8) != 0)
+		return(-EINVAL);            /*KRB5_BAD_MSIZE*/
+
+
+	if((i = find_enctype(key->enctype)) == -1)
+		return( -EINVAL);
+
+	ret = -ENOMEM;
+	tfm = crypto_alloc_tfm(cipher_list[i].seal_name,
+                               cipher_list[i].seal_mode);
+	if (!tfm)
+		goto out;
+
+	/* set initialization vector as per rfc1510 */
+	ret = -EINVAL;
+	if (crypto_tfm_alg_ivsize(tfm) != 8 ) {
+		dprintk("RPC: gss_k5encrypt: tfm iv size to large %d\n",
+		crypto_tfm_alg_ivsize(tfm));
+		goto out_free;
+	}
+	if (iv) {
+		memcpy(local_iv,iv, crypto_tfm_alg_ivsize(tfm));
+	} else {
+		memset(local_iv,0,crypto_tfm_alg_ivsize(tfm));
+	}
+	crypto_cipher_set_iv(tfm, iv, crypto_tfm_alg_blocksize(tfm));
+
+
+	/*XXX need to check key parity here*/
+
+	dprintk("RPC: gss_k5decrypt :setkey args: \n");
+	dprintk("               key->contents %p, key->length %d\n",
+	                key->contents,key->length);
+
+	dprintk("RPC: gss_k5decrypt: key data:\n");
+	print_hexl((u32 *)key->contents, key->length, 0);
+
+	ret = crypto_cipher_setkey(tfm, key->contents, key->length);
+	if (ret) {
+		dprintk("RPC: setkey failed. ret: %d\n",ret);
+		goto out_free;
+	}
+
+	memcpy(out, in, length);
+	sg[0].page = virt_to_page(out);
+	sg[0].offset = ((long)out  & ~PAGE_MASK);
+	sg[0].length = length;
+
+	ret = crypto_cipher_decrypt(tfm, sg, 1);
+	if (ret) {
+		printk("des_cbc_decrypt() failed flags=%x\n",
+		tfm->crt_flags);
+		goto out_free;
+	}
+
+
+#if 0
+	dprintk("RPC: gss_k5decrypt: out: ");
+	print_hexl((u32 *)out, length, 0);
+#endif
+
+out_free:
+	crypto_free_tfm(tfm);
+out:
+	dprintk("gss_k5decrypt returns %d\n",ret);
+	return(ret);
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_encrypt.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_encrypt.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_encrypt.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_encrypt.c	2002-10-31 15:45:11.000000000 -0500
@@ -0,0 +1,158 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_encrypt.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/crypto/raw/raw_encrypt.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ *
+ * All rights reserved.
+ *
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+/* combines functionality of kg_encrypt(), krb5_c_encrypt(), and 
+ * krb5_raw_encrypt()
+ */
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <asm/scatterlist.h>
+#include <linux/highmem.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/crypto.h>
+
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+extern const krb5_2_linux_keytypes cipher_list[];
+
+u32
+gss_k5encrypt(
+	krb5_keyblock *key,
+	int usage,
+	void * iv,
+	void * in,
+	void * out,
+	int length)
+{
+	u32 ret = 0;
+	int i = -1;
+        char *p;
+        struct crypto_tfm *tfm;
+        struct scatterlist sg[1]; /* XXX when do i need more than 1? */
+	u32 local_iv[8] = {0,0,0,0,0,0,0,0};
+
+	dprintk("gss_k5encrypt:\n");
+
+	dprintk("RPC: gss_k5encrypt: TOP out %p in %p in data:\n",out,in);
+	print_hexl((u32 *)in,length,0);
+
+	/* key->enctype was checked by the caller */
+
+	if (key->length != 8)
+		return(-EINVAL);            /*KRB5_BAD_KEYSIZE*/
+	if ((length%8) != 0)
+		return(-EINVAL);            /*KRB5_BAD_MSIZE*/
+
+	if((i = find_enctype(key->enctype)) == -1)
+		return( -EINVAL);
+
+	ret = -ENOMEM;
+	dprintk("RPC: gss_k5encrypt calling crypto_alloc_tfm for:  %s\n",
+	             cipher_list[i].seal_name);
+	tfm = crypto_alloc_tfm(cipher_list[i].seal_name,
+                               cipher_list[i].seal_mode);
+	if (!tfm)
+		goto out;
+
+	if (crypto_tfm_alg_ivsize(tfm) != 8 ) {
+		dprintk("RPC: gss_k5encrypt: tfm iv size to large %d\n",
+		         crypto_tfm_alg_ivsize(tfm));
+		goto out_free;
+	}
+
+	/* set initialization vector as per rfc1510 
+	 * local_iv is set to zero unless input iv is set..
+	 */
+	if (iv) {
+		dprintk("RPC: gss_k5encrypt : iv %p: \n",iv);
+		memcpy(local_iv, iv, crypto_tfm_alg_ivsize(tfm));
+	} 
+
+
+    	/*XXX need to check key parity ?*/
+
+	dprintk("RPC: gss_k5encrypt : setkey args: \n");
+	dprintk("               key->contents %p, key->length %d\n",
+		key->contents,key->length);
+
+	dprintk("RPC: gss_k5encrypt: key data:\n");
+	print_hexl((u32 *)key->contents, key->length, 0);
+
+	ret = crypto_cipher_setkey(tfm, key->contents, key->length);
+	if (ret) {
+		dprintk("RPC: setkey failed. ret: %d\n",ret);
+		goto out_free;
+	}
+
+#if 0
+	dprintk("RPC: gss_k5encrypt : calling encrypt:\n");
+	dprintk("     in:%p  in data:\n",in);
+	print_hexl(in,length,0);
+	dprintk("     out %p\n",out);
+	dprintk("     blocksize %d\n",crypto_tfm_alg_blocksize(tfm));
+	dprintk("     local_iv %p local_iv data:\n",local_iv);
+	print_hexl((u32 *)local_iv,8,0);
+#endif
+	memcpy(out, in, length);
+	sg[0].page = virt_to_page(out);
+	sg[0].offset = ((long)out & ~PAGE_MASK);
+	sg[0].length = length;
+
+	ret = crypto_cipher_encrypt(tfm, sg, 1);
+	if (ret) {
+		printk("des_cbc_decrypt() failed flags=%x\n", tfm->crt_flags);
+		goto out_free;
+	}
+
+#if 0
+	dprintk("RPC: gss_k5encrypt : after ci->encrypt:\n");
+	dprintk("     out:%p  out data:\n",out);
+	print_hexl(out,8,0);
+#endif
+
+out_free:
+	crypto_free_tfm(tfm);
+out:
+	dprintk("gss_k5encrypt returns %d\n",ret);
+	return(ret);
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_md5.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_md5.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_md5.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_md5.c	2002-10-31 15:45:11.000000000 -0500
@@ -0,0 +1,116 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_md5.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/crypto/hash_provider/hash_md5.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ * 
+ * All rights reserved.
+ * 
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ * 
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ * 
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <asm/scatterlist.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/crypto.h>
+
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+static void gss_k5_md5_hash_size(size_t * output)
+{
+	*output = RSA_MD5_CKSUM_LENGTH;
+}
+
+static void gss_k5_md5_block_size(size_t * output)
+{
+	*output = 64;
+}
+
+static s32
+gss_k5_md5_hash(unsigned int icount, krb5_data * input, krb5_data * output)
+{
+	char *p;
+	int i, ret = 0;
+	struct scatterlist sg[1];	/*XXX when do i need more than 1? */
+	struct crypto_tfm *tfm;
+	char digest_out[128];	/*XXX dynamic memory ? */
+
+	dprintk("RPC: gss_k5_md5_hash\n");
+	if (output->length != RSA_MD5_CKSUM_LENGTH)
+		return (-EINVAL);
+
+	/* initialize the kernel hash interface */
+	ret = -ENOMEM;
+	tfm = crypto_alloc_tfm("md5", 0);
+	if (!tfm)
+		goto out;
+
+	memset(digest_out, 0, sizeof(digest_out));
+	p = input->data;
+	sg[0].page = virt_to_page(p);
+	sg[0].offset = ((long) p & ~PAGE_MASK);
+	sg[0].length = input->length;
+
+	crypto_digest_init(tfm);
+
+	for (i = 0; i < icount; i++) {
+		dprintk("gss_k5_md5_hash: INPUT TEXT: u8 len %d\n",
+			input[i].length);
+		print_hexl((u32 *) input[i].data, input[i].length, 0);
+		crypto_digest_update(tfm, sg, 1);
+	}
+	crypto_digest_final(tfm, digest_out);
+
+/*XXX use crypto_tfm_alg_digestsize(tfm) instead of RSA_MD5_CKSUM_LENGTH? */
+	memcpy(output->data, digest_out, RSA_MD5_CKSUM_LENGTH);
+#if 0
+	dprintk("gss_k5_md5_hash: digest buffer HASH RESULT byte len %d\n",
+		RSA_MD5_CKSUM_LENGTH);
+	print_hexl((u32 *) digest_out, RSA_MD5_CKSUM_LENGTH, 0);
+	dprintk("gss_k5_md5_hash: output buffer HASH RESULT byte len %d\n",
+		RSA_MD5_CKSUM_LENGTH);
+	print_hexl((u32 *) output->data, RSA_MD5_CKSUM_LENGTH, 0);
+#endif				/*0 */
+	ret = 0;
+	crypto_free_tfm(tfm);
+      out:
+	return (ret);
+}
+
+const struct krb5_hash_provider krb5_hash_md5 = {
+	gss_k5_md5_hash_size,
+	gss_k5_md5_block_size,
+	gss_k5_md5_hash
+};
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_mech.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_mech.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_mech.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_mech.c	2002-10-31 15:50:48.000000000 -0500
@@ -0,0 +1,297 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_mech.c
+ *
+ *  Copyright (c) 2001 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson <andros@umich.edu>
+ *  J. Bruce Fields <bfields@umich.edu>
+ *
+ *  Redistribution and use in source and binary forms, with or without
+ *  modification, are permitted provided that the following conditions
+ *  are met:
+ *
+ *  1. Redistributions of source code must retain the above copyright
+ *     notice, this list of conditions and the following disclaimer.
+ *  2. Redistributions in binary form must reproduce the above copyright
+ *     notice, this list of conditions and the following disclaimer in the
+ *     documentation and/or other materials provided with the distribution.
+ *  3. Neither the name of the University nor the names of its
+ *     contributors may be used to endorse or promote products derived
+ *     from this software without specific prior written permission.
+ *
+ *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
+ *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
+ *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
+ *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
+ *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
+ *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
+ *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
+ *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
+ *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/auth.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/sunrpc/xdr.h>
+#include <linux/crypto.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY	RPCDBG_AUTH
+#endif
+
+GSS_OID gss_mech_krb5_oid =
+   {9, "\052\206\110\206\367\022\001\002\002"};
+
+void
+print_krb5_gss_ctx_id_rec(krb5_gss_ctx_id_t k5_ctx)
+{
+	dprintk("some of krb5_gss_ctx_id_rec: \n");
+	if (!k5_ctx) return;
+	dprintk("     initiate:      %d\n",k5_ctx->initiate);
+	dprintk("     gss_flags:     0x%x\n",k5_ctx->gss_flags);
+	dprintk("     seed_init:     %d\n",k5_ctx->seed_init);
+	dprintk("     signalg:      %d\n",k5_ctx->signalg);
+	dprintk("     cksum_size:      %d\n",k5_ctx->cksum_size);
+	dprintk("     sealalg:      %d\n",k5_ctx->sealalg);
+	dprintk("   ENC types: \n");
+	if (k5_ctx->enc) {
+	    dprintk("     enc->enctype:     %d\n",k5_ctx->enc->enctype);
+	    dprintk("     enc->length:     %d\n",k5_ctx->enc->length);
+	}else 
+	    dprintk("     NULL ENC\n");
+	if (k5_ctx->seq) {
+	    dprintk("     seq->enctype:     %d\n",k5_ctx->seq->enctype);
+	    dprintk("     seq->length:     %d\n",k5_ctx->seq->length);
+	}else
+	    dprintk("     NULL SEQ\n");
+}
+
+static inline int
+get_bytes(char **ptr, const char *end, void *res, int len)
+{
+	char *p, *q;
+	p = *ptr;
+	q = p + len;
+	if (q > end || q < p)
+		return -1;
+	memcpy(res, p, len);
+	*ptr = q;
+	return 0;
+}
+
+static inline int
+get_netobj(char **ptr, const char *end, struct xdr_netobj *res)
+{
+	char *p, *q;
+	p = *ptr;
+	if (get_bytes(&p, end, &res->len, sizeof(res->len)))
+		return -1;
+	q = p + res->len;
+	if (q > end || q < p)
+		return -1;
+	if (!(res->data = rpc_allocate(0, res->len)))
+		return -1;
+	memcpy(res->data, p, res->len);
+	*ptr = q;
+	return 0;
+}
+
+static inline int
+get_keyblock(char **p, char *end, struct _krb5_keyblock **res)
+{
+	struct xdr_netobj	tmp;
+
+	if (!(*res = rpc_allocate(0, sizeof(struct _krb5_keyblock))))
+		goto out_err;
+	if (!get_bytes(p, end, &(*res)->magic, sizeof((*res)->magic)))
+		goto out_free;
+	if (!get_bytes(p, end, &(*res)->enctype, sizeof((*res)->enctype)))
+		goto out_free;
+	if (!get_bytes(p, end, &(*res)->length, sizeof((*res)->length)))
+		goto out_free;
+	if (!(get_netobj(p, end, &tmp)))
+		goto out_free;
+	(*res)->length = tmp.len;
+	(*res)->contents = tmp.data;
+	return 0;
+out_free:
+	rpc_free(*res);
+out_err:
+	return -1;
+}
+
+static int
+krb5_ctx_internalize(struct _krb5_gss_ctx_id_rec **ctxp, char **p, int len)
+{
+	char *end = *p + len;
+	struct _krb5_gss_ctx_id_rec *ctx;
+
+	if (!(*ctxp = rpc_allocate(0, sizeof(**ctxp))))
+		goto out_err;
+	ctx = *ctxp;
+	memset(ctx, 0, sizeof(*ctx));
+
+	if (!get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->seed_init, sizeof(ctx->seed_init)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, ctx->seed, sizeof(ctx->seed)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->signalg, sizeof(ctx->signalg)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->cksum_size, sizeof(ctx->cksum_size)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->sealalg, sizeof(ctx->sealalg)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->seq_send, sizeof(ctx->seq_send)))
+		goto out_err_free_ctx;
+	if (!get_bytes(p, end, &ctx->big_endian, sizeof(ctx->big_endian)))
+		goto out_err_free_ctx;
+	if (!get_netobj(p, end, (struct xdr_netobj *)&ctx->mech_used))
+		goto out_err_free_ctx;
+	if (!get_keyblock(p, end, &ctx->enc))
+		goto out_err_free_mech;
+	if (!get_keyblock(p, end, &ctx->seq))
+		goto out_err_free_keyblock1;
+	if (*p != end)
+		goto out_err_free_keyblock2;
+	return 0;
+out_err_free_keyblock2:
+	rpc_free(ctx->seq->contents);
+	rpc_free(ctx->seq);
+out_err_free_keyblock1:
+	rpc_free(ctx->enc->contents);
+	rpc_free(ctx->enc);
+out_err_free_mech:
+	rpc_free(ctx->mech_used);
+out_err_free_ctx:
+	rpc_free(ctx);
+	*ctxp = NULL;
+out_err:
+	return -1;
+}
+
+u32
+gss_import_sec_context_kerberos(GSS_BUFFER_T	*inbuf,
+				GSS_CTX_ID_T	ctx_id)
+{
+	krb5_gss_ctx_id_t ctx;
+	int length;
+	char *p;
+
+	dprintk("RPC: k5_gss_import_sec_context inbuf: %p:%d\n",
+	          inbuf->data,inbuf->len);
+	/* Skipping the mech oid; we don't really need it, but it might
+	 * be useful as a sanity check. */
+	p = inbuf->data;
+	length = *p++;
+	length = (length << 8) + *p++;
+	length = (length << 8) + *p++;
+	length = (length << 8) + *p++;
+	if (length > inbuf->len) {
+		dprintk("RPC: k5_gss_import_sec_context mech oid length"
+			" too large %d:\n", length);
+		return(KG_BAD_LENGTH);
+	}
+	p += length;
+
+	if (krb5_ctx_internalize(&ctx, &p, inbuf->len))
+		return(GSS_S_FAILURE);
+	ctx_id->internal_ctx_id = ctx;
+
+	print_krb5_gss_ctx_id_rec(ctx);
+	return(0);
+}
+
+u32
+gss_verify_mic_kerberos( GSS_CTX_ID_T	contextid,
+			GSS_BUFFER_T	*signbuf,
+			GSS_BUFFER_T	*checksum,
+			u32		*qstate) {
+	u32 maj_stat = 0;
+	int qop_state;
+
+	dprintk("GSS_VERIFY_MIC\n");
+
+	print_krb5_gss_ctx_id_rec(contextid->internal_ctx_id);
+
+	dprintk("VERIFY MIC calling kg_unseal\n");
+
+	maj_stat = kg_unseal(contextid, checksum,signbuf,
+	                  NULL, &qop_state, KG_TOK_MIC_MSG);
+	if (!maj_stat && qop_state)
+	    *qstate = qop_state;
+
+	dprintk("VERIFY MIC returning err %d\n", maj_stat);
+	return maj_stat;
+}
+
+u32
+gss_get_mic_kerberos(GSS_CTX_ID_T contextid,
+		     u32 qop,
+		     GSS_BUFFER_T *message_buffer,
+		     GSS_BUFFER_T *message_token) {
+	u32 err = 0,i;
+	unsigned char *pp;
+
+	dprintk("GSS_GETMIC\n");
+
+	print_krb5_gss_ctx_id_rec(contextid->internal_ctx_id);
+
+	if (!message_buffer->data) return -EINVAL;
+
+	dprintk("GSS_GETMIC: message_buffer->len %d\n",message_buffer->len);
+	pp = message_buffer->data;
+	for(i=0;i<message_buffer->len;i++)
+	    dprintk("%02x",*pp++);
+	dprintk("\n");
+
+	dprintk("GETMIC calling kg_seal\n");
+	err = kg_seal(contextid, 0, qop, message_buffer, NULL,
+		      message_token, KG_TOK_SIGN_MSG);
+
+	dprintk("GETMIC kg_seal return: %d \n",err);
+
+	return err;
+}
+
+static struct gss_api_ops gss_kerberos_ops = {
+	.name			= "krb5",
+	NULL,
+	.gss_import_sec_context	= gss_import_sec_context_kerberos,
+	.gss_get_mic		= gss_get_mic_kerberos,
+	.gss_verify_mic		= gss_verify_mic_kerberos,
+	.gss_delete_sec_context	= gss_delete_sec_context_generic,
+};
+
+/* XXX error checking? reference counting? */
+static int __init init_kerberos_module(void)
+{
+	struct gss_api_mech *gm;
+
+	if (gss_mech_register(&gss_mech_krb5_oid, &gss_kerberos_ops))
+		printk("Failed to register kerberos gss mechanism!\n");
+	gm = gss_mech_get_by_OID(&gss_mech_krb5_oid);
+	gss_register_triple(RPC_AUTH_GSS_KRB5 , gm, 0, RPC_GSS_SVC_NONE);
+	gss_mech_put(gm);
+	return 0;
+}
+
+static void __exit cleanup_kerberos_module(void)
+{
+	gss_unregister_triple(RPC_AUTH_GSS_KRB5);
+}
+
+MODULE_LICENSE("GPL");
+module_init(init_kerberos_module);
+module_exit(cleanup_kerberos_module);
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_seal.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_seal.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_seal.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_seal.c	2002-10-31 15:53:25.000000000 -0500
@@ -0,0 +1,366 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_seal.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/k5seal.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright 1993 by OpenVision Technologies, Inc.
+ *
+ * Permission to use, copy, modify, distribute, and sell this software
+ * and its documentation for any purpose is hereby granted without fee,
+ * provided that the above copyright notice appears in all copies and
+ * that both that copyright notice and this permission notice appear in
+ * supporting documentation, and that the name of OpenVision not be used
+ * in advertising or publicity pertaining to distribution of the software
+ * without specific, written prior permission. OpenVision makes no
+ * representations about the suitability of this software for any
+ * purpose.  It is provided "as is" without express or implied warranty.
+ *
+ * OPENVISION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
+ * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
+ * EVENT SHALL OPENVISION BE LIABLE FOR ANY SPECIAL, INDIRECT OR
+ * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
+ * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
+ * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
+ * PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ *
+ * All rights reserved.
+ *
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/jiffies.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+#include <linux/random.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+
+static s32
+make_seal_token_v1(krb5_keyblock * enc,
+		   krb5_keyblock * seq,
+		   s32 * seqnum,
+		   int direction,
+		   GSS_BUFFER_T * text,
+		   GSS_BUFFER_T * token,
+		   int signalg,
+		   int cksum_size,
+		   int sealalg,
+		   int encrypt, int toktype, int bigend, GSS_OID * oid)
+{
+	s32 code = 0;
+	size_t sumlen;
+	char *data_ptr;
+	krb5_data plaind;
+	krb5_checksum md5cksum;
+	krb5_checksum cksum;
+	int conflen = 0, tmsglen, tlen;
+	unsigned char *t, *ptr;
+	int encblksize, sumblksize;
+
+	/* will eventually add support for other algorithms */
+	dprintk("RPC: gss_krb5_seal");
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		sumblksize = 1;
+		break;
+	default:
+		dprintk("RPC: gss_krb5_seal: bad signalg %d\n", signalg);
+		return KG_BAD_SIGN_TYPE;
+	}
+	dprintk("RPC: gss_k5seal: sealalg %d\n", sealalg);
+	switch (sealalg) {
+	case SEAL_ALG_NONE:
+	case SEAL_ALG_DES:
+		encblksize = 8;
+		break;
+	default:
+		dprintk("RPC: gss_krb5_seal: bad sealalg %d\n", sealalg);
+		return KG_BAD_SIGN_TYPE;
+	}
+
+	/* create the token buffer */
+
+	if (toktype == KG_TOK_SEAL_MSG) {
+		if (bigend && !encrypt) {
+			tmsglen = text->len;
+		} else {
+			code = k5_get_blocksize(enc->enctype, &conflen);
+			if (code)
+				return code;
+			/* XXX knows that des block size is 8 */
+			tmsglen = (conflen + text->len + 8) & (~7);
+			dprintk("RPC:make_seal_token_v1: tmsglen: %d \n",
+				tmsglen);
+		}
+	} else {
+		tmsglen = 0;
+	}
+
+	tlen = g_token_size((GSS_OID *) oid, 14 + cksum_size + tmsglen);
+
+	if ((t = (unsigned char *) rpc_allocate(0, tlen)) == NULL)
+		return GSS_S_FAILURE;
+
+	/*** fill in the token */
+
+	ptr = t;
+
+	g_make_token_header((GSS_OID *) oid, 14 + cksum_size + tmsglen,
+			    &ptr, toktype);
+	/* 0..1 SIGN_ALG */
+
+	ptr[0] = signalg & 0xff;
+	ptr[1] = (signalg >> 8) & 0xff;
+
+	/* 2..3 SEAL_ALG or Filler */
+
+	if ((toktype == KG_TOK_SEAL_MSG) && encrypt) {
+		ptr[2] = sealalg & 0xff;
+		ptr[3] = (sealalg >> 8) & 0xff;
+	} else {
+		/* No seal */
+		ptr[2] = 0xff;
+		ptr[3] = 0xff;
+	}
+
+	ptr[4] = 0xff;
+	ptr[5] = 0xff;
+
+	/* pad the plaintext, encrypt if needed, and stick it in the token */
+
+	/* initialize the the cksum */
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		md5cksum.checksum_type = CKSUMTYPE_RSA_MD5;
+		break;
+	default:
+		return KG_BAD_SIGN_TYPE;
+	}
+
+	if ((code = k5_get_checksum_length(md5cksum.checksum_type, &sumlen)))
+		return code;
+	md5cksum.length = sumlen;
+
+	if (toktype == KG_TOK_SEAL_MSG) {
+		unsigned char *plain;
+		unsigned char pad;
+
+		if (!bigend || encrypt) {
+			if ((plain =
+			     (unsigned char *) rpc_allocate(0,
+							    tmsglen)) ==
+			    NULL) {
+				rpc_free(t);
+				return GSS_S_FAILURE;
+			}
+			get_random_bytes(plain, conflen); /* "confounder" */
+			memcpy(plain + conflen, text->data, text->len);
+
+			/* XXX 8 is DES cblock size */
+			pad = 8 - (text->len % 8);
+
+			memset(plain + conflen + text->len, pad, pad);
+		} else {
+			/* plain is never used in the bigend && !encrypt case */
+			plain = NULL;
+		}
+
+		if (encrypt) {
+			if ((code = gss_k5encrypt(enc, KG_USAGE_SEAL,
+						  NULL,
+						  plain,
+						  ptr + cksum_size + 14,
+						  tmsglen))) {
+				if (plain)
+					rpc_free(plain);
+				rpc_free(t);
+				return code;
+			}
+		} else {
+			if (bigend)
+				memcpy(ptr + 14 + cksum_size, text->data,
+				       text->len);
+			else
+				memcpy(ptr + 14 + cksum_size, plain,
+				       tmsglen);
+		}
+
+		/* compute the checksum */
+
+		/* 8 = head of token body as specified by mech spec */
+		if (!(data_ptr = (char *) rpc_allocate(0,
+					8 + (bigend ? text->len: tmsglen)))) {
+			if (plain)
+				rpc_free(plain);
+			rpc_free(t);
+			return GSS_S_FAILURE;
+		}
+		memcpy(data_ptr, ptr - 2, 8);
+		if (bigend)
+			memcpy(data_ptr + 8, text->data, text->len);
+		else
+			memcpy(data_ptr + 8, plain, tmsglen);
+		plaind.length = 8 + (bigend ? text->len : tmsglen);
+		plaind.data = data_ptr;
+		code = krb5_c_make_checksum(md5cksum.checksum_type, seq,
+					    KG_USAGE_SIGN, &plaind, &md5cksum);
+		rpc_free(data_ptr);
+
+		if (code) {
+			if (plain)
+				rpc_free(plain);
+			rpc_free(t);
+			return code;
+		}
+
+		if (plain)
+			rpc_free(plain);
+	} else {
+		/* Sign only.  */
+		/* compute the checksum */
+
+		if (!(data_ptr = (char *) rpc_allocate(0, 8 + text->len))) {
+			rpc_free(t);
+			return GSS_S_FAILURE;
+		}
+		memcpy(data_ptr, ptr - 2, 8);
+		memcpy(data_ptr + 8, text->data, text->len);
+		plaind.length = 8 + text->len;
+		plaind.data = data_ptr;
+		code = krb5_c_make_checksum(md5cksum.checksum_type, seq,
+					    KG_USAGE_SIGN, &plaind, &md5cksum);
+		rpc_free(data_ptr);
+		if (code) {
+			rpc_free(t);
+			return code;
+		}
+	}
+
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		dprintk("RPC: make_seal_token:SGN_ALG_DES_MAC_MD5:"
+			" calling gss_k5encrypt CBC MAC\n");
+		if ((code = gss_k5encrypt(seq, KG_USAGE_SEAL,
+					  NULL,
+					  md5cksum.contents,
+					  md5cksum.contents, 16))) {
+			dprintk("make_seal_token: gss_k5encrypt FAILED"
+				" returns code %d\n", code);
+			rpc_free(md5cksum.contents);
+			rpc_free(t);
+			return code;
+		}
+		dprintk("RPC: make_seal_token: gss_k5encrypt returns"
+			" %d OUTPUT:\n", code);
+		print_hexl((u32 *) md5cksum.contents, 16, 0);
+
+		cksum.length = cksum_size;
+		cksum.contents = md5cksum.contents + 16 - cksum.length;
+		memcpy(ptr + 14, cksum.contents, cksum.length);
+
+		dprintk("make_seal_token: ptr with cksum data: \n");
+		print_hexl((u32 *) ptr, 14 + 8, 0);
+		break;
+	default:
+		return KG_BAD_SIGN_TYPE;
+	}
+
+	rpc_free(md5cksum.contents);
+
+	/* create the seq_num */
+
+	dprintk("RPC: make_seal_token: calling kg_make_seq_num\n");
+	if ((code = kg_make_seq_num(seq, direction ? 0 : 0xff, *seqnum,
+				    ptr + 14, ptr + 6))) {
+		rpc_free(t);
+		return code;
+	}
+	dprintk("RPC: make_seal_token: kg_make_seq_num returns %d\n",
+		code);
+
+	/* that's it.  return the token */
+	(*seqnum)++;
+	token->len = tlen;
+	token->data = (void *) t;
+
+#if 0
+	dprintk("RPC: kg_seal: DONE! token:\n");
+	print_hexl((u32 *) token->data, token->len, 0);
+#endif
+
+	return GSS_S_COMPLETE;
+}
+
+/* if signonly is true, ignore conf_req, conf_state,
+   and do not encode the ENC_TYPE, MSG_LENGTH, or MSG_TEXT fields */
+
+/* NOTE: caller validates the context_handle*/
+u32
+kg_seal(GSS_CTX_ID_T context_handle,
+	int encrypt,
+	int qop_req,
+	GSS_BUFFER_T * input_message_buffer,
+	int *conf_state, GSS_BUFFER_T * output_message_buffer, int toktype)
+{
+	krb5_gss_ctx_id_rec *ctx = context_handle->internal_ctx_id;
+	s32 code;
+	s32 now;
+
+	output_message_buffer->len = 0;
+	output_message_buffer->data = NULL;
+
+	if (qop_req != 0)
+		return GSS_S_FAILURE;
+
+	now = jiffies;
+
+	code = make_seal_token_v1(ctx->enc, ctx->seq,
+				  &ctx->seq_send, ctx->initiate,
+				  input_message_buffer,
+				  output_message_buffer, ctx->signalg,
+				  ctx->cksum_size, ctx->sealalg,
+				  encrypt, toktype, ctx->big_endian,
+				  ctx->mech_used);
+
+	if (code)
+		return (GSS_S_FAILURE);
+
+	if (conf_state)
+		*conf_state = encrypt;
+
+	return ((ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : GSS_S_COMPLETE);
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_seqnum.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_seqnum.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_seqnum.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_seqnum.c	2002-10-31 15:45:11.000000000 -0500
@@ -0,0 +1,91 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_seqnum.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/util_seqnum.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright 1993 by OpenVision Technologies, Inc.
+ * 
+ * Permission to use, copy, modify, distribute, and sell this software
+ * and its documentation for any purpose is hereby granted without fee,
+ * provided that the above copyright notice appears in all copies and
+ * that both that copyright notice and this permission notice appear in
+ * supporting documentation, and that the name of OpenVision not be used
+ * in advertising or publicity pertaining to distribution of the software
+ * without specific, written prior permission. OpenVision makes no
+ * representations about the suitability of this software for any
+ * purpose.  It is provided "as is" without express or implied warranty.
+ * 
+ * OPENVISION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
+ * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
+ * EVENT SHALL OPENVISION BE LIABLE FOR ANY SPECIAL, INDIRECT OR
+ * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
+ * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
+ * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
+ * PERFORMANCE OF THIS SOFTWARE.
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+s32
+kg_make_seq_num(krb5_keyblock * key,
+		int direction,
+		s32 seqnum,
+		unsigned char *cksum, unsigned char *buf)
+{
+	unsigned char plain[8];
+
+	plain[0] = (unsigned char) (seqnum & 0xff);
+	plain[1] = (unsigned char) ((seqnum >> 8) & 0xff);
+	plain[2] = (unsigned char) ((seqnum >> 16) & 0xff);
+	plain[3] = (unsigned char) ((seqnum >> 24) & 0xff);
+
+	plain[4] = direction;
+	plain[5] = direction;
+	plain[6] = direction;
+	plain[7] = direction;
+
+	return (gss_k5encrypt(key, KG_USAGE_SEQ, cksum, plain, buf, 8));
+}
+
+s32 kg_get_seq_num(krb5_keyblock * key,
+			  unsigned char *cksum,
+			  unsigned char *buf,
+			  int *direction, s32 * seqnum)
+{
+	s32 code;
+	unsigned char plain[8];
+
+	dprintk("kg_get_seq_num: \n");
+
+	if ((code =
+	     gss_k5decrypt(key, KG_USAGE_SEQ, cksum, buf, plain, 8))) {
+		printk("kg_get_seq_num: gss_k5decrypt failed with return: %d\n",
+		       code);
+		return (code);
+	}
+
+	if ((plain[4] != plain[5]) || (plain[4] != plain[6])
+				   || (plain[4] != plain[7]))
+		return ((s32) KG_BAD_SEQ);
+
+	*direction = plain[4];
+
+	*seqnum = ((plain[0]) |
+		   (plain[1] << 8) | (plain[2] << 16) | (plain[3] << 24));
+
+	return (0);
+}
diff -u --recursive --new-file linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_unseal.c linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_unseal.c
--- linux-2.5.45-07-auth_upcall2/net/sunrpc/gss_krb5_unseal.c	1969-12-31 19:00:00.000000000 -0500
+++ linux-2.5.45-08-krb5/net/sunrpc/gss_krb5_unseal.c	2002-10-31 15:53:42.000000000 -0500
@@ -0,0 +1,374 @@
+/*
+ *  linux/net/sunrpc/gss_krb5_unseal.c
+ *
+ *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/k5unseal.c
+ *
+ *  Copyright (c) 2000 The Regents of the University of Michigan.
+ *  All rights reserved.
+ *
+ *  Andy Adamson   <andros@umich.edu>
+ */
+
+/*
+ * Copyright 1993 by OpenVision Technologies, Inc.
+ *
+ * Permission to use, copy, modify, distribute, and sell this software
+ * and its documentation for any purpose is hereby granted without fee,
+ * provided that the above copyright notice appears in all copies and
+ * that both that copyright notice and this permission notice appear in
+ * supporting documentation, and that the name of OpenVision not be used
+ * in advertising or publicity pertaining to distribution of the software
+ * without specific, written prior permission. OpenVision makes no
+ * representations about the suitability of this software for any
+ * purpose.  It is provided "as is" without express or implied warranty.
+ *
+ * OPENVISION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
+ * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO
+ * EVENT SHALL OPENVISION BE LIABLE FOR ANY SPECIAL, INDIRECT OR
+ * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
+ * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
+ * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
+ * PERFORMANCE OF THIS SOFTWARE.
+ */
+
+/*
+ * Copyright (C) 1998 by the FundsXpress, INC.
+ *
+ * All rights reserved.
+ *
+ * Export of this software from the United States of America may require
+ * a specific license from the United States Government.  It is the
+ * responsibility of any person or organization contemplating export to
+ * obtain such a license before exporting.
+ *
+ * WITHIN THAT CONSTRAINT, permission to use, copy, modify, and
+ * distribute this software and its documentation for any purpose and
+ * without fee is hereby granted, provided that the above copyright
+ * notice appear in all copies and that both that copyright notice and
+ * this permission notice appear in supporting documentation, and that
+ * the name of FundsXpress. not be used in advertising or publicity pertaining
+ * to distribution of the software without specific, written prior
+ * permission.  FundsXpress makes no representations about the suitability of
+ * this software for any purpose.  It is provided "as is" without express
+ * or implied warranty.
+ *
+ * THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
+ * IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
+ * WARRANTIES OF MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE.
+ */
+
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/jiffies.h>
+#include <linux/sunrpc/gss_krb5_types.h>
+
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+
+/* message_buffer is an input if SIGN, output if SEAL, and ignored if DEL_CTX
+   conf_state is only valid if SEAL. */
+
+u32
+kg_unseal_v1(krb5_gss_ctx_id_rec * ctx,
+	     unsigned char *ptr,
+	     int bodysize,
+	     GSS_BUFFER_T * message_buffer,
+	     int *conf_state, int *qop_state, int toktype)
+{
+	s32 code;
+	int tmsglen = 0;
+	int conflen = 0;
+	int signalg;
+	int sealalg;
+	GSS_BUFFER_T token;
+	krb5_checksum cksum;
+	krb5_checksum md5cksum;
+	krb5_data plaind;
+	char *data_ptr;
+	s32 now;
+	unsigned char *plain = NULL;
+	int cksum_len = 0;
+	int plainlen = 0;
+	int direction;
+	s32 seqnum;
+	size_t sumlen;
+
+	dprintk("RPC: kg_unseal_v1\n");
+	if (toktype == KG_TOK_SEAL_MSG) {
+		message_buffer->len = 0;
+		message_buffer->data = NULL;
+	}
+
+	/* get the sign and seal algorithms */
+
+	signalg = ptr[0] + (ptr[1] << 8);
+	sealalg = ptr[2] + (ptr[3] << 8);
+
+	/* Sanity checks */
+
+	if ((ptr[4] != 0xff) || (ptr[5] != 0xff))
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	if ((toktype != KG_TOK_SEAL_MSG) && (sealalg != 0xffff))
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	/* in the current spec, there is only one valid seal algorithm per
+	   key type, so a simple comparison is ok */
+
+	if ((toktype == KG_TOK_SEAL_MSG) &&
+	    !((sealalg == 0xffff) || (sealalg == ctx->sealalg)))
+		return GSS_S_DEFECTIVE_TOKEN;
+	/* there are several mappings of seal algorithms to sign algorithms,
+	   but few enough that we can try them all. */
+
+	if ((ctx->sealalg == SEAL_ALG_NONE && signalg > 1) ||
+	    (ctx->sealalg == SEAL_ALG_1 && signalg != SGN_ALG_3) ||
+	    (ctx->sealalg == SEAL_ALG_DES3KD &&
+	     signalg != SGN_ALG_HMAC_SHA1_DES3_KD))
+		return GSS_S_DEFECTIVE_TOKEN;
+
+	/* starting with a single alg */
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		cksum_len = 8;
+		break;
+	default:
+		return GSS_S_DEFECTIVE_TOKEN;
+	}
+
+	if (toktype == KG_TOK_SEAL_MSG)
+		tmsglen = bodysize - (14 + cksum_len);
+
+	/* get the token parameters */
+
+	/* decode the message, if SEAL */
+
+	if (toktype == KG_TOK_SEAL_MSG) {
+		dprintk("RPC: kg_unseal_v1 KG_TOK_SEAL_MSG\n");
+
+
+		if (sealalg != 0xffff) {
+			plain = (unsigned char *) rpc_allocate(0, tmsglen);
+			if (plain ==  NULL)
+				return (GSS_S_FAILURE);
+
+			code = gss_k5decrypt(ctx->enc, KG_USAGE_SEAL, NULL,
+					   ptr + 14 + cksum_len, plain,
+					   tmsglen);
+			if (code) {
+				rpc_free(plain);
+				return (GSS_S_FAILURE);
+			     }
+		} else {
+			plain = ptr + 14 + cksum_len;
+		}
+
+		plainlen = tmsglen;
+
+		if ((sealalg == 0xffff) && ctx->big_endian) {
+			token.len = tmsglen;
+		} else {
+			code =
+			    k5_get_blocksize(ctx->enc->enctype, &conflen);
+			if (code)
+				return code;
+			token.len = tmsglen - conflen - plain[tmsglen - 1];
+		}
+
+		if (token.len) {
+			token.data = (void *) rpc_allocate(0, token.len);
+			if (token.data == NULL) {
+				if (sealalg != 0xffff)
+					rpc_free(plain);
+				return (GSS_S_FAILURE);
+			}
+			memcpy(token.data, plain + conflen, token.len);
+		}
+
+	} else if (toktype == KG_TOK_SIGN_MSG) {
+		dprintk("RPC: kg_unseal_v1 KG_TOK_SIGN_MSG\n");
+		token = *message_buffer;
+		plain = token.data;
+		plainlen = token.len;
+	} else {
+		token.len = 0;
+		token.data = NULL;
+		plain = token.data;
+		plainlen = token.len;
+	}
+
+	dprintk("RPC kg_unseal_v1: token.len %d plainlen %d\n", token.len,
+		plainlen);
+
+	/* compute the checksum of the message */
+
+	/* initialize the the cksum */
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		md5cksum.checksum_type = CKSUMTYPE_RSA_MD5;
+		break;
+	default:
+		return (GSS_S_DEFECTIVE_TOKEN);
+	}
+
+	if ((code =
+	     k5_get_checksum_length(md5cksum.checksum_type, &sumlen)))
+		return (code);
+	md5cksum.length = sumlen;
+
+	switch (signalg) {
+	case SGN_ALG_DES_MAC_MD5:
+		dprintk("RPC kg_unseal_v1 SGN_ALG_DES_MAC_MD5\n");
+		/* compute the checksum of the message.
+		 * 8 = bytes of token body to be checksummed according to spec 
+		 */
+
+		data_ptr = (void *) rpc_allocate(0, 8 + (ctx->big_endian ? token.len : plainlen));
+		if (!data_ptr) {
+			if (sealalg != 0xffff)
+				rpc_free(plain);
+			if (toktype == KG_TOK_SEAL_MSG)
+				rpc_free(token.data);
+			return (GSS_S_FAILURE);
+		}
+
+		memcpy(data_ptr, ptr - 2, 8);
+		if (ctx->big_endian)
+			memcpy(data_ptr + 8, token.data, token.len);
+		else
+			memcpy(data_ptr + 8, plain, plainlen);
+
+		plaind.length = 8 + (ctx->big_endian ? token.len : plainlen);
+		plaind.data = data_ptr;
+
+		dprintk
+		    ("RPC:kg_unseal calling make_checksum with PLAIN TEXT\n");
+		print_hexl((u32 *) plaind.data, plaind.length, 0);
+
+		code = krb5_c_make_checksum(md5cksum.checksum_type,
+					    ctx->seq, KG_USAGE_SIGN,
+					    &plaind, &md5cksum);
+
+		rpc_free(data_ptr);
+
+		if (code) {
+			if (toktype == KG_TOK_SEAL_MSG)
+				rpc_free(token.data);
+			return (GSS_S_FAILURE);
+		}
+
+		code = gss_k5encrypt(ctx->seq, KG_USAGE_SEAL, NULL,
+					  md5cksum.contents,
+					  md5cksum.contents, 16);
+		if (code) {
+			rpc_free(md5cksum.contents);
+			if (toktype == KG_TOK_SEAL_MSG)
+				rpc_free(token.data);
+			return GSS_S_FAILURE;
+		}
+
+
+		if (signalg == 0)
+			cksum.length = 8;
+		else
+			cksum.length = 16;
+		cksum.contents = md5cksum.contents + 16 - cksum.length;
+
+		dprintk
+		    ("RPC: kg_unseal_v1: memcmp digest cksum.length %d:\n",
+		     cksum.length);
+		dprintk("          md5cksum.contents\n");
+		print_hexl((u32 *) md5cksum.contents, 16, 0);
+		dprintk("          cksum.contents:\n");
+		print_hexl((u32 *) cksum.contents, cksum.length, 0);
+		{
+			u32 *p;
+
+			(u8 *) p = ptr + 14;
+			dprintk("          ptr+14:\n");
+			print_hexl(p, cksum.length, 0);
+		}
+
+		code = memcmp(cksum.contents, ptr + 14, cksum.length);
+		break;
+	default:
+		return (GSS_S_DEFECTIVE_TOKEN);
+	}
+
+	rpc_free(md5cksum.contents);
+	if (sealalg != 0xffff)
+		rpc_free(plain);
+
+	/* compare the computed checksum against the transmitted checksum */
+
+	if (code) {
+		if (toktype == KG_TOK_SEAL_MSG)
+			rpc_free(token.data);
+		return (GSS_S_BAD_SIG);
+	}
+
+	/* it got through unscathed.  Make sure the context is unexpired */
+
+	if (toktype == KG_TOK_SEAL_MSG)
+		*message_buffer = token;
+
+	if (conf_state)
+		*conf_state = (sealalg != 0xffff);
+
+	if (qop_state)
+		*qop_state = GSS_C_QOP_DEFAULT;
+
+	now = jiffies;
+
+	if (now > ctx->endtime) {
+		return (GSS_S_CONTEXT_EXPIRED);
+	}
+
+	/* do sequencing checks */
+
+	if ((code = kg_get_seq_num(ctx->seq, ptr + 14, ptr + 6, &direction,
+				   &seqnum))) {
+		if (toktype == KG_TOK_SEAL_MSG)
+			rpc_free(token.data);
+		return (GSS_S_BAD_SIG);
+	}
+
+	if ((ctx->initiate && direction != 0xff) ||
+	    (!ctx->initiate && direction != 0)) {
+		if (toktype == KG_TOK_SEAL_MSG)
+			rpc_free(token.data);
+		return (GSS_S_BAD_SIG);
+	}
+
+	return (GSS_S_COMPLETE);
+}
+
+/* message_buffer is an input if SIGN, output if SEAL, and ignored if DEL_CTX
+   conf_state is only valid if SEAL. */
+
+u32
+kg_unseal(GSS_CTX_ID_T context_handle,
+	  GSS_BUFFER_T * input_token_buffer,
+	  GSS_BUFFER_T * message_buffer,
+	  int *conf_state, int *qop_state, int toktype)
+{
+	krb5_gss_ctx_id_rec *ctx = context_handle->internal_ctx_id;
+	unsigned char *ptr;
+	int bodysize;
+	int err;
+
+	ptr = (unsigned char *) input_token_buffer->data;
+
+	/* parse the token, leave the data in message_buffer, setting conf_state */
+	if ((err = g_verify_token_header((GSS_OID *) ctx->mech_used,
+					 &bodysize, &ptr, toktype,
+					 input_token_buffer->len)) != 0)
+		return (GSS_S_DEFECTIVE_TOKEN);
+	err = kg_unseal_v1(ctx, ptr, bodysize,
+			   message_buffer, conf_state, qop_state, toktype);
+	dprintk("kg_unseal_v1 returned %d\n", err);
+	return (err);
+}


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
