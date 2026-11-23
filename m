Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=46.4.95.116
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795395426;
	b=qbSh/+DS+0MvVPtoqikGqXGrbLXWKQfb5wgv2jvd3hNFc0AfFIzM0OBraC69DXoWS6wr
	 9qs6vBiKZCVKkrV2vm2u8MAGJzcbAgEEcN6ZADVx/rSS9HC34aFAWUZ/+Os5+RHTGtTMw
	 j11v/FUoa1w7IB0wztA6T4dsaNkGew2pkm9BakV7u2cHJ2xT1b8H/ZiN85xO2jCC8jRQK
	 WuS0LtW5d7+kGFXxllawMPOE3KXQAx21gC4Yh3xQeZRAqtLyAM5w/k1d6I2yYj7jEsdL7
	 auUmWMb2feChHt0sfuI/tC8rVPaua5Ti2pO8hKIqCXS0rb0E6nsozSzqciFzQNldpQw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795395426;
	h=DMARC-Filter:Received:DKIM-Signature:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=TEsERubr0nxn3V+b4tExa2I4w/jU3AIUXY9+wvk7pSo=;
	b=yhxTcTvTmMwqoTz498+j++QPTWoz22DqpvKYNpw3QCgSHSWjfDzVaOU6ryN5EC6URjZe
	 MY9CZ0X3trRGJ43P+2iEyDEvlJnd/kbV5qRrKMcmMt3TteLBgX7PBHVjP9fef9anEG9xi
	 09ufulcIxDfRIErqO8x5TcXXgjFgZVtZxTcrV081/TTCeoeb23wUPQRoyiJ0JItg1mBpT
	 DjEoZ7oJC8msSGIq6zPldptwCs0WcOumLRkXKQmDw6Ht8YU3WTLsaB7zS1M72CLJ/b7nE
	 i6Ago9tBxQElZZgbPc4GmUlaNQztRYPFqESDcG74QhpNbR+p9khLtmwVb1FfXv1juSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=fail header.from=dolda2000.com;
	spf=none smtp.mailfrom=dolda2000.com;
	dkim=fail reason="signature verification failed" header.d=dolda2000.com header.i=@dolda2000.com header.a=rsa-sha256 header.s=dolda header.b=WptCuvrF;
	arc=none smtp.remote-ip=46.4.95.116
Received: from ansgar.seatribe.se (unknown [46.4.95.116])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (prime256v1) server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A441C606A681;
	Mon, 23 Nov 2026 00:57:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A441C606A681
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=dolda2000.com
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=dolda2000.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key, unprotected) header.d=dolda2000.com header.i=@dolda2000.com header.a=rsa-sha256 header.s=dolda header.b=WptCuvrF
Received: from [2001:9b1:40cc:0:ffff:e9ff:2d3f:febd] (helo=nerv.dolda2000.com)
	by ansgar.seatribe.se with esmtps  (TLS1.3) tls TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
	(Exim 4.96)
	(envelope-from <fredrik@dolda2000.com>)
	id 1xVIMZ-0004Z5-1Z;
	Mon, 23 Nov 2026 01:56:55 +0100
DKIM-Signature: v=1; a=rsa-sha256; c=simple/simple; d=dolda2000.com;
	s=dolda; t=1795395411;
	bh=ktLwfBjNFkTg+TnjlCy4sYPCk4m1323utcqzfsDZJbo=;
	h=From:To:Cc:Subject:Date:From;
	b=WptCuvrF7kmg1Nqbd1o1Wivt2IPd4U0VSjviIhJWIirqVe4nzt1VmmRqiqoWtG/V5
	 P3goS5BHNQBytSnfce66q377RGHRup5LAPM2+RIl7nJ8MLsZKwMIiAwboGAjqcCjCW
	 SI/tGuyTlPNFDcjiLCLIkMxPhZQRgtpqFxfxt22qIxhof1CQ9mWPifcWKkAUMZYg+o
	 VJetRxrxdl5+k0EKR05YqXsQvgW9EZR+lIdxOmrgOLXxWU/ZLnr6AHTNIjxN6fw+YZ
	 CIJETCoIdeTc8kVbD1SCTDotD7cPLbmikUuIrGJBMC0NStFe3mmYfF96WmroY89sqc
	 Y7rjUoKYXLftQ==
Received: from shack.dolda2000.com (shack.dolda2000.com [192.168.1.187])
	(authenticated bits=0)
	by nerv.dolda2000.com (8.18.1/8.18.1/Debian-6) with ESMTPSA id 6AN0unRC017457
	(version=TLSv1.3 cipher=TLS_AES_256_GCM_SHA384 bits=256 verify=NO);
	Mon, 23 Nov 2026 01:56:51 +0100
From: Fredrik Tolf <fredrik@dolda2000.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, Fredrik Tolf <fredrik@dolda2000.com>
Subject: [PATCH] SUNRPC: Make svcauth_gss sequence-number window size tunable
Date: Mon, 23 Nov 2026 01:56:48 +0100
Message-ID: <20261123005648.29562-1-fredrik@dolda2000.com>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The concrete problem that I seek to resolve with this is an issue where MIC
verification, due to being schedulable, may sometimes delay the checking of
sequence number so long that the sequence window in the meantime has drifted
beyond the sequence number being verified. This causes the NFS server to
disconnect the client in question despite it having done nothing wrong, making
the client do 15-second timeouts before reconnecting and retrying, killing
performance.

Now, I would of course like to fix this *properly*, since the client, indeed, is
doing nothing wrong, but as far as I can tell, I am not sure there is a way to
fix this properly in a TCP context without serializing the entire authentication
process, which in turn seems that it would require a full rewrite of the sunrpc
servicing threading model, since it seems made to be intrinsically asynchronous.
This makes sense given its past UDP primacy, where also the occasional dropping
of a packet due to transient authentication failures like these would not be an
issue since the request would just be treated as lost and retransmitted by the
client, but in a TCP context, clearly, retransmission is left to the network
layer and the client just terminates the whole connection on an authentication
failure instead.

Due to this difficulty in developing a proper fix, probably better done by
someone actually familiar with the NFS/sunrpc code, I'm just making the window
size tunable, so that I tune myself out of the problem. I considered a number of
other heuristics along the way, but since they weren't really technically more
correct, I figured this was the simplest and therefore best.

The default window size was also inreased from 128 to 1024, due to 128 being
clearly too small.

This also relates to <https://bugzilla.linux-nfs.org/show_bug.cgi?id=416>

Signed-off-by: Fredrik Tolf <fredrik@dolda2000.com>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 123 ++++++++++++++++++++++--------
 1 file changed, 91 insertions(+), 32 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 78d30d5dc72f..4d82ecb230e4 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -26,8 +26,8 @@
  * The content of this cache includes some of the outputs of GSS_Accept_sec_context,
  * being major_status, minor_status, context_handle, reply_token.
  * These are sent back to the client.
- * Sequence window management is handled by the kernel.  The window size if currently
- * a compile time constant.
+ * Sequence window management is handled by the kernel.  The window size is tunable
+ * via sysctl.
  *
  * When user-space is happy that a context is established, it places an entry
  * in the rpcsec_context cache. The key for this cache is the context_handle.
@@ -42,6 +42,7 @@
 #include <linux/types.h>
 #include <linux/module.h>
 #include <linux/pagemap.h>
+#include <linux/sysctl.h>
 #include <linux/user_namespace.h>
 
 #include <linux/sunrpc/auth_gss.h>
@@ -354,14 +355,35 @@ static struct rsi *rsi_update(struct cache_detail *cd, struct rsi *new, struct r
 #define	RSC_HASHBITS	10
 #define	RSC_HASHMAX	(1<<RSC_HASHBITS)
 
-#define GSS_SEQ_WIN	128
+#define GSS_SEQ_WIN_MIN		    0x80
+#define GSS_SEQ_WIN_DEFAULT	   0x400
+#define GSS_SEQ_WIN_MAX		0x100000
+
+static unsigned int gss_seq_win_size = GSS_SEQ_WIN_DEFAULT;
+
+static struct ctl_table_header *sysctl_table_header;
+
+static struct ctl_table gss_tunables_table[] = {
+	{
+		.procname	= "gss_seq_win_size",
+		.data		= &gss_seq_win_size,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= proc_douintvec_minmax,
+		.extra1		= &(unsigned int[]){GSS_SEQ_WIN_MIN},
+		.extra2		= &(unsigned int[]){GSS_SEQ_WIN_MAX}
+	},
+};
+
 
 struct gss_svc_seq_data {
+	/* size of this context's sequence window.: */
+	u32			sd_size;
 	/* highest seq number seen so far: */
 	u32			sd_max;
-	/* for i such that sd_max-GSS_SEQ_WIN < i <= sd_max, the i-th bit of
+	/* for i such that sd_max-sd_size < i <= sd_max, the i-th bit of
 	 * sd_win is nonzero iff sequence number i has been seen already: */
-	unsigned long		sd_win[GSS_SEQ_WIN/BITS_PER_LONG];
+	unsigned long		*sd_win;
 	spinlock_t		sd_lock;
 };
 
@@ -390,6 +412,7 @@ static void rsc_free_rcu(struct rcu_head *head)
 	struct rsc *rsci = container_of(head, struct rsc, rcu_head);
 
 	kfree(rsci->handle.data);
+	bitmap_free(rsci->seqdata.sd_win);
 	kfree(rsci);
 }
 
@@ -437,11 +460,13 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 {
 	struct rsc *new = container_of(cnew, struct rsc, h);
 	struct rsc *tmp = container_of(ctmp, struct rsc, h);
+	struct gss_svc_seq_data *sd = &new->seqdata;
 
 	new->mechctx = tmp->mechctx;
 	tmp->mechctx = NULL;
-	memset(&new->seqdata, 0, sizeof(new->seqdata));
-	spin_lock_init(&new->seqdata.sd_lock);
+	sd->sd_max = 0;
+	bitmap_zero(sd->sd_win, sd->sd_size);
+	spin_lock_init(&sd->sd_lock);
 	new->cred = tmp->cred;
 	init_svc_cred(&tmp->cred);
 }
@@ -449,11 +474,24 @@ update_rsc(struct cache_head *cnew, struct cache_head *ctmp)
 static struct cache_head *
 rsc_alloc(void)
 {
-	struct rsc *rsci = kmalloc_obj(*rsci);
+	struct rsc *rsci = NULL;
+	struct gss_svc_seq_data *sd = NULL;
+
+	rsci = kzalloc_obj(*rsci, GFP_KERNEL);
+	if (!rsci)
+		goto error;
+	sd = &rsci->seqdata;
+	sd->sd_size = READ_ONCE(gss_seq_win_size);
+	sd->sd_win = bitmap_zalloc(sd->sd_size, GFP_KERNEL);
+	if (!sd->sd_win)
+		goto error;
+	return &rsci->h;
+error:
+	if (sd && sd->sd_win)
+		bitmap_free(sd->sd_win);
 	if (rsci)
-		return &rsci->h;
-	else
-		return NULL;
+		kfree(rsci);
+	return NULL;
 }
 
 static int rsc_upcall(struct cache_detail *cd, struct cache_head *h)
@@ -660,19 +698,19 @@ static bool gss_check_seq_num(const struct svc_rqst *rqstp, struct rsc *rsci,
 
 	spin_lock(&sd->sd_lock);
 	if (seq_num > sd->sd_max) {
-		if (seq_num >= sd->sd_max + GSS_SEQ_WIN) {
-			memset(sd->sd_win, 0, sizeof(sd->sd_win));
+		if (seq_num >= sd->sd_max + sd->sd_size) {
+			bitmap_zero(sd->sd_win, sd->sd_size);
 			sd->sd_max = seq_num;
 		} else while (sd->sd_max < seq_num) {
 			sd->sd_max++;
-			__clear_bit(sd->sd_max % GSS_SEQ_WIN, sd->sd_win);
+			__clear_bit(sd->sd_max % sd->sd_size, sd->sd_win);
 		}
-		__set_bit(seq_num % GSS_SEQ_WIN, sd->sd_win);
+		__set_bit(seq_num % sd->sd_size, sd->sd_win);
 		goto ok;
-	} else if (seq_num + GSS_SEQ_WIN <= sd->sd_max) {
+	} else if (seq_num + sd->sd_size <= sd->sd_max) {
 		goto toolow;
 	}
-	if (__test_and_set_bit(seq_num % GSS_SEQ_WIN, sd->sd_win))
+	if (__test_and_set_bit(seq_num % sd->sd_size, sd->sd_win))
 		goto alreadyseen;
 
 ok:
@@ -683,7 +721,7 @@ static bool gss_check_seq_num(const struct svc_rqst *rqstp, struct rsc *rsci,
 
 toolow:
 	trace_rpcgss_svc_seqno_low(rqstp, seq_num,
-				   sd->sd_max - GSS_SEQ_WIN,
+				   sd->sd_max - sd->sd_size,
 				   sd->sd_max);
 	goto out;
 alreadyseen:
@@ -1018,24 +1056,20 @@ svcauth_gss_set_client(struct svc_rqst *rqstp)
 }
 
 static bool
-svcauth_gss_proc_init_verf(struct cache_detail *cd, struct svc_rqst *rqstp,
-			   struct xdr_netobj *out_handle, int *major_status,
-			   u32 seq_num)
+svcauth_gss_proc_init_verf(struct rsc *rsci, struct svc_rqst *rqstp,
+			   int *major_status)
 {
 	struct xdr_stream *xdr = &rqstp->rq_res_stream;
-	struct rsc *rsci;
 	bool rc;
 
 	if (*major_status != GSS_S_COMPLETE)
 		goto null_verifier;
-	rsci = gss_svc_searchbyctx(cd, out_handle);
 	if (rsci == NULL) {
 		*major_status = GSS_S_NO_CONTEXT;
 		goto null_verifier;
 	}
 
-	rc = svcauth_gss_encode_verf(rqstp, rsci->mechctx, seq_num);
-	cache_put(&rsci->h, cd);
+	rc = svcauth_gss_encode_verf(rqstp, rsci->mechctx, rsci->seqdata.sd_size);
 	return rc;
 
 null_verifier:
@@ -1169,11 +1203,13 @@ svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 {
 	struct xdr_stream *xdr = &rqstp->rq_arg_stream;
 	struct rsi *rsip, rsikey;
+	struct rsc *rscp;
 	__be32 *p;
 	u32 len;
 	int ret;
 	struct sunrpc_net *sn = net_generic(SVC_NET(rqstp), sunrpc_net_id);
 
+	rscp = NULL;
 	memset(&rsikey, 0, sizeof(rsikey));
 	if (dup_netobj(&rsikey.in_handle, &gc->gc_ctx))
 		return SVC_CLOSE;
@@ -1212,18 +1248,23 @@ svcauth_gss_legacy_init(struct svc_rqst *rqstp,
 		return SVC_CLOSE;
 
 	ret = SVC_CLOSE;
-	if (!svcauth_gss_proc_init_verf(sn->rsc_cache, rqstp, &rsip->out_handle,
-					&rsip->major_status, GSS_SEQ_WIN))
+	if (rsip->major_status == GSS_S_COMPLETE)
+		rscp = gss_svc_searchbyctx(sn->rsc_cache, &rsip->out_handle);
+	if (!svcauth_gss_proc_init_verf(rscp, rqstp, &rsip->major_status))
 		goto out;
 	if (!svcxdr_set_accept_stat(rqstp))
 		goto out;
 	if (!svcxdr_encode_gss_init_res(&rqstp->rq_res_stream, &rsip->out_handle,
 					&rsip->out_token, rsip->major_status,
-					rsip->minor_status, GSS_SEQ_WIN))
+					rsip->minor_status,
+					(rscp != NULL) ? rscp->seqdata.sd_size
+					: READ_ONCE(gss_seq_win_size)))
 		goto out;
 
 	ret = SVC_COMPLETE;
 out:
+	if (rscp != NULL)
+		cache_put(&rscp->h, sn->rsc_cache);
 	cache_put(&rsip->h, sn->rsi_cache);
 	return ret;
 }
@@ -1305,12 +1346,14 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 {
 	struct xdr_netobj cli_handle;
 	struct gssp_upcall_data ud;
+	struct rsc *rscp;
 	uint64_t handle;
 	int status;
 	int ret;
 	struct net *net = SVC_NET(rqstp);
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 
+	rscp = NULL;
 	memset(&ud, 0, sizeof(ud));
 	ret = gss_read_proxy_verf(rqstp, gc, &ud.in_handle, &ud.in_token);
 	if (ret)
@@ -1340,18 +1383,23 @@ static int svcauth_gss_proxy_init(struct svc_rqst *rqstp,
 		goto out;
 	}
 
-	if (!svcauth_gss_proc_init_verf(sn->rsc_cache, rqstp, &cli_handle,
-					&ud.major_status, GSS_SEQ_WIN))
+	if (ud.major_status == GSS_S_COMPLETE)
+		rscp = gss_svc_searchbyctx(sn->rsc_cache, &cli_handle);
+	if (!svcauth_gss_proc_init_verf(rscp, rqstp, &ud.major_status))
 		goto out;
 	if (!svcxdr_set_accept_stat(rqstp))
 		goto out;
 	if (!svcxdr_encode_gss_init_res(&rqstp->rq_res_stream, &cli_handle,
 					&ud.out_token, ud.major_status,
-					ud.minor_status, GSS_SEQ_WIN))
+					ud.minor_status,
+					(rscp != NULL) ? rscp->seqdata.sd_size
+					: READ_ONCE(gss_seq_win_size)))
 		goto out;
 
 	ret = SVC_COMPLETE;
 out:
+	if (rscp != NULL)
+		cache_put(&rscp->h, sn->rsc_cache);
 	gss_free_in_token_pages(&ud.in_token);
 	gssp_free_upcall_data(&ud);
 	return ret;
@@ -2145,11 +2193,22 @@ gss_svc_shutdown_net(struct net *net)
 int
 gss_svc_init(void)
 {
-	return svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
+	int err;
+
+	err = svc_auth_register(RPC_AUTH_GSS, &svcauthops_gss);
+	if (err)
+		return err;
+	if (!sysctl_table_header)
+		sysctl_table_header = register_sysctl("sunrpc", gss_tunables_table);
+	return 0;
 }
 
 void
 gss_svc_shutdown(void)
 {
+	if (sysctl_table_header) {
+		unregister_sysctl_table(sysctl_table_header);
+		sysctl_table_header = NULL;
+	}
 	svc_auth_unregister(RPC_AUTH_GSS);
 }
-- 
2.47.3

