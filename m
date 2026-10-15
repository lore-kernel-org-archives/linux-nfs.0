Received: from vtj.irix.systems (vtj.irix.systems [82.76.27.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7625B525A61;
	Thu, 15 Oct 2026 12:48:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.76.27.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792068518; cv=none; b=FnUyCx83M5nBUSBWCUStwFlGIpajLbSFApvjXjRhtOZwM1GJ0l+XjYrqvxguNqXu+7Zwc5AvU3ieah/tOxM+tc41gimir2lAhMBqPTGWMiADKKUoSl7gk++vLVei9d0CDuqSq9MuL9GhxSURiEaV83HbNFrcSTR/LgAMibGN4MA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792068518; c=relaxed/simple;
	bh=z07TVzYXM1jRmFoR6nl9/1yYUtyer7YepNvmldlBkG4=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=cflvRmvvqYARwW2p1gyKIiHRxlZ2a5SSqXdazGbKJQy+/4xFllEuZuBiLm0YHMQpRW6jVLx337PwDKCG+rksvr6epRjHAI32cloLhmQi68se42W0+TzPw5vraVXA6E2Qlj7dJLqJ0bMVMw1TW9/Wn7MBN9y97CZukBOE6TNG3L0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com; spf=pass smtp.mailfrom=andrei-z.com; dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b=X1UOeabO; arc=none smtp.client-ip=82.76.27.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b="X1UOeabO"
Received: from MAILGW-HP.hp.vtj.corp.irix.systems (localhost [127.0.0.1])
	by vtj.irix.systems (Proxmox) with ESMTP id 7673B21344;
	Thu, 15 Oct 2026 15:48:29 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=andrei-z.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:from:from:message-id:mime-version:reply-to:subject:subject:to
	:to; s=sig1; bh=Wi062/qPlsR7jF1ZZXk4rpe47tL9Gsd6z4BWAhu7j6k=; b=
	X1UOeabOkYWhowKKGkRwBZiKLKEvazzijM4nUDhSOKM/nCGl83PcmEANiEeU18im
	SNj1RJyrOuPWmXmMwI8qP9OHu1gjFjlW213jPg83RTOLvw68bmmbbjY1wAGQc4C6
	qz/cj95OQ6AAU1bAR7A4vcAbz+uQrThf8TiB9GODglyQ7K5DbBu2UzquBFkDc+HV
	X9T/dQzVzPRgd2DMgBrEC8ilZciNXBRy+xcelb+j4h/ydTVRhiKaCv5JG2/bCmGr
	vrS4XdtokVQIKOObbtEXt9t347S6m5gzYlsMeexuYRWaGY5fe5+vQfnF4ZEcFYis
	IDBJFlCBwKY+8vj5H9Pq5Q==
Received: from VTJ-MX.corp.irix.systems (unknown [IPv6:2a02:2f04:1:9c24::6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vtj.irix.systems (Proxmox) with ESMTPS id 5BDD4211F2;
	Thu, 15 Oct 2026 15:48:27 +0300 (EEST)
Received: from [10.89.11.73] (10.57.8.14) by VTJ-MX.corp.irix.systems
 (2a02:2f04:1:9c24::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.49; Thu, 15 Oct
 2026 15:48:27 +0300
From: Andrei-Alexandru Bleortu <me@andrei-z.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	<linux-nfs@vger.kernel.org>
CC: Andrei-Alexandru Bleortu <me@andrei-z.com>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, <linux-kernel@vger.kernel.org>
Subject: [PATCH 0/1] xprtrdma: Post small RPC Calls inline
Date: Thu, 15 Oct 2026 15:48:25 +0300
Message-ID: <20261015124826.2962950-1-me@andrei-z.com>
X-Mailer: git-send-email 2.56.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6) To
 VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6)

The client posts every RPC Call by reference, so the HCA reads it from
host memory before transmitting. This patch asks for 256 bytes of
inline data at QP creation and posts small Calls with IB_SEND_INLINE.
If the device refuses, it asks for less. The commit message has the
details and the measurements.

The matching server change, "svcrdma: Post small Replies inline", is
going to the NFSD maintainers on its own. The two do not depend on
each other.

It builds with W=1 on Anna's linux-next without new warnings. I tested
it in a QEMU guest with rdma_rxe on a dummy netdev. The NFS client and
server ran on the same host over RDMA, using NFSv3 and NFSv4.1.
8 MiB of 4 KiB O_DIRECT writes and reads, and 200 small files,
compared equal. 9836 Calls went inline and 214 by reference.

I also made rxe refuse inline requests above a limit and report a
chosen vendor ID. The data still compared equal in each case:

  vendor ID   limit        QP got
  Intel       216/101/48   216/101/48 bytes
  Alibaba     96           96 bytes
  rxe         101          96 bytes

At 216 bytes 5632 Calls went inline; at 96 or 101 only 3 did, as most
Calls in this test are larger. The guest kernel also carried the
svcrdma patch. Its xprtrdma client code is linux-next's without two
later commits, 0b5bb4e586f7 and 9ee534a75912, which do not change how
Calls are posted.

I wrote this patch with an LLM coding assistant (Claude Code), which
also drafted the commit message and ran the build and the VM test.

Andrei-Alexandru Bleortu (1):
  xprtrdma: Post small RPC Calls inline

 net/sunrpc/xprtrdma/rpc_rdma.c | 30 ++++++++++++++++++
 net/sunrpc/xprtrdma/verbs.c    | 58 +++++++++++++++++++++++++++++++++-
 2 files changed, 87 insertions(+), 1 deletion(-)


base-commit: 9ee534a75912361308b1f956bc3e7895a082a422
-- 
2.56.0


