From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [enctypes round 2: PATCH 11/26] gss_krb5: import functionality to
	derive keys into the kernel
Date: Wed, 30 Apr 2008 12:46:44 -0400
Message-ID: <20080430164644.16010.42166.stgit@jazz.citi.umich.edu>
References: <20080430164306.16010.44650.stgit@jazz.citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from citi.umich.edu ([141.211.133.111]:41641 "EHLO citi.umich.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757325AbYD3Qqo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Apr 2008 12:46:44 -0400
In-Reply-To: <20080430164306.16010.44650.stgit-zTNJhAanYLVZN1qrTdtDg5Vzexx5G7lz@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Import the code to derive Kerberos keys from a base key into the
kernel.  This will allow us to change the format of the context
information sent down from gssd to include only a single key.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 include/linux/sunrpc/gss_krb5.h     |   31 ++++
 net/sunrpc/auth_gss/Makefile        |    2 
 net/sunrpc/auth_gss/gss_krb5_keys.c |  252 +++++++++++++++++++++++++++++++++++
 net/sunrpc/auth_gss/gss_krb5_mech.c |    1 
 4 files changed, 285 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb5.h
index 3bac309..8bb9c46 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -41,6 +41,9 @@
 #include <linux/sunrpc/gss_err.h>
 #include <linux/sunrpc/gss_asn1.h>
 
+/* Length of constant used in key derivation */
+#define GSS_KRB5_K5CLENGTH (5)
+
 /* Maximum key length (in bytes) for the supported crypto algorithms*/
 #define GSS_KRB5_MAX_KEYLEN (32)
 
@@ -69,6 +72,9 @@ struct gss_krb5_enctype {
 	u32 (*decrypt) (struct crypto_blkcipher *tfm,
 			void *iv, void *in, void *out,
 			int length);		/* decryption function */
+	u32 (*mk_key) (struct gss_krb5_enctype *gk5e,
+		       struct xdr_netobj *in,
+		       struct xdr_netobj *out);	/* complete key generation */
 };
 
 struct krb5_ctx {
@@ -150,6 +156,25 @@ extern struct xdr_netobj krb5_oid;
 #define ENCTYPE_UNKNOWN         0x01ff
 
 /*
+ * Constants used for key derivation
+ */
+/* for 3DES */
+#define KG_USAGE_SEAL (22)
+#define KG_USAGE_SIGN (23)
+#define KG_USAGE_SEQ  (24)
+
+/* from rfc3961 */
+#define KEY_USAGE_SEED_CHECKSUM         (0x99)
+#define KEY_USAGE_SEED_ENCRYPTION       (0xAA)
+#define KEY_USAGE_SEED_INTEGRITY        (0x55)
+
+/* from rfc4121 */
+#define KG_USAGE_ACCEPTOR_SEAL  (22)
+#define KG_USAGE_ACCEPTOR_SIGN  (23)
+#define KG_USAGE_INITIATOR_SEAL (24)
+#define KG_USAGE_INITIATOR_SIGN (25)
+
+/*
  * This compile-time check verifies that we will not exceed the
  * slack space allotted by the client and server auth_gss code
  * before they call gss_wrap().
@@ -213,3 +238,9 @@ krb5_get_seq_num(struct crypto_blkcipher *key,
 
 int
 shift_head_data(struct xdr_buf *buf, unsigned int base, unsigned int shiftlen);
+
+u32
+krb5_derive_key(struct gss_krb5_enctype *gk5e,
+		const struct xdr_netobj *inkey,
+		struct xdr_netobj *outkey,
+		const struct xdr_netobj *in_constant);
diff --git a/net/sunrpc/auth_gss/Makefile b/net/sunrpc/auth_gss/Makefile
index 4de8bcf..74a2317 100644
--- a/net/sunrpc/auth_gss/Makefile
+++ b/net/sunrpc/auth_gss/Makefile
@@ -10,7 +10,7 @@ auth_rpcgss-objs := auth_gss.o gss_generic_token.o \
 obj-$(CONFIG_RPCSEC_GSS_KRB5) += rpcsec_gss_krb5.o
 
 rpcsec_gss_krb5-objs := gss_krb5_mech.o gss_krb5_seal.o gss_krb5_unseal.o \
-	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o
+	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
 
 obj-$(CONFIG_RPCSEC_GSS_SPKM3) += rpcsec_gss_spkm3.o
 
diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c b/net/sunrpc/auth_gss/gss_krb5_keys.c
new file mode 100644
index 0000000..832ce90
--- /dev/null
+++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
@@ -0,0 +1,252 @@
+/*
+ * COPYRIGHT (c) 2008
+ * The Regents of the University of Michigan
+ * ALL RIGHTS RESERVED
+ *
+ * Permission is granted to use, copy, create derivative works
+ * and redistribute this software and such derivative works
+ * for any purpose, so long as the name of The University of
+ * Michigan is not used in any advertising or publicity
+ * pertaining to the use of distribution of this software
+ * without specific, written prior authorization.  If the
+ * above copyright notice or any other identification of the
+ * University of Michigan is included in any copy of any
+ * portion of this software, then the disclaimer below must
+ * also be included.
+ *
+ * THIS SOFTWARE IS PROVIDED AS IS, WITHOUT REPRESENTATION
+ * FROM THE UNIVERSITY OF MICHIGAN AS TO ITS FITNESS FOR ANY
+ * PURPOSE, AND WITHOUT WARRANTY BY THE UNIVERSITY OF
+ * MICHIGAN OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING
+ * WITHOUT LIMITATION THE IMPLIED WARRANTIES OF
+ * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
+ * REGENTS OF THE UNIVERSITY OF MICHIGAN SHALL NOT BE LIABLE
+ * FOR ANY DAMAGES, INCLUDING SPECIAL, INDIRECT, INCIDENTAL, OR
+ * CONSEQUENTIAL DAMAGES, WITH RESPECT TO ANY CLAIM ARISING
+ * OUT OF OR IN CONNECTION WITH THE USE OF THE SOFTWARE, EVEN
+ * IF IT HAS BEEN OR IS HEREAFTER ADVISED OF THE POSSIBILITY OF
+ * SUCH DAMAGES.
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
+#include <linux/err.h>
+#include <linux/types.h>
+#include <linux/crypto.h>
+#include <linux/sunrpc/gss_krb5.h>
+#include <linux/sunrpc/xdr.h>
+
+#ifdef RPC_DEBUG
+# define RPCDBG_FACILITY        RPCDBG_AUTH
+#endif
+
+/*
+ * This is the n-fold function as described in rfc3961, sec 5.1
+ * Taken from MIT Kerberos and modified.
+ */
+
+static void krb5_nfold(u32 inbits, const u8 *in,
+		       u32 outbits, u8 *out)
+{
+	int a, b, c, lcm;
+	int byte, i, msbit;
+
+	/* the code below is more readable if I make these bytes
+	   instead of bits */
+
+	inbits >>= 3;
+	outbits >>= 3;
+
+	/* first compute lcm(n,k) */
+
+	a = outbits;
+	b = inbits;
+
+	while (b != 0) {
+		c = b;
+		b = a%b;
+		a = c;
+	}
+
+	lcm = outbits*inbits/a;
+
+	/* now do the real work */
+
+	memset(out, 0, outbits);
+	byte = 0;
+
+	/* this will end up cycling through k lcm(k,n)/k times, which
+	   is correct */
+	for (i = lcm-1; i >= 0; i--) {
+		/* compute the msbit in k which gets added into this byte */
+		msbit = (
+			/* first, start with the msbit in the first,
+			 * unrotated byte */
+			 ((inbits << 3) - 1)
+			 /* then, for each byte, shift to the right
+			  * for each repetition */
+			 + (((inbits << 3) + 13) * (i/inbits))
+			 /* last, pick out the correct byte within
+			  * that shifted repetition */
+			 + ((inbits - (i % inbits)) << 3)
+			 ) % (inbits << 3);
+
+		/* pull out the byte value itself */
+		byte += (((in[((inbits - 1) - (msbit >> 3)) % inbits] << 8)|
+				  (in[((inbits) - (msbit >> 3)) % inbits]))
+				 >> ((msbit & 7) + 1)) & 0xff;
+
+		/* do the addition */
+		byte += out[i % outbits];
+		out[i % outbits] = byte & 0xff;
+
+		/* keep around the carry bit, if any */
+		byte >>= 8;
+
+	}
+
+	/* if there's a carry bit left over, add it back in */
+	if (byte) {
+		for (i = outbits - 1; i >= 0; i--) {
+			/* do the addition */
+			byte += out[i];
+			out[i] = byte & 0xff;
+
+			/* keep around the carry bit, if any */
+			byte >>= 8;
+		}
+	}
+}
+
+/*
+ * This is the DK (derive_key) function as described in rfc3961, sec 5.1
+ * Taken from MIT Kerberos and modified.
+ */
+
+u32 krb5_derive_key(struct gss_krb5_enctype *gk5e,
+		    const struct xdr_netobj *inkey,
+		    struct xdr_netobj *outkey,
+		    const struct xdr_netobj *in_constant)
+{
+	size_t blocksize, keybytes, keylength, n;
+	unsigned char *inblockdata, *outblockdata, *rawkey;
+	struct xdr_netobj inblock, outblock;
+	struct crypto_blkcipher *cipher;
+	u32 ret = EINVAL;
+
+	blocksize = gk5e->blocksize;
+	keybytes = gk5e->keybytes;
+	keylength = gk5e->keylength;
+
+	if ((inkey->len != keylength) || (outkey->len != keylength))
+		goto err_return;
+
+	cipher = crypto_alloc_blkcipher(gk5e->encrypt_name, 0,
+					CRYPTO_ALG_ASYNC);
+	if (IS_ERR(cipher))
+		goto err_return;
+	if (crypto_blkcipher_setkey(cipher, inkey->data, inkey->len))
+		goto err_return;
+
+	/* allocate and set up buffers */
+
+	ret = ENOMEM;
+	inblockdata = kmalloc(blocksize, GFP_KERNEL);
+	if (inblockdata == NULL)
+		goto err_free_cipher;
+
+	outblockdata = kmalloc(blocksize, GFP_KERNEL);
+	if (outblockdata == NULL)
+		goto err_free_in;
+
+	rawkey = kmalloc(keybytes, GFP_KERNEL);
+	if (rawkey == NULL)
+		goto err_free_out;
+
+	inblock.data = (char *) inblockdata;
+	inblock.len = blocksize;
+
+	outblock.data = (char *) outblockdata;
+	outblock.len = blocksize;
+
+	/* initialize the input block */
+
+	if (in_constant->len == inblock.len) {
+		memcpy(inblock.data, in_constant->data, inblock.len);
+	} else {
+		krb5_nfold(in_constant->len * 8, in_constant->data,
+			   inblock.len * 8, inblock.data);
+	}
+
+	/* loop encrypting the blocks until enough key bytes are generated */
+
+	n = 0;
+	while (n < keybytes) {
+		(*(gk5e->encrypt))(cipher, NULL, inblock.data,
+				   outblock.data, inblock.len);
+
+		if ((keybytes - n) <= outblock.len) {
+			memcpy(rawkey + n, outblock.data, (keybytes - n));
+			break;
+		}
+
+		memcpy(rawkey + n, outblock.data, outblock.len);
+		memcpy(inblock.data, outblock.data, outblock.len);
+		n += outblock.len;
+	}
+
+	/* postprocess the key */
+
+	inblock.data = (char *) rawkey;
+	inblock.len = keybytes;
+
+	BUG_ON(gk5e->mk_key == NULL);
+	ret = (*(gk5e->mk_key))(gk5e, &inblock, outkey);
+	if (ret) {
+		dprintk("%s: got %d from mk_key function for '%s'\n",
+			__func__, ret, gk5e->encrypt_name);
+		goto err_free_raw;
+	}
+
+	/* clean memory, free resources and exit */
+
+	ret = 0;
+
+err_free_raw:
+	memset(rawkey, 0, keybytes);
+	kfree(rawkey);
+err_free_out:
+	memset(outblockdata, 0, blocksize);
+	kfree(outblockdata);
+err_free_in:
+	memset(inblockdata, 0, blocksize);
+	kfree(inblockdata);
+err_free_cipher:
+	crypto_free_blkcipher(cipher);
+err_return:
+	return ret;
+}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index ed73441..ca7cbc5 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -60,6 +60,7 @@ static struct gss_krb5_enctype supported_gss_krb5_enctypes[] = {
 	  .cksum_name = "md5",
 	  .encrypt = krb5_encrypt,
 	  .decrypt = krb5_decrypt,
+	  .mk_key = NULL,
 	  .signalg = SGN_ALG_DES_MAC_MD5,
 	  .sealalg = SEAL_ALG_DES,
 	  .keybytes = 7,

