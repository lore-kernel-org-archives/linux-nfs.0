Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47765 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752815Ab2DLAM0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 20:12:26 -0400
Date: Wed, 11 Apr 2012 20:12:24 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kevin Coffman <kwc@umich.edu>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>
Subject: Re: RFC: Handling GSS rotated data
Message-ID: <20120412001224.GB2523@fieldses.org>
References: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
 <20120410215633.GL18465@fieldses.org>
 <20120410230202.GM18465@fieldses.org>
 <CAKnQG+fBw8--kfGmEvh4Fq0tzfAKq0gwi6kQHsKMQ38YmJNQ_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAKnQG+fBw8--kfGmEvh4Fq0tzfAKq0gwi6kQHsKMQ38YmJNQ_A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 10, 2012 at 08:56:56PM -0400, Kevin Coffman wrote:
> The rotation values we've seen from Microsoft clients/servers for AES
> have been 28.  Your code definitely looks simpler!

So, here's something that actually compiles.  I'll need someone else to
test, though, and I won't be at all surprised if it needs some
fixing....

--b.

commit cf3f40cb1fdda74abf76614f03eb00f5d6f35b54
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Apr 11 20:08:45 2012 -0400

    rpc: handle rotated gss data for Windows interoperability
    
    The data in Kerberos gss tokens can be rotated.  But we were lazy and
    rejected any nonzero rotation value.  It wasn't necessary for the
    implementations we were testing against at the time.
    
    But it appears that Windows does use a nonzero value here.
    
    So, implementation rotation to bring ourselves into compliance with the
    spec and to interoperate with Windows.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 38f388c..2070681 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -381,21 +381,47 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 }
 
 /*
- * We cannot currently handle tokens with rotated data.  We need a
- * generalized routine to rotate the data in place.  It is anticipated
- * that we won't encounter rotated data in the general case.
+ * We can shift data by up to LOCAL_BUF_LEN bytes in a pass.  If we need
+ * to do more than that, we shift repeatedly.  Kevin Coffman reports
+ * seeing 28 bytes as the value used by Microsoft clients and servers
+ * with AES, so this constant is chosen to allow handling 28 in one pass
+ * without using two much stack space.
+ *
+ * If that proves to a problem perhaps we could use a more clever
+ * algorithm.
  */
-static u32
-rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
+#define LOCAL_BUF_LEN 32u
+
+void shift_buf_a_little(struct xdr_buf *buf, unsigned int shift)
 {
-	unsigned int realrrc = rrc % (buf->len - offset - GSS_KRB5_TOK_HDR_LEN);
+	char head[LOCAL_BUF_LEN];
+	unsigned int this_len, i;
 
-	if (realrrc == 0)
-		return 0;
+	BUG_ON(shift > LOCAL_BUF_LEN);
 
-	dprintk("%s: cannot process token with rotated data: "
-		"rrc %u, realrrc %u\n", __func__, rrc, realrrc);
-	return 1;
+	read_bytes_from_xdr_buf(buf, 0, head, shift);
+	for (i=0; i + shift < buf->len; i += shift) {
+		char tmp[LOCAL_BUF_LEN];
+		this_len = min(shift, buf->len - i);
+		read_bytes_from_xdr_buf(buf, i+shift, tmp, this_len);
+		write_bytes_to_xdr_buf(buf, i, tmp, this_len);
+	}
+	write_bytes_to_xdr_buf(buf, buf->len - shift, head, shift);
+}
+
+void rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, unsigned int rrc)
+{
+	struct xdr_buf subbuf;
+	int shifted = 0;
+	int this_shift;
+
+	rrc %= buf->len;
+	xdr_buf_subsegment(buf, &subbuf, offset, buf->len);
+	while (shifted < rrc) {
+		this_shift = min(rrc, LOCAL_BUF_LEN);
+		shift_buf_a_little(&subbuf, this_shift);
+		shifted += this_shift;
+	}
 }
 
 static u32
@@ -495,11 +521,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	seqnum = be64_to_cpup((__be64 *)(ptr + 8));
 
-	if (rrc != 0) {
-		err = rotate_left(kctx, offset, buf, rrc);
-		if (err)
-			return GSS_S_FAILURE;
-	}
+	if (rrc != 0)
+		rotate_left(kctx, offset, buf, rrc);
 
 	err = (*kctx->gk5e->decrypt_v2)(kctx, offset, buf,
 					&headskip, &tailskip);
