Received: from mail-ej1-f50.google.com (mail-ej1-f50.google.com [209.85.218.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F06943D5668
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 20:50:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791406253; cv=none; b=STWhxuJuFfwstxUkZA5taIaSmtzQP0xH4+IdyTTEbbiD8UXcqF8P5wXsY35BUtvA2RGM1CBCiW8iuTiIoqzamT9Bq4tVSe+Q1ZcpHsm1X9QlumpPDgEFDUs86XIfqMGizUTURLWR0DBOJiVf90HZMCg7jVvI7gcE3QS5WBKGAYA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791406253; c=relaxed/simple;
	bh=EXFVAvTC/vWiJrFlpA2elpEgBuaKO/kQcp09aEgW/vo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Bs/nh29AnET1u8a0JACCFs5ekDM6QwnkXYbLsgv+nLiFUlL9+ieXgGRxipXd9ipjV8Vavj/XU4jMeyKH4B4TnFdnFka3v4wZaBmx0eOpo/gRyqORLM0Wc4bFTlvDrAT8P39+3kB/HNU6mCjuLUuQLuB5oXMx4akirISQCons4tc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=l7RBQR2G; arc=none smtp.client-ip=209.85.218.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="l7RBQR2G"
Received: by mail-ej1-f50.google.com with SMTP id a640c23a62f3a-c262f1186f0so305802366b.1
        for <linux-nfs@vger.kernel.org>; Wed, 07 Oct 2026 13:50:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1791406250; x=1792011050; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Io16ZQYZqnv/XY4N0OIZ2PKkHhmCNfXqi9mdoeoE9zg=;
        b=l7RBQR2G5krsT0OJmuAHyFfkijU1GAYfYSSkUz5zTXEGVUgYBEGpqvx/0y33r/Rp8c
         2i6iIJJtP/9yjZR7o6Kuxeq2X6shspNE6Vwv2lB2dbMBxkl/lMhvcHTI4bdSxXDAasbC
         Eo/xs0cAhPcHLVBcVH7c1J530qrLrBbpg/lW0cDGLWPRMYdf80/FpzbsP4f+ajay5BHq
         Sjzxdk9P+0R66V9MJMa0lbzuoSWSnPglJZ0p8QYLS8yLotP9yUIh4ouq6Abc22b5awwZ
         kgn4V3P/zcoFS0tFCkjp94lSsPfF8AdPT3yTKealqSBNs6fF/4FkRXLlJNfzZP3eeGvM
         UENw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791406250; x=1792011050;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Io16ZQYZqnv/XY4N0OIZ2PKkHhmCNfXqi9mdoeoE9zg=;
        b=E7Nl0oGPnv7S7qqKLm8YDMWkV2/RDvZvyzNED0gA0QAqrUyKATzuyBYNb1wQxpUpQt
         vZ639exPU9nXfxKxFKXjZGhOhFNUXElU+kJ0MB8t2TjnD/9S2I55KUmRiuKWA1fy8gWa
         Bpj8rPuLsHzyHLrbvfTZVXlpcrAMimqz+D8Z5nFmUzoqDz8LbYBsLPN45Jx1GV62KVCw
         qFNMvTMKpWTTbp1CH4enrKeqhnbsXMmFwv/pnbjDX1oftDBaR+RBTYCPwH2J9+OdztS1
         9RnAGFGJI49U3UuRpZEugP98wfLTWqng5lyv2Pwf2vClPiUt1qk2ddt5QyjsHTqeU4ja
         QrxA==
X-Gm-Message-State: AFq9FYLMmv3EYZwMuKCHKqfD+/XTYhuIa31nR9bM8JaIuVRvnyw7dNjB
	DqGMpNc7u52BgMMzVckdNQ3r46gpZcyIvvuYlfJjR8ylQGQoO9sAFdsi4rqhly17
X-Gm-Gg: AYBFou3jLtQ7OBnw0ICrottV00+VQnzUVOz7agpCEbAUEKewWITtRWsNzL5lRSZ3taJ
	XuhZ6pTd8fP81atKHJJYacGczIyft4DH0Oss5zY8DFHwYSRVSM6Jjpe/yRt7OVZTEm98+3xr025
	h781EYRWx9iXfnalM5FDrrTDufBU2LZbI6nuAcsulsb0TwzbHyQx1901kY+Pez05muC6FU/U238
	4ymW6Zc9vNPKr80MPVTA0TohOZRhPFoDqcoZt/gqkN2MySczVTpCgNsdkhAvsiAihG9WlHajn+E
	U5r7JXi3j9LbGKVS0VRiuUQqUKbB50NGwPhz4kw0N60o3B/1cUG6B3vFSNvW7ayPdKndEeVyIxw
	XX8sZvL2ZK3853B9q5VAG3yRkIPZ9MRE4nLK8TKj50Siu7McnLuLRzL3zyctVjYP4ZpnDaR7QGQ
	Xe8jpJ4RMj6A/Wc7trwmZu6FXy2GKzj3ixdV9FFKHOUyLP+0CMEdNI96dTviCQfe66BQKJEtFY0
	C4FbvZeFCNw59WYPQfrWprYZK6BKaSDNrxU0N0hCPxxd3m7m/AA
X-Received: by 2002:a17:907:948f:b0:c2d:d1d8:b220 with SMTP id a640c23a62f3a-c317c0d9959mr343402466b.42.1791406250029;
        Wed, 07 Oct 2026 13:50:50 -0700 (PDT)
Received: from docker-desktop (host-145-14-240-255.wtvk.pl. [145.14.240.255])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c317c1c66fbsm141707166b.45.2026.10.07.13.50.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 07 Oct 2026 13:50:49 -0700 (PDT)
From: Marcin Krystianc <marcin.krystianc@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org,
	Marcin Krystianc <marcin.krystianc@gmail.com>
Subject: [PATCH] SUNRPC: reset the svc decode stream after unwrapping a privacy request
Date: Wed,  7 Oct 2026 20:49:17 +0000
Message-ID: <20261007204917.1818086-1-marcin.krystianc@gmail.com>
X-Mailer: git-send-email 2.51.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

For RPCSEC_GSS privacy (krb5p), gss_krb5_unwrap_v2() decrypts the request
in place and then removes the GSS token header and the confounder from the
head iovec: it memmoves the plaintext down to @offset and subtracts
GSS_KRB5_TOK_HDR_LEN + headskip (32 bytes for the AES enctypes) from
buf->head[0].iov_len.

svcauth_gss_unwrap_priv() only accounts for that in xdr->nwords. The
stream's xdr->end still points at the end of the head as it was before
unwrapping, 32 bytes past the data that is now there.

Decoding is unaffected while every argument lies within the head. It breaks
once an argument spans the head and the page array: xdr_stream_subsegment()
advances to the stale xdr->end, so it counts 32 bytes of leftover head
buffer as argument data and then takes 32 bytes too few from the pages.
xdr_stream_set_pos() corrects the position counter but not xdr->p, which is
left 32 bytes inside the argument. The next operation of the COMPOUND is
then decoded from argument data.

Do what the client already does in gss_unwrap_resp_priv() after decrypting
a reply: discard the stream and build a new one over the buffer as it now
is.

Fixes: 42140718ea26 ("SUNRPC: Convert unwrap_priv_data() to use xdr_stream")
Signed-off-by: Marcin Krystianc <marcin.krystianc@gmail.com>
---
Found with xfstests generic/486 (a 1-byte to 64 KiB XATTR_REPLACE) on an
NFSv4.2 mount with sec=krb5p; sec=sys and sec=krb5i pass. Tested with
knfsd and the NFS client in one UML kernel over loopback, an MIT KDC in the
guest and an xfs-backed export: generic/486 fails without this change and
passes with it, and xfstests -g quick under krb5p shows no other
difference.

 net/sunrpc/auth_gss/svcauth_gss.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index ab01156a1af9..d5da541353e7 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -944,7 +944,6 @@ svcauth_gss_unwrap_priv(struct svc_rqst *rqstp, u32 seq, struct gss_ctx *ctx)
 	struct xdr_stream *xdr = &rqstp->rq_arg_stream;
 	u32 len, maj_stat, seq_num, offset;
 	struct xdr_buf *buf = xdr->buf;
-	unsigned int saved_len;
 
 	if (xdr_stream_decode_u32(xdr, &len) < 0)
 		goto unwrap_failed;
@@ -959,11 +958,14 @@ svcauth_gss_unwrap_priv(struct svc_rqst *rqstp, u32 seq, struct gss_ctx *ctx)
 		goto unwrap_failed;
 	offset = xdr_stream_pos(xdr);
 
-	saved_len = buf->len;
 	maj_stat = gss_unwrap(ctx, offset, offset + len, buf);
 	if (maj_stat != GSS_S_COMPLETE)
 		goto bad_unwrap;
-	xdr->nwords -= XDR_QUADLEN(saved_len - buf->len);
+	/* gss_unwrap redacts the opaque blob from the head iovec.
+	 * buf has changed, thus the stream needs to be reset.
+	 */
+	xdr_init_decode(xdr, buf, buf->head[0].iov_base + offset, NULL);
+	xdr_set_scratch_folio(xdr, rqstp->rq_scratch_folio);
 
 out_seq:
 	/* gss_unwrap() decrypted the sequence number. */
-- 
2.51.0

