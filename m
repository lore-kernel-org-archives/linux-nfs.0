Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=51.81.61.61
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793686088;
	b=NBE6jac8Cn5Oe7KZP6r6IGtcvmU0r3W8jOi4G1EZS8OQIprQvFwQUP2BxUubCp484pPz
	 mzQn651OeJZTA1ZNlE5Om6hn198SdnqGmQF3Xq+TN2yBf4xDqMp6oX3ovoLvBGOv592eT
	 X69DVIp0dTX2lzmTuJiMFcxjQnqGpRxp+Oy5kGCYgUWRk89q1VRCzyH8Fzl/v/risq+tX
	 ZhAOTt6zF1qnjiAKsJI/Bch+jZBqnqoHqQh2Hq1+io3FwPbGSwVHcYRjmsk75FwPrbmk5
	 C4Ew5dAx+1SLr/Halk1lNFCx7TrpPTcE6o7u1i5bwYLtMNqzV8fze3jjwTpS5mPttYw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793686088;
	h=DMARC-Filter:DKIM-Signature:Received:From:To:Cc:References:
	 In-Reply-To:Subject:Date:Message-ID:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:X-Mailer:Thread-Index:Content-Language;
	bh=t8G6CbFsg+EAS60xfvbx65hckUEbcoi9pIdPoIAeYSY=;
	b=ESi4c+1b0cu+vYw6U9RACYS9hBNCYFwiGQp30OUjynhrUik1qEqqLsxXLoXpuDMDEOEL
	 XwoQpTCqAc/z26oGMMlwJ/UpUOoCfHPFrvAK23IMeGg9en0BHN2+KQe5wiH8INOp009iu
	 ROfTqB+mUGXl1kTNNPxv2MM11F3EtajWDAiS2ALwXut7WP295ykzdM84r8vq1x8Co3NWg
	 yBhPVuJZLK4/nWzXGidyOk9yc8r+EN+r4+cCK//5rg1LB8AvGdfOzXJFQZWOAHonilBHJ
	 FQ4tKhiZzKgatT9MpDaMCQVI6T/vpDrE4fqXOfP3n5AituqE1w2VLm0d5a90zZ6ZyJw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=mindspring.com;
	spf=pass smtp.mailfrom=mindspring.com;
	dkim=pass header.d=earthlink.net header.i=@earthlink.net header.a=rsa-sha256 header.s=dk12062016 header.b=CybntqE2;
	arc=none smtp.remote-ip=51.81.61.61
Received: from mta-101a.earthlink-vadesecure.net (mta-101b.earthlink-vadesecure.net [51.81.61.61])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C789606A329
	for <linux-nfs@vger.kernel.org>; Tue,  3 Nov 2026 06:08:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2C789606A329
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=mindspring.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mindspring.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=earthlink.net header.i=@earthlink.net header.a=rsa-sha256 header.s=dk12062016 header.b=CybntqE2
DKIM-Signature: v=1; a=rsa-sha256; bh=t8G6CbFsg+EAS60xfvbx65hckUEbcoi9pIdPoI
 AeYSY=; c=relaxed/relaxed; d=earthlink.net; h=from:reply-to:subject:
 date:to:cc:resent-date:resent-from:resent-to:resent-cc:in-reply-to:
 references:list-id:list-help:list-unsubscribe:list-unsubscribe-post:
 list-subscribe:list-post:list-owner:list-archive; q=dns/txt;
 s=dk12062016; t=1793686071; x=1794290871; b=CybntqE2BfNXXFiDXf7bg0p3+k9
 ZMAhbixFRSL8Gj+FUNZC9i5S64j3Ey0KxTUMx3rPhrxvH+RKnVIC5WWJmkP2+0FInpP38m7
 XTxsj0msWvTyje0c6/tneojJuXc8KFdz8u1wv/VLvMQTyE4KJenXGzYN2knzTsNpbfM34AQ
 EpNlGceSeaywxy0hW45JTAJyU2tdsll8oLzJ9ZNmfylBzNgVL3UeOdeKx2ZfkhCrZ3vC4RT
 eD/0cSQk8hX5NQgwgKlV7QAFax7Nsb7iasxaAVUvBJgGWZ6pjMuXWv56XuIhHSFg6nl1iDg
 m+EdrktR6ETcJKJhZtbc9yM/d1FG3cg==
Received: from FranksP16 ([24.21.95.216])
 by vsel1nmtao01p.internal.vadesecure.com with ngmta
 id 2ab930c5-18e473f9d012402b; Tue, 03 Nov 2026 06:07:51 +0000
From: "Frank Filz" <ffilzlnx@mindspring.com>
To: "'Chuck Lever'" <cel@kernel.org>,
	"'Calum Mackay'" <calum.mackay@cdmnet.org>,
	"'Jeff Layton'" <jlayton@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
References: <20261102214351.602543-1-cel@kernel.org>
In-Reply-To: <20261102214351.602543-1-cel@kernel.org>
Subject: RE: [PATCH pynfs v1] 4.0 server tests: remove RPLY14
Date: Mon, 2 Nov 2026 22:07:48 -0800
Message-ID: <018501dd6b59$a92af8d0$fb80ea70$@mindspring.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-Mailer: Microsoft Outlook 15.0
Thread-Index: AQLEzOCjqKXcmNdr+G6RhJo7D6gd6LVNGSDQ
Content-Language: en-us

Could we keep this test case but change the flags from "replay all" to
"ganesha"?

NFS-Ganesha still passes this test case.

Thanks

Frank

-----Original Message-----
From: Chuck Lever [mailto:cel@kernel.org] 
Sent: Monday, November 2, 2026 1:44 PM
To: Calum Mackay <calum.mackay@cdmnet.org>; Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH pynfs v1] 4.0 server tests: remove RPLY14

RPLY14 sends a CREATE, then resends it twice with the same XID on the same
TCP connection and expects NFS4_OK each time. The other RPLY tests exercise
the per-state-owner reply cache that RFC 7530 Section 9.1.7 requires, or
replay an idempotent LOOKUP. RPLY14 alone depends on an XID-based duplicate
request cache, which RFC 7530 does not specify.
Section 3.1.1 also forbids an NFSv4.0 client from retrying a request unless
the transport connection has been broken.

A recent NFSD change drops a retransmission that arrives on the connection
that carried the original request, so RPLY14 now fails against NFSD.
Reconnecting before the replay does not rescue the test.
NFSD may evict a DRC entry once the client has acknowledged the cached
reply, so the replayed CREATE executes a second time and fails with
NFS4ERR_EXIST.

Remove RPLY14 and record its code as retired.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.0/servertests/st_replay.py | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/nfs4.0/servertests/st_replay.py
b/nfs4.0/servertests/st_replay.py index 48e5363432ec..7f490e3d48c3 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -250,14 +250,4 @@ def testOpenConfirmFail(t, env):
     ops += [op.open_confirm(stateid, c.get_seqid(t.word())+1)]
     _replay(env, c, ops, NFS4ERR_BAD_SEQID)
 
-def testMkdirReplay(t, env):
-    """REPLAY a succesful directory CREATE
-
-    FLAGS: replay all
-    DEPEND: MKDIR
-    CODE: RPLY14
-    """
-    c = env.c1
-    c.init_connection()
-    ops = c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
-    _replay(env, c, ops)
+# RPLY14 permanently retired, please do not reuse
--
2.56.0


