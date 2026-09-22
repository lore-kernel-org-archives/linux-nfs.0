Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B17022F0C7E;
	Tue, 22 Sep 2026 01:51:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790041892; cv=none; b=Zi0r+1upL0dSUElYMBTo7plXOorddbompFHvcqKgsSdjQx+i0S1blPV5fsOGjC/R9gQTVI1yqBcBXqEY/vqASRhHLopNOqqOOBx1vaQ3Sych/7BgBfM2BxKRiL91Fhqjo87/EieoDYukrwkKuvh6NYIku3QSXhROjEA/hmIGAyE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790041892; c=relaxed/simple;
	bh=Arz7UgP90weelG+1AX3kaLqQuBhCzorzaLzrzixPVJw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ck+taVF6YqWzXLysK8XHsXOlKyH74wYqNUXPMU3EKMa6wk7AvEV4mLYncvN2faQDd8f4+UPh49WHYYSDZ/3+9IYs+yIzZDC+CAHqLQ/fT2/fBd/mjzxh9wSNtv3rmDpEA5lLvxKy3rp7JtvYw2lAwHavpG3th6lAeqwrsGIRCUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TI0HQMAX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TI0HQMAX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D56DA1F00898;
	Tue, 22 Sep 2026 01:51:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790041891;
	bh=zdWtl6C1PuUIS+CZSaasQpmUdZKxtaNNhtKUZ5YAU7s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=TI0HQMAXJeNJ30UNtVXcrtSpqaqkq9VIF37TkJ0/g1vD/bvFsT/swRKxdHM6HtrAI
	 Fj2jre1wSxwzdiAuPjiMc/DUcNT6kUWWQZwZysvBGDIIX6xfQwxIh9QqSSqYU93sYj
	 UE3f/Vw8fgERCJkPbGYbRvnzMZPJJtfsWkH1yCOmevog/qcgeLS7tG0WhjWcUIr5VF
	 gGC+fq7FwbgmfXoH9qgtmlSmlxScN0Byi1thDTMN6LA0xGHhuA3TXCi75tGC3zAWgm
	 U+bgXTboTH5wIpCnkIvTGnCXopgVG73OgHUV4M6/EUIGaVCWjSAppTjpYw91TZrW2n
	 WelyZN2vOaYZQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	<linux-rdma@vger.kernel.org>
Subject: [PATCH v1 2/5] SUNRPC: fire svc_defer_queue tracepoint before publishing the request
Date: Mon, 21 Sep 2026 21:51:25 -0400
Message-ID: <20260922015128.240977-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260922015128.240977-1-cel@kernel.org>
References: <20260922015128.240977-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_revisit() adds the deferred request to xpt_deferred, drops
xpt_lock, and then fires trace_svc_defer_queue(), which reads the
request's XID and source address. Once the request is on the list,
an nfsd thread already servicing that transport can dequeue it in
svc_deferred_dequeue(), process it, and free it in
svc_xprt_release() before the tracepoint reads it. The window is
narrow, but nothing keeps the request alive across it.

Fire the tracepoint before the list_add(), while svc_revisit()
still owns the request.

Fixes: 8954c5c212d3 ("SUNRPC: Clean up request deferral tracepoints")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 908569035e57..713f4ba19ba1 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1271,9 +1271,9 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
 		return;
 	}
 	dr->xprt = NULL;
+	trace_svc_defer_queue(dr);
 	list_add(&dr->handle.recent, &xprt->xpt_deferred);
 	spin_unlock(&xprt->xpt_lock);
-	trace_svc_defer_queue(dr);
 	svc_xprt_enqueue(xprt);
 	svc_xprt_put(xprt);
 }
-- 
2.55.0

