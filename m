Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ABFDB7263B
	for <linux-nfs@vger.kernel.org>; Sat, 21 Feb 2026 18:40:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771699202; cv=none; b=WXWH6xBiGtY7BPo3k7Ns7GnR6yenwy+BndNV6fuTdfSZaL+qCYRFgQO2AyQ8vRukWTT9bCfWPQ92msaBwnY1LbhyglJRRPMAw0ApZW4i6esntnh6i1VwhTCZV8LjVwS7Ajqm8mtucNt8KVpjh7MR1lUsjJooMOUf0NkXiQe5ZWA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771699202; c=relaxed/simple;
	bh=UDss4PqNurn+HyznqmX79jBZWJb8O8k6bnq9AIzdG2g=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=SfZ2kvPCB35luQ10RR4woS+v3qns7anvmvglUKIi61yv7/Q2i97tEgVBn9h1JYBlNiALNvkWcTcfJAWktxsaN/njV7d0gaTkzCrFBGr37ZGmsWc6f5/kMOBxZwwzrQlYfzqwwbRLn6+qzm+oeUOMSytkU4q66wwbVnYjLwycl9o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=tv/VySmk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="tv/VySmk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A1900C4CEF7;
	Sat, 21 Feb 2026 18:40:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771699202;
	bh=UDss4PqNurn+HyznqmX79jBZWJb8O8k6bnq9AIzdG2g=;
	h=From:To:Cc:Subject:Date:From;
	b=tv/VySmkOQcLcbGcoiLnbGPPU2O1ewc6YZCapFZbwfPN/0F9VLvgXfA4jWtnPt8Qm
	 K1Nbb7ufUo2ZRKOs26N7u3hu9UhyPYRvjMZqDR5cjxgVkZA92L3mmN2I99IhrfsUnl
	 zE1LIThxJl4e0QPyfvyeyYH+IXNeNOKf06zDCBnlRZQCcaxPiq+NFlArepr1DvdOeC
	 OOmVOg8fuLuIAsB2Koy7eIm+nonNap+257uH05m3nzoJxNsikfbOhsbSmF9B2A0Fq3
	 3/dfIMo7ij3h3+6uh7qHYHfAWyn6Dj4WP5I2faMZMd0GgNh4sokxiUFr0OPBbzigrx
	 JRiD689EstHGQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] sunrpc: Add XPT flags missing from SVC_XPRT_FLAG_LIST
Date: Sat, 21 Feb 2026 13:39:59 -0500
Message-ID: <20260221183959.7672-1-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

Commit eccbbc7c00a5 ("nfsd: don't use sv_nrthreads in connection
limiting calculations.") and commit 898374fdd7f0 ("nfsd: unregister
with rpcbind when deleting a transport") added new XPT flags but
neglected to update the show_svc_xprt_flags() macro.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/sunrpc.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 750ecce56930..ff855197880d 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1933,7 +1933,9 @@ TRACE_EVENT(svc_stats_latency,
 	svc_xprt_flag(CONG_CTRL)					\
 	svc_xprt_flag(HANDSHAKE)					\
 	svc_xprt_flag(TLS_SESSION)					\
-	svc_xprt_flag_end(PEER_AUTH)
+	svc_xprt_flag(PEER_AUTH)					\
+	svc_xprt_flag(PEER_VALID)					\
+	svc_xprt_flag_end(RPCB_UNREG)
 
 #undef svc_xprt_flag
 #undef svc_xprt_flag_end
-- 
2.53.0

