Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7173049363A;
	Fri, 21 Aug 2026 17:22:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787332974; cv=none; b=p6RTwGVzpL+zBz8mEAS3YvSd+JFmE8YVR6FxQaTpz4amVVYALgZuHr5XGYwY6Airs3JGiwxiRLtWEh9W+dFE4o4SUxWz3GpneocmZ5r1Ak3VALgYK1dGlGQHgEgR3fnOwHW8MsvAHAIDRo2AQlmtFr0Seq+zIr9aQTyfydrJNPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787332974; c=relaxed/simple;
	bh=7Wtq+05AWuqisBqvZVmpB9kpbo/sIif/hgnre31d52Q=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=mRakQgTxeEBtnBnkvwMEGNsJSScFmZE6QyAnRL/+Nevw8h0zY8niG8o7BGkLwy4tGOJCPv2oTxD6/1K9Lbj5/sUdRyE23KZgrcksbDLjzXCUILO2sICtHkWMMC4dqARkEqGgeCVwbkuFShjKAuCsHsV6/hUwxwnSdTbgiyktY/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DLUlJHDY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DLUlJHDY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E6E5D1F000E9;
	Fri, 21 Aug 2026 17:22:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787332973;
	bh=UyLDnNmyV48Ru6yhOQFcglUDO4smCdLDRGJrPFzT2TY=;
	h=From:Subject:Date:To:Cc;
	b=DLUlJHDYZmD78Hnx+cGGAhJPw6QgTHvNkVI9StvOC1RZFScjM0N7Fsmn2WR0gJPLV
	 8rKKLB6ezniFz6CrzRn6xmDaPNpHVGCjtB1LrOSDgpLitTSG/jRYBQ5JuN1QO4a1a6
	 14caK9wu63MAkCrwFjQ3y1zCikXxpIk0nvSmymC3koYq/ABrTzZChbNdJBr4eCoBP+
	 zAxD5xyddHfxq03sdv7B+OGNEDbnQ5PtU/1Q9fNrqyz6SpOPrtpl19gC5JgU4TGGVL
	 7gMm5T8TcUF69sCHbLx1RSucwzEzfYWfqcZip22qkxmoZ7A8ooePX107X3IkbOLBy1
	 bjKOJ6oTKZXjg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/5] SUNRPC: Receive svcsock TCP records with ->read_sock
Date: Fri, 21 Aug 2026 13:22:38 -0400
Message-Id: <20260821-tls-read-sock-2-v1-0-7ffce164eb45@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWMQQ6CMBBFr0Jm7cQyJEC8inHRTgeokmI61ZgQ7
 m6ry/fz39tBJQVRuDQ7JHkHDVss0J4a4MXGWTD4wkCGejNSi3lVTGI96sYPJKSRqeu9G0w3QLG
 eSabw+RWvtz/ry92Fc83Uh7Mq6JKNvNSJZT3HST1m0RziDMfxBXGmyNOWAAAA
X-Change-ID: 20260821-tls-read-sock-2-28c236db7037
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2893; i=cel@kernel.org;
 h=from:subject:message-id; bh=7Wtq+05AWuqisBqvZVmpB9kpbo/sIif/hgnre31d52Q=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqiIlkSHzCOkHJUdkyPfHHmMsn4NIWMu/5AvSc5
 li6+eYX4HCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoiJZAAKCRAzarMzb2Z/
 l+JPD/4xCFSyJmfFMRHzqO5xkaRa7CldC95TW5Wewy8MPJW1bOYQ/sNkAVpfiD0BZb5Ox/hJD2j
 qHPCsbVV5/wbScpAsgY7yUCPs4xYoxHWOLEepesetLWvu2uOeD4n2TCXFgFje0PplbywWCI1/6n
 WRpxrcFZivAJXWb10QBMJhAxpJgWN1ZDiqQQCxvP3xD7gazVy+rwNb0Q85a06xcVSP87txGqXo6
 NThZV3GMtIVYiBtwuVJbhQQSssEbMIo6hYnR79bqCKxv87RRO5lRbC2y0u8i61rODfWz4nYYecu
 5ggYmcnsw5xEOfzfpsJTK142HA391V2AkyXPp1YtiqlHkBcpQudGJ0vYFhjQAp6XWs5j8XJkGS+
 MS7oKAZxiIafPFw/CBqGTlODEc7AspMGwVNmVXj1WEUJDdXqP9RjAu/gZGiCj9W+470g2lmytOo
 UmD08fwg/nCrpj7+2XYqAndi/4UfEwjhuVaMo710ICJIZp+KcyGwI7iW5qghin43zx2P+VWbiiT
 vwBt1PH2MvqetinN8Dg2VH2UbMSx5cpB8AsEGmCOTk7N8US2wa0OX2MH586yt3nf7pdqHsG2sIF
 NFjJVP27+7HuwsQ6neZVBza6I2dY/sLP28DoFYU3NNWHblr05nqIngjeDOm2GggPhXimCKD2MHm
 FUqZ8tkjrtRktfw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

kTLS splits a TLS control record across two destinations. The record
type arrives in a control-message buffer. An alert's level and
description land in the buffer the caller set aside for application
data. Every in-kernel consumer thus constructs the same recvmsg()
sequence: install a cmsg buffer, discover mid-call that a control
record arrived, take the body from the data buffer, re-issue the
receive with a kvec, and rewind the iterator that the first copy
advanced.

No consumer has gotten that sequence quite right. tls_alert_recv()
read a kvec holding no valid data on the server side (bee47cb026e7)
and again, found independently, on the client side (cc5d59081fa2).
xprtsock processed only the first cmsg and dropped every record type
behind it (9559d2fffd4f). nvmet-tcp and nvme-tcp were built on the
same split and never took the corresponding repair. bee47cb026e7 was
itself a repair, and it left two more defects that stood for a year
(dbabcbc9cf46, b6c603a2415f).

netdev rejected the read_sock_rectype proto op that would have made
that mistake unrepresentable for every consumer. Instead, this series
fixes the svcsock instance alone. Data records and control records
now arrive through separate calls with separate buffers, and no
buffer carries both application data and record metadata. The
MSG_CTRUNC recovery that bee47cb026e7 installed is removed with the
old path. xprtsock, nvmet-tcp, and nvme-tcp are left for future work.

Classifying a record before consuming it needs a receive that reports
the record type without also deciding what that type means for the
transport. That split sits in front of the conversion (patch 1).

Two types of receive that used to keep a connection running now close
it:

- A handshake record during an established TLS session was drained
  and the receive retried, and svcsock has no handler for a
  post-handshake handshake record.

- ->read_sock stops at an urgent octet and consumes none of it.
  recvmsg() walked past that octet and cleared the condition. So,
  when ingested via read_sock, an RPC stream that carries urgent
  data can no longer advance, and the connection must be dropped.

Signed-off-by: Chuck Lever <cel@kernel.org>

---
Chuck Lever (5):
      SUNRPC: Separate the TLS control-record receive from its policy
      SUNRPC: Close the transport on an unhandled TLS record type
      SUNRPC: Flush a received record's pages once it is complete
      SUNRPC: Receive RPC records with ->read_sock
      SUNRPC: Bypass sock_recvmsg() for the TLS control-record receive

 net/sunrpc/svcsock.c | 555 +++++++++++++++++++++++++++------------------------
 1 file changed, 295 insertions(+), 260 deletions(-)
---
base-commit: 01c2994ccb0197cb44b0db89aacab460110f6347
change-id: 20260821-tls-read-sock-2-28c236db7037

Best regards,
--  
Chuck Lever <cel@kernel.org>

