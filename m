Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EBBE471CE4
	for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2026 20:27:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787776031; cv=none; b=tRaA0j92Q3aEDER9n8P5tKa8prWUnSBdsVr+MqiaufdcYBsa7t58E6rd68VzDt/sqkLDnULmHt/w6aZAKuzCaNpny1yTWCG4Nc0gaLonxhz62KdU/ZjoXcoMG6UXD2HIH0iGLJjz3v9tk/ym63IZ4yyxA2SJUVvcXKuVpdROrdc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787776031; c=relaxed/simple;
	bh=aq0RIZOA0Rm1iSojL4qVeXiKqTxXw6cRpM+5iAuLm5U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tKYZt/Np2++rV14Fu6zXzXG3CXDhjGcy/llZnuPEys735SUhBuOoEkk6RyPmiovAYVu5QRznqD899z7MhA5j0PADZ6JHbXTvnxMp3xYAAOOQpF6n6zKGZ2uhawp8C9zwH43FVSQ1i3Ozgf3P412ybQUu7vFUXcIrBC+OfHyUxgY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N4X0Kujk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N4X0Kujk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 793DD1F000E9;
	Wed, 26 Aug 2026 20:27:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787776026;
	bh=S6pI0ycjmUUXDD+U51XyrdkpwGc8BLyYx7TpfN8ajHo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N4X0KujkUG/JWQYafKeuajtJlzFr/cOAFnpGOUqsH69Ozr9FTlXeDlaiiwikduaKS
	 O7xpZ7KkH/HO46wkkOkoPuwZ7MKfDnhKxR5ysxG6ElYc5OEC/LT8tO30N8LGXL3g3S
	 X1R8nupZN+mu3AroyO44l9r/gffQRUv+F/ADHhqRybUCicesNGq/26FBilcb+PvOAC
	 LwcvY+haYtP9Gn5fHQ756kfc4r55Wlmam+Z8jI2oBm/1Msb2g6b1GJAq2xyvktAFBO
	 ShAd65bKWCWBNmOETZuR7xAL/LKBbziboAtRFOrZ+9pFNC3Csv/eLtCcoctJOYBeNj
	 Km5FkP4aC/kfw==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 26 Aug 2026 16:26:54 -0400
Subject: [PATCH 4/7] SUNRPC: Mark connection-oriented transports on
 svc_xprt
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260826-duplicate-reply-cache-v1-4-b1d51e1af5c7@kernel.org>
References: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
In-Reply-To: <20260826-duplicate-reply-cache-v1-0-b1d51e1af5c7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3279; i=cel@kernel.org;
 h=from:subject:message-id; bh=aq0RIZOA0Rm1iSojL4qVeXiKqTxXw6cRpM+5iAuLm5U=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqj0wVDXRYrOqSv6zg/PSEoZqhjqeRNJHKF5u3W
 SqTchLjumuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCao9MFQAKCRAzarMzb2Z/
 l+xEEACas/4eUMdLeLYXvDAFEHqG73nU0LR+MqwanyFizqgj5danqEoXID0h1N4J/Tu5y/URcYl
 gOoZL6zqXXFjjMaFDEWC9upYCWarY5cTgJ6z41LvuZMa1jv/Go4eczPg4yuzCbRPDnBT7VV9eCv
 ZaTOZLAEDweqpqXs5wkCDw+GmIO/LAkNPAdnHQe7weIVop4ye1oZyo751fQ0Oeh7/U5BFHKG7ch
 fmE39gPH5xEhXGcgvbn7m78+9cSJkAGAcv3QEL0WRx1JpxiR3rGa6vIPfmYOpRIIMbiYIh53Vhm
 UR5MdN+XPO1uCgwVnHoWMCILY6VPKl9EffcJWD7K3LD1LOkj6CHA0SmKUiA5MqJYyeiHJzrOkQD
 SXzzogkfMOOnKUbpCxseA1VJhnCqDfGIJdD23RfkAv/m8uWq+gKt3DBkXV56iqgIgG65XLZ0ul3
 Gf/5my0Zp25YqUuJG9AXeAxkPIzJl0svJK1P0uomE4QUX3+JbmpXDBy+Uec6W3VjGUge+UlxwZG
 Qt+dDuWE9wct8DYZlTGvTHBfYjXPtxyNxmRFzXBexMkllgAjEhKyZP7/VQjzFvdy0RTzZ7/1UH8
 QqKem39qMyvo79TByf+9nXSLXm34DBiemZ9Ytp/wcvRpJSLnBMXvqekiRIgC/XN00tYYpj6iSsR
 nQxIBVTKbTCMQwA==
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

