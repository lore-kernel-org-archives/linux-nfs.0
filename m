Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6D6D447F2D1;
	Tue,  1 Sep 2026 13:40:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788270016; cv=none; b=cQIzZ96rNYDhtnugS94bKe0lB0KOhyxvh7KBhYO/UsQOTOpu02GsipkiGq/Qr+boCVaMFhtBmfIvWqHg98lhbxi8mbtjXMVFVFojfxCpOc+GVXuhjWvK8MFqdIXx0ZmkRz9BxAg0772QzjtzXax7HME2OvxKXa07v/OAJAHEnQY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788270016; c=relaxed/simple;
	bh=C33LkpUKt/07H9evJ07qv3CM9i/amV7NHBG7uNyOI24=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ML9gIKYRrRi+qoDSfIawx8mtBH9ngmZNcXC5tjsmirEqHNA4JBEUgsMnaqjQP5yHsEgGNYFMfvuzvLTF+XjTc315Hl5suPGTqouJyvFnGPNGp4dSxyYq6xu4Qcw7i6aLQ8XMbO7pAx8rzhmvHBLHIWb1Y2g9kDRQybMKhd2Ez4w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xrq14D6F; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xrq14D6F"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F8921F00A3D;
	Tue,  1 Sep 2026 13:40:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788270015;
	bh=uu/5w6dnsC16IumNu9SsTj4UaX4P/j02MChTCzfrPns=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Xrq14D6F+DpkYhwRnmq2fPIN4gC108LdFWRW6c6FK90reQSIiXCzliVGMAUCBVyWs
	 5X9rXuz8pwibiQa6YSOQiROMtqPNbmK3FRmutENgN5wvu7PswyA6zCCMcxfrb5zTc5
	 lf4M0ryHpsE/5AZ8YBiUr8hveQKjTQC/nqAaKTUjvJZb4BrJPm3rNHWXEFNhYE9ld+
	 tHzf3NXjfbnwaDgf03JhKLr91EcIK4KcbQ/rmAUAsGRyxaEMqXgteVjZkfjhVfTyvX
	 iiTe0qi4uDck3WhU4VVOxuywdNDFhHbwP9C5g9Lkdc+Ldr5N93aFqYR3O2P3lZ6aBZ
	 TZCdGccYaGc6w==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 01 Sep 2026 09:39:45 -0400
Subject: [PATCH v5 07/15] SUNRPC: stop svc_register() once rpcbind stops
 answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260901-nfsd-nl-hang-v5-7-a540d86668b0@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=985; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=C33LkpUKt/07H9evJ07qv3CM9i/amV7NHBG7uNyOI24=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqltWvicBGa60Lij2LJ9FxksICclXD28o5vjpwZ
 UwbwxL8Ku6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapbVrwAKCRAADmhBGVaC
 FdxCD/9VH4WsjdVWlI+g/i9mAB1SEuUyn4hXVuwaxh0qygq5j1wAj3OT4su98YE55DuvWXAGdXT
 ehPpmJdqsZ5IaoVtpOfJjqzp+JCbGC7qabsUa2XrVLTxXYDTh09i4KLGGOtTnDybOYiZfhcuu8o
 s+1SyL1lFNV1ykuVaoywjjM9FyvNaCNn4BAnyWV3OgwY5nO24dnKK2dcWjYJYR27HZTLFnYs6qX
 ut5UgoOQddrdGQqC368BL1MYA1iFIfM2fL9pO/DzWkMl78qe6XVHEEk8Skp1VtGIJZlcXsm9isj
 9/eeBupG4AWgBd4odK82XawbpaLG+9EemzFEKfXVExwzTchrWD8VFXA7ZWLkK+QG/wb0AvYh6iy
 bGdBxFN9L4LLKODeubtlnhb9/VgFY7dNEvZpS2Flwe1506TnrMJb8p5v4FNXMqWldeiUnM2XFEL
 kpPJ6XpgmQLTl9dAzasBkCY+ESgCO949qzEO0fsrScKb2nEs+1jemPrC51XeA/cgPEtGMjUywsV
 XUCAxZb3NeK5BOrk9UVunPMf5VWnmt1i+YvtjpCQpGrUru5i6UYBUe4FmRZMwj7HYBulCEdXVGR
 8J5dIpO2nJmGtyN9mhp2nJ9WewyuvZX6oaTTP5SFesaUmZNiLqWJKUMspT0xg1cXx1nLlu0oirW
 WaZWf3gIWeL25Iw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

svc_register() walks every program and every version. The break on error
leaves the version loop only, so a program whose call to the local rpcbind
timed out is followed by the next program timing out in the same way. With
the 1s bound on the local rpcbind client, an nfsd serv pays 2s for that,
once for nfsd and once for nfsacl.

Stop the program loop too, but only when the call got no answer.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 net/sunrpc/svc.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ca6f90653327..592f2745b028 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1257,7 +1257,13 @@ int svc_register(struct svc_serv *serv, struct net *net,
 					error = ret;
 				break;
 			}
+			if (noanswer)
+				break;
 		}
+
+		/* Give up on trying to register anything if it didn't respond */
+		if (noanswer)
+			break;
 	}
 
 	if (noanswer)

-- 
2.55.0

