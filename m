Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83DFE22DF9E
	for <linux-nfs@vger.kernel.org>; Fri, 13 Jun 2025 20:08:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1749845280; cv=none; b=KVWXTHQ/KYPK0tGJ+xGM/SZl41LFFVNY3NcQ3/8JmK+970hJgxKGVZD/XxwHKi2coKoEyjU+49ryHL4dyD87Tj9hX/M6pw9WSnIhi+hQMukY1z/Fo+8lzFzcUn8h86pku4hAo5KA/rF9cRPJVlkModi9jQbvfLdW5Gsa8BJ/VZY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1749845280; c=relaxed/simple;
	bh=6zWjBQlOCQk3klR4ci1GFuHyHeXWC4N+TqJqz41bZoY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=OzN6ZOCxGtd+9+ER0zidCNFxPAPykXCq/v/8PXYsbSl6iIsiJiCpPuSnrE9Eikwsj1H7NNx/GUU3b/KWRSVJuPeUJDobponvZFx/ZxWDr+RyN2OaDlm/wZU/E+KruF/Inf4tUNJX030Rq8plcbAqlJeLOrLkYH8tZVaWjeRx4co=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TzhexAfF; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TzhexAfF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B73EC4CEF1;
	Fri, 13 Jun 2025 20:07:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1749845280;
	bh=6zWjBQlOCQk3klR4ci1GFuHyHeXWC4N+TqJqz41bZoY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=TzhexAfFC4FgNLS11x/oKTrUvE5acJbOF6rXlZdjKERldHGs9/t5RCOYfRNgFO1FF
	 gA/7UMJrVj1tYhqDVBDo8bEg2akpIlhYEfbmE0xOIAWvUardoWuInRk5PVIcnmajXf
	 fbu32PZMJdKymc+EU7SxxR5PuyjI+Koy+gG2OArC0UJ6NKhzhEFfaXSobuXFzGJ2AX
	 Gf0c/Qqxvnj5eg2zZ34aUdd9unFbMRpqZhibr71MYJVnNDEtUitGOssOCWcNNR3izx
	 d5F+6+fA0KvDHu4o2APFnPrHn7wIztuMfLPQeSuTm7uQP2tlfiKAhFvEAYWwqU2y6g
	 Ei9hDaIvdTHnQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	Steven Rostedt <rostedt@goodmis.org>
Subject: [PATCH v1 4/5] NFSD: Remove definition for trace_nfsd_ctl_maxconn
Date: Fri, 13 Jun 2025 16:07:46 -0400
Message-ID: <20250613200747.7110-4-cel@kernel.org>
X-Mailer: git-send-email 2.49.0
In-Reply-To: <20250613200747.7110-1-cel@kernel.org>
References: <20250613200747.7110-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

trace_nfsd_ctl_maxconn() was removed by commit a4b853f183a1
("sunrpc: remove all connection limit configuration") but did not
remove the event.

Reported-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/trace.h | 19 -------------------
 1 file changed, 19 deletions(-)

diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index 693d3d8fcdce..a664fdf1161e 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -2099,25 +2099,6 @@ TRACE_EVENT(nfsd_ctl_maxblksize,
 	)
 );
 
-TRACE_EVENT(nfsd_ctl_maxconn,
-	TP_PROTO(
-		const struct net *net,
-		int maxconn
-	),
-	TP_ARGS(net, maxconn),
-	TP_STRUCT__entry(
-		__field(unsigned int, netns_ino)
-		__field(int, maxconn)
-	),
-	TP_fast_assign(
-		__entry->netns_ino = net->ns.inum;
-		__entry->maxconn = maxconn;
-	),
-	TP_printk("maxconn=%d",
-		__entry->maxconn
-	)
-);
-
 TRACE_EVENT(nfsd_ctl_time,
 	TP_PROTO(
 		const struct net *net,
-- 
2.49.0

