Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549769;
	b=jys7uFz5xval5WeesD7sZL/ohjwjVVJyNuzIyJkJq/EmjZmaNwX01jR3sdrNkoUSB4H1
	 XQ7uqdzWC3oOo3fPsRsKbUZ7k1H2G8h9zN4L65EAciX3kW7EOtaShtCs7u7whbEk+ShIn
	 iW9KxzGPQ1DPWVM24I8o9u4OXZymZSx5IWlyaivMbpZHD8E1DMJ3Aq5qakauzHPc4Ky0k
	 dDBSxWpoei7Tt1FyYV7saDMy/Ml8q/0TGWKfnvz6TDPuIWlPOiDCr60bHpU3NiEsb7EYb
	 O4am6shkelR83i531WrNgVlrbLfg5OqMVA3h3qJZ+xXxef6NSTETkyulKUmBtx2V+Qg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549769;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=zHwfQCfJmb38lEqFT76DaImX1atMSnLcBbVhYr/nfyM=;
	b=IFJBLRlvpgtWh1STyr/JYkMcl1cQuw/s34tvdoSQfFmksmlJckYOSm3JFgR+wmnTqbxL
	 nsVJ3OMc8XbHR4ySyqERQLKrOgIGY4a4W07A0lky4JtPrPXRHP/fJBYbUabNiLUalFWLN
	 G3lrlvxOxKjH8MLU8Aaokars+ovr7gUpl5fQ2f1XwlAgZsL6pjXLxqtW4EAmEASUuxMpL
	 UUHiMFhUR/0UUO9MygPUr+NeQNJSUk8isUQPMzqukmgZyS3+MaQlSiblcmLjKOaX8+sqh
	 NjNhKkh0jRCjZUyRQHVvyBVBi9wBZ6NtgbUpOr1AXwTQFYhmBWiNA62ZXD1tEQh1sPw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mJ3UZqMg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE58260A2637;
	Tue, 24 Nov 2026 19:49:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mJ3UZqMg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B281D1F000EF;
	Tue, 24 Nov 2026 19:49:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549769;
	bh=zHwfQCfJmb38lEqFT76DaImX1atMSnLcBbVhYr/nfyM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=mJ3UZqMgGmLdb82o80SR1ozHE88enUbrnt1eX4uBOZ43rQ8H7143TB23+zCQEo+SC
	 qGTSoJzL/whWgyeQW+wWwjEGzgcL9JyBpO4okIxEblPfJZSe+BIzDrx4tWy1hQVayp
	 if9tLAZ6rzTXUA6vYxWAJxYGAYtbkpgu5qz+++BeX/9OjUbQFKo0qgRANyHJg78Ol9
	 M4iX7eMYDUuAhNoytBbgdZwbZ/UG9Rua3+44GUCFndjAiXWj/wNLRU6HJq+uNdYlpt
	 1Z9p2J3nUg7nzpPMnSS/n1FsFVS+IfqZvakQ4swqmpR34qyxjHgFDTXNGBDl2jr056
	 52aO44LJcFYHA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:51 -0500
Subject: [PATCH v3 12/12] nfsd: move ctime when CB_GETATTR applies a
 delegated mtime
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261124-delegts-fixes-v3-12-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1444; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1zT3UR8D3JA8M02VhrGNMqquxLfZZpeteUoT2Rr+yYs=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo3L99VriAkr4qzcnB0Tc1cqC359ivgWAqd6
 /GPFv/DzViJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNwAKCRAADmhBGVaC
 FaAJEACl395lXbeuYFS0OkikolFouk/IuYDNKKgjir6xFOvFg/vJ1MZfNHUjRTzpl3ZgrN59BZw
 ru0JRZFKQSnXFKfoUhhqdgXurlEoXTN5IrsSZU2cgM0qpktCofGRkyrKhM+mYLFfq1Rqbf+KQpD
 2oBTZRrsbG2HmgREcpNWZAA2Ks0Fh0k1bsNc185y1nQra6ieb4aJu8Sv97SDEb1/9OpvzIQrY2p
 2w7nVlUFyYboHJWh2e0/KL9+9SSyzSLaqPmrg0zgLWq4bhTuvFWNhacTssfuGd9Q/lV0iyO04gT
 lXw4rOg0ToG8JqlG8+AXbFFKLj6xOlxpoI8PBHewJE2XwnYXhpYAHeKH1ZsVUXzH22DTy/N9gtA
 dWpbICbYG+26LbsEwt7fpBxgKSt8xV7iP1eoloQXa79AWpxelMmXs2rVUaqb85a6VGYlbYdf5aW
 gJkIaJkPa03SSGcYYSJwcQr5kzxYVHzIob/8NUSrYlLcQqOKQBnFBvmGzvBztKxeH6Rg+6lgiwE
 eXmpyJho6V5OdJxEVGn42EAmflAjuGX7KqF3Ani3O4YnlNdDDIBKpSjDk1cEk0yxUk3gWZvUMWD
 sJudAjGOOylD7Ayde9aCKCb34PYfnDBO/yQrxMnI9Y+ny7dojL1cDECUDN1KN3FNOAWTpOOmwMB
 /TJaz80uVnJNvng==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

cb_getattr_update_times() sets ATTR_CTIME only when the delegated ctime
passes vetting. When the vetted mtime is applied but the ctime is
rejected, the inode's mtime changes and its ctime doesn't.

Always set ATTR_CTIME with an applied mtime, and ATTR_CTIME_SET only
when the ctime passes vetting, so a rejected ctime moves to the current
time. This matches SETATTR with delegated times.

Fixes: b40b1ba37ad5 ("nfsd: fix timestamp updates in CB_GETATTR")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6bb3ce974c9c..9ebee4fca9d6 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10910,10 +10910,11 @@ static int cb_getattr_update_times(struct dentry *dentry, struct nfs4_delegation
 			attrs.ia_valid |= ATTR_ATIME | ATTR_ATIME_SET;
 
 		if (nfsd4_vet_deleg_time(&attrs.ia_mtime, &dp->dl_mtime, &now)) {
-			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET;
+			/* A rejected ctime still moves, to the current time */
+			attrs.ia_valid |= ATTR_MTIME | ATTR_MTIME_SET | ATTR_CTIME;
 			attrs.ia_ctime = attrs.ia_mtime;
 			if (nfsd4_vet_deleg_time(&attrs.ia_ctime, &dp->dl_ctime, &now))
-				attrs.ia_valid |= ATTR_CTIME | ATTR_CTIME_SET;
+				attrs.ia_valid |= ATTR_CTIME_SET;
 		}
 	} else {
 		attrs.ia_valid |= ATTR_MTIME | ATTR_CTIME;

-- 
2.56.1

