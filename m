Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5CF73C5DDB
	for <linux-nfs@vger.kernel.org>; Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791951026; cv=none; b=MuA0EI92Qq4TpXo/PfB1NwVxhDht112g/AIlsfsGSvXO/Io+UbK4Tk/DPm4udGwoxO9wL2rvOY8/GWX90AGOxOk7J3E+9bjyihBAnBOOID/XDpW/ct27RLO2TdZRSod7u9UVdZAThKf3Kv8a9Gl7d8nMWU1VhV0F1oMKBNxKFDY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791951026; c=relaxed/simple;
	bh=pyJnT/1HJaNuexUJ29Bd39L2Pk6I7AVyLNs18hA3dxU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=AnYz7pghWkXLIo4wyieu9V2wne2N7uLARchTQhyqnorz3JM2sQkmR1DXinvXgz6KbJmp18UprOpWXkP/dvTsIkEvd7hd1FtTH+B5ZOgl9+0aUJKHa0nf6CCkDlLLSvvpJ4pfnNEm8rFT2gUdDKMDUnxPwbslU8YEeFrSqOKsjgs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=M/LWI8BN; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="M/LWI8BN"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 7ACF3C2BD04;
	Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791951026;
	bh=pyJnT/1HJaNuexUJ29Bd39L2Pk6I7AVyLNs18hA3dxU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=M/LWI8BNOPXYI9A6DQn3Ai81ONbOMfjhboEiYBfGWakaL/Xzb9VnY6ZZ0ZbkRv5OE
	 eTrfNkTpjAh8LjYDT2ZK1ZQ6WPFZCiKucazZE5FFPnEpau+mOWipBbzM+eg+uCJC9F
	 X1TydJVNxga+GMh+9XKhj1wcY8JoStr6smJpJtYN9PzeUZU9RwB5NvRThtJHqxHwxi
	 kJl8xDb8mW5xOuhxm7/vxgJHlZwqAd+qgz3tqyrql9Wj8E2jUPxt02pl9/ik93dQIT
	 1BWfK+nisjsjALf2OFwmRSBv1vVNQF520jhGHC1WAFn7AIcocFsJu5IAYJJLh18QVe
	 rs9oseExrTAKQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 662BFCC6B24;
	Wed, 14 Oct 2026 04:10:26 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 14 Oct 2026 13:10:28 +0900
Subject: [PATCH pynfs 3/3] Add README-blocklayout
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261014-pynfs-block-commit-v1-3-1723979f495f@samsung.com>
References: <20261014-pynfs-block-commit-v1-0-1723979f495f@samsung.com>
In-Reply-To: <20261014-pynfs-block-commit-v1-0-1723979f495f@samsung.com>
To: Calum Mackay <calum.mackay@oracle.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Christoph Hellwig <hch@lst.de>, 
 Dai Ngo <dai.ngo@oracle.com>, Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791951025; l=2601;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=YqS0ogQssgr7gKBiOnKJ3S7SC8ISwfMrFhVX+bxl4Ns=;
 b=rtX1zAYBOjwXcsa68uY5QfmDPhb+tV1dg3Bkeaz0pDeg/gMrTXC9upUf8a4El1qwXl4s5rn6Q
 hsCbRYBS+vFBf6qS1s23INA+HxyvBToxy8sQoTsxUALb1LrPzk3rGLO
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

Describe how the block layout tests are run against Linux nfsd: the
kernel options and export option that nfsd needs to hand out block
layouts, a setup that the tests have been run with, the testserver.py
command line, and how to leave out the tests that commit ranges no
layout covered when testing a server that shuts down on them.

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 nfs4.1/README-blocklayout | 41 +++++++++++++++++++++++++++++++++++++++++
 1 file changed, 41 insertions(+)

diff --git a/nfs4.1/README-blocklayout b/nfs4.1/README-blocklayout
new file mode 100644
index 0000000..48d3c1b
--- /dev/null
+++ b/nfs4.1/README-blocklayout
@@ -0,0 +1,41 @@
+Testing a block layout server
+=============================
+
+The "block" tests (server41tests/st_block.py) run testserver.py as the
+pNFS client of a server that hands out block layouts (RFC 5663). They
+only send NFS operations: none of them reads or writes the shared
+volume, so the host that runs them does not need access to it.
+
+They ask for LAYOUT4_BLOCK_VOLUME layouts. Linux nfsd hands those out
+for an XFS export with the "pnfs" option when it is built with
+CONFIG_NFSD_BLOCKLAYOUT. With CONFIG_NFSD_SCSILAYOUT it also hands out
+SCSI layouts (RFC 8154) if the device supports persistent
+reservations; the tests do not use those.
+
+One setup that the tests have been run with:
+
+  - nfsd built with CONFIG_NFSD_BLOCKLAYOUT=y, and XFS (mkfs.xfs
+    defaults, internal log) on a whole NVMe namespace, exported with
+    this line in /etc/exports:
+
+        /export  10.10.0.0/24(rw,sync,no_root_squash,pnfs)
+
+  - The namespace came over NVMe/TCP from nvmet on another host. As
+    the pynfs host never touches the volume, any block device that
+    XFS can be made on works for these tests; a shared device only
+    matters for clients that do I/O through the layout.
+
+  - A directory /export/pynfs on the server that the test user can
+    write to, and on the pynfs host:
+
+        ./testserver.py SERVER:/export/pynfs --secure --maketree block
+
+    --secure sends from a privileged port, which nfsd requires unless
+    the export has "insecure". --maketree creates the files that the
+    tests expect; it is needed the first time.
+
+BLOCK7 to BLOCK10 commit ranges that no layout covered. A server that
+does not refuse those may allocate blocks for them or, as XFS did,
+shut the filesystem down, which makes the tests after them fail. To
+leave them out, add "noBLOCK7 noBLOCK8 noBLOCK9 noBLOCK10" after
+"block".

-- 
2.43.0


