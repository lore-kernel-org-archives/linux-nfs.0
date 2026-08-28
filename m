Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3A2494534A7;
	Fri, 28 Aug 2026 16:37:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787935078; cv=none; b=eVSK62y98i0YzeFqKQdhFBlgQ+3Y1f7DW1nD/zB0isUjnf1y1tmL9RwlLtnVy2uyWnQTfZpZKiyQ/iUNyh3+jLqEwnCq+hkzknG9ZsfC73Ozxt2gf/8CBWq0mKPTb5lif6j9YWobLi/NYsT0XS2GY3j8NCEhmZTt/m3xeYDkfr0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787935078; c=relaxed/simple;
	bh=iBISyt3zCPwOU6LhEil5+ZXak53MIzcx4tHXZSTAl18=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=jW0DroESnpschAy19LqUXs/n9w2mHvKJIs9OztkHR9r6B+wopNanT6NhPzr1c+nqQFfuOxuybPCecIz1qx6AI1qDJStb4tzUB6nmYhKjW+7jY33SLKR4l/NNd0xHo+LUhNeYw0PMKXvYKn6XUIyf93g/h4uinRRmJalcsXVYhxM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fHOD29UF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fHOD29UF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 611231F00A3F;
	Fri, 28 Aug 2026 16:37:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787935076;
	bh=p4VaHOgmeNFMziXpqxvwDBqmcVr4dEvVqtOV2sYB+yY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=fHOD29UFj4s/cNiCiPTgSw0uWqqqD1ee9xX/a6A32/fmANJQ7SacguFI4SI5UwJiv
	 wh8ommnFswfOSOgUfR7oFVGu2gcLO0CY8egy3sRmSoH1KpjagPyff57+og/21cjypN
	 BPclDR0kM3s64A40TRA10ueifZFPxCYABgFG6+FGap5WOiEQ+Qap3On5/w8FqKmaYy
	 MKDZ9lQ137ng+Opm5u8brzhczW6MAMuoYqBNXGLClLg9KYSkGgntOxRtEPDSpdYc8X
	 cCtprGnr1JOkAU9yR6HWwIaz2vmLJ828YjG8k3+4vbCEbD337e5twCvhJhjp1XJLQa
	 2iRtF17VxuI/w==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 28 Aug 2026 12:37:37 -0400
Subject: [PATCH v3 07/14] SUNRPC: stop svc_register() once rpcbind stops
 answering
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-nfsd-nl-hang-v3-7-55026685c75d@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=931; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=iBISyt3zCPwOU6LhEil5+ZXak53MIzcx4tHXZSTAl18=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqkblVlWDOGbDKEE0DrYizTKFH8DxyCPM9XY2OK
 QcY1YE1iNmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCapG5VQAKCRAADmhBGVaC
 FSEnD/4utauLkgitX1LWSsTq11DqkDEAZgmizCQkzQSaL1T7KMG+KBO3B/pHMSP9/K68RimkQ7/
 jgv1iBk7vxvI1AH3uuC3QmI7z5zRRRArS6YWBR0nLbnQ9M437bsYHo37PbEWGu8hXxSmcwBV60k
 mxWSvPa02v+QR46q0YRiaZpFFq3B8ORdSp+O1XvpT5OwnAKnPmSm20O+h8tStWYPfYnkjLZ/M7b
 bIEllrMCKR6QQbcnYkFECpGODER+AFtDn1GIHoPJUlZpnUylbI8XTssOXB4E1yKkzvOlUC/1HFE
 4DiJ0NdmxlUYWIJ/g+nHuC/IaYayju46ovYZU3DKUB+6dtqdwy7Mn7g0zyzADLXFWFW6Un5HnLL
 6dYEQwpF802KebFeXGu2WX6xEfThnuNLosJ4ZQiuQ5lHPUWQ/sxQ0jbGlFbB95E4Nnt7JCBsCVw
 vZ0QVEan9TNJwwuM3+5IoXCRjYaMBWbDsD2B2mrWt0KcfvWdXF85BhFTTBod8i+1wsE/5FOnDhN
 dmOdJ3MsPACUknKyeCfwg4n3LP9pTu/F4WGhp/7kVLPFgCQ3pHJcYsgcAJpCRU3g0LgvhW8Goxn
 i8nYiWatrfztxwzia7EhDCJG9AmVMyvbFfJdMvzQ0O4T76HdsPDEb3UcWN0FiTAoAsYzG9Rl3Ua
 d5BYhaqjkz8kw7g==
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
 net/sunrpc/svc.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 54f8e8b0bf28..e437e99a0b36 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1258,6 +1258,10 @@ int svc_register(struct svc_serv *serv, struct net *net,
 				break;
 			}
 		}
+
+		/* Give up on trying to register anything if it didn't respond */
+		if (noanswer)
+			break;
 	}
 
 	if (noanswer)

-- 
2.55.0

