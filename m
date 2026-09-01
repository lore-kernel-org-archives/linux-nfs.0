Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AA8A9476CCF;
	Tue,  1 Sep 2026 13:40:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270009; cv=none; b=NzNIaGiG7vgQJZdETOGFmy/TYdzmKJqYKBnJOlB9o8CjfDLBKQI/g9pVnBEbpse7TFI0ROpLbuBGNdx3wLk5xf8n7Y4MLjhUuULQSvKzhT+6vackO5nKK4J+xYTXkTsy8b/MS1NSn45Z5/S4aqr7BfC0s6CxCGOUrAUuEziJQfU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270009; c=relaxed/simple;
	bh=0/b63pHsH99q59pHXxgWpdCiis0fT0wFTjXendozs0s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=suOHlBePPFdbZho5+2SW1Z16LQ7NyDQTRd7NuhFeOQpvtZVAkMN+OnbG+mbbBGsi7NYmaxLiQaIHrN/q0aFBDVnGfaM7/qAyNZN7Egiy1/3pXghn9ucknrqAb5CFEEqWHYw3GYNNUexL9hmsrtiJramH9lz9jyVuX2cnoJcCIdI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=htSmE64q; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="htSmE64q"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D55E61F00A3E;
	Tue,  1 Sep 2026 13:40:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270008;
	bh=yBYuY0qF5cKQRzExECF4YXQMQy4ClFSSmJFRGPrU+CQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=htSmE64q3fC4iWTwmrjYUzjhlxQP+2ZM3ufi3PUvYqLBvyHNKCukNgVV/nxlEWX+W
	 5mBYTTFexmUJ7ZU1L0jeZD62h6saaAygYcn4Sy5kVbqBrgwFs0j6PG/CpRuvn7YBSt
	 eD0OD3Fe6a85fIw99LuQilH7zBJhuqK5t5OHVBLmuVBcxM1/5mh+NDdLtQDx6yM/rd
	 ZjPghyE9BNEsPFrwkTFoc1SwcSm0TxnyHgi4zyTyulFJOHPNuv4IlRGRwBtGSxNYyz
	 wFAoQM2ihlvOOaUiPHdadjkNZIF1Zn8ZOB+K+OPs9XihOg+5KZyC2b6ajqoTMWiyaF
	 THrinhIQ72+bg==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:41 -0400
Subject: [PATCH v5 03/15] SUNRPC: keep the first error in svc_register()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-3-a540d86668b0@kernel.org>
References: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
In-Reply-To: <20260901-nfsd-nl-hang-v5-0-a540d86668b0@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWuGrYPAMgfxAOn/iOdOtkSUH386teawscqI
 YllYO1KZiyJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrgAKCRAADmhBGVaC
 FVu3D/9a6ti55iWJsHI0pwGN8SrUgxqjRPylCcyyd2jNm7tU07QTHQ8M9PueVVGY2Disa5ACXka
 L/ezVVrKL3q6Mt+o3B6t6f139OEs/nFZEfonPatA5ojo5sM3O3K9qWGgdhwH5FZa5qCjXLwidBg
 6BtFVH96UqeoVHQTKp4frd/Q984qwJ8eO3ONuhmhUAGJVbdg10D3W3S3GQSb6fzWwaG8tg6kauT
 MjhH3nnrjINwRp5letgeBPK/ckXpNsQZStnz8BC4aiDVPLCdyDgZDmgtw6O7wrjNlKWqrhyTBC4
 ngCth155C3R3ziviO2c9Ump+d1cKKfPxWZ2LNkxHJLrixDSVu7dXWaNGgXhh1N/woNG4lIPQtBw
 D9gJgkgJgnlXY8gs+kwWR1Tytm2AtU/Vm1ImCQpnYDK90oUL/6WV0DPg74yzYbp6SSLN0c8lCSW
 /UZRAJIHj2s0zJyR5xVL/TGnfYaZ1zXnaZ1Twr7B6GIoLimwlCxDrYq0xim9bSjg4nRMNeSV6FY
 AUk5HJFHofAL6blQH+lIEcsX/er0UssDHNOlDJVnHduZc5GNQXOjWvqzTfnNWsSYzq5L45pcr1D
 qgBrNXx8g/8mzPk9tgEolLfKZbD83uHRRtj5N+FGL8azk7PSGWZC6CmcWh7xVZgHD7pZyn2sJZ0
 ivOft0iLXuL8e6Q==
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

