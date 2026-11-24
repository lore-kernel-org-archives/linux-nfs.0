Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795490543;
	b=iPhZde1QPdRiK6MM9T1AUt2nrgbld6ZL+b5SWxsrXxEiiudY012dQOvzyCccx6WpSMzU
	 N/ukj3Hl3wylZW24U3Nyx9dj8z7s44/hGUxwwdTuRKl5Y9YLNREMxtBoUkYBfd+1YxI6m
	 MEjj+T4TQmXd2LmJLnO6jb3+sxMVG8Eouf5Qfo9Ke56NXYx9v3uHF7n0fmcDZvwumrwvO
	 wpw81TbthTpJgHTZs1mjWBDw9HTcencu+XszbN4ecm3l8Xq8ITRdWM/U4HJMhCgtLoHBd
	 TQGv8Xf6RZoQCZ8gaPQchvgRA2prN27Gigq2Uv9xmXPXOajQ+cYDJZUXWz0dkBm66gg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795490543;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=TnLuvvweS9A2U7qk6ahP5TVUX6RcDHF0f+wUM5oQqe0=;
	b=RP5JA7uAUfOu7JJOZOUyTtV7TnhrXj85HWqDrQuXjrpG8kZjshOT5a1vDK3hdaUpmerE
	 fe8GgrBJWkamZFpcXrQneOINngrhoV+60yFrLvDrPb6Dy9ZGgXrnzpS7DlscOUBYTVp7O
	 STtULilJ1E6nzV7s2c5XlQLrTLtCp39cxj/8BvMRnIhvbDyd1GNeAUHGv8y5H+Suj/0yH
	 6wV7/0V4BZ6vDA70xM8sXTAQf/SZTNOMPC44jpwuZt/E+7627VKOOpXYLCmDX0obLqAXa
	 si9nemTUZi0SPpv80/Zt6Jee1VmOKphbE4I9VmxpBDpzvs5bImxEE1pogvBdqIop8EA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B67lmcvB;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1BF3F606A322
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 03:22:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=B67lmcvB
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D38181F000CF;
	Tue, 24 Nov 2026 03:22:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795490542;
	bh=TnLuvvweS9A2U7qk6ahP5TVUX6RcDHF0f+wUM5oQqe0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=B67lmcvB7tqMs/4JOoWVq7mKpsdhMipM19LpKss1Nc9FhXyhNkqCog23W9SNoMZMW
	 AEfI6NG78p6G4MynItvKuSuSBcebr09W7T4Z2dRNy1z4HEg6hdXw8b6a0SyHjluNuY
	 7pLReBxsFtMrSXB0KoougJ/+fnyYDU/uadvIV+b8UBBvmOX4nxYHJKxQlC9GgX2y0h
	 UbraXwYeqjBFB0MMAQg2kqfBCn3bFMnkzFs2dR1jIaYn+knggNI9jtZzEQMzZjP2aq
	 gH/VvwMZ3t8dVnUd1CTWaxfbtSvxiRH+uOqDDdINH+F1025KVWnktAc4hLpmGBOTFQ
	 R2yEI9NwVR7wQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 23 Nov 2026 22:22:08 -0500
Subject: [PATCH 7/7] SUNRPC: Reject an AUTH_TLS probe within an existing
 TLS session
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
Message-Id: <20261123-xprtsec-recv-snapshot-v1-7-90564efc4cff@kernel.org>
References: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
In-Reply-To: <20261123-xprtsec-recv-snapshot-v1-0-90564efc4cff@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1257; i=cel@kernel.org;
 h=from:subject:message-id; bh=B+c/AcZWebmfI+i1Gf4EMY8jC01ZplE1GXV/9ehYQXw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBrBQLiVqMF5u7bUN5Hye2qy15vatY7s/A0Egeq9
 TvwZwjxf2KJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCawUC4gAKCRAzarMzb2Z/
 l3i/EACsGyz+GJnRftBCwJ98FKsno9zVEp+9itTyNOJKNrtV/LCkLV/FO33ooPo/JLqw+oK5Zrk
 HYHW0OzzCdccNl3X57fV/067J2V+kIM/TQTP+qWsT/nhDocxikmYWLQV7VFa7NEFNmnHKnHsO7o
 sYMG5GxOp/kD9/1z6qfqVXE1XXaPJfMrbBQgz2ZubsdTkVnHoz3CQdKsuHsoAjT56/BNjHbTmqT
 vYWrz8+dRfrIaBDHwCkjEReUmQpxxzm608UYjYp1nSatb5HBToaxExDE8YvPD9d2zQ1mZCIuTNW
 8owfE7jXKUHgM/QqlWJzgUv8v2dtzjhwUdS8xtQy4pDhRNBDEa+jmH5QcfGEP4sXglbt5cG67bv
 GvmOmXh1H97jvU+i0RC00jp7XfOnldwCzdDorwYKdKDynaW/j5RraO6VtL58Y+KjcRwMY8ZZYDK
 V/TMHm7gecvmv0JiZ6dM1Mv7TPjJ6/MRX2Q1r/fvhuqkoQi43WyZjgQ8vJt4IRuNdnC2WaCAKL4
 4gym4NJXwgTlt41aqULSQUmC8kcv1Dv29VfjUINiT+JZhnliTzj1wlsfOph684ZPs86WQJ6/6bq
 1YYd/S+VlWDC8g4Qzj+KQueKAfXKTYpRXsyuC9yInnwP2l8ZPAC2goHKr6XAJXVFLYrljLItiBS
 FbnZsi+zeqJ7T8g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 9289 Section 4.1 requires a server to reject an AUTH_TLS probe
sent within an existing TLS session with AUTH_BADCRED.
svcauth_tls_accept() replies to such a probe with STARTTLS and sets
XPT_HANDSHAKE. svc_tcp_handshake() then clears XPT_TLS_SESSION and
hands a socket that already carries kTLS to tlshd for a second
handshake.

Reject the probe with AUTH_BADCRED when RQ_TLS_SESSION shows that
the Call arrived on a TLS session.

Fixes: b3cbf98e2fdf ("SUNRPC: Support TLS handshake in the server-side TCP socket code")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svcauth_unix.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index a32d8f7412ca..0f1aae684130 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -1139,8 +1139,9 @@ svcauth_tls_accept(struct svc_rqst *rqstp)
 		return SVC_DENIED;
 	}
 
-	/* AUTH_TLS is not valid on non-NULL procedures */
-	if (rqstp->rq_proc != 0) {
+	/* AUTH_BADCRED cases from RFC 9289 Section 4.1 */
+	if (rqstp->rq_proc != 0 ||
+	    test_bit(RQ_TLS_SESSION, &rqstp->rq_flags)) {
 		rqstp->rq_auth_stat = rpc_autherr_badcred;
 		return SVC_DENIED;
 	}

-- 
2.56.0

