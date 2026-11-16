Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834899;
	b=UOcBOd51k5iipuljBQNihiURT1up0SY0nMeJ6wWz/7GOsTJxUqv1BN/veZQ/o872/MYx
	 PhRbxJ9pm85BgD6Tcknra6eH8rUFTk5UGyb072ZSNCjmCCfwoXH9W0m5KZ0EiefwCXnPu
	 M8PsF3GSy1B6bNNnvTqHQdwNlt9k5kgKI3WmO+2hRmPwaFF+oay+GkvXx5jNc+ZfL0Qy4
	 5wvSHZFepKUmLG1VSs8ZhOdVZuMc/muRITJP4XFKqxqDehurENRE9/Ri5CFAw5XdEfxHv
	 OXnAzp9d05uCTrStzuLSmlfkcaTOqzCb9zT+WGx5r1/sXjMpidY+Vr8axCScwKUHFiw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834899;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:X-Virus-Status;
	bh=T5ZKTrPdlK+nSz9spEoYr5zD+1cFjo+PsatiHD3EGPo=;
	b=RIZMJeWET076kayK1QADUyA2Uo97ga3AbKYFcu2e9DSrL1eo+vgpsJ36RYV2BxEAPAr8
	 ZJFexqb7MhB6+4WhrvTYM3/AMhgZkrklycFeh4WVHQMPEqRYBNe491kRHvPAoI9sasPyg
	 jzsptMmh5szKKLT4ZL8s8NxTSErEUpgJU8CVjcUdXK6JzxmjbY8T+ncHbt363NAi9hBXE
	 WgLJvWp6eSJVkJxUIHg4A3k5zdIYv/UIB/1n4v440SPsiqVf6OIX2rANPuKR2xDOyONrz
	 2CHm8wFjav+LuDRR1jHDOnWuMqEEAFEwu67OOsxB0dLWx/xVPg79mKyFWLdQEY49oCw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=Pvv+oU3K;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DD88606A336;
	Mon, 16 Nov 2026 13:14:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0DD88606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=Pvv+oU3K
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1794834890;
	bh=FWpP5xyPXHPvVyGrtu0jAEyw5XCnKtzulKgWzriPGWc=;
	h=From:To:Cc:Subject:Date:From;
	b=Pvv+oU3KlCeHsFb8EgE8jT2x7pFZ58D//Kmb9OV1trRBVYJ5lGzXVy36WH9w6sV26
	 VXC88xl9QKqjnYYI21az8XKw6X0CffntkuFWpSD9yDL+R2SWl5VLfJ75uRuMw27xdA
	 BTkqklgABYqI2avqAEnYumiTtK/nG9nDGBhteV6CelYiFZPap/urG0WvKMQjrUC7ai
	 DVBGeSeySzTxQQs+I/sMZic/zYgN2Bk9mGQ3/Sctcz1lHbRZo3Gjb8LStDNNNkgzTI
	 d2g43rs3d6FWB6r57Kr0hMTdH+AUnW0Ordd/sPlIYcKwNnYGQbAjAo+MUvathbEkT9
	 K9OQx5ZMMAvVA==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id D1CC8109F980E;
	Mon, 16 Nov 2026 13:14:48 +0000 (UTC)
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfauth.phl.internal (Postfix) with ESMTP id B053FF40068;
	Mon, 16 Nov 2026 08:14:47 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 16 Nov 2026 08:14:47 -0500
X-ME-Sender: <xms:xwH7agmFkiFnR4Hdti3eV9YVqAXwISywOZ2bWLPJfHfz_DE8Sfq3jg>
    <xme:xwH7anaKxrfJQn62IFPeStQnvRIm7dUJognvRugHw2mKVUbS5X4jU_IaaFsUw5NAl
    i7IAuSM2s2Lj_YWTRn8mMJuDg-noxmoBZR-crrS1VL8H0UZBq239daVjA>
X-ME-Received: <xmr:xwH7auQCYrPcUFPWoAWNdbgU8dmYUIzn-ysPBrzX1d9RN8sXi9RlyxfBvwLPlC8tD-RnS8LUBfwc_DChmy2aQl6fUM7ZncFy4MY_1ALoNO8>
X-ME-Proxy-Cause: dmFkZTFSfBySFfSf/XqIKdkGOYSTHyyhENcKQoMaWNNNQc8ne5MXNq0wt2wNj7LzzgyKtE
    KhFWu+m5FGBQVqaOaUbF/u0iNTsTdU0opTrKjvpXuvbwEVH1ebFSJI2WEDp6dWfXej0Lxc
    YZHZ+rYNlfNUrOILHFJ984rbhRJclBozcuxPWLifBhEb0xEnr51ALK1kPcyuc1sSMPDRCo
    iOofgbU+2KXrDZ23OJ+5qXhDCSglymxCHQlPPhoaEPYiXxFY9QH8OmgdWZ7Mvdl/5RTV/d
    JJY+Ymbpx7QLSrok2U+g++zatrw3zcZNJAZTEeeXBUDkhlfbhXGziYo+bxcen+AqULHudf
    dRS2oI+/j9Sl/oPzAIyx+/DwC9/8cLVCTiYD2VIdiM2PO+CoTXLhgjgDK6Wr3davQlq6xL
    u/5sOEdZgJLpDkYn6p/cCERThuDxeLiSBj/R3ENztewzCAK1luP5DaD4aBsXodrjD7x23N
    47CedpVL7r0GBrzpLXb9T5mqufsdIR++WIVEe5eZ1OX3prq18jt2fPvUyzaDVCMqPzTbTb
    iTG2roOuF/TDI/xb/+xof5awExxZt6DWihhFomrhZCFHIOde0KKo63t4PDAa2PZFIQuCl8
    mx9knnU0nJeQ9vMONbwdM1WbbHxlqR8ao2Aes3AXW/Op8re9/0wuBr7sVe5A
X-ME-Proxy: <xmx:xwH7apVyN4UqfnGibsiFjE3rtklzppKwoyTStg2W8CIdCq_MAlAC7g>
    <xmx:xwH7alYvO3VGQm3ZY7nveBTWmCcRmZrRLD5EdXsMMC23e76jk7Xj-g>
    <xmx:xwH7aq6piC2T5XQJlYmEZa7hfC4i_OM7eQRJ-KBKahusJGqoXyZKUA>
    <xmx:xwH7auyuBvLfCcLVr16ZJv1d_gStE3-K9LH1zTZwmTOls9U93ALcfA>
    <xmx:xwH7ajrO9sj-xShaRS4nLYU7g-n8wkwuIhtJPV-TFSLvYbXKtP8p3SUT>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 08:14:43 -0500 (EST)
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
Subject: [PATCH v2 0/3] SUNRPC: keep NFS client connections consistent across hibernation
Date: Tue, 17 Nov 2026 00:14:24 +1100
Message-ID: <20261116131428.1024230-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Mon, 16 Nov 2026 13:14:50 +0000 (UTC)
X-Virus-Scanned: clamav-milter 1.4.6 at shining
X-Virus-Status: Clean

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
sequence ids are all behind the server's. Depending on what happened in
that window, the client:

  - resends data that the server discards as a duplicate, so the
    connection carries nothing;
  - gets NFS4ERR_SEQ_MISORDERED on a slot indefinitely, while the state
    manager waits in nfs4_begin_drain_session() for that slot; or
  - waits for replies it acknowledged before the restore, which the
    server will not send again.

A partial overlap also makes nfsd read the middle of a request as a
record marker ("svc_tcp_read_marker nfsd RPC fragment too large").
Patch 1 includes a capture from a Linux 7.0 client and a 6.12 server
showing the first two cases byte by byte.

Patches 1 and 2 make rpciod, xprtiod and lease renewal freezable, so
nothing is sent after the snapshot. That keeps the session slots
consistent, but not the receive side: TCP still acknowledges replies
that arrive after the snapshot. Patch 3 therefore disconnects every
client transport once the system has resumed. Requests in flight are
retransmitted on the new connection, and the server's reply cache
answers any it has already executed.

Tested in QEMU/KVM on 7.4-rc2 for v1: a 7.4-rc2 nfsd with a 10 second
lease and an NFSv4.2 client hibernating in test_resume mode, with the
image write throttled to 81 seconds:

                                         unpatched   1-2 only   1-3
  RPCs received during the image write       12          0        0
  20 hibernations under continuous I/O    hung at 1  hung at 6  20/20

Every freeze of kernel threads completed in 1 ms or less. A capture of
the stress runs confirms patch 3's case: the client's acknowledgement
went backwards on the cycle that hung with patches 1-2 only, and on two
of the twenty cycles with patch 3, where the client reconnected and
carried on. v2 was retested on 7.4-rc3 with the same harness: unpatched,
the client hung on the third of twenty hibernations under I/O; with the
series, all twenty completed with I/O progressing on each. The test
harness (two busybox initramfs VMs, no root needed) is available on
request.

Not addressed: the same window affects every active TCP connection, not
only SUNRPC. Keeping network devices quiet while the image is written,
or resetting TCP connections on restore, would fix that generally, but
would need agreement between the PM core and netdev. This series fixes
the case where protocol state outlives the connection and the client
cannot recover by itself. Patches 1 and 2 also freeze rpciod and xprtiod
during suspend to RAM, which is harmless there.

Patch 1 touches the same two alloc_workqueue() calls as Mike Snitzer's
"SUNRPC: Make rpciod and xprtiod visible in sysfs"; the flags are
independent, so whichever lands second needs only a trivial rebase.
Patch 3 is compatible with commit 9d84719d34cb ("SUNRPC: add
request-scoped disconnects when cancelling tasks"): its conditional
disconnect is skipped once the connection cookie has moved on, so it
cannot close the connection that patch 3's reconnect creates.

Changes in v2:
  - Rebased onto v7.4-rc3. Patches 1 and 2 are otherwise unchanged.
  - Patch 3: rpc_pm_notify() took transport references into a list
    allocated with GFP_ATOMIC under rpc_client_lock and, if an
    allocation failed, skipped the rest of that client's transports,
    leaving them stalled. It now counts the transports first, allocates
    an array with GFP_KERNEL outside the locks, and recounts if
    transports were added in between; an allocation failure is logged.
  - v1: https://lore.kernel.org/all/20261106060735.637295-1-andrew@sericyb.com.au/

The analysis of the packet captures, the patches, their changelogs, the
QEMU test harness and this letter were drafted with an AI coding
assistant (Claude, from Anthropic), working from the hung client and
server, their logs and captures. It also ran the tests. I have
reviewed the patches and am responsible for them.

Andrew Pam (3):
  SUNRPC: freeze rpciod and xprtiod across system sleep
  NFSv4: run lease renewal on a freezable workqueue
  SUNRPC: reconnect client transports after resuming from hibernation

 fs/nfs/nfs4renewd.c      |   2 +-
 net/sunrpc/clnt.c        | 112 +++++++++++++++++++++++++++++++++++++++
 net/sunrpc/sched.c       |  11 ++--
 net/sunrpc/sunrpc.h      |   2 +
 net/sunrpc/sunrpc_syms.c |   7 +++
 5 files changed, 130 insertions(+), 4 deletions(-)


base-commit: aebb7274476403040d582c61478df8f4a7bf9cd3
-- 
2.53.0

