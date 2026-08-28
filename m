Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8367335CB6B
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 16:18:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787933888; cv=none; b=VBrkU4RjFrCCYlxg0mMc7NrFF9yu+DzhICSj7ODmE2z2TEkMUtZygItxZXl7NzzakuPdLLoMCbwc5Je/YZuMBuVWZgt0PwBOhBSgy1ODD5Yn6rLXsDPxq6Nhx6Vn0a3RM6Ea71NY8MRkB+l6G8lkXcRnTL2UgNyDn05nEX8PI0I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787933888; c=relaxed/simple;
	bh=aq0RIZOA0Rm1iSojL4qVeXiKqTxXw6cRpM+5iAuLm5U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LQd8BECIY6ejXDvbCtuQw/UlfTrWlpKdBVm98Acn6yMeetB0PgwAqFyv1W0hx+kYWODK/Z/+UzJeJ0OPkbB5p6yzEvnXiVosAFs5Nocsc/Vdzb1jdJdUsfDPyPx1ifc/U+Er62M9vCEuMxNZZtsTyCsaaWxaOPK+oXLnukP8tOA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f5COwgTa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f5COwgTa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB4441F00A3E;
	Fri, 28 Aug 2026 16:18:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787933887;
	bh=S6pI0ycjmUUXDD+U51XyrdkpwGc8BLyYx7TpfN8ajHo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=f5COwgTaXyKx3pKDnwlxk2/E/V1gZ5GgorqKJBv0WCPZcnvY9qG4nq4uegD4O9S9X
	 /+UfuT++VoyOZWv4arU0lY5N9ioyuUMikCT6KPFzQil8xE4QTDTvHkEgAlee+eTZD1
	 /qGviEUdXTZ5PnI4Q9KQ/YlgWL1/DXUYlG0VWJpJkG+x2CzlzunL/+YTIPQRY3+swD
	 wkX+KUKmhJjO7zQRAQRKYPakVLfwkTLCXvAh34VoiwXnIEVDb009Dl4Qf6jsoklaWg
	 J9TL/zNHTKxxygLggLZ6qiMYOtqLyDAk9xQLBL7Eny4w4dZHIuE/ZtF3Q1Vkrspoeb
	 SQQCE8Q3iKMxA==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 28 Aug 2026 12:17:56 -0400
Subject: [PATCH v2 4/7] SUNRPC: Mark connection-oriented transports on
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260828-duplicate-reply-cache-v2-4-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
In-Reply-To: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3279; i=cel@kernel.org;
 h=from:subject:message-id; bh=aq0RIZOA0Rm1iSojL4qVeXiKqTxXw6cRpM+5iAuLm5U=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqkbS6ktP3Yg4auH+EQf6G/rg9EE5jmhuuDmOei
 PaC+ABrb2eJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapG0ugAKCRAzarMzb2Z/
 l9s9EACO7xrBdI4SKGg0MnxB++46CXVkFIfHNt7Y/OvMYSeh4BlqJqv3Wrc6eAxJS6sffgh0HGq
 w2oWdPyAQkePPttVEGoyE0H5yxr3/A3m59ZigIEiWENZ5Jk3xdMs+of8L2xJtT2gTAJGE3IDOkh
 NB3Qg9iRnR7hzHho3xunhfmQNkS7YsuYSgij1WUOU0Y85t5g/oXa/uCdgGJPhgMrnEXS0pXXDJX
 U+oCtSFzDuZ/B78HTvkY/MMrZ2lZme2rjlB8fW703SJM8/D7cpB1PUaaNsEgv4lYqgHivvw/KH+
 vU+om5OTWzX6G6751A1WGgSFU30J+KFv/3fgTdJ7qTnxTaxs6j4TKGZmUnPyX1JJcZ2kqim5VUF
 25MSAdFV+7M1Lbvsa2Jedg4ujJeyPxk1Ysxo4jdZnIySJi2s3SSomHpXFh6yjmNwS6nWcuM7d/z
 7g3in833q13ZOgRdtRw3KyUCo8oM28j1b/riRNZuR3tqnfSsQvmShkos6mvyKnpMTdtHH+ONdts
 JlQ7I1+1xwexf7ElhrpvjbCA7nTIxRQQ8sllIFKaxW8afIRF6H/0o5Se6hLvbiT968fLfgtXhpr
 e5P16HPi9s3A/noK3D6i95yvqYsnAXlUKMx/Boeo30XhfdEYHVnd0cLH+fxf7Etx8a6zLTA8cjp
 vftMljoltbqek3Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

A TCP or RDMA svc_xprt carries one client's request stream, delivered
reliably and in order, so a later request on it indicates that earlier
replies reached the client. A UDP svc_xprt is shared by every peer and
offers no such signal.

Add an XPT_ORDERED flag, set by the TCP and RDMA init paths and clear
for UDP, so the NFSD duplicate reply cache can confine implied-ACK
eviction to transports where the signal holds.

The flag has a cost on svcrdma. handle_connect_req() zeroes the remote
port in the DRC key so a cached reply survives a reconnect, and
implied-ACK eviction can retire such an entry while the original
connection is still up. TCP gives up the same thing whenever a client
re-binds its reserved port, so this follows from the eviction policy
rather than from RDMA.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/sunrpc/svc_xprt.h          | 1 +
 include/trace/events/sunrpc.h            | 1 +
 net/sunrpc/svcsock.c                     | 1 +
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 1 +
 4 files changed, 4 insertions(+)

diff --git a/include/linux/sunrpc/svc_xprt.h b/include/linux/sunrpc/svc_xprt.h
index 53ed073640a6..ebab18e403b2 100644
--- a/include/linux/sunrpc/svc_xprt.h
+++ b/include/linux/sunrpc/svc_xprt.h
@@ -99,6 +99,7 @@ enum {
 	XPT_LOCAL,		/* connection from loopback interface */
 	XPT_KILL_TEMP,		/* call xpo_kill_temp_xprt before closing */
 	XPT_CONG_CTRL,		/* has congestion control */
+	XPT_ORDERED,		/* connection-oriented, in-order delivery */
 	XPT_HANDSHAKE,		/* xprt requests a handshake */
 	XPT_TLS_SESSION,	/* transport-layer security established */
 	XPT_PEER_AUTH,		/* peer has been authenticated */
diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
index 180346e520ff..2154fbe69945 100644
--- a/include/trace/events/sunrpc.h
+++ b/include/trace/events/sunrpc.h
@@ -1931,6 +1931,7 @@ TRACE_EVENT(svc_stats_latency,
 	svc_xprt_flag(LOCAL)						\
 	svc_xprt_flag(KILL_TEMP)					\
 	svc_xprt_flag(CONG_CTRL)					\
+	svc_xprt_flag(ORDERED)						\
 	svc_xprt_flag(HANDSHAKE)					\
 	svc_xprt_flag(TLS_SESSION)					\
 	svc_xprt_flag(PEER_AUTH)					\
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 840bec53e1ee..97a592ddeb48 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1486,6 +1486,7 @@ static bool svc_tcp_init(struct svc_sock *svsk, struct svc_serv *serv)
 		return false;
 	set_bit(XPT_CACHE_AUTH, &svsk->sk_xprt.xpt_flags);
 	set_bit(XPT_CONG_CTRL, &svsk->sk_xprt.xpt_flags);
+	set_bit(XPT_ORDERED, &svsk->sk_xprt.xpt_flags);
 	if (sk->sk_state == TCP_LISTEN) {
 		strcpy(svsk->sk_xprt.xpt_remotebuf, "listener");
 		set_bit(XPT_LISTENER, &svsk->sk_xprt.xpt_flags);
diff --git a/net/sunrpc/xprtrdma/svc_rdma_transport.c b/net/sunrpc/xprtrdma/svc_rdma_transport.c
index fabdfd891a41..5d39fce231a3 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_transport.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_transport.c
@@ -218,6 +218,7 @@ static struct svcxprt_rdma *svc_rdma_create_xprt(struct svc_serv *serv,
 	 * transports are suitable here.
 	 */
 	set_bit(XPT_CONG_CTRL, &cma_xprt->sc_xprt.xpt_flags);
+	set_bit(XPT_ORDERED, &cma_xprt->sc_xprt.xpt_flags);
 
 	return cma_xprt;
 }

-- 
2.55.0

