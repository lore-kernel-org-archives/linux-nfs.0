Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254014;
	b=P+eD8tfbbGfvn88lRnStusZSuH9XVitWajkXEO0X09T8WgMqok/+cjhg+alSUVfhIgsP
	 YpbgDJ8Q3aTsSqTdFhjMybCVX7pB41DCA6ikv0WTG0nEyXNnJeeuihGw3vvTdY1i+a8Lf
	 STAyovtU7jaoG123V6WvUUIfR5lX20+vYzjhTqQagGf8OK70XjIoqEfQFqDST7s95ldYT
	 jCxFW01bz95FAx82/prOl8zUHPPs4jjeNgKCJRnGGATaR6URGeyqBgiyGGDitjKGH0isl
	 FY1eJYpgBr2G5/yFtFTPAS+YPalpy7aVnUTlx/pwHumO2/7hXPJsS94qOcU5e0+02Sw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254014;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=MlrY/L8JVyeHzRoseYpzNxVNrSaGp6oi2vPywCYIVzg=;
	b=MHytXvqjo4KnQbjoX+C0bmd67wJxhfYwZgvrv9kIWD2JrrMJVsfeJTZYDWv8NHNeWCEW
	 ayM+I7uccx2hWYIxbTLqjVN65Ukgy6IZdKnW7CjXfAY+A1FiDG4BwgVl8nc/IU6ttcFaw
	 tN5159OHaC3iSD7NK11LLE3g+GFVek1zOaLERVidX7YBYoq0EuoktEvtQiBVY/Uq0bCBj
	 TWkmEhZYNvD85wx4/p68cT6TNtUC9lpwIkxMa38j/p5DS6i0GGtW5hUaCx3nHAhWJfzk1
	 7zHqutbgvKNwh+3BuF4+h/i42IZ5NDHHlmkXmn4C9lgbNZkfW9mCBxJLuHW8DvK6ghw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AVOsM83S;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5BD860A2630
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=AVOsM83S
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E60E91F008BF;
	Mon,  9 Nov 2026 19:53:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254013;
	bh=MlrY/L8JVyeHzRoseYpzNxVNrSaGp6oi2vPywCYIVzg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=AVOsM83ShYSeg7Q/7IrX+3Vdc08DOxDKmFnD3S0d3MoS1AGIQnYR6YWvW3tGYnm38
	 EfcDJhYQr6yntTt/cv+H6KJSIrrttU4SiZp3yVu9quOJqYpJ7EQMZEmehzwuuHuPE4
	 pZWpdni8yz7nmPXgXokYAG+GmYVidHkVwQindL6+hGEI4N27dVBdfd/KT+LCvZwICV
	 GwPA1A2QHDQ13rNj1NsfpL+9fhSwrTdUEA+6p/6yX7eXLl1eCmod9mEpsUyPoqUVCu
	 /FB7QLkhB/HFHoU2jKikk7GKt6jTp4psZJlIBCVeMYlfjMoika01QnvHuUndxFGJLP
	 XszbrgVDos/LQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:20 -0500
Subject: [PATCH 04/13] SUNRPC: Check the Write chunk before inserting an
 opaque payload
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
Message-Id: <20261109-xdr-page-base-v1-4-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=2614; i=cel@kernel.org;
 h=from:subject:message-id; bh=qiU+yIg0tsL8nNEnkhVWPMI4UqT7FtXj7aYKUBi49YM=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS3gbS2g2q/mZ/z8xIOhgk64YPx0ra3Iglzc
 dxTMUYtp2GJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIktwAKCRAzarMzb2Z/
 l09ND/9NXxu7UXFpC3W8Nw3OB8vuCIKMfsuhVn86gWMDD4AcjKPMcbb/tnw7z+FAiOGoXGBt8d4
 f+lE4Ev5uEadzF6HHVjMeNwYySlmSSwmrcpv+X1OsvZDWkiK3wSznAK9OZvEC4qAk6j9UHo+pD1
 AVG2Oa/5hHb2GLa90N0NUBMDYDzD4yWlK1oye0ckx1QduODek+npurRsg+XJs9lc7ocLZGNvYyy
 Q0s7vKizi173Nam8vqJPAhbUK61Tr6df89QILGYOfjxwS4qHmw4ZKdOhAMZ4Sa1nuDQCafUgH5P
 KPhAH9Vr+dtzla2lyyKWDE+RqcahXMm56JIk50w9qHHTp4D2KcMrE5LW1FvY6aRnNaXT1u7/sE0
 /DpmoYTYBbt9qaFOsYsp3R80X4KBRKk64hackBuIjo94H5KIEDhqXtfIihkJIHIUaqDiO60t7IF
 dcsero7C3fs/Q3CEQ0V+S2S4FBc0i1atXjOpZZng2nk2YXJaOaOwLg+sQbwbjNsDy8cAW1smFyN
 wQZ9ht7BTjmgj31Og5hArZK8CASbxwEGauwnv8JQIOJf3R5P9rUCENYN3mXtj6F9NZQJjUl1EHC
 1tlJW/r9YTV9PDAsIIMwNpK9JNFlhXfz8nggu1w0ZbWvm42ABKmRTeU4OxA/Uu5df4Qc9/ckGfa
 T7iNRczCDBod6FQ==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

svcxdr_encode_opaque_payload() inserts the payload pages before it
calls svc_encode_result_payload(). When the payload length is not a
word multiple and svc_rdma_result_payload() fails with -E2BIG, the
XDR pad is already in the tail. xdr_truncate_encode() then hits
WARN_ON_ONCE(fraglen) when it empties the tail. An NFS client on
RPC/RDMA triggers the warning with an odd-length NFSv2 or NFSv3 READ
or READLINK and a short Write chunk, and crashes a system with
panic_on_warn set.

Check the Write chunk before inserting the pages, as
nfsd4_encode_splice_read() does. A splice READ has already set
page_len before the encoder runs, so clear page_len on every failure
exit. Otherwise xdr_truncate_encode() takes the page branch and hits
WARN_ON_ONCE(xdr->iov) for a payload of any length.

svc_rdma_result_payload() has rejected an oversized payload since the
commit below.

Fixes: 7a1cbfa18059 ("svcrdma: Use parsed chunk lists to construct RDMA Writes")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc.h | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b1dff5c8aa89..43ec1c08bed1 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -624,7 +624,8 @@ static inline void svcxdr_encode_opaque_pages(struct svc_rqst *rqstp,
  * Return:
  *   %true: Success
  *   %false: The reply head cannot hold the length prefix and XDR
- *   padding, or the transport could not accommodate the result payload
+ *   padding, or the transport could not accommodate the result
+ *   payload. The page_len of @xdr->buf is reset to zero.
  */
 static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
 {
@@ -638,13 +639,21 @@ static inline bool svcxdr_encode_opaque_payload(struct xdr_stream *xdr, u32 len)
 	 * pad word does not fit.
 	 */
 	if ((xdr->end - xdr->p) * XDR_UNIT < XDR_UNIT + xdr_pad_size(len))
-		return false;
+		goto out_err;
 	if (xdr_stream_encode_u32(xdr, len) < 0)
-		return false;
-	svcxdr_encode_opaque_pages(rqstp, xdr, buf->pages, buf->page_base, len);
+		goto out_err;
 	if (svc_encode_result_payload(rqstp, buf->head->iov_len, len) < 0)
-		return false;
+		goto out_err;
+	svcxdr_encode_opaque_pages(rqstp, xdr, buf->pages, buf->page_base, len);
 	return true;
+
+out_err:
+	/*
+	 * A splice read sets page_len but not buf->len. Clear page_len, or
+	 * xdr_truncate_encode() takes the page branch.
+	 */
+	buf->page_len = 0;
+	return false;
 }
 
 /**

-- 
2.56.0

