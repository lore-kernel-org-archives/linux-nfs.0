Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43426 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755254Ab2EAXwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 19:52:12 -0400
Date: Tue, 1 May 2012 19:52:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kevin Coffman <kwc@umich.edu>
Cc: NFS list <linux-nfs@vger.kernel.org>, Steve Dickson <SteveD@redhat.com>,
        aglo@citi.umich.edu
Subject: Re: RFC: Handling GSS rotated data
Message-ID: <20120501235210.GA2083@fieldses.org>
References: <CAKnQG+dVhQ3JSXJnQihzs0FnS_aeyUKftDX7j7X6iJTjRGMzPQ@mail.gmail.com>
 <20120410215633.GL18465@fieldses.org>
 <20120410230202.GM18465@fieldses.org>
 <CAKnQG+fBw8--kfGmEvh4Fq0tzfAKq0gwi6kQHsKMQ38YmJNQ_A@mail.gmail.com>
 <20120412001224.GB2523@fieldses.org>
 <20120412001922.GC2523@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120412001922.GC2523@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2012 at 08:19:22PM -0400, J. Bruce Fields wrote:
> On Wed, Apr 11, 2012 at 08:12:24PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 10, 2012 at 08:56:56PM -0400, Kevin Coffman wrote:
> > > The rotation values we've seen from Microsoft clients/servers for AES
> > > have been 28.  Your code definitely looks simpler!
> > 
> > So, here's something that actually compiles.  I'll need someone else to
> > test, though, and I won't be at all surprised if it needs some
> > fixing....

By the way, handing it off to Olga for testing this afternoon I gave it
some more review and found some bugs; this is the version she's testing.

--b.

commit 52980de302070f9c182d18a803a51196617c509f
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Wed Apr 11 20:08:45 2012 -0400

    rpc: handle rotated gss data for Windows interoperability
    
    The data in Kerberos gss tokens can be rotated.  But we were lazy and
    rejected any nonzero rotation value.  It wasn't necessary for the
    implementations we were testing against at the time.
    
    But it appears that Windows does use a nonzero value here.
    
    So, implement rotation to bring ourselves into compliance with the spec
    and to interoperate with Windows.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 38f388c..107c452 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -381,21 +381,53 @@ gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 }
 
 /*
- * We cannot currently handle tokens with rotated data.  We need a
- * generalized routine to rotate the data in place.  It is anticipated
- * that we won't encounter rotated data in the general case.
+ * We can shift data by up to LOCAL_BUF_LEN bytes in a pass.  If we need
+ * to do more than that, we shift repeatedly.  Kevin Coffman reports
+ * seeing 28 bytes as the value used by Microsoft clients and servers
+ * with AES, so this constant is chosen to allow handling 28 in one pass
+ * without using too much stack space.
+ *
+ * If that proves to a problem perhaps we could use a more clever
+ * algorithm.
  */
-static u32
-rotate_left(struct krb5_ctx *kctx, u32 offset, struct xdr_buf *buf, u16 rrc)
+#define LOCAL_BUF_LEN 32u
+
+static void rotate_buf_a_little(struct xdr_buf *buf, unsigned int shift)
 {
-	unsigned int realrrc = rrc % (buf->len - offset - GSS_KRB5_TOK_HDR_LEN);
+	char head[LOCAL_BUF_LEN];
+	char tmp[LOCAL_BUF_LEN];
+	unsigned int this_len, i;
+
+	BUG_ON(shift > LOCAL_BUF_LEN);
 
-	if (realrrc == 0)
-		return 0;
+	read_bytes_from_xdr_buf(buf, 0, head, shift);
+	for (i = 0; i + shift < buf->len; i += LOCAL_BUF_LEN) {
+		this_len = min(LOCAL_BUF_LEN, buf->len - (i + shift));
+		read_bytes_from_xdr_buf(buf, i+shift, tmp, this_len);
+		write_bytes_to_xdr_buf(buf, i, tmp, this_len);
+	}
+	write_bytes_to_xdr_buf(buf, buf->len - shift, head, shift);
+}
 
-	dprintk("%s: cannot process token with rotated data: "
-		"rrc %u, realrrc %u\n", __func__, rrc, realrrc);
-	return 1;
+static void _rotate_left(struct xdr_buf *buf, unsigned int shift)
+{
+	int shifted = 0;
+	int this_shift;
+
+	shift %= buf->len;
+	while (shifted < shift) {
+		this_shift = min(shift - shifted, LOCAL_BUF_LEN);
+		rotate_buf_a_little(buf, this_shift);
+		shifted += this_shift;
+	}
+}
+
+static void rotate_left(u32 base, struct xdr_buf *buf, unsigned int shift)
+{
+	struct xdr_buf subbuf;
+
+	xdr_buf_subsegment(buf, &subbuf, base, buf->len - base);
+	_rotate_left(&subbuf, shift);
 }
 
 static u32
@@ -495,11 +527,8 @@ gss_unwrap_kerberos_v2(struct krb5_ctx *kctx, int offset, struct xdr_buf *buf)
 
 	seqnum = be64_to_cpup((__be64 *)(ptr + 8));
 
-	if (rrc != 0) {
-		err = rotate_left(kctx, offset, buf, rrc);
-		if (err)
-			return GSS_S_FAILURE;
-	}
+	if (rrc != 0)
+		rotate_left(offset + 16, buf, rrc);
 
 	err = (*kctx->gk5e->decrypt_v2)(kctx, offset, buf,
 					&headskip, &tailskip);
