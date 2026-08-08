Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99E2B3451DA;
	Sat,  8 Aug 2026 15:40:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786203623; cv=none; b=bQu4k1bvYcaEkSBwLUu9APXjOPuG1/vV/yn6QKR52GurNTKCUhG3GZxrJOpnQJlpHxWtYxxW2QaQCH1iZOBevBfHc+CwR9b2a3PttQphI61OyDkNWJi+FmNuhBpXGmrgwACMMez6ybzB3cP4cZndnJNJEYLlfzgxqcvtJK8aKF4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786203623; c=relaxed/simple;
	bh=th7Ome2phtmDqoWCagkAIg/QyObd4DM9KTJoTF5F/hY=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=tsZNKO6usP9cbFUG95DxucZWb8aAqCjG16FHE4FNj5+JvZa+NLIeiRxKILhZPtuGj6S17fjUPEFlflK1jrIlOOEiGCkjPDDwPsTxLNtL6DUBK/b5enb/MFgyl2qDO/R1kDbgBllZj2zIQ7E5g9EPMoCM6da7YQGN1VRFUBGTVh0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=f+36GC9E; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="f+36GC9E"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 683621F000E9;
	Sat,  8 Aug 2026 15:40:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786203621;
	bh=mjk4FgOC+NnI5q6+pYoobxTNeWtr5248SFk+UsI/YZ4=;
	h=From:Subject:Date:To:Cc;
	b=f+36GC9ECOPSRiqdDViGvXWX5zeGbCNZ1fwzLrSFo0BioVOmxsw7Yxb4+taTj0AkF
	 S/9UM3HAkP5IYucBPg7eppYfIClKQ+x/pS4C/iTMbEDb4AtnUYqTK6EVVBayeKpKPz
	 gguV96acnosKn7Hrx5Eg2JZCfEH/73NZ2Y+unffTYMbsppWn94MLUOMbVPrnifzL66
	 oU4iW6GtiLoajZPIydkNxaGlKOl+cK7eG4gQ+C4n6YyxtQBticWKcQQlGTLMnWv0PG
	 EN2dNiScV4hsm6BGt0bwMbp6LBhKKW74l0ZgofLMHUWtsyI/5eb84/gHzUOo3Wf0UA
	 lXZISXY7B4Jkg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v3 0/7] SUNRPC: Fix TLS control record handling
Date: Sat, 08 Aug 2026 11:40:08 -0400
Message-Id: <20260808-svcsock-cmsg-fixes-v3-0-62d9a631c880@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/32OQQ6CMBBFr0K6dpQWQXHlPYyLtkyhisV0sNEY7
 m6LG02Myz/z/8t7MkJvkdguezKPwZIdXAzFImO6k65FsE3MTOSiyrd5CRQ0DfoM+kItGHtHgpp
 Xpam0UtsGWRxePc6PuDsc35lu6oR6TKTUUJIQlJdOd+mksV85Qw2MSKN1bap0lsbBP2axwBPqr
 0PgkMO6KPlaFqKRtdqf0Tvsl4NvWZII4pNR/WSIyEDDFTdyI3gtvxjTNL0AdOaqUS4BAAA=
X-Change-ID: 20260805-svcsock-cmsg-fixes-9165f6cbb8de
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3531; i=cel@kernel.org;
 h=from:subject:message-id; bh=th7Ome2phtmDqoWCagkAIg/QyObd4DM9KTJoTF5F/hY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqd03cyetMfPjisk5yvsg62Fll/s4ns+xkkf8tP
 2obzb1DO/OJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCandN3AAKCRAzarMzb2Z/
 l7HVEAC6EDtOFGor/IsruMAXQlU9XBfsK5EakVNZXeS12U/h8ccPku23js2nQBNewsZ1G2mUJSC
 wjf6hB48hBBQGIEgOTVBMpdgSQuChlfwQY2EgFILNlT6FVrxwU3WEoFv9kAvflreF6trgLxQDs/
 IV2nICwgqy4nivSTOYwtv9YHYFBSgPET35Yi3BJ3J5jqbb+Aa/n9lktoenxb7jcOoxkCJfBDVOm
 ajp4CK2yLziWpKZa7ksneTgRaiyJ4Wn3P0O24qDRu4oXosoyFXh3l0WTchSWnLOQJCQg22hLQvW
 nWTEE3TtLuozNifAtGvTkHGwwvpHgpehKBy5qsJAOi/Iq3PVWILCcJ8XdipNTzSTN7FcuBi4jjC
 mK2dWMkkcR+8RP7XZYPj2ObqqaojYCLMJggjrn1S3nhbsKd4N8TAxVBOIn50sYp5TcXlb2tUQio
 Alqz8Ej0Beu2bzIr3q8U9BMl9B1JzCOrX6ySh2z82FSQ27AHFioN0mOA1xS7GZnACLFKYXeU23K
 HPeoMP/hVkQsAcKsuuG/Qw2VyumjGrH7iON3Vvxy6qC8sCs60SMs0fp6QO1wWE0W3UlT15m//SG
 jkOyDRsplff8o0tzfCbxubDGj7lM75O/WPz7aZ7fKho5jomrTv1mC9rhOv50s6PF7yXq/T+8L1T
 1YBRpphOm+51eNg==
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
Changes in v3:
- Drop the svc_tcp_sock_process_cmsg() fold; follow-on work re-splits it
- Link to v2: https://patch.msgid.link/20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org

Changes in v2:
- Series reorder: length check goes before the severity change it guards
- Reword the XPT_DATA comment to drop an overstated guarantee
- Link to v1: https://patch.msgid.link/20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org

---
Chuck Lever (7):
      SUNRPC: do not credit control-record octets to the RPC stream
      SUNRPC: reject a TLS alert record that is not two octets
      SUNRPC: treat every TLS error alert as fatal
      SUNRPC: resume receiving after a TLS control record
      SUNRPC: reject a client-side TLS alert record that is not two octets
      SUNRPC: treat every client-side TLS error alert as fatal
      SUNRPC: fold xs_sock_process_cmsg() into its only caller

 net/sunrpc/svcsock.c  | 84 ++++++++++++++++++++++++++++++++++++++++++++++++---
 net/sunrpc/xprtsock.c | 69 +++++++++++++++++++++---------------------
 2 files changed, 114 insertions(+), 39 deletions(-)
---
base-commit: 0b6d2c7e3abca8d17fddeecb6e4c32a8438ec2fb
change-id: 20260805-svcsock-cmsg-fixes-9165f6cbb8de

Best regards,
--  
Chuck Lever <cel@kernel.org>

