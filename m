Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F2A336A372
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 16:01:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789401661; cv=none; b=AjHEWb89U0HGhl6jztXndKv83Z8vMLNKux4b+B36cp4mdg/RXV17ooNMx9+ndv+KXwWdWlQyuIXzoQS/82jVngWdIeeN5UO1AkmE7jnf/20wOhpY99/jNo1qSGuNhpkb89WyKByMNCz+1JC4xn4iPLAp6GboFKPF4dIh+EQsUrA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789401661; c=relaxed/simple;
	bh=0410vtVGxQ4lu6Laz1XKp946QO0EokxLFKmAY2rWAVM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gP/qG0CWprXGtVXslcXBnBfSFM24WSvrRWou9P20VSjSq9nmsKyLpv5Lr7VBw1u8jfXORgDdOBglhJmH3kwv4dnyNiK2lCwQcwEjTiphAa3hPh4aTZVkt8Tc7iUzLz1rQuIRCya1r4NZwhuA1w+Zl69dojrMCknSGqygxI9QJ/c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Wemul0yZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Wemul0yZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8CD3D1F0089A;
	Mon, 14 Sep 2026 16:00:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789401660;
	bh=gzXXbOLe+8+3YzFizEULm5KLU8snab1C/Y3vQWUzgsM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Wemul0yZUDavzcLjsShoAC6e1+Q4DSLJDSIbsL9p8lpMMNFyJKo6sObIbblIdg2EO
	 jHictQbIxO3zHzpq2rD4f7a77IUdoNwTglNQeUZvvVFzENm2NNmRekH1G9byVq3wy1
	 017jy2zl+6e/ADBmIIKVHmawrxtBziVRa2Yt6Sfy7fZVs05Jgfn1q3vCcTdGfuDx99
	 Y1O5J8ii9kqNhjwjFTq33Sy8ljJsFQc6a/adySFXWimOUDZXs22Bp+jb5P0u5PThjw
	 NX3GjMgHKb9iZINa92+sqsxs66vBn+E3EGy21Tk9IURTnxVwtGtdN15rbg0MME9HFs
	 TlvCK/DBNrYeQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 12:00:37 -0400
Subject: [PATCH RFC nfs-utils v2 09/10] nfsdctl: reject a listener
 insertion when the table is full
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260914-nfsdctl-rpcb-v2-9-b2c679ac0107@kernel.org>
References: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
In-Reply-To: <20260914-nfsdctl-rpcb-v2-0-b2c679ac0107@kernel.org>
To: Steve Dickson <steved@redhat.com>, Trond Myklebust <trondmy@kernel.org>, 
 Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1397; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=0410vtVGxQ4lu6Laz1XKp946QO0EokxLFKmAY2rWAVM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqqBoy1hWfj7oxcI4yiCDlaHtNnSoeirBO+kr5Z
 KTdSxEbJOuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqgaMgAKCRAADmhBGVaC
 FVsAEAC/V/kj5wOcAnu+RxzbkJIbemOwE0pEYdFJfGAjkttepsjHN5ehQEvwuNWVz4vzUZV92/L
 htGyTD0UJY1HjvClclfy5gfHVtwmj2cYCFTTQuO3yRO13rR72qZTkJ7vqpYLWSi+Hz1WJP8xcZt
 eY5aGgDf5uAe+CWeppzi47ZhmAx8QuGaOYCaDdKo3wAOPGKPLY64eSzBYdt8UYHaIm8CzwsOiN5
 RDAqcivXXWPnop0EQHmXGi2GNxYufE2CQw39YUaYH01+b8eGcw/M+U6rx2XX5L7tP3RcEbaUw3h
 WrUHe+Gp5qFo/8XdIBVlosjYjt8mQhPd0CBH5mX3jrg0r0l0zhu9Qmr7EOCYUS5PPPj0iBd9RCk
 YNn0pS4iaC8jb6G5pqIkLb5msB03x3PHTdneU7ABMmZxV5SJqkSsbMHNsAssQIDQNA9tRkc+zuK
 qGkaJ/QFAKwydduqxj4i6dcrTJyGJSrfSkMfh4+OIUNpBpGD5lCNdgO/b2s6Gsa1TyNNOYB3i4t
 QmDzybJ+subEq9Kr20rQutiz5wHykqw9rW+NuZpgcFAJPw5SARpTWolJB/Rd7ULJfKXnwpLQm7B
 8dL9Fwv3IjrJ6976ki5BXOeoePBxAciJX8vkzPN5+etjDbSGiniG3EHcrCmnALALIjR9etvlyuy
 UfOTXlq4xRE5rPw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

parse_listener_get() stops at MAX_NFSD_SOCKETS and publishes
nfsd_socket_count = MAX_NFSD_SOCKETS. update_listeners() then scans the
whole table for a match, finds none because every slot is taken, and
forms &nfsd_sockets[MAX_NFSD_SOCKETS] for the insert. The memcpy() of
res->ai_addr writes one element past the array.

Reachable only with 256 listeners already up, and the count comes from
the kernel rather than the network, so this is hardening.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 utils/nfsdctl/nfsdctl.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/utils/nfsdctl/nfsdctl.c b/utils/nfsdctl/nfsdctl.c
index a2b5dea75dac..7464baad279f 100644
--- a/utils/nfsdctl/nfsdctl.c
+++ b/utils/nfsdctl/nfsdctl.c
@@ -1425,8 +1425,16 @@ static int update_listeners(const char *str)
 			break;
 		}
 		if (!found && sign == '+') {
-			struct server_socket *sock = &nfsd_sockets[nfsd_socket_count];
+			struct server_socket *sock;
 
+			if (nfsd_socket_count >= MAX_NFSD_SOCKETS) {
+				xlog(L_ERROR, "Too many listeners, max is %d",
+				     MAX_NFSD_SOCKETS);
+				free(buf);
+				return -ENOSPC;
+			}
+
+			sock = &nfsd_sockets[nfsd_socket_count];
 			memcpy(&sock->ss, res->ai_addr, res->ai_addrlen);
 			strncpy(sock->name, netid, MAX_CLASS_NAME_LEN);
 			sock->name[MAX_CLASS_NAME_LEN - 1] = '\0';

-- 
2.55.0

