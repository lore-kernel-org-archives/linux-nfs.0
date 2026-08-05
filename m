Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 780A03D410C;
	Wed,  5 Aug 2026 18:31:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785954670; cv=none; b=Oqzb1Xr8TpXHVEzzdRMTvG2/MGm2GN4MbsWDzU9GZymjOPak3CSkaK9u5GnKJPGWpGlcmjXmovLNzd41nMIYWbpAyxyBo8QG9k/+YQpWjHQb4zTAFd/B94gyKdy2LbZKRwdfgqkvOpY8ZxoAxJdq7zp+xj6dXAPtVHponerdE+o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785954670; c=relaxed/simple;
	bh=fKBa5gJQfZoIOv3IpC0fParVB+kQ4VdskMRPggxUFbs=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=HhtEt3sLyegpn7ZgK/Cq8PS/PjwMnQCbFxX9HtMqpYGprntIY++gqqaBTKvSRzj4QQiX4UEgBCOFkJR+NAL5eum+WftGBjGczluxDtMnGbEzhsMRxSY/PrQ/EfEdMjIfvAlzU/ah/gyhpTqx6oJKgtXoxbNnA2OJEpKjD1n9au8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RngofCK/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RngofCK/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 382941F000E9;
	Wed,  5 Aug 2026 18:31:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785954669;
	bh=7OmWCSXRriBmXvN269dcHHOnjc1Kdk4mUYYRsP4h9C8=;
	h=From:Subject:Date:To:Cc;
	b=RngofCK/iTZaXb8cC2z/Uy58EGoAU8bPUUmbQPDl9C/cj5g0jldOTVGUDY8lJROuK
	 xaC0TWXV4Mqk1ym3JNY0c+Ns3Y+TQoZHqrYwuSqEXKslEWvKl1MxeqKa9TTcUa/UX4
	 81AGL2QhwAcn5uwCO3eSgiYgCrZ13nieRvEjODAJwIxKbbZmQwaui15JIMB3NCFImt
	 2iGEiOkpBc3qJXin1kKB0P4gf/0sxHuW2G4dCr/R8plqGJuqIlCLAQv1HL5xxHhqcI
	 kYu4JQ0RqI7Sl80FEEF4qYZu0akBCVBe1w0SlikyjVA9SUAD9RB47Eilu65s4qFBVW
	 5dIwReL+NsJyg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH 0/8] SUNRPC: Fix TLS control record handling
Date: Wed, 05 Aug 2026 14:30:51 -0400
Message-Id: <20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/yWM2w7CIBBEf6XZZzfSJiXVXzE+wLJQvFDDYmPS9
 N8FfTwzc2YD4RxZ4NxtkHmNEpdUoT90QLNJgTG6yjCoQatJjSgryUJ3pKcE9PHDgqdej16TtZN
 jqOIr86+o3uX6Z3nbG1NpT21hjTDabBLNLSJ+HJMXh4WlxBRg379zYE2umQAAAA==
X-Change-ID: 20260805-svcsock-cmsg-fixes-9165f6cbb8de
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3145; i=cel@kernel.org;
 h=from:subject:message-id; bh=fKBa5gJQfZoIOv3IpC0fParVB+kQ4VdskMRPggxUFbs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqc4FjZHzhk6I11MagRI9U5rkKdDEEIeZVxZDWq
 Fi11efHVuOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanOBYwAKCRAzarMzb2Z/
 l0dnD/wIG7YlQRCTWrBr2y4XRRYL5WDsvr5Or2Tg03hyXwZCb+N2ir1pv5GCPawlLCBG6Pz+0NN
 lT9oWxbj/a+whTirWWkR5HNGBJ+lcbiZIvyFhB7uKMBNLKIrDmP6g028NgBtnLH0K/5EUxt1okN
 xCzaMiNAuNkmnlqerMeQefQcKKH+QDKwOSclAUWjQIO5EsDSawqXox0SmYYNs5S5qBP2WYMEPGy
 CXRViwbCNLdBjjjnN1fmnal3k9Brj67x+QUETBD20VNGxqEScXMjhmO/pLv0N6l2U+jbAFng2MZ
 6spi4nmOe6yycUR3V788FymvIVOsgQ7zTdMOvV3gxhSNEPB0pFrXuT81YSCZebNARLpeXP1bMDO
 Cq/dFXjcBzpx66jJ4AX7jH8S+SVnfPreQ5UZJWyt1qUg7LuK7TG2fzVbEYyS/MnSWG2a+dGHX4Z
 a+w9d/AkBUHWa0IV/yM4GTtu2MTPHAkoa0AkuMp1d64wRxry6snMhaP4veideLnVzEb5J89rTCK
 xUGoE98RZDuxHfuF5gocbILzuo8ERGYQoA5o3jDEg72CxzUEAkQJW8N4Aq4bdwXo52UIxxAB/RQ
 ibHLdEz7qLRoOd9XdGSumw5bzpgGAOVOAii7YfcSsJTh7xDv4PbWo4b9syHkXlaiVxDMvggvnzW
 wp1GZ6ip5J9cQ0A==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The read_sock_rectype proto_ops method is not going forward. Designing
its replacement meant another pass over the receive path it was meant to
replace, and that pass turned up the defects fixed here. None arrived as
a bug report.

The code path that handles TLS Alerts on behalf of in-kernel kTLS
consumers has been reworked twice already. For the record: 5e052dda121e
added control message recognition, and 39067dda1d86 moved the parsing
into the net/handshake helpers. bee47cb026e7 and cc5d59081fa2 then
reworked both sides after Scott Mayhew reported that kTLS was writing
alert bodies into the RPC receive buffer. Mounts against a FreeBSD
server over mutual TLS broke, and 9559d2fffd4f restored the other cmsg
types. The same rework moved the receive into a local buffer, but the
length accounting did not follow. A control record's octets are credited
to the RPC stream, and a consumed control record leaves the server
transport unmarked. The peer still controls the alert body's length, and
nothing checks it before tls_alert_recv() reads two octets. A peer that
aborts with an error alert while leaving that octet set to warning
currently leaves a dead TLS session attached to a live transport.

These accounting defects do not have a trigger today. Both need a peer
that sends a post-handshake control record (e.g., KeyUpdate). However,
no existing RPC-with-TLS implementation does this today. Therefore these
patches are posted as individual fixes that can be backported if LTS
kernels should need to interoperate when KeyUpdate subsequently arrives
in clients and servers.

Eagle-eyed reviewers might notice that the two call sites this series
touches are the last consumers of <net/tls_prot.h> in net/sunrpc/. Both
sites now state the same record-type test, the same two-octet rule, and
the same closure classification. A helper in net/handshake/alert.c
could hold all three and return a verdict, which would let net/sunrpc/
drop the header and keep only the transport policy. That is deferred to
a next step rather than included as part of this series to keep LTS
backports practical.

I'd appreciate an Acked-by from the client maintainers for the three
patches that touch xprtsock.c.

---
Chuck Lever (8):
      SUNRPC: treat every TLS error alert as fatal
      SUNRPC: do not credit control-record octets to the RPC stream
      SUNRPC: reject a TLS alert record that is not two octets
      SUNRPC: resume receiving after a TLS control record
      SUNRPC: fold svc_tcp_sock_process_cmsg() into its only caller
      SUNRPC: treat every client-side TLS error alert as fatal
      SUNRPC: reject a client-side TLS alert record that is not two octets
      SUNRPC: fold xs_sock_process_cmsg() into its only caller

 net/sunrpc/svcsock.c  | 108 +++++++++++++++++++++++++++++++++++++-------------
 net/sunrpc/xprtsock.c |  69 ++++++++++++++++----------------
 2 files changed, 115 insertions(+), 62 deletions(-)
---
base-commit: 0b6d2c7e3abca8d17fddeecb6e4c32a8438ec2fb
change-id: 20260805-svcsock-cmsg-fixes-9165f6cbb8de

Best regards,
--  
Chuck Lever <cel@kernel.org>

