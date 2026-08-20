Received: from mail-ej1-f51.google.com (mail-ej1-f51.google.com [209.85.218.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAF2F257ACF
	for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 14:31:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.51
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787236264; cv=none; b=n5Y1u/l4uBcqerliks+LROKl/K1Iaw3j57j/uiMTms8U232cN74pPBmQepAB17+wLktt9bu+lbkeihZKLRPdh6B0C9FsRLwnK3H1XzJcb8/Lu3djEhEyOiOaCgE8YUMlAQwXMxf9iQaHyx/dA8oisUFRhrqFcy7WhZGPvyoaTgk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787236264; c=relaxed/simple;
	bh=sTMoBmTrinnC8lwfW2fCvb2D3YZ/CBZ4iAtD4qXcs+U=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bce2gNFdodlIQHF0a+asLlxS6/jyA6lfAHmkaNkpc1pBsVPklaNVicwUK9hfR0f13km3qB/bikfyks/aIHWFQYNifs0hvEeMUJaC+Y8kJTjCuzO6LRqGzR3c9Ms0Y48LGt7hKttZYJJ3Ia6iWwIaddw+DCgyYk6B6ZUJop5zkPU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io; spf=pass smtp.mailfrom=bynar.io; dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b=CMMTllHQ; arc=none smtp.client-ip=209.85.218.51
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bynar.io
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b="CMMTllHQ"
Received: by mail-ej1-f51.google.com with SMTP id a640c23a62f3a-c169ae1cb26so212375666b.1
        for <linux-nfs@vger.kernel.org>; Thu, 20 Aug 2026 07:30:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bynar.io; s=google; t=1787236257; x=1787841057; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=AT+tBHmsx3dK9lOSgCRs3rftd3IYRNkrbDueB9ygYGk=;
        b=CMMTllHQRkJqarJzVyXIG6jrYV4FGZ9+nZmPGWHqucUvwFRqzM1eil1/0VU/+ElvUh
         Jh4ZBRNPLjVlStl44xN0Fo8aEjDBqeaFLy2W1MkV3RDlBnDysHkFdRiyVClS2ViozcPa
         bQmSThDX7xMAEs05RunvR3GXyPPJvsPJ7GlMPxwrbWHuQhKV1FBfiHD7605z4yt91i1J
         xFU4GwAefYDz/o1IoFt+RZNsCmZNO0I4q3uO3wJpG3cronLDKAGmlPzXWamqkTMri/fm
         DrucklSNavwQvnGD2CKDWt0C4Jc2Ui+oPIXsoQfiYwLoJqiJvvezg9Or/yM5bnCn7LTl
         7m4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787236257; x=1787841057;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=AT+tBHmsx3dK9lOSgCRs3rftd3IYRNkrbDueB9ygYGk=;
        b=AxOxGcRXBZCSp8xuLfm46MeAJgp18AmvHF+o4wLYHVx2EMHzGHTFrQuyXDY+pToaFr
         BQZVLRpU/1YL8SgDfQem9FLe+j7lOnT53UCqdqjN2YYrBhBI6shK06DEKkLM63as8lZ2
         FERS8mSgrrgduOT7V5y3AXmF185m9dKmQeJhWQMzGmBFstqMw2wNqAc4Bc2aOAuNenRF
         A1DWcjRaEzjMsdxJ/4mHCU2nY+TN44RnQsdCBMuwDovKFr7KQi+51//5zaN8WoXqvuHv
         YkGPuHciEyDI7Roqsqt2S9FnW9SCVora0s3SO1CuBycVXjvfeZByXoLPsViNiqA2hxk6
         2aog==
X-Forwarded-Encrypted: i=1; AHgh+RqLmmAYnkrACaHMoWeEau7DRgzJc03oNqjA+Z7FjrzKaijN9TpP+8FhCYlrYqFnH1JGF3iXjnMk9Lo=@vger.kernel.org
X-Gm-Message-State: AOJu0YzqGwMvO9gmbTMRG15LJMyr6SYffp/BTGc9OWwktO+uSEdHeW3b
	tsCG7r1fo/gSzToqcQ/9dq4y8U2Z5X0hZyJhHfwjwwgqJj1JVOWHvIT7kY6H4x8Kp7+g
X-Gm-Gg: AR+sD13fPPNcqIXigtre4fDHlbzOt/gkKR0VjW4/JNOUbsY2hkJ3jBPvTQgT0Hxwqez
	68XOycz3jtLuD/8MOD972q9JyTSDW46Eo1A9HvKA2N/anmG3mQChDJFk4L8TD/l7Lra4wcWmZh/
	6H/Eo/71q6or4sLsCYub8YuBcDJPysVdO2M2jVU5qPG2sw5iU94vdjH29JN4zzUvx5uJMoDyvJi
	LC5zBD2fT55uMjFkhdPzod6GB7UK+/i6nKxZDy5IDrnatIyS005fHu+EhqViizVQlCLMQX4mqur
	ksWFi2pPVHE/Kr/qdQM7NrCTA62zPK2QeZn081PdWo0xuxJvQ9SzsLKKt8L4l8E0wK6Fzij8OA7
	dJ5PvRiYBSOH/mh6qmWN6RHq69uGpoUoQCAdzplnl82kIyWhRSp5UUcxLiJV8uJjECkA1RAlg4X
	tDejikmiGW+WqATofgi779o6gBhqHc2Fcoa3iUi/0UpsYg9NioFK7JFGoicucJwuB4p9aZkazl9
	xEsmzShaUa7ZhFzFEgA8LidlHp/XxoZJLdoc3StQC41PtWxldaOlSlwD1U=
X-Received: by 2002:a17:907:608f:b0:c12:3cbf:9f6d with SMTP id a640c23a62f3a-c244d2f63cfmr452190366b.1.1787236256949;
        Thu, 20 Aug 2026 07:30:56 -0700 (PDT)
Received: from localhost.localdomain (cpc69057-oxfd26-2-0-cust39.4-3.cable.virginm.net. [82.6.0.40])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-c2459198d64sm77482866b.36.2026.08.20.07.30.54
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Thu, 20 Aug 2026 07:30:55 -0700 (PDT)
From: Paula Moutafian <paula@bynar.io>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] SUNRPC: fix out-of-bounds write in xdr_inline_pages()
Date: Thu, 20 Aug 2026 15:30:49 +0100
Message-ID: <20260820143049.25712-1-paula@bynar.io>
X-Mailer: git-send-email 2.50.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

xdr_inline_pages() re-carves an existing receive buffer into a head, a
page list and a tail at a caller-supplied offset, computing the tail
length as buflen - offset.  It does not check that the offset lies
within the buffer being carved, and iov_len is unsigned, so an offset
past the end wraps the tail length instead of failing.

The offset reaches it from wire data.  rpc_prepare_reply_pages() derives
it from the authentication flavour's au_ralign, which is read on every
encode, while the receive buffer's size is fixed once in call_allocate()
from au_rslack.  unx_validate() raises au_verfsize, au_rslack and
au_ralign from the reply verifier's length, and runs before
rpc_decode_header() reads the accept_stat, so a GARBAGE_ARGS reply
poisons the alignment and only then selects call_encode().
call_allocate() short-circuits on the existing buffer, so rq_rcvsize is
not recomputed and the retry carves a new offset against the old size.
auth_unix keeps these fields in a file-scope static rpc_auth shared by
every AUTH_SYS client.

For an NFSv3 READ the design slack is exactly one XDR word, so the
underflow needs only au_ralign at encode to exceed au_rslack at
allocation by two -- a five-byte verifier body.  Observed with eight:
rq_rcvsize is 132 with a 128-byte head and a 4-byte tail, the verifier
raises au_ralign from 2 to 4, and the retry carves at (26 + 4 + 4) << 2
= 136 against an unchanged 132-byte buffer.  The in-tree
sunrpc:rpc_xdr_reply_pages tracepoint shows the transition on one task:

  rpc_xdr_reply_pages: head=[..a18,128] tail=[..a98,4]
  rpc_xdr_reply_pages: head=[..a18,136] tail=[..aa0,4294967292]

(one task, before and after the re-encode; addresses abbreviated)

xs_read_xdr_buf() then fills the tail against that length, and the TCP
record length is not capped against rq_rcvsize, so the reply to the
retried call writes peer-controlled bytes past the object:

  BUG: KASAN: slab-out-of-bounds in _copy_to_iter+0x7c8/0x1538
  Write of size 1664 at addr ffff0000c7640aa0 by task kworker/u8:0/12
  Workqueue: xprtiod xs_stream_data_receive_workfn
   _copy_to_iter+0x7c8/0x1538
   __skb_datagram_iter+0x33c/0x560
   skb_copy_datagram_iter+0x3c/0x454
   tcp_recvmsg_locked+0x110c/0x2308
   xs_sock_recvmsg.constprop.0+0x34/0xe4
   xs_read_stream_request.constprop.0+0x410/0x1140
   xs_read_stream.constprop.0+0x680/0xe9c
   xs_stream_data_receive_workfn+0xcc/0x420
  Allocated by task 12:
   rpc_malloc+0x174/0x2d0
   call_allocate+0x25c/0x944
  The buggy address belongs to the object at ffff0000c7640880
   which belongs to the cache rpc_buffers of size 2048
  The buggy address is located 544 bytes inside of
   allocated 2048-byte region [ffff0000c7640880, ffff0000c7641080)

That is 160 bytes past the object, with both the length and every byte
chosen by the peer.  Under KASAN the interposed __asan_memcpy() returns
without calling __memcpy once the range check fails, so the report
establishes that the write is reachable and out of bounds; it does not
establish that the copy executed.  The enlarged head stays inside the
same slab object and is not itself a violation.

Reproduced twice on an unmodified v7.2-rc7 arm64 KASAN kernel with
CONFIG_NFS_V3=y and no other configuration change; the geometry above
came from tracepoints that already ship in the kernel, not from added
instrumentation.  The trigger is an ordinary read(2) on an already
mounted NFSv3 AUTH_SYS share over TCP and needs no client privilege;
every byte the attacker supplies is a legal server reply.  Under
RPCSEC_GSS the verifier is authenticated and cannot be forged.  UDP is
bounded by the datagram length in xs_udp_data_read_skb() and is not
affected.  NFSv4 does not take the retry path, since
RPC_TASK_NO_RETRANS_TIMEOUT suppresses the re-encode.

Commit 53bc19f17f21 ("SUNRPC: receive buffer size estimation values
almost never change") placed the equivalent slack update behind
RPCAUTH_AUTH_UPDATE_SLACK in gss_update_rslack(), but auth_unix was
never converted and still assigns unconditionally.  Gating it the same
way narrows the window without closing it, because the first update can
still land between the allocation and the re-encode of an in-flight
request, and it would leave the other caller of xdr_inline_pages()
unguarded.

Clamp the offset to the length of the buffer being carved so the tail
length cannot underflow.

Assisted-by: Bynario AI
Signed-off-by: Paula Moutafian <paula@bynar.io>
---
Note: the defect is reproduced 2/2 on an unmodified v7.2-rc7 arm64 KASAN
kernel; the patched kernel has not been built or booted.  A reproducer
exists and can be shared privately on request.

No Fixes: tag: the unbounded carve is original to xdr_inline_pages()
(unchanged since the initial git import) and unx_validate() has written
the shared rpc_auth's slack from the reply verifier since at least
v2.6.32, so there is no commit that introduced this.

 net/sunrpc/xdr.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index fa6a30b..f77dbdb 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -409,6 +409,9 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int offset,
 	char *buf = (char *)head->iov_base;
 	unsigned int buflen = head->iov_len;
 
+	if (offset > buflen)
+		offset = buflen;
+
 	head->iov_len  = offset;
 
 	xdr->pages = pages;

base-commit: a4ff2be345d0abc943da8dd8da98151843b750dc
-- 
2.50.1 (Apple Git-155)

