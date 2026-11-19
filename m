Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795056461;
	b=GfIEoqb6WC0J/C51KR2Sr/8odGwRVtDZnDqLdF4nQI2GqJ/JUzpx6lVbDCEEBSskSXrN
	 +7VSzFpj+KlBoP6P+uPy73ncwjXsSbewJ57hoJ0I7C+NmPXcsogOBkM3uGp9lS/RB6Grc
	 L9Y+c+7JBeKy8Az7LUNcWM2HP3lNCtDwKw42mL15FG9bLWZeQTHMsrls0pAG0HRSMCos/
	 /TpI/PfYHwJBZMWH74ebC8BejK7+eAvCxLwTfjQ6FACvIUOGR4XBEyH89Uj/JbHwc+yL9
	 KbrlqXOa4w6TUbiRMGm53QL0z3/OyQ4r5fSyJzrtis6ehiZhE6lP76l44EcguzpwoJg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795056461;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:X-Greylist;
	bh=Zfs/mZkSzGM5aX8ipR571btLK0cF3xTqtEpu5UVT4go=;
	b=r2UWp4oAuPx/3CJCoo/w0bLiVD8eR5kf4RzyqOaiTTr2RAmftc4TUlUqmeICVYM59p5l
	 mchSV+zdIjDTuYgdin1gZoe4OSFbKe8fh2obxma3XBS1Dd3hWOxxkKFG6YJoKv3XWSCYT
	 ts0bh20LnYIlsUg6nxPpvSrvfBeqUCGKPdY/PaK1itQ6qAsD3gfZUZnKOlnWEsuPRPTyJ
	 18iQKRffKtP5V5S0fBPTBRsnNrHWU/rCcihrSai6jNQOB/z/t4HlAEu5XN/eNIee5gY0w
	 Bt0LF2I9sId9K91L+lbyI02nr9PRmjKI0kWXToa0vhwXEBx5PEEb78WePzMVmKuRp9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b="QDc18k/5";
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCD29606A320;
	Thu, 19 Nov 2026 02:47:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org BCD29606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=QDc18k/5
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1795056453;
	bh=mwXCopiP9I1Zc69OmrECthJzg3itd0NAL19oqxAFCcc=;
	h=From:To:Cc:Subject:Date:From;
	b=QDc18k/5lM6u3eaWbtZ74JVpseaahfy217KwXCmF3ji471cgxFD8K1s/TaXo5stzo
	 Y0oDuD+YUpjLx8ezuSRVN4VTrRSQvQ+E1SbE3KkfGPoL/m5C/sbygnT2p8amT5TEUd
	 i+k+D+NDvjmZH173+uZhBhieaf8U5WhcMV4Y5ib9LN3MDEZ/0/JMBQ7ELMBQMspNrJ
	 04GahS/tvaKbafDw1oJsczy++MQdjTiAM6Y4zR2Mb2n0yQBzQ7zaVb0hH6M8zFqWNj
	 lkV9zMz40HqmEGxYZoArbLTO+SIifY5nHW/joJd7u9UYZMGdV7xQQc1WXlSNTe83+5
	 w4NOEjAEEQKRQ==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id A12BE10A47D0B;
	Thu, 19 Nov 2026 02:47:31 +0000 (UTC)
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfauth.phl.internal (Postfix) with ESMTP id 6D163F40066;
	Wed, 18 Nov 2026 21:47:30 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-03.internal (MEProxy); Wed, 18 Nov 2026 21:47:30 -0500
X-ME-Sender: <xms:QmP-amEYvPgOBoYXv4SrtpB_JA3HG1r_u6cRma6d7PBFgunXH6VKcQ>
    <xme:QmP-au5W-9Pki3HFWZatWheOPnattbKd-nGU-PbpDR2PAUgyxzxKP-Lqn6c5ZxYru
    xSWCEy1F7vgCm94BfkjJmSXfxjk14f3fzlFitV48NZfLO2r3CgWT4hX>
X-ME-Received: <xmr:QmP-avzhMLTu-qUQePV9G3nokgUZRguOV-w5FuOTOLrUr_hVkNwmsd3kGJKIzOXtf8Tbmq5pEmMdRKsu1S_gOdACBoOupIZ8gyqt6esCcuefE1N19HQQKXO3F-6r>
X-ME-Proxy-Cause: dmFkZTGjblIteJsh8okDPJnXMJT0QMSgN/rrzfz7VvZN0KFPBls5yjfZVCEBxI0ESNWsBs
    7uIffPLeSn3LrvJRn/TMwerWyC5iH1SAdhSifkOHPhnDl1tkObQaMb/7tcU6Z0S3Rg/zbP
    pOKkuChynybjxMq9u/bWepYNoXJdyYuD8gkoeV7Tmc2BXmbqDFF+XQU+bcEVSPdF8GWQw1
    vlI/+NZ5gGTlKJ0NbDRspLKv0Dcta0vlTy1L72w+nFIq8WxC2DmsJfCMrGaY1eE0J5r0tH
    6gE0vIkbnkFjwMpySGPuhwOAa6MqCirLqqwxgnVLnUxbeXERxIKk4xodtWfjMmwEX/yZcN
    Re3Wba8ETsl3cKJIDyK6P2XRVcCOOLj9l+pG7wRTF9pJuAhecsRDqHF2UrHjL67E7qQ36b
    kqvF1iI42kDtD2C258n5kdl9aDb623QxszirFL4fVsZR0ap3A9h+NZyH5aB8i30KHqhXfd
    BiDUfBbB/uB7Z4SZ9hE0BgPn+1KBIL3Y5yhKrQs7JzcwAZ3icjPQb7LRCozw0aTtZngsIq
    rnrr9lLzrej1Bha/iMya7HCfE3Xaj6X/ig65g4UWvVbwR+gem7TgOsAKNnX7QkRpQ8Ykkx
    rwudFytA/c2+xnaNhZrUKL0JblBacWDA0jiVSp4yNkj42E+QWeqs9vYChWBw
X-ME-Proxy: <xmx:QmP-as3_2zOfKA-pG8Ynx2fvWJQmpCi7BrbTT7sdBHjBBEqaOMoUNQ>
    <xmx:QmP-ai6gy2dbwkiMIw98BPJ3n7JzlQFz7riJqsnjhEEWWSROQwjkgg>
    <xmx:QmP-aqbFipHG5DWblsqH37cJVwDK3OeMWumGOqnY8N3kdRDgDItLWQ>
    <xmx:QmP-aoRnrUQ_IDrvt3fijdNX0AdgS_IABc_hZK7VKnvR9cqkmafzkQ>
    <xmx:QmP-avL267_-0A4v06x1IC6f-SAh7X9OP8Rac7lYQfo6g4QB0HqvpjH7>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 18 Nov 2026 21:47:25 -0500 (EST)
From: Andrew Pam <andrew@sericyb.com.au>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Andrew Pam <andrew@sericyb.com.au>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v3 0/3] SUNRPC: keep NFS client connections consistent across hibernation
Date: Thu, 19 Nov 2026 13:47:15 +1100
Message-ID: <20261119024719.311474-1-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Thu, 19 Nov 2026 02:47:33 +0000 (UTC)

An NFS client that hibernates with a mount active can resume with the
mount hung, until the server's nfsd is restarted. The underlying
problem was described on linux-pm in 2011 ("hibernate hangs TCP") and
not fixed. This series fixes it for SUNRPC clients.

After hibernation takes its snapshot, the kernel thaws devices, the NIC
among them, to write the image. Freezable kernel work stays frozen until
the image is restored, but rpciod, xprtiod and the NFSv4 lease renewal
work are not freezable. So RPCs are still sent and answered while the
image is written, and TCP acknowledges data from the server, none of
which the restored image knows about. On resume the client's TCP
sequence numbers, its acknowledgement point and its NFSv4.1 session slot
sequence ids are all behind the server's.

Captured between a Linux 7.0 client and a 6.12 server:

  - 05:06:02 last exchange before the snapshot; client snd_nxt
    2711544997.
  - 05:06:15 hibernation entry.
  - 05:06:44 and 05:07:48, after the snapshot: a lease-renewal
    SEQUENCE on slot 0 (seqid 192219), the next (192220), and
    DELEGRETURNs on slots 1-5. The server executes all of them and
    acknowledges up to TCP sequence 2711546645.
  - 14 hours later, on resume: the client retransmits the slot 0
    SEQUENCE from TCP sequence 2711544997. The server discards it as a
    duplicate and acknowledges 2711546645, which the client ignores as
    acknowledging unsent data. Nothing more crosses the connection.
  - On reconnecting, slot 0 gets NFS4ERR_SEQ_MISORDERED (server at
    192220, client at 192219) every 15 seconds indefinitely; the state
    manager waits in nfs4_begin_drain_session() for that task, and
    every other RPC waits behind it.

Other resumes produced the same rollback with different symptoms:
requests accepted by the server's TCP but never reaching nfsd, a partial
overlap that left nfsd reading a session ID as a record marker
("svc_tcp_read_marker nfsd RPC fragment too large"), or a client
waiting for replies it had acknowledged before the restore, which the
server will not send again.

Patches 1 and 2 make rpciod, xprtiod and lease renewal freezable, so
nothing is sent after the snapshot. That keeps the session slots
consistent, but not the receive side: TCP still acknowledges replies
that arrive after the snapshot. Patch 3 therefore disconnects every
client transport once the system has resumed. Requests in flight are
retransmitted on the new connection, and the server's reply cache
answers any it has already executed.

Testing, in QEMU/KVM: an NFSv4.2 client hibernating in test_resume mode
(the image is written, then restored at once) against an nfsd with a 10
second lease, with 1.2 GB of incompressible data in memory and the swap
device throttled so that writing the image takes 81 seconds. The stress
test runs 20 hibernations back to back while NFS writes (8 MB, fsync)
and reads run continuously. On 7.4-rc2, for v1:

                                         unpatched   1-2 only   1-3
  RPCs received during the image write       12          0        0
  20 hibernations under continuous I/O    hung at 1  hung at 6  20/20

Unpatched, the restored client also showed a SEQUENCE error, two extra
connections and 10 seconds of queueing after a single hibernation; with
the series it resumed without errors. Every freeze of kernel threads
completed in 1 ms or less. A capture of the stress runs confirms patch
3's case: the client's acknowledgement went backwards on the cycle that
hung with patches 1-2 only, and on two of the twenty cycles with patch
3, where the client reconnected and carried on. The indefinite
NFS4ERR_SEQ_MISORDERED loop seen on real hardware was not reproduced in
the VM: it also needs a request holding a session slot across the
restore.

On 7.4-rc3, unpatched, the client hung on the third of twenty
hibernations; v2 and v3 each completed all twenty. v3 also ran twenty
hibernations under lockdep (PROVE_LOCKING, PROVE_RCU,
DEBUG_ATOMIC_SLEEP) without a report from the new code, and was built
with SUNRPC as a module. The test harness (two busybox
initramfs VMs, no root needed) is available on request.

Not addressed: the same window affects every active TCP connection, not
only SUNRPC. Keeping network devices quiet while the image is written,
or resetting TCP connections on restore, would fix that generally, but
would need agreement between the PM core and netdev. This series fixes
the case where protocol state outlives the connection and the client
cannot recover by itself. Patches 1 and 2 also freeze rpciod and xprtiod
during suspend to RAM, which is harmless there.

This series applies on top of Chuck Lever's "SUNRPC: Set WQ_SYSFS on
rpciod and xprtiod":
https://lore.kernel.org/linux-nfs/20260915-performance-v3-3-ae26d460bfd3@kernel.org/
Mike Snitzer's "SUNRPC: Make rpciod and xprtiod visible in sysfs"
changes the same two alloc_workqueue() calls for the same purpose.
Patch 3 is compatible with commit 9d84719d34cb ("SUNRPC: add
request-scoped disconnects when cancelling tasks"): its conditional
disconnect is skipped once the connection cookie has moved on, so it
cannot close the connection that patch 3's reconnect creates.

Changes in v3:
  - Rebased onto Chuck Lever's WQ_SYSFS patch; patch 1 now adds
    WQ_FREEZABLE to its shared wq_flags. The original comment in
    rpciod_start() is left alone. (Anna Schumaker)
  - Patch 3: no array, counting pass or transport references. The
    notifier calls xprt_force_disconnect(), which does not sleep, on
    each transport while holding its switch's xps_lock, which keeps the
    listed transports alive. This also removes the misplaced double
    comment. (Anna Schumaker)
  - Changelogs trimmed to what each patch does and why; the capture and
    test results moved here. (Anna Schumaker)
  - v2: https://lore.kernel.org/all/20261116131428.1024230-1-andrew@sericyb.com.au/

The analysis of the packet captures, the patches, the QEMU test harness
and drafts of the changelogs and this letter were produced with an AI
coding assistant (Claude, from Anthropic), working from the hung client
and server, their logs and captures. It also ran the tests. I have
reviewed and edited the patches and am responsible for them.

Andrew Pam (3):
  SUNRPC: freeze rpciod and xprtiod across system sleep
  NFSv4: run lease renewal on a freezable workqueue
  SUNRPC: reconnect client transports after resuming from hibernation

 fs/nfs/nfs4renewd.c      |  2 +-
 net/sunrpc/clnt.c        | 61 ++++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c       |  3 +-
 net/sunrpc/sunrpc.h      |  2 ++
 net/sunrpc/sunrpc_syms.c |  7 +++++
 5 files changed, 73 insertions(+), 2 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
prerequisite-patch-id: a8475a72e4e9a2df387e41ca12df8aa67733256b
-- 
2.53.0

