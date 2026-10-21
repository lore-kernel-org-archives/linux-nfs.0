Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.176
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792615125;
	b=JXS70Y2H0PnktzhMyLw+KSauKggnvwsfxG5rvOlkcLbcGuxiMeFCyfXJ0ZxKpqgrKDRZ
	 Z7XA7fOTkNHLhfUREF1hZ3Yxy1FZ6Mf1sNtuxcVcPsDExY5FAn4+feF8+9TWp/YNOt7FU
	 4Cl2dm3/8SS5Ws/FTEM+PmwK+AbbV25c3gSebKAzZt9M1d3Id14F1vwPEX7KS0IPjtZO7
	 WUUw7Sm+lk6D6PSCbKQZedHwOWujseeQWSAl6oex0Mrjoe2vml/4uNlcEKlTYTyuCkp1P
	 1mMO4suW1sJKKMa4PsU7oWxIrHmUTFhHeNusbRPXcqUn9X4eZDvtXU0x9reLJ0JaJRQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792615125;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=QDqMOsDuzil6WajGuk0RdRf8D0CQ7SO9x51N1GbZQdM=;
	b=paQtsJjqnYd0nA5bkxT2EyHc6dJTQq21ex9uK7PzX0uJJk3T2S9T2PFtJdt6kIKVj6UL
	 HStK4VOqYxkPSsnfb45qBW7P9pWfpnJpWeNZjT2Ly4aLwDKIoDvGzTwzjUsP/kMnNJuoL
	 LcI8rqrPJsEbi9ybeiWSjHfaIhNeOi3jSRM7uXtAA+vB4Ng6WeEy0BxhXEiOvUlkeY5nl
	 aT2gNE26SYa1giwJXFLJDiyMZvJ39RyLvC9I9L+M4FeNbJPJ0MzucfH7RfE/TH1W6WnrL
	 Yq27Qy1g8j8W5dvTE8xw+WrC3aF+lWF9cEM14YsU8RcHDQjOrVDqUydMIyiFcyHtj5w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=asu.edu;
	spf=pass smtp.mailfrom=asu.edu;
	dkim=pass header.d=asu.edu header.i=@asu.edu header.a=rsa-sha256 header.s=google header.b="TYuqt/5m";
	arc=none smtp.remote-ip=74.125.82.176
Received: from mail-dy1-f176.google.com (mail-dy1-f176.google.com [74.125.82.176])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86BD4606A31B
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 20:38:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86BD4606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=asu.edu
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=asu.edu
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=asu.edu header.i=@asu.edu header.a=rsa-sha256 header.s=google header.b=TYuqt/5m
Received: by mail-dy1-f176.google.com with SMTP id 5a478bee46e88-33fb4680717so2801949eec.1
        for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 13:38:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=asu.edu; s=google; t=1792615124; x=1793219924; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=QDqMOsDuzil6WajGuk0RdRf8D0CQ7SO9x51N1GbZQdM=;
        b=TYuqt/5mO4PjbfnCRxwcJm7BAZwyqRgmg3wp2FBQnEulaSDO8PG1kkau9TrwwG/4rm
         S54X/KvrMS9ftanemrX+21iKHDVucwkzknh255Dw7twnycP9vUEZrqRsbbDZwXmPkQkt
         kL9NjK5dKf6Fr2cUe9oywBQ442UmXHTvzbL3IJRcSb2SOTFLMItZhRVw8nyLvka7+ENJ
         8pSUlA6e168H6A/u6qwE2ZDguV9Upife7jLXEE2IVYaQfjU7FxjhZXDPmilKpww/F5rD
         vaRFpqIqaJcohE82mXETz77IOXcp5EmcODCg+YODE4SJdZTAHCS2QOp91iygN85PDmBY
         KeQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792615124; x=1793219924;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=QDqMOsDuzil6WajGuk0RdRf8D0CQ7SO9x51N1GbZQdM=;
        b=g6jaoebn0wBoRbIlp6Ct86ULs2k9gVTobbT3dgURwMkrBKuq5rb5HS9lLpR7XNIJrN
         RpO81BUmkSOFKo24hmGfAHjy7d2AG6kUGjwSxTd7YarXt43CF9HujoAHeSNCNbSy13n1
         eRQF6JfmhwaBClhC/qdW2igxWjLBQQuqsuhrSdVnR73fu+qsJ2ops7SoOmw4dvlyqAYE
         DhFRvsePYsYmoa3wmh2WMlMKAyK9UjteKgkEpyF6MVBc8VE9xqjpdb9j+2Sc85jp6gxC
         RJ+lx1mXvc8iobXQyo2HBqC7SAmS6sMQA+WJYx35LqEAf171LGVk3HZ/Dl4ooLmwZgfI
         v9Ng==
X-Forwarded-Encrypted: i=1; AKwUvByzLYGR37xWgEialrhDUrr9jdm3Yf4qKjadTiDkDQWCWlBMcX4qvYn9K2c+6hyWEp5TGl7m17e7YIg=@vger.kernel.org
X-Gm-Message-State: AFq9FYIiaQ+GfMgOU+zuafxvRqQoDXSim2Gxha3sN856UsyRtJP47Dgh
	eOi00wTVkgKmyrpsAwbu2JW+PbXq2S3g+2GSnlxdm6I1SSMgClQzMZtUImv3+v1ooA==
X-Gm-Gg: AYBFou2qp6jhepUERUHzUDHlOxl4Yhgv1ATdZahUFsi/zlJmygpB5ASSYK4e5v9L2HM
	/ubgAO/EGvf06uVdXD7mP686orYtBExE0d+BdPOymJVBNqVIcGQYyRhchwfYnqBysBTbVIMw8p1
	IBuKV6HHZlYxbNT7qXT7tdTYqUbCtl92QnGBNJFuFUAOG8pdfx1nJGWSoi75hCKMbFExQsLy9p3
	WPCEQZy4COvlzrcbx2Olj5bIndGIrAsgB2DGOvfjet4PDjoEFhy+yOU2QfAl97oKrJp1ka20YjT
	c/gxSLF0ypwqmFtPzilDyQP1OKiQ0biJL4WKMTLdI1zwTyXF7ms+Ayf1hxvUfFV6vCA2gVzv/Hh
	xYAnjh99HCwvrxPFdwJZR0436othlEZZ+zTMVKUeqWT7dEwGBWMdDy2LNncSKQTEUCzG+SyPv9o
	1+8VGWkJTpxOrJ78lur65BMRUbnUyFbNmz+on79jZ+tzmOO5RtYmtvTapBw7DR0rzS52UqjsLDv
	hVx5fK3MSni5YtN+h5PlZazKaFAAxAGhOWy6JYGsSUKa5sS9MSiC8s4Y9RuUY1R1k7MCuzpRYNs
	CaLpzhj33hE=
X-Received: by 2002:a05:693c:8955:20b0:339:7b3b:236d with SMTP id 5a478bee46e88-3674cf43498mr4460582eec.15.1792615123572;
        Wed, 21 Oct 2026 13:38:43 -0700 (PDT)
Received: from gio.localdomain (ip68-109-140-205.ph.ph.cox.net. [68.109.140.205])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-367405edd7bsm9857018eec.6.2026.10.21.13.38.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 21 Oct 2026 13:38:43 -0700 (PDT)
From: Giorgi Kobakhia <gkobakhi@asu.edu>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Xiang Mei <xmei5@asu.edu>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Giorgi Kobakhia <gkobakhi@asu.edu>,
	stable@vger.kernel.org
Subject: [PATCH] svcrdma: bound check rc_curpage in svc_rdma_build_read_segment
Date: Wed, 21 Oct 2026 13:38:17 -0700
Message-ID: <20261021203817.3898293-1-gkobakhi@asu.edu>
X-Mailer: git-send-email 2.43.0
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

The existing guard in the end of loop is not enough for bounding
rc_curpage, because it only checks if some part of the chunk goes beyond
the rq_maxpages.

    if (len && ((head->rc_curpage + 1) > rqstp->rq_maxpages))
	goto out_put;

If the chunk exactly fills up the pages, then len is 0, guard is skipped
and the next chunk makes head->rc_curpage go over rq_maxpages.

Commit 81381d1a90de ("svcrdma: Adjust the number of entries in
svc_rdma_recv_ctxt::rc_pages") made OOB accessible, since it
shrunk the rc_pages array size to rc_maxpages.

Commit d1bea0ce35b6 ("svcrdma: bound check rq_pages index in inline
path") added a loop-top "rc_curpage >= rq_maxpages" guard in nearby
function svc_rdma_copy_inline_range(). The same check would guard it in
svc_rdma_build_read_segment().

OOB write is triggered in svc_rdma_process_read_list():

 BUG: KASAN: slab-out-of-bounds in svc_rdma_process_read_list
        (svc_rdma_rw.c:1148 svc_rdma_rw.c:1197)
 Write of size 8

 Call Trace:
  svc_rdma_process_read_list (svc_rdma_rw.c:1148 svc_rdma_rw.c:1197)
  svc_rdma_recvfrom (net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:1022)
  svc_recv (net/sunrpc/svc_xprt.c:870 net/sunrpc/svc_xprt.c:968)
  nfsd (fs/nfsd/nfssvc.c:919)

Add bound check for rc_curpage in the beginning of the loop.

Fixes: 81381d1a90de ("svcrdma: Adjust the number of entries in svc_rdma_recv_ctxt::rc_pages")
Cc: stable@vger.kernel.org
Assisted-by: LLM
Tested-by: Xiang Mei <xmei5@asu.edu>
Signed-off-by: Giorgi Kobakhia <gkobakhi@asu.edu>
---
 net/sunrpc/xprtrdma/svc_rdma_rw.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_rw.c b/net/sunrpc/xprtrdma/svc_rdma_rw.c
index 9aaaade99e6e..a98041139075 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_rw.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_rw.c
@@ -777,6 +777,9 @@ static int svc_rdma_build_read_segment(struct svc_rqst *rqstp,
 	ctxt->rw_nents = nr_bvec;
 
 	for (bvec_idx = 0; bvec_idx < ctxt->rw_nents; bvec_idx++) {
+		if (head->rc_curpage >= rqstp->rq_maxpages)
+			goto out_put;
+
 		seg_len = min_t(unsigned int, len,
 				PAGE_SIZE - head->rc_pageoff);
 
-- 
2.43.0

