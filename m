Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.49
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792480502;
	b=XuOkNY6Jtnv6iIAAWB01gHL11lEzlEqKoJ08YaXNL+HJAUDAXwtBpn6ImecoAL3bnBjm
	 YC4gk8X1USbVqp5aFZlajDMZVwMhvQP/MqeZGwk/mktSAXHILg8AvYJdgAy/oXUXI2Y7E
	 a6EPhZcqes3VJ0Z1lhP/j6YSTQktzlAOe5lWh1BzTsp9crjtDOmnMrEGyKbtoFx1ePCEk
	 ayXOwg06LzfkM2QZe4WkIDZ17hwA5f60WVv7UEVjJBRMpSae9X0Cbl26BqiYERKDdZilf
	 mr6BuIxAQcoxl5OU16IzpCHGT81fBaiwGiN73xyLkbLujB3C1pBExxkmpPaGdpAW4ig==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792480502;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=aeybFht21ximE2zGrDhdYkm9IGgBZ7NtmVQeskPV6cc=;
	b=FvJlUcUlHgQ/EyajudmnZYzqWPs/28qT5KP+OFsmotvKNYQ5i9P4gztxDY3A2Y90WJHG
	 LG38vbYkJDjQk3ZdjAlvs+XmlO/a+5MxbpEoJVgwEDmV860y6A8W8h0PoVRFL1B4aWIVA
	 V7LMkvwJqNmsUkscWkOT2P1X61FuR+rpOsa6RuHAx+PNsiXc14Mw8czDsH+BMuibUg/fF
	 oT4hw27eJHuHMklIZKcUwO2l1/7DbLrbLktnuaMAOEmX2lmOyDagH1GcTIL/mw4mu1uMe
	 pVV81ZXXr82pLHgaDZvRKQBaFANeSYCsN7ZFNOHWo3bRs8j/S/wMmn4gEW5B5cw+GTA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=PY3AVgY5;
	arc=none smtp.remote-ip=209.85.221.49
Received: from mail-wr1-f49.google.com (mail-wr1-f49.google.com [209.85.221.49])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F7DA606A31C
	for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 07:15:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2F7DA606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=PY3AVgY5
Received: by mail-wr1-f49.google.com with SMTP id ffacd0b85a97d-48bbb06e746so1441848f8f.3
        for <linux-nfs@vger.kernel.org>; Tue, 20 Oct 2026 00:15:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792480500; x=1793085300; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=aeybFht21ximE2zGrDhdYkm9IGgBZ7NtmVQeskPV6cc=;
        b=PY3AVgY57S8OAeGOHlwBWVsIg/NkQZwFT2yp1fnavp4cTzU+Ac0WjtpV0VtH2XaRhK
         fJOf+jVnOfGoc+8NWjh19dHG1T/cCZ9NcBZURl9TDZba98Pkg2Mvh4B4i5dBNs+rC0PE
         ZYrU1yPdyL8+tXTvK6TJwxLandvcWYDpABTxjWZTepQnwwpUIjqhhJugS3DQKN0RPbl7
         IXpeF9WhiocrE3CPYczt8OZQjeMrz9Irgapr8L2cElkYuQdt+Z1AUNHcLAuRZu8XXXmH
         QL6OlIFdmPvgq3DSp5t6R2KqIq3ZolFC2L0D86YL72QDKW5nFH4yYD2uDFRUzkrqpBCw
         BFNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792480500; x=1793085300;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=aeybFht21ximE2zGrDhdYkm9IGgBZ7NtmVQeskPV6cc=;
        b=lN/Zx/TOEq1DzbNXqjI3oq+yZ/PG4mH4D+PbbgvvGGpmRirEo9MZfcOlV8VjJ9/0Ui
         NdEduqPczvdtf15ejdPANk6WR9YjAM45MxxMfbb1j++qYXoGPVj04FIi5w/7N5RroWzm
         /qa4oHoIbGVl5U8nGgWR7H6owTF8GxsCjvzAmzIk7V/v3mKV4BUbnThAntjRZ7r/qa0u
         LxTrLviVSIlAG7cx4uw8DCtWfKVQMr/wVbAS2TmMvmHhwxFx2J23WGet2lcxCqA3Fg8H
         t2yCp4cB7Z9XPRXIlt4MhLOZ03TTGzdb/I9sZGT0NPfA+ul5tbiGmIepw3TML62GPW3x
         Z4Ng==
X-Forwarded-Encrypted: i=1; AKwUvBxsVz84sMWmDo/F0ECpnB3PbLa7nOJ50f0Xg61NqVZkdcy8UjI0BCblJ+t5u4RaShszCM7sRpGti9k=@vger.kernel.org
X-Gm-Message-State: AFq9FYIeDPh6OstsHtnjqhjF+x7muRw/nlJSAzMVMfTZJDiycChJKGGG
	/IP/rM9HH9r8phwPhKXSt5BqZIZvIQ9OiAnh7z7HIFzvYYAsppVwJYrE
X-Gm-Gg: AYBFou1oEvWemG7BeIfoenxPTUEBB1lsnEZeIpIf0+USR73aVLX9YhR8Aje79iY96Qy
	mV0DueXUQ6yk0I/NRVegWOjxma6ZvPfC0NUKvsIMgX31EjIEm4ssxmfSuRoX+GQCZJVMB49LaEF
	YAajQND0no/uHUGeGEPDbnJvEnMMqOu5iR198FRZWOgwApR/fSDvnxlQIJyFiNtNzIclXyidqB0
	wJImRDrFKGfrpBwBLRTZDFVbTfosRB8olReEviIWgXYsJXeg6GpCECncdL/3ikrE+gzFS8Y7/M8
	Qt6GuiskDkM8r5pa1D5sEw3AZkOjGF58M4u/OcExq3mvrOp0Qj7ihgjEFw4YrdjUj/mY0bmnp1P
	kCWPzcs7VH1+9D1vbLncRDPl4mvNyBQWhocU0HEV8oxC7obYNGQeyw3DCitcGY7RBzV16zC+sLa
	V8U5fXJEMSkDNZt8Onusbam/fqyMFYDyoqhIQkOaID6YT0g/pVDxtEYhiXuXRD4H7OESOwbq736
	9u8Zp1A9EOxxW8=
X-Received: by 2002:adf:e19a:0:b0:48e:6f:a9c1 with SMTP id ffacd0b85a97d-48e07fa6ffamr20565735f8f.54.1792480500303;
        Tue, 20 Oct 2026 00:15:00 -0700 (PDT)
Received: from localhost.localdomain ([2a06:c701:4778:c500:9306:24f1:3e60:eff0])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48e1d6dbf12sm4250248f8f.1.2026.10.20.00.14.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Oct 2026 00:14:59 -0700 (PDT)
From: Avi Weiss <thnkslprpt@gmail.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Chuck Lever <cel@kernel.org>
Cc: Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	linux-nfs@vger.kernel.org
Subject: [PATCH] SUNRPC: wake poll waiters when an empty pipe is unlinked
Date: Tue, 20 Oct 2026 10:14:55 +0300
Message-ID: <20261020071455.775967-1-thnkslprpt@gmail.com>
X-Mailer: git-send-email 2.43.0
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

When an empty rpc_pipefs pipe is unlinked, rpc_purge_list() returns
without waking the pipe wait queue. An existing epoll waiter can
remain blocked even though rpc_pipe_poll() reports EPOLLHUP and
EPOLLERR for the disconnected pipe.

Wake the wait queue after clearing RPC_I(inode)->pipe so existing
poll waiters are notified regardless of whether messages were purged.

Fixes: 9842ef3557ab ("SUNRPC: rpc_timeout_upcall_queue should not sleep")
Signed-off-by: Avi Weiss <thnkslprpt@gmail.com>
---

Tested with an empty rpc_pipefs pipe in QEMU:
- 7.3.0 baseline: fresh poll() reports HUP/ERR (0x18),
  but an existing epoll_wait() times out.
- 7.3.0 with this patch: fresh poll() reports HUP/ERR (0x18),
  and epoll_wait() returns events=0x18.

 net/sunrpc/rpc_pipe.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9d349cfbc4831..68b4e040a77d9 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -191,6 +191,7 @@ rpc_close_pipes(struct dentry *dentry)
 	cancel_delayed_work_sync(&pipe->queue_timeout);
 	rpc_inode_setowner(inode, NULL);
 	RPC_I(inode)->pipe = NULL;
+	wake_up(&RPC_I(inode)->waitq);
 	inode_unlock(inode);
 }
 

base-commit: c03c1a14507dfaf8b856c2608f9ac216021fc222
-- 
2.43.0

