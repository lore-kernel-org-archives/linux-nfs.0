Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794599049;
	b=msLqP0ujHcx6OiWFr/PFlDv36iDdrJUwYk62WcnHW+li3cSvGezoTiCBKP1P2z4SNt8n
	 OucMv5992dF0zgSwU9q5LY/XeZD56JQXG6s6Gfki8DSA6Oyg0dy+Anl18CcBBVhbZWtoO
	 oG1tB+lUtB9qdgDHeVAjUH1oBtVm+jZUIck/B92CTq5yCqGaiAXlTisigHH5MXpRD5qhr
	 VILsyOkJ5yY+i0t+fBsXmnm4K9abJuLcBxbzLV5NvncWMsdsN1mMYJun9z7JcxAgRl4fg
	 nBSnwNHWSeFGpER/zvwPJDwx2VDnTcQCo6qW2be1h7pxOxx7ahiLHym+YX6CnnBzxog==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794599049;
	h=Received:DKIM-Signature:From:Subject:Date:Message-Id:MIME-Version:
	 Content-Type:Content-Transfer-Encoding:X-B4-Tracking:X-Change-ID:To:
	 Cc:X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XDkjdhPRVcvJZSE/95zllMaFps867vC3zDKdBfuJAWU=;
	b=DsrHh2vOIxSPvv/yo7LSdJZ4LqMH5J4DkC+1Dt2aa7bNwLoWT9sVgEQ59Eqsn+d23rw9
	 mH7T/MT/1niKqJVPS06XgzQzmjH1h2fLFbcoSIXbHtp65cJe+0wEy+HCoTHbZYw80HMsX
	 02zX6zsxZ6ZWWT1KW8VLaCmpwH3ODTI0lWsiGuvi3u0qEiR+wuRfkTlyjMfECyBYw9MjC
	 GVsu8VXVaOhrlMO81aApu9BvDB96kA+6kbFnuxMbl6pXSdGRbHaI4ecljfSoNvNXWjZEh
	 GWUxY2r9kBkGy/vwZaLPV0bA5QUwD4rdHqytrZvKYc26o7NAVY3xMo0kVInv9/CYZ0g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iwmOXUft;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7E69C606A88B
	for <linux-nfs@vger.kernel.org>; Fri, 13 Nov 2026 19:44:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iwmOXUft
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 48EB21F000C4;
	Fri, 13 Nov 2026 19:44:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794599049;
	bh=XDkjdhPRVcvJZSE/95zllMaFps867vC3zDKdBfuJAWU=;
	h=From:Subject:Date:To:Cc;
	b=iwmOXUft8sxQrKYRtOhvTvDD4JioByFx9Dln/NX04NY91XNlR3p8f6CjvnpFFIQMa
	 QFli8HncFVA8dMgevxVkhRrczHx9+bO5XMzeFRfINrWdj7+QuroVEqWY4LbsxMXXa+
	 tSrEpNSMv7xZd7gKMqS1NOX0IFzDmvyhpUhiWdgmbHEynLFDEBi1FbZe//QYaZx7Y9
	 aQ+vovSQehTR1azrtPhk0m5gFAtScgEiRMOngUB7ZaptVY1XAsmfSGT3GELciEc3gT
	 3TTkiisC9f4j9Y7FGdd1BrC+9YcEYTHhhDqZpAghnwi2IC5rv19EZA/rRPGY17mRCw
	 vcm/lbyY9ThBg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/8] SUNRPC: Send and receive through rq_bvec in svcsock
Date: Fri, 13 Nov 2026 14:43:58 -0500
Message-Id: <20261113-svcsock-bvecs-v1-0-5dd41f205aeb@kernel.org>
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
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMwQrCMBBEf6Xs2UUTxFJ/RTwkm027Kqlk0yKU/
 ruJzu0NM28D5SyscO02yLyKypwqmEMHNLk0MkqoDPZkL6YGdSWd6Yl+ZVLsA5noB2eHcw/1884
 c5fPz3e5/1sU/mEqTtIV3yuizSzS1ivh1TFEDFtYiaYR9/wIt7LUrlAAAAA==
X-Change-ID: 20261111-svcsock-bvecs-7dc1fb9a2947
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2945; i=cel@kernel.org;
 h=from:subject:message-id; bh=lNEzU5Bl9L8brh0kWL9ml7IOIWT4s8GvXqLxD3w7DtQ=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq92iABg3y4Q5VCUpjDPtVVkwNupWv4lbFkFmkE
 J5t9Mtm4F2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavdogAAKCRAzarMzb2Z/
 l+YrD/93qwUwgcVbqZpw3TodVFiHCterHrEmohyPC72HW/4Bb/1z267Rkxz2ehEEVXqKhKiENve
 R3vzxUf2Cz4sKXtn0dODsktvMPkpQMgToB2KF9PfsiX5m0Ys9GY6i/JYAHv1jBOLhuVJ9eybjqO
 u0CPTpICfYGwQ/822Evac02OBolGd/P9YJ/QXhuadaaUheZmBe6A4ojJWZAA2mwwimPlurhwbne
 D1vWhkLp2PHdiExwO2mNqb04Cq28tHwlAwLYEXu/5/9JnuvkjxAlOEqQNWTV3upMbEv6c07GlXd
 dKQKqaaoxFPdog5JtmBwZjsIQg+5ZMwUJekRr5Mrs35SMIXVc/x4VPZkCS6SrPFK5w+Pz1Wlhuv
 3mBBdjq3x6Y8OlKtZ92iM2SiURwmDxWfTqIO8HpoO+CRAWSZQzwH0NojBOYQprxDEuOMMoDl6zl
 3BDmiTMS4eCOZF3aD+d+GTK52Rw6u+1m/zBDOmro3l2M+obikGkHifhgTuOvq7D5xuk1PbSibUz
 xmgNdw4z7sE+r7MCbVyB6pR5q66ylbSiDbQ+DySTiuFCFbUhLqRTpVcT+YZzV1+zpQbNrxi+sFu
 IZyg02Y78V4WI6GT6AGeUOaHfGmTdAmLR/s8C5ZFjTOfQxpeA4UGZRvKEvI5oPXxERtOW5ORxHu
 mA2OHc3Bsu5LM9g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

This series is a first step toward letting NFSD pass folios from a
filesystem directly to an RPC transport. That goal requires
transports that take their send and receive buffers as bio_vec
arrays. This series does not change struct xdr_buf, which still
carries one page per entry; that will come later on.

Currently svcsock has two obstacles to a bvec-only transport
interface. svc_tcp_sendmsg() and svc_udp_sendto() build the reply's
bio_vec array in the per-socket sk_bvec, which NFSD cannot reach.
svc_udp_recvfrom() points rq_arg.head into a linear skb instead of
copying the datagram into rq_pages.

After this series both socket transports send from the per-thread
rq_bvec and receive into rq_pages through a bvec iterator. The new
helpers take an svc_rqst and do not reference struct svc_sock, so
the calls can move into svc_send() and svc_recv() later without a
change to the helpers. This series does not make that move. A later
series converts svcrdma to the same helpers.

The TCP record marker stays in a page_frag buffer, now carried in the
reserved rq_bvec[0]. Placing the marker in rq_respages[0] ahead of
the head would save the allocation on each reply. That placement
changes the buffer length setup in svc_process(), the head
reassignment in svc_process_bc(), and the head-page assumptions in
GSS wrap, which seems to me like a layering violation. The reserved
entry serves either placement.

The UDP receive conversion is the only behavior change and comes
last (patch 8). Patches 1-7 do not depend on patch 8. A single
sock_recvmsg() with a bvec iterator would also take over the
checksum and truncation handling from svcsock. Patch 8 keeps the
MSG_PEEK receive followed by skb_recv_udp() so that the timestamp
write-back and the error exits do not change. The cost of the added
copy on NFSv3 NULL and GETATTR rates has not been measured.

---
Chuck Lever (8):
      SUNRPC: Add KUnit tests for xdr_buf_to_bvec()
      SUNRPC: Reserve a leading rq_bvec slot and add svc_rqst_res_to_bvec()
      SUNRPC: Send TCP replies from rq_bvec
      SUNRPC: Send UDP replies from rq_bvec
      SUNRPC: Remove svc_sock::sk_bvec
      SUNRPC: Add svc_rqst_set_arg_len()
      SUNRPC: Move the receive bvec iterator setup out of svcsock
      SUNRPC: Receive UDP datagrams into rq_pages through a bvec iterator

 include/linux/sunrpc/svc.h     |  13 ++
 include/linux/sunrpc/svcsock.h |   4 +-
 net/sunrpc/Kconfig             |   5 +-
 net/sunrpc/svc.c               |  34 ++--
 net/sunrpc/svc_xprt.c          |  87 +++++++++
 net/sunrpc/svcsock.c           | 217 ++++++----------------
 net/sunrpc/tests/xdr_kunit.c   | 397 +++++++++++++++++++++++++++++++++++++++--
 7 files changed, 563 insertions(+), 194 deletions(-)
---
base-commit: 9d9a3e68a2f8a7d69d597c65cc52026456edbf6c
change-id: 20261111-svcsock-bvecs-7dc1fb9a2947

Best regards,
--  
Chuck Lever <cel@kernel.org>

