Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51B10394788;
	Mon, 20 Jul 2026 14:28:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784557695; cv=none; b=Qv6d5YHWvR48cx1dXuYOyqOC2uT6f+ZaiYlkJqoylP5f5ze6OGQpm7ArcMYu6OX/VpPcpUouoWFrGDuTQaTfRa6dV4H8Kr2jEox/rE5TaFnYRSLRFovGZKiEovf3wYgqZog5vM3UoE0usAgFpR4/apeq/9oRhYzMmg+sC1mxsXQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784557695; c=relaxed/simple;
	bh=WYomIgBZvA0nHYdfvwUK5hJTsVfNZwyJ7Zg4MaGFB40=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=dzKyvEKjx6Ax8hsHB4mnw7w1Ci1/81kekVQxVvbhqZHtO/XgTt9QcXSoEof/MV+uKcoGjNmAn7fFa6qoph4Au9/KxdQD6B/kPVGUzJMP+dEhkP5fGFiNvtMH7Cz/FWkyvYnhUCkjBNUwf/mGZzn5JvzcmcG7eq3b5B+5lbPdoHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=n1K0KfdB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="n1K0KfdB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C472B1F000E9;
	Mon, 20 Jul 2026 14:28:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784557693;
	bh=1ZjkL89uRLLCvQeiYng/nTUQOZYSdfV7I6hbvurF/bc=;
	h=From:Subject:Date:To:Cc;
	b=n1K0KfdBltXDoZS8QNvu2uFayPzTrkZYXBXgs9JxQWYJSEA4TUKLgTVhT3/4MfhxB
	 +GUXxw9zKQpEuWj6ycQw3gYScKp2w3CTHaeZKKzA3V81PUuTX+/LH+vqSS0L4P9Alb
	 VumXbfN0tXwvmiHYXt3ZdmBoS2ry8PA5A1rOgLX7+2Nc8a747h0ozo01QRzBjKM7du
	 1Verhz5zL9oK5mxWOgb/88U6c4SW3rXse6aUCx+Kl1YHlujMlGRkdBqrqpCB4QkP3h
	 9zBca0fNpbhlQhXqEPT1+iMeiNmVWnz6GdSGDrxrw5gcQgyfiDid7PvCV2PLa0mwnD
	 LnCEKNaHTKgJQ==
From: Chuck Lever <cel@kernel.org>
Subject: [PATCH net-next v2 0/6] Deliver TLS control records to kernel
 read_sock consumers
Date: Mon, 20 Jul 2026 10:27:54 -0400
Message-Id: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/zWMwQ7CIBBEf6XZsxsJGlB/xfSw0MWuRtoAmiZN/
 13QeJyZN2+FzEk4w6VbIfFbskyxBr3rwI8Ub4wy1AxaaaMO2mLxMyamAfPkH2jtiY5nY1QIFup
 nThxk+fquELlg5KVA/1vyy93Zl6ZrrKPM6BJFP7bqT++fJBG27QPmeVwbmwAAAA==
X-Change-ID: 20260327-tcp-read-sock-778a49660ff7
To: Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, John Fastabend <john.fastabend@gmail.com>, 
 Sabrina Dubroca <sd@queasysnail.net>, Shuah Khan <shuah@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Chuck Lever <cel@kernel.org>
Cc: netdev@vger.kernel.org, kernel-tls-handshake@lists.linux.dev, 
 linux-kselftest@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3595; i=cel@kernel.org;
 h=from:subject:message-id; bh=WYomIgBZvA0nHYdfvwUK5hJTsVfNZwyJ7Zg4MaGFB40=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqXjByC+b9EK6CTmIkn4dlX9rcwPUdGbDNUw0Ha
 WrbJo+UmY2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCal4wcgAKCRAzarMzb2Z/
 ly4gD/4mywxYFMEJ+bKBFO3TRPTg6f7bxYa4NZMQE/3L4iKAy7rgzYo1mn9J7TKXUUBNgpfsVLb
 x+TE4ulYmrtue1vVxSAeN/yakOp4VR+FK1vqsSqkk79dCOW2qG72IlrSeNmdRrWlsPYZYiFe7Jz
 ba9eTvVrQbRVrVbvBSmOte/rIXESn27Xgj7pVrBSJfVa6/bJGz/u7RWnoWtLs6apbA1f4Xt2y5B
 UrpZgbyZtrABhuDCvLWAoncBiUcf/+FZ1IwvIL4lY80KUBruJsJthvd70nd6BAzfL+wPLDPjt76
 CwAG3KsnPZCJz5gb3+Puyi6HEKlZZ2/DRWsiNffTpT1b6FbRWpir/GIUXZXq/Os/oO8x6lrbAsP
 rpWLxMwNoQjW8z32hmDLvunJ8+0mqZ+YpRHNxWCSiPLWt5olSIusTIV9L/+WxnEKEfThPD0Cgpf
 pxeG8W7GGwxQSYZ5/Td4je2Di2/cDAtRGuL05FAu2OfEujvV2ibEGCc5fgjzPojAzcbw9fm5j2Y
 HoZxeq16ovflXsjbj7HKOXD5j9Te4zzKrLCO+CcaMvaoDWUB0SKRPMOOLuDaxymt5+1CB4v+R/h
 Gfe8J6IEcjHUzoaw/cJlNNCJsOl+2RqSM7eKuGbgzf/BeKbMQCXF15295pKqnDSxHmPzt3a4/a5
 qnUxLiRdWw5if7w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

When kTLS is active, kernel consumers of the read_sock API cannot
see TLS control records: tls_sw_read_sock() rejects Alerts and
Handshake records with -EINVAL. A consumer that needs those records
falls back to sock_recvmsg() with ancillary buffers, which is why
NFSD's svcsock runs a MSG_CTRUNC recovery dance on every receive.

This series adds a read_sock_rectype proto_ops method that delivers
non-data records through a separate callback, then converts its first
consumer, NFSD's svcsock, to use it. NFS client (xprtsock), NVMe
target, and NVMe host are meant to move onto the same mechanism in
later series. The existing read_sock data path is unchanged.

The improvement is more than cosmetic. All of these consumers need
to handle TLS Alert messages efficiently and securely (in particular,
for KeyUpdate). A few design points worth mentioning:

- The new sk_read_rectype_actor_t callback does not share the data
  actor's byte-counting contract. It returns 0 to consume a record or
  a negative value to requeue it and stop delivery. The return is
  never a byte count. svc_tcp_rectype_actor() relies on this,
  returning 0 to consume every non-data record while stopping the
  read loop through desc->count on a fatal alert.

- The no-data cap (patch 1) is a prerequisite, not a stand-alone fix.
  Once control records reach read_sock, a record carrying no payload
  stops advancing the caller's read descriptor, so a peer streaming
  such records would pin the socket lock and the kernel receive
  context for as long as the flood lasts. Bounding consecutive
  no-data records supplies the return boundary a system call would
  otherwise provide. The cap is scoped to tls_sw_read_sock() alone:
  splice and recvmsg run in the caller's own context, reschedule, and
  drop the lock on return, so they need nothing.

- The svcsock conversion is split so the new path can be reviewed
  against the old. The old path is then removed by the last patch
  in the series.

- read_sock_rectype has no direct userspace entry point, so its
  selftest coverage (patch 4) drives the shared decryption and
  rx_list delivery pipeline through the recvmsg and splice paths
  instead.

---
Changes in v2:
- Renamed the read_sock_cmsg proto_ops method to read_sock_rectype.
- Non-data records now use a record-type actor, not RFC cmsg-style.
- Bound no-data records so they can't pin the socket lock (new patch 1).
- Added selftests for data/control record interleaving (new patch 4).
- Link to v1: https://lore.kernel.org/r/20260217222033.1929211-1-cel@kernel.org

---
Chuck Lever (6):
      net/tls: Bound consecutive no-data records in tls_sw_read_sock()
      net: Introduce read_sock_rectype proto_ops for control record delivery
      tls: Implement read_sock_rectype for kTLS software path
      selftests/tls: Add tests for data/control record interleaving
      SUNRPC: Use read_sock_rectype for svcsock TCP receives
      SUNRPC: Remove sock_recvmsg path from svcsock TCP receives

 include/linux/net.h               |  28 +++
 net/sunrpc/svcsock.c              | 381 +++++++++++++++++---------------------
 net/tls/tls.h                     |   3 +
 net/tls/tls_main.c                |   5 +
 net/tls/tls_sw.c                  |  54 +++++-
 tools/testing/selftests/net/tls.c | 298 ++++++++++++++++++++++++++++-
 6 files changed, 556 insertions(+), 213 deletions(-)
---
base-commit: 298bb2b8903323f6ef2eab4819a2e477765f0ff1
change-id: 20260327-tcp-read-sock-778a49660ff7

Best regards,
--  
Chuck Lever <cel@kernel.org>

