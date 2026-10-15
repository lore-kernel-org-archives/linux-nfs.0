Received: from vtj.irix.systems (vtj.irix.systems [82.76.27.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 51FAE4DB56E;
	Thu, 15 Oct 2026 12:48:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.76.27.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792068519; cv=none; b=Q0tGomjRleqQYKDnF4Ra78/IUVlixLwZInpAN7rSUBouk9WpZYjBS8ol6nmE6htdSjWYT358/p7J9dey72gs44W18nkgaJfJ75baz+NnIWNbd+15LKpUrGZbpahEM6gfOZA/z55nObbNhPMeKh1pP9Zm8KLxnsZ/5/Ra3qs4gjU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792068519; c=relaxed/simple;
	bh=DDrhK6cEYuEdzKZnEYKqiGFrYjXfqUZpW/pOJWUAKV8=;
	h=From:To:CC:Subject:Date:Message-ID:MIME-Version:Content-Type; b=TpFEGZocSu6WykI/ilmTqv54AUkoeCUu5J0g4UAv2xDQuoC3I9XMGHDwel8lKHI7/dKTbC9ESgVLy2VnfPTA5zsj/TbWnJ35W3P2Upo2X0PFh60S2g1fqP3reE+ZbCBo33jDaDNwV4gQoRfuYkcJbIcZmh1sprsCft3a7z+td+c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com; spf=pass smtp.mailfrom=andrei-z.com; dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b=Rs9gAHcf; arc=none smtp.client-ip=82.76.27.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b="Rs9gAHcf"
Received: from MAILGW-BIG.big.vtj.corp.irix.systems (localhost [127.0.0.1])
	by vtj.irix.systems (Proxmox) with ESMTP id 586D111CE4;
	Thu, 15 Oct 2026 15:48:31 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=andrei-z.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:from:from:message-id:mime-version:reply-to:subject:subject:to
	:to; s=sig1; bh=pSfeGOpMpiprqEI4nj4NucY4gLurRa86KRjoIACsb70=; b=
	Rs9gAHcfqv35DWL9OfCJ8VX8UdAekcAS6HD5dMXMk+LNh+kVnd7hf9jYT8rFHlv6
	sM1eRBc3gnMKFGHtOkECdmidAnDTHA8jY1tZKAgFnu/caHnRpFN154MpXcFz6eIx
	48dmo11iXjjVZqaYlIFA9j0rAsXx10rBwkReYx3rPpTEQ6wFVgt1ubDPhqN3XjrT
	vQeYVkG1RlFvtJ+gkMBgJQGORx8581/MsyWvFPVI0VALLm7z09TiAwfuU/1mnOoK
	/70Z1ugC19L0qo16OhgVr7XUNY4P7S7yJYtq8V4giIHjhqV1wiS/MytchNQte4Q9
	jo/1Uwze45k52mov/WxH8w==
Received: from VTJ-MX.corp.irix.systems (unknown [10.57.36.6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vtj.irix.systems (Proxmox) with ESMTPS id D959711D40;
	Thu, 15 Oct 2026 15:48:30 +0300 (EEST)
Received: from [10.89.11.73] (10.57.8.14) by VTJ-MX.corp.irix.systems
 (2a02:2f04:1:9c24::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.49; Thu, 15 Oct
 2026 15:48:30 +0300
From: Andrei-Alexandru Bleortu <me@andrei-z.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
CC: Andrei-Alexandru Bleortu <me@andrei-z.com>, <linux-nfs@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Subject: [PATCH 0/1] svcrdma: Post small Replies inline
Date: Thu, 15 Oct 2026 15:48:29 +0300
Message-ID: <20261015124830.2963045-1-me@andrei-z.com>
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

The server posts every Reply by reference, so the HCA reads it from
host memory before transmitting. This patch asks for 256 bytes of
inline data at QP creation and posts a small Reply with IB_SEND_INLINE
when it is the only WR in its ib_post_send() call. If the device
refuses, it asks for less. The commit message has the details and the
measurements.

The matching client change, "xprtrdma: Post small RPC Calls inline",
is going to the NFS client maintainers on its own. The two do not
depend on each other.

It builds with W=1 on nfsd-testing without new warnings. I tested it
on the nfsd-testing of 25 September, in a QEMU guest with rdma_rxe on
a dummy netdev. The NFS client and server ran on the same host over
RDMA, using NFSv3 and NFSv4.1. 8 MiB of 4 KiB O_DIRECT writes and
reads, and 200 small files, compared equal on the client and in the
exported file. 5529 Sends went inline and 4521 by reference. The
latter include the READ replies, which follow their data in the same
chain.

I also made rxe refuse inline requests above a limit and report a
chosen vendor ID. The data still compared equal in each case:

  vendor ID   limit        QP got
  Intel       216/101/48   216/101/48 bytes
  Alibaba     96           96 bytes
  rxe         101          96 bytes

At 216 bytes 5329 Sends went inline; at 96 or 101 only 6 did, as most
Replies in this test are larger. The guest kernel also carried the
xprtrdma patch.

I wrote this patch with an LLM coding assistant (Claude Code), which
also drafted the commit message and ran the build and the VM test.

Andrei-Alexandru Bleortu (1):
  svcrdma: Post small Replies inline

 include/linux/sunrpc/svc_rdma.h          |  2 +
 net/sunrpc/xprtrdma/svc_rdma_sendto.c    | 31 ++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 62 +++++++++++++++++++++++-
 3 files changed, 90 insertions(+), 5 deletions(-)


base-commit: 78c334bc5ae61d23ca1cc2e43079c620f1d40866
-- 
2.56.0


