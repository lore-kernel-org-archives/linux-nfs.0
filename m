Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CBE054BAA07;
	Mon, 31 Aug 2026 16:15:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788192943; cv=none; b=d4UpyCVRicYNw79/v+TDdX1fRVTVxCNNTv4yMT2fKPR5C4PDS7zTK5fVx0FFXzjk1arJChgQNQugLtvnZCnQik9s+vwDYvmc3hy2Sc0RjSREcmnUvWj2RCINS2bWjyhZoR0+q6p/W+jsZiMcX0D6DOIJ32rWQyrxZzZNdYAQMqY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788192943; c=relaxed/simple;
	bh=0/b63pHsH99q59pHXxgWpdCiis0fT0wFTjXendozs0s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pnYxNMC+cGPoBmtBZnbIl5SS74RX9/6auTVy/ohi7BAfFwksnYTSPGmP6GCzQsnMcPsEROvHCNfvX7VlCRDkKFYm6jU9uRprr4pdvUxHb6EWV2tlp6IfVgfKLsjYJJ04loqju7xf6+ykGEvG+gilqvZ8RYqbOoa/jc1HkkcBJPs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=kH880J8Y; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="kH880J8Y"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DA7301F00A3D;
	Mon, 31 Aug 2026 16:15:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788192942;
	bh=yBYuY0qF5cKQRzExECF4YXQMQy4ClFSSmJFRGPrU+CQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kH880J8YfqTiHkCpfXySCRxWeIscyFxHnLCcqnJodHw4LXNx41/m7pGE4+uePht7m
	 uo7yy+27TgcWhvdaHC2QJMv8Tqhp5igKNWZYB2owkcna4+YozbLwzUgTpejxT0FLH/
	 yIXSH8vu3GVMtPXJcvtXW1VQqdaO5uCSwLldQSFvF6xrnMjMT+dErggM97BT8CaahQ
	 wjkC/fii0CIGPSxP0QPMcBr495IMYi3hjz97X9tbNBbAiq3JehG+tIB+gIKbNoJxnd
	 EozBM9tVtWflufqZbQbF9p7ELxpr9CqHjbAs9dwUzz8KQkVeoQKzUiGh5ZIGOpOoR1
	 G7RmkfEUS8c3w==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 31 Aug 2026 12:14:45 -0400
Subject: [PATCH v4 03/14] SUNRPC: keep the first error in svc_register()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-nfsd-nl-hang-v4-3-0f4e89139409@kernel.org>
References: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
In-Reply-To: <20260831-nfsd-nl-hang-v4-0-0f4e89139409@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Shuah Khan <shuah@kernel.org>
Cc: Slawomir Stepien <sst@poczta.fm>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
 Trond Myklebust <trondmy@gmail.com>, linux-kselftest@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1206; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=0/b63pHsH99q59pHXxgWpdCiis0fT0wFTjXendozs0s=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqlaifr4kI+z+Z/m0ZQ3U+vttDEKp4mDsd6valh
 Vcm0XymZYWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapWonwAKCRAADmhBGVaC
 FcJ1EAC2sYxpKivKMWjoAawHsfvUYbvw2PgdZ6oFidkbs81ICYPVn06JC7hb/Q5dlt2VQE+GlzL
 5hooFA4p5mzLGxhEbD9UB8XZh/EuZC4PR/zH45xgqBTq03qVitYOZDsEiRyuGklcGOMe53FlqeR
 9UVzpbLi8j3fXWNyr3Wsg/Hm+jp06HokierApoQGbg4h2YkczQ0M4kPIkM9IbaUKzDS7tLZIcjC
 i79joYCzf13Qt7WuQ67gnSI2AlhuqviCqEwrYKonkMu6OXQtmTdlX5VUMsxnC6DGq28KHMIHVtv
 acLzLPSjn/FtT2rVOafKGdFAcPVWQWYclChivIo8fyQsaOQCZQVKvqBzgHJkN/rT6IfDWat+fjd
 nb56YQJUaceyPbk5/vYJZ7319QtdMCjSdp3PTpk7vixv2WXFAJLU8N++JuPmN95xWKnFAhEtS+3
 CBhsFIGMUsSCholUw14YRYuylYnK/9BWfQnLt//+YKtca85+BfA4AGMLOKfXDPS7yDB9WhfrGnS
 bJAMNjqmwldVxchQlcaNHK5nQh79ADKdrRq1jrGPGduOLVAQsEr+zA2i0Phsn+wRrJqWX5MbPeo
 m5CJfjY+KzLStMtb2VM2J+cZc2kX28jHBJz+RBC/TD+xWgpqO3eBXarwgMRXDptDT+a2o9L02uE
 kB338AJUGggFHHA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_register() assigns every pg_rpcbind_set() result to the same "error"
variable and returns the last one, so a later result erases an earlier
failure.

Keep the first error instead of the last.

Fixes: 642ee6b209c2 ("SUNRPC: Allow further customisation of RPC program registration")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 8297bad2b177..4f402bbf97ba 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1208,13 +1208,16 @@ int svc_register(const struct svc_serv *serv, struct net *net,
 		struct svc_program *progp = &serv->sv_programs[p];
 
 		for (i = 0; i < progp->pg_nvers; i++) {
+			int ret;
 
-			error = progp->pg_rpcbind_set(net, progp, i,
+			ret = progp->pg_rpcbind_set(net, progp, i,
 					family, proto, port);
-			if (error < 0) {
+			if (ret < 0) {
 				printk(KERN_WARNING "svc: failed to register "
 					"%sv%u RPC service (errno %d).\n",
-					progp->pg_name, i, -error);
+					progp->pg_name, i, -ret);
+				if (!error)
+					error = ret;
 				break;
 			}
 		}

-- 
2.55.0

