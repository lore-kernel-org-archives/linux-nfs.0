Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793655834;
	b=wfGxxaLWdEkfMZTOwKX5CpxF7A9ITcrhuWoccba2OI1uO9Kflc7KSuyz9tgaRqyUYlSn
	 etN2COkVL7vvKPxLeSryArA1PwSBidDAP219tahvHJmAhLn/QSzNX144Jj6/c8ixIoXCu
	 CqHYTFwbVSGOViHg46iCQb/tPHW7sKERuoFDDkEH8fE1BIsUz2No3qN+ZRTikssfrmklr
	 N+IItpw9qn9ilNP8JkKtPhlLufnfNAtLeEZ+gz0tYP/oUSLC0eerBJ7Nq8nKPqO2spol1
	 +YPkLb11Bw6ZyCxNQH/puhtBpCXeetVPmfn+ZibBWN7BnhAjnjTogXjy/4SmIlY43qw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793655834;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=jRzarDuVZbtg3YDbDnXxZ4uDppbaaB7s4SJ7+jaG+vk=;
	b=GJC80V8Df9VfbVlLWPkahAbYSsCyntUO4cy+HHAY1vph7ShgjvmaftOD4JRiDuW5HTRz
	 sZZC2PvL6ad6btSV+G68HrSKmhrsqHnKdK//uI2N5LHITpxygTZOIg4+DAAbd9WoVtzx5
	 b/RMN9MaFS17dYbC903AeWas0nYBSXWyv1UdS6R9YzDvcG5pq6D0Do4FN6BTtirpgObRW
	 vhdANCoBTGf7Eq8Hnn3vdFgGnGHOWqxDLj1E25MZ2387Gzo0n8lsgRpmPFaj16alfxzEt
	 TCMnjbd9pEmkMow/JfgZ8Q90by2JDVHXkiQrYpkGeI9h1AHtEMYKQaIXZVIltos/wfA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i5OMeuYA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 067D5606A327
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 21:43:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i5OMeuYA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1C5D31F00A16;
	Mon,  2 Nov 2026 21:43:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793655833;
	bh=jRzarDuVZbtg3YDbDnXxZ4uDppbaaB7s4SJ7+jaG+vk=;
	h=From:To:Cc:Subject:Date;
	b=i5OMeuYA4CNVbbabbnNZGzevpeRrmf5EK8Q9WKV6ZNlCreLXIZvfSCxr50te90Fpn
	 4JjTt/myVoMlfGrzaNjsiwZz6oZwV/FE2NJumoDxaIirA5AG2GNYjfb7CVz2fzzuOZ
	 iZB1Ci1AMmfRKQ1qgKx7S1Nxr5bkaR0Bh2NITCi11/lqddP9VwtVMtQkSc56/LOCv6
	 WKsdPDziq94b9/fuoZP+bwVYjwMzIbS3g2tUS4UidH6dVotV0xcTUKCA1VEN/LZ6eO
	 ijZ6x7Tc5h6QReq02OB05vAW5oLU4uCC7b4dy3ImtDgR/hPwtdNRu65/ohrBtwgqjY
	 MQYH1bFzar2pg==
From: Chuck Lever <cel@kernel.org>
To: Calum Mackay <calum.mackay@cdmnet.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH pynfs v1] 4.0 server tests: remove RPLY14
Date: Mon,  2 Nov 2026 16:43:51 -0500
Message-ID: <20261102214351.602543-1-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RPLY14 sends a CREATE, then resends it twice with the same XID on the
same TCP connection and expects NFS4_OK each time. The other RPLY tests
exercise the per-state-owner reply cache that RFC 7530 Section 9.1.7
requires, or replay an idempotent LOOKUP. RPLY14 alone depends on an
XID-based duplicate request cache, which RFC 7530 does not specify.
Section 3.1.1 also forbids an NFSv4.0 client from retrying a request
unless the transport connection has been broken.

A recent NFSD change drops a retransmission that arrives on the
connection that carried the original request, so RPLY14 now fails
against NFSD. Reconnecting before the replay does not rescue the test.
NFSD may evict a DRC entry once the client has acknowledged the cached
reply, so the replayed CREATE executes a second time and fails with
NFS4ERR_EXIST.

Remove RPLY14 and record its code as retired.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 nfs4.0/servertests/st_replay.py | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/nfs4.0/servertests/st_replay.py b/nfs4.0/servertests/st_replay.py
index 48e5363432ec..7f490e3d48c3 100644
--- a/nfs4.0/servertests/st_replay.py
+++ b/nfs4.0/servertests/st_replay.py
@@ -250,14 +250,4 @@ def testOpenConfirmFail(t, env):
     ops += [op.open_confirm(stateid, c.get_seqid(t.word())+1)]
     _replay(env, c, ops, NFS4ERR_BAD_SEQID)
 
-def testMkdirReplay(t, env):
-    """REPLAY a succesful directory CREATE
-
-    FLAGS: replay all
-    DEPEND: MKDIR
-    CODE: RPLY14
-    """
-    c = env.c1
-    c.init_connection()
-    ops = c.go_home() + [op.create(createtype4(NF4DIR), t.word(), {})]
-    _replay(env, c, ops)
+# RPLY14 permanently retired, please do not reuse
-- 
2.56.0

