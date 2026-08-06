Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D160E490C0C;
	Thu,  6 Aug 2026 20:20:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786047631; cv=none; b=kFsjrp92owejfjyHOScGXm2NpmerbdBZSVewI81uA+q1B1SmttI1Hadl/s33mdJMuJ4egz24oU/QavL7DkOHcSl9sg+Zp/9ND5t+5PGOe5rrP6K3w77ffm+8HgFo7BTtxVnkuoNbbiBtyF+q9pJ5WIjal/n7EyKnk3DlUdUz/es=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786047631; c=relaxed/simple;
	bh=gOy84EJeuacq41WL5JoUaZlQrNu2y755XW2zveknySY=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=AW7QcN1R1kjgl09LKAEluah3HYUzARqmC0PEGYePL2VPVQMbiVGnN5RLrF66LR5/tt/1canfr61yUrmdjSZcNguLrwUztblzglJlV2qbE8EzmzzOQNbRQJ0RsnPxL1fue4nB0XFcao8Pl2XyQylJVUGPNHxyG8gUqwJw4bcCvaI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DfszwPU2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DfszwPU2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF3B61F000E9;
	Thu,  6 Aug 2026 20:20:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786047629;
	bh=P7xR4kJ3TzeQAibDRUXYrSK8ohiNUtnD9JpvD99AZhw=;
	h=From:Subject:Date:To:Cc;
	b=DfszwPU2wWmOkRKFmIptfTLN2n8541bu3nCAbGSmiRDJhwUfZrLxRSzFAOPe5cji+
	 YSUC5a4titSRIJQ4wBzYxo9SgkaZqvPhgNZZqHQ+hzCSVAQOwHgUAljSvyJTwtC0YZ
	 FC3cv8Ytj3EbiZ3qUZSrAsNGqnM7Z332lZ5YdOBDMGh4pNFNt7dIyLLEUSzw/Nd6KM
	 EETNTiTgXuXLRTnsSyZ0hirlp7k6gNOkLhShtH70SesltTC5Vt8zbf7oC/iLqvqVMr
	 9nMx+TLj/30smdGd68Uxey1FhBBOxIhHsBHThMwMnUBLmXsgRzdiHcVgNx85DKiLZp
	 cIuqmfBsdQLRg==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH v2 0/8] SUNRPC: Fix TLS control record handling
Date: Thu, 06 Aug 2026 16:20:15 -0400
Message-Id: <20260806-svcsock-cmsg-fixes-v2-0-ef1b1fa7219a@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/32Oyw6CMBBFf8V07WjLK+DK/zAs2jKUChbTqURD+
 Hdb3Ls895W7MkJvkdjlsDKPiyU7uwjZ8cD0IJ1BsF1klvGs4jUvgRZNsx5BP8hAb99I0Iiq7Cu
 tVN0hi8Wnx92IvVv7Y3qpO+qQllJCSUJQXjo9JEnjdHY9dRCQgnUmRQZLYfaf/dgi0tTfD4sAD
 kVeikLmWScbdR3RO5xOszes3bbtC7wlLDvqAAAA
X-Change-ID: 20260805-svcsock-cmsg-fixes-9165f6cbb8de
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3402; i=cel@kernel.org;
 h=from:subject:message-id; bh=gOy84EJeuacq41WL5JoUaZlQrNu2y755XW2zveknySY=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqdOyDeg8VoERQ1MImhaw0sJ+N3U8NrLgT7F8Ya
 LaqBUkY0NGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanTsgwAKCRAzarMzb2Z/
 l5I1D/9FZ++qNHOxaUNKrkoEwWEy/PKodG+nyA6e6bEYd3A6fdmBTVnwd1PT9UJMSpBqzGz8PDQ
 cyx1uGVkQ+MfLbbhGZ2SZkNrh4HxBDPKT6iSAIIJvnWRbsy4CYr+4LFHwVeswv2Rae3jcDTVMjJ
 Bxqvvhjc/wiRfEKMKA5IEMPAF3T10qg+5UW8vABFspC1WivFyNK4W/KoVIiBtLhOOk6HKFbDUyr
 wYwg8GiruoGX4JFE6K/pHtxGQLhI+CUXus+TFoy/543XfSEIxOnFYwCK1RXxnLnnr17n1tnGgGD
 D2qI1fesRC1hpQQWgiR9OhVTW/Qdsuu8iR/Br5xQUtKwmuKPtfvWHe4OxekJHZYlamr67VKWwe2
 5pqh45WLjM8j07O2bPDTZs1YDvgEQSbIQmn9bRiq+IimiV9BozeKsbXNPSG1+dH1V9UzvrTRjhH
 PmbYS9J3DdpK47sXO+Fl5IVjUbqTgzx0C2ZhzHfSTn2Gaw0jFErYBIA58jG5/XZqKIRam5+RWHt
 DhriU5aYqnqdzzN/LW8AUQ2PU17VZuIAcrtt96SZXmKP9XH1dDQLQoGqu/AMZWzzWeJvSkuVIU/
 dI2mEv+U0DHfCkqydtvB+gOtHT34vkoO/Q4JSx+G4lgwOgEq9u4JxIjoumvIjVG6v77IOlMwoCA
 xmSNV+xYgIi0e9A==
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
Changes in v2:
- Series reorder: length check goes before the severity change it guards
- Reword the XPT_DATA comment to drop an overstated guarantee
- Link to v1: https://patch.msgid.link/20260805-svcsock-cmsg-fixes-v1-0-43514a32da9b@kernel.org

---
Chuck Lever (8):
      SUNRPC: do not credit control-record octets to the RPC stream
      SUNRPC: reject a TLS alert record that is not two octets
      SUNRPC: treat every TLS error alert as fatal
      SUNRPC: resume receiving after a TLS control record
      SUNRPC: fold svc_tcp_sock_process_cmsg() into its only caller
      SUNRPC: reject a client-side TLS alert record that is not two octets
      SUNRPC: treat every client-side TLS error alert as fatal
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

