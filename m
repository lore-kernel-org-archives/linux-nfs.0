Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9B383D413D
	for <linux-nfs@vger.kernel.org>; Mon, 30 Mar 2026 13:38:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774877936; cv=none; b=Yi8RLGoE+/n8PubRjvNURjFNQeVjgIOQMHHsIbvmtM9QxlsIJAFOkSGFKCjUFPDZo6Aekx7RDUH71LAU0eHUjjtSTOHdYX27aHThDsTpR4P4Nde1wwSJZZ5ZgNl0EQmgZrk49Ax3oB3DzY6lHIb/lKPUCpy37HHg8U8a4Ll2h1s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774877936; c=relaxed/simple;
	bh=I4uBVcx8FSgS4psUNqHj5/Dpd/xkvsY1z39PDwrHgT0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iLctSS19AYXP3SP1WpH5zUFu1/SrNPiy0Gb7nwS7nboccakC0XsBsBBjXogDPVZYCw9T20CzH+8vIRLVLUav5vk/Fcf/SE533oD3R/WoZ1DONRNsaWcitchRi7gn55Zecj0bYypoWUhPu1CjNtbJM7cALYdKX+0y0ZM26VN9xx0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n9NYic6M; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n9NYic6M"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 90D49C2BCB0;
	Mon, 30 Mar 2026 13:38:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774877936;
	bh=I4uBVcx8FSgS4psUNqHj5/Dpd/xkvsY1z39PDwrHgT0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:From;
	b=n9NYic6Me2HdU2eFBcv5TT7Sregkd0TpOgYDzrLmiDAj8kgCr0/pOJEp0WI72nVRh
	 DZgPWc0tEYH9f9PMtVZYg4Q3JypB/utzUirWbQukvO9kU+4wyXGZGJd5eZaG4O0PUp
	 rJrai05jxehwDKKI7fN2BDPEPPDoZisx/SDFB/EGE7cJmSwEltXgrgm5oS1G/okuAf
	 w7mdXZfFy3IPyZO89FRE7hVdc8FmZmySZbtFcappfgvS9bdPkaCGyiIw6LqgG5R31v
	 K1d6lr5LvLFPbURRQ7lLEuHBFExvdiMV33Nn61g20vrH1IpWW8guapgnv1AHBYhCIg
	 nJg9UOv+3kx7w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 30 Mar 2026 09:38:32 -0400
Subject: [PATCH nfs-utils v2 12/16] support/export: check for pending
 requests after opening netlink sockets
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260330-exportd-netlink-v2-12-cc9bd5db2408@kernel.org>
References: <20260330-exportd-netlink-v2-0-cc9bd5db2408@kernel.org>
In-Reply-To: <20260330-exportd-netlink-v2-0-cc9bd5db2408@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.2
X-Developer-Signature: v=1; a=openpgp-sha256; l=1166; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=I4uBVcx8FSgS4psUNqHj5/Dpd/xkvsY1z39PDwrHgT0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBpynzgWoRI6Q+VktVmd0tQI4WjO7NDrhmU7yCZ2
 JOf4hGXWi2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCacp84AAKCRAADmhBGVaC
 FTgHEACEZe/h4fjv5gFhDFq/tSqUiIIZlcDnmBTpxISkL3TwGRbB0E37angl9KPP3zOnQ8JPXYl
 9Yd2h5cGAY+4122JlNdlVwpmaE4POQ3fJsLLLm59uU5pSryAoV3ZK/CGsolUEElKpKf07fR6yDx
 PnSl3OqrUkDf1avtVxTptWa9kPMcxgN979MYX4rk74aj1LVOoLcD8gZ01mxlQKNR+0QxJkU6no2
 m4cLn5XmtM6fgZQJbNGAuNRuMJXN+34fa6Dgywnbg8A8YVQ3icb1R97MdozJP+5NfBaucUjkIgF
 7zEtsi5x54NyddadW6Ygn0VR9o5JY4DgPYMCEzKQGCU4V9v7ewyXG8tMlQd6dqKEL7Cjqs38WL3
 ndLv7PoCUH1X6cibFtzVXoAQ+/TO/PW5rt5DsT7UKBMR0z57q9ekZgIrG1/jfnzp7zIt0AFUcv3
 t+juTK5pVRepG3/jMxrr6JWZ5fCIM6yZDUqbjl+7aXToBtUMiLdUWM6KrWy+VmfmFwIiB6is7hV
 3vPHRZDOoSs+NATZV1xZxLoIRv4zjfQvm4kvZKbPRgnGQjnj2KhAZ509wJJPFxJ8Wiz+w7VuXJd
 CvgtYv/S58cANy4sXF0zixpGlcdYRhMj34nJtamX+yXmOZJ3Fz/k2JnKRDivvxsdl/NKPg5UXJ7
 qlm9V2DJ4XCYmLQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

It's possible for there to be requests queued before mountd comes
online. Always check for already-pending requests after opening netlink
sockets.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 19cfbf6594b0a51d85814460f3153add89aa3a8a..4261e1861215ea53183dd8ce14890b0195d841e8 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -3014,8 +3014,19 @@ void cache_open(void)
 	int i;
 
 	if (cache_nfsd_nl_open() == 0) {
-		if (cache_sunrpc_nl_open() == 0)
+		if (cache_sunrpc_nl_open() == 0) {
+			/*
+			 * Check for pending requests, in case any
+			 * were queued before we opened the socket.
+			 */
+			auth_reload();
+			cache_nl_process_export();
+			cache_nl_process_expkey();
+			cache_nl_process_ip_map();
+			if (manage_gids)
+				cache_nl_process_unix_gid();
 			return;
+		}
 		xlog(L_NOTICE, "sunrpc netlink family unavailable, falling back to /proc");
 		nl_socket_free(nfsd_nl_notify_sock);
 		nfsd_nl_notify_sock = NULL;

-- 
2.53.0

