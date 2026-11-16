Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=52.42.203.116
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794837391;
	b=kVjpENhCX5pqFHebRSilCzjlp1/OKCIZzuTQgy9rPcBbmRzDg+Vt0J1dMnrZ4YbkWUSy
	 i7mqgri1QUqLJQQC2dsz86OV6geUYVK0ilOvFEruEvMPYZC0Y9cvNckzTUBtOAgT/SFUA
	 M6rSz7OxbreEhomiRYtKDjM4K9XMDNenxgQte4FiJ5IescKR5a3rmfh8FrmbbgKjjLrlR
	 QPU2VrYR7hHl7SIHoiUHMtPR3wEFvXGzbkblGYlBAQBMT4saYi7q9AHFPIEYxdsVUGkz+
	 o1RdtsBprHL7rbOhHOrw/0IfwFWKPGjsjmyNcQdgKAru0U2DhKX4CALYeRDN3NEBNjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794837391;
	h=DMARC-Filter:DKIM-Signature:X-CSE-ConnectionGUID:X-CSE-MsgGUID:
	 X-IronPort-AV:Received:Received:X-Farcaster-Flow-ID:Received:Received:
	 From:To:CC:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=X0MZiv+7I8rasT3tWedmaVXcEdTKVEiNIUxeh6hwJD4=;
	b=Ennc1HaxQHjdAj/4s9VyJz87r+DMzbUVQJpPP03Fk1S5ObChjvgdFU09tUTDMAAToLcN
	 F2PvGqoS7S/RL4as5cWd2s9gmLBH+rLH70wTl8ShCiIWTkYjnSGgRmdFNQE3+Owvvf1iq
	 DFqK0fiOLb2Ii+EApg5xaDXUFkvtmW0jxEHjErPRYhUp0hd8AcD2Cp/osSW+90oFpN1iu
	 WZ3h7h3L3IX0xOTCEKSjrb4FDlsKNonqSQnAPXKivE4/HiKVbx8+WOm2NXpG6lVwIYbnr
	 o3YOXAQywq57LZngfbcdpzdkhY0mmNscvK2HKoIxXL2JJUbb/AMAl+fobVHhBT92DrQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=amazon.de;
	spf=pass smtp.mailfrom=amazon.de;
	dkim=pass header.d=amazon.de header.i=@amazon.de header.a=rsa-sha256 header.s=amazoncorp2 header.b=kGukngRM;
	arc=none smtp.remote-ip=52.42.203.116
Received: from pdx-out-008.esa.us-west-2.outbound.mail-perimeter.amazon.com (pdx-out-008.esa.us-west-2.outbound.mail-perimeter.amazon.com [52.42.203.116])
	(using TLSv1.2 with cipher ECDHE-ECDSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D13DB606A894;
	Mon, 16 Nov 2026 13:56:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D13DB606A894
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=amazon.de header.i=@amazon.de header.a=rsa-sha256 header.s=amazoncorp2 header.b=kGukngRM
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.de; i=@amazon.de; q=dns/txt; s=amazoncorp2;
  t=1794837390; x=1826373390;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=X0MZiv+7I8rasT3tWedmaVXcEdTKVEiNIUxeh6hwJD4=;
  b=kGukngRMOQ6QyzSnXDnyqIhO1Jk2SOj/iWermWupSJ1XZb0TPS8q3wVt
   UYg27p9a9EidE88LAOTHXGSGodVU8xDnDkOSkM9UJosiiAMouNPTEzb/F
   pVmpc+BBJi6d9vSDPOKm0BbLo2KzN6ZGjSVY8STwhcL+j2x52n4TV2HEN
   35U7I8U7Ai81UnPc0THrFULr4Erbr2jfpX2CSSlA4I9W25I2OofTdEsmu
   7pznouZ0jWBkOIg6CSD5vsFinMm5bsuWAMyn1HEB+M+lV70cJM71JHvg6
   cVprK0ZV9jEk+Auwm9oRk96mNCOTJjyHeHDhiiCTRtluJvCHEDSxmOZwF
   w==;
X-CSE-ConnectionGUID: /2Ij3QezQ/2gANYbfFWLnw==
X-CSE-MsgGUID: UI6jPlkGRTixlsY2xMSQnQ==
X-IronPort-AV: E=Sophos;i="6.27,216,1787011200"; 
   d="scan'208";a="34269716"
Received: from ip-10-5-0-115.us-west-2.compute.internal (HELO smtpout.naws.us-west-2.prod.farcaster.email.amazon.dev) ([10.5.0.115])
  by internal-pdx-out-008.esa.us-west-2.outbound.mail-perimeter.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 16 Nov 2026 13:56:28 +0000
Received: from EX19MTAUWA001.ant.amazon.com [205.251.233.182:20287]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.34.255:2525] with esmtp (Farcaster)
 id eab0ca1a-5cb8-495b-a272-c0415033ad3c; Mon, 16 Nov 2026 13:56:27 +0000 (UTC)
X-Farcaster-Flow-ID: eab0ca1a-5cb8-495b-a272-c0415033ad3c
Received: from EX19D001UWA001.ant.amazon.com (10.13.138.214) by
 EX19MTAUWA001.ant.amazon.com (10.250.64.204) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.56;
 Mon, 16 Nov 2026 13:56:27 +0000
Received: from dev-dsk-doebel-1a-7b355d76.us-east-1.amazon.com (10.169.119.5)
 by EX19D001UWA001.ant.amazon.com (10.13.138.214) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.2562.56;
 Mon, 16 Nov 2026 13:56:26 +0000
From: Bjoern Doebel <doebel@amazon.de>
To: <stable@vger.kernel.org>
CC: <gregkh@linuxfoundation.org>, <cel@kernel.org>,
	<linux-nfs@vger.kernel.org>, Kimi Security Team <bug-report@moonshot.ai>,
	Yilin Zhang <yilinzhang@moonshot.ai>, Bjoern Doebel <doebel@amazon.de>
Subject: [PATCH 6.1] SUNRPC: Copy the deferred RPC Call from the head buffer
Date: Mon, 16 Nov 2026 13:56:19 +0000
Message-ID: <20261116135619.2582482-1-doebel@amazon.de>
X-Mailer: git-send-email 2.50.1
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
Content-Type: text/plain
X-ClientProxiedBy: EX19D031UWC001.ant.amazon.com (10.13.139.241) To
 EX19D001UWA001.ant.amazon.com (10.13.138.214)

From: Chuck Lever <cel@kernel.org>

commit 2192a56b0686599358909c3e12e9a366f5b5d452 upstream.

svc_defer() snapshots the RPC Call for replay once a pending cache
upcall resolves. It copies the Call starting (rq_arg.len -
head[0].iov_len) bytes before head[0].iov_base, a back-up that once
covered a transport header. No transport has had one since commit
983084b2672c ("SUNRPC: Remove svc_rqst::rq_xprt_hlen"), so the two
lengths are meant to be equal.

An RPCSEC_GSS Call breaks that assumption. Unwrapping the integrity
service truncates rq_arg.len by the length of the trailing checksum,
and unwrapping the privacy service leaves rq_arg.len short by an
amount the client sets with trailing bytes after the wrap token.
Neither adjusts head[0].iov_len. Both lengths are size_t, so the
subtraction underflows and the copy starts past head[0].iov_base.
Every deferred integrity Call replays a shifted snapshot.

A deferred replay skips GSS verification, so a shifted snapshot runs
as an authenticated Call. With the privacy service the offset is
client-chosen. A forged Call placed in that window, naming another
user's GSS context handle, runs under that identity.

Copy the Call from head[0].iov_base. Refuse to defer a Call whose
length runs past the head buffer, so the copy cannot read out of
bounds.

Fixes: 260c1d1298f6 ("svc: Add transport hdr size for defer/revisit")
Cc: stable@vger.kernel.org
Reported-by: Kimi Security Team <bug-report@moonshot.ai>
Reported-by: Yilin Zhang <yilinzhang@moonshot.ai>
Link: https://patch.msgid.link/20260902133101.48914-1-cel@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
[doebel: 6.1 backport. In this tree the RPC Call header is parsed
 with svc_getnl(), which advances rq_arg.head[0].iov_base while
 rq_arg.len keeps measuring from the start of the receive buffer, so
 len > head[0].iov_len for every Call at svc_defer() time and the
 upstream guard and copy-from-iov_base cannot apply; keep the
 skip-based snapshot that svc_deferred_recv() expects. A GSS privacy
 unwrap breaks the len - iov_len invariant by resetting rq_arg.len
 (gss_unwrap_kerberos_v2()); refuse to defer after a GSS
 integrity/privacy unwrap (rq_auth_slack != 0) or when
 len < head[0].iov_len.]
Signed-off-by: Bjoern Doebel <doebel@amazon.de>
---
 net/sunrpc/svc_xprt.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 1393eefbf2187..151e3d1747922 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1221,6 +1221,20 @@ static struct cache_deferred_req *svc_defer(struct cache_req *req)
 	} else {
 		size_t skip;
 		size_t size;
+
+		/*
+		 * A GSS integrity/privacy unwrap can reset rq_arg.len so
+		 * it no longer measures from the start of the receive
+		 * buffer (see gss_unwrap_kerberos_v2()). In that state
+		 * len - iov_len does not locate the buffer start, and a
+		 * snapshot taken here would be replayed without GSS
+		 * verification. Refuse to defer; the caller fails the
+		 * request and the client retries.
+		 */
+		if (rqstp->rq_auth_slack ||
+		    rqstp->rq_arg.len < rqstp->rq_arg.head[0].iov_len)
+			return NULL;
+
 		/* FIXME maybe discard if size too large */
 		size = sizeof(struct svc_deferred_req) + rqstp->rq_arg.len;
 		dr = kmalloc(size, GFP_KERNEL);
-- 
2.50.1

