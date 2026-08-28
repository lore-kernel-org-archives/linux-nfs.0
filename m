Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 82AC338DC52;
	Fri, 28 Aug 2026 16:37:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935071; cv=none; b=P450CogYyNLCHuMbDUXlddzDWdW5jP0SIKvIidr0jd2wpMOdhMJ32mI/7E42kePs/I7CaXFtzlDQaBqNP79T16kDusFYwMSoTgldL6fByTbdE+DtmITQ6S1ljotFgkXjYokpsaTjbGMBU+Z7qaTQRddvdmCDgDn2gx9fk6G14wU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935071; c=relaxed/simple;
	bh=0/b63pHsH99q59pHXxgWpdCiis0fT0wFTjXendozs0s=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ltxpDxMQ9xUQlDTD6njjjrLt/EPlCEsDl6uiSsU0bLHedtVFNIH3LDwhDZ8Xxl28KE4OEtnKJS1Ptrg5BwB7O1X7OF4/0EyB4ivYmJLlsHllKwzI9Y7UWFIvZ73uxsw0PA9HYuXVFAeVxxosSuUWNftaWqozbb2CJTSKttCheKQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EecOYMky; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EecOYMky"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A4B901F00A3D;
	Fri, 28 Aug 2026 16:37:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935070;
	bh=yBYuY0qF5cKQRzExECF4YXQMQy4ClFSSmJFRGPrU+CQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EecOYMky7iDMtCaMk7yWVpPRVh9hVl5RaRI/k0GZTuFPqAIiOMBwp+D4lVlQAIcqu
	 QhIW798nX9/sKvoJZWdAFzvNoIRvQMpIvSC2DSQgrrptF85g7yRFke8iJoYJAt5H82
	 HOvYphUN3Py2kDE7thUDTd/IWzBoIJe+Fqwrar9RxyPcPoKMcY1DeEgCGonzWudvMc
	 lxpaCNu9t/XjRXhNPvJaOIII9/r6IW8hJCSJX+8B7lxQfWCFf1adOpjRTDuLpEkODm
	 LC4mwsWTRarSrDIHGDGd2aMRblWGz4auauvwID3wQQQXWiDDEUZaHCPzgSi1NgNAIs
	 X0VYfUkF+U9Vw==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:33 -0400
Subject: [PATCH v3 03/14] SUNRPC: keep the first error in svc_register()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-3-55026685c75d@kernel.org>
References: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
In-Reply-To: <20260828-nfsd-nl-hang-v3-0-55026685c75d@kernel.org>
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
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblUvEmFdS94dVuTXCNOUtAs56USDL2OGxbpe
 /64bYD1kBuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VAAKCRAADmhBGVaC
 FWgYEACccaQGhvRELt+7BtoJgnHmtUHra93CFjuqhYVs8DWbI3nU0wCJGUOMcKmN1iSVj0vh+xZ
 saVsWWaykCacCxZb6HcBfmXiUzsNnq6G9RbRk6bjdbIsiGlZutrxJSBi0+aXxilcU9cQPTYvZo7
 ZYo93zcQm5JD8GH5fOssixKhO78GEUz82VS75mTBp9CBvywCdbPva9dqevIF9C10BqHN/080wJK
 /gHFjqRQAgn8jc9Km6hKRcqxIx5vx5u7WfJRThOlfpFTNWs/7wLqxEytXoK/DhwbJSFvet5IoGz
 cNsin/UrUwsZUKd6nyZYfGwMNk9aExQc+GvkDM2Wu/rl9vcbmFNbBJtTOb8pfQoh9Y/iR8ThjMY
 X8upl5R3VSFxJlG2ofxJ4riZiiwDyNcfUGzdu1BCiRSA0XZqtOWpEqQP9WIYAYoVbZuk8Iuc9oa
 nAXn9RV08W2Ks6k3pqp1tSv/lX21lZxMyYPbVv4dsVOnQM4zh+ZSkKjUEhQ4vi9qwxO6hucqdnc
 qZhtP+4ULhnI/YnSwDXGVsVw+nefxHn1McB16PlLkyTTISjPXJD89Rf9pfrT0oEBLjTtJOhu/d7
 Csd6SRBf6geWb++VmfEhKNLuqQ3rwLP2vKWiP7gg2HJNDgHOVAC8Bkc4cArHAOSLiOalDuWmyq2
 nKeKumSP7QhelPA==
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

