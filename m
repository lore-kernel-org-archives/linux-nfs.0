Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85C7143747B;
	Tue,  4 Aug 2026 10:55:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785840927; cv=none; b=Jr3iBfZhYniZic0x/yW8e5prTfrUg+Xy/dBKwM8LZ7Dst1nul9BtTC8Rn5xeY10beFI56LRUoLCCdyTzIXE92/bF/2yr4g7scnyAEBXrf944h0jiKedAHAMRxzjUhuJyRHvIaM9KHFfawhss1sF9XX4z6ugFqM9ygWs5rSmddKw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785840927; c=relaxed/simple;
	bh=/zX1dK5pUUwfUUMgp/WjTg2pjQrJvqcIYBJwxISBk4k=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=skLjRqGKWXsKciYkJfFRBHSj6/ccv4sWekGHcGigHjhJ/xrblUHXpOBjat/3aNcCscYtBPnucmxUNc4rUtPDXP7K9dE7v/W3/9EK9obrZs+IIO7kvSjY7gTRg3q37IkCevNfftEvoif5sLEeb9vniXmzWHYMmZRnb4v6a7uHCS4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XtYgSNmU; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XtYgSNmU"
Received: by smtp.kernel.org (Postfix) with ESMTPS id A442BC2BCF6;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1785840926;
	bh=/zX1dK5pUUwfUUMgp/WjTg2pjQrJvqcIYBJwxISBk4k=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=XtYgSNmUw1N+43MoNDdnc670SG/gZcUOVmDEZbWK86886C6R9Jnyf9zb+KpvFS/Tn
	 Esm3aKpvH65qCy2M8MxcUtFKENfax4G1ZuSyHIunQDLNvTrUYljqPOiiuYy0CJxKYd
	 FPIKVRNA9csszA6MKZCVKx4AHtyN6LwOFv3UTsd3xHRSP1gfzNigD0HDQFqQZp2Roc
	 4CiHLIjBmMb69c4AvHFIA/t+9lgfE2gE+GIbaXXNnPQX9Eqxux9v8CzsuwZvtuM1mE
	 fB7FhdokQavUVoOfUJjh0lMwCmHjIUC571Jrum5IxWNZbdGMb0frEbVbUuA+tLkDWO
	 dsRdIrDuKW6bQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 86D27C55ABA;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Tue, 04 Aug 2026 18:55:01 +0800
Subject: [PATCH 1/5] NFSv4/flexfiles: bound the multipath address count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260804-nfs-fixes-v1-1-1544df970e7c@outlook.com>
References: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
In-Reply-To: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jonathan Curley <jcurley@purestorage.com>, 
 Michael Bommarito <michael.bommarito@gmail.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2777;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=P//3MuVFQOmbnVMiCO1Tok8Ub0duINavLD89ty/UirE=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMKj0lencjE0C4WblrXsYp/Rcy7yYd609HPb7srF/
 35Tdbbv/5SOUhYGMS4GWTFFluMFl75Z+G7R3eKzJRlmDisTyBAGLk4BmIjITEaG/62+nILezh4n
 b73SZ3V7GplUd21nJJNFl9W1uQsfpMunMDKc0uSRMly77kPLkY416VHr48LebK71n2K0O8fjxgz
 W6VN5AaIpShg=
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

nfs4_ff_alloc_deviceid_node() decodes the multipath address list of a
flexfiles device from the GETDEVICEINFO reply body. mp_count is taken
straight off the wire and used as the loop bound for the
nfs4_decode_mp_ds_addr() calls. nfs4_get_device_info() bounds pdev->pglen
but not the counts encoded inside it, so a server can advertise up to
2^32 - 1 addresses in a body that holds none of them.

Once the xdr_stream is exhausted the loop stops making progress:
xdr_stream_decode_string_dup() fails in xdr_stream_decode_opaque_inline()
, so nfs4_decode_mp_ds_addr() returns NULL without consuming a byte and
every remaining iteration re-fails at the same offset. With mp_count set
to 0xffffffff this spins for roughly 2^32 iterations with no rescheduling
point, potentially tripping the soft lockup watchdog and the RCU stall
detector on non-preemptible kernels. The list_empty(&dsaddrs) check
below the loop only runs once the loop has finished.

Reject implausible counts up front, as ff_layout_alloc_lseg() already
does for mirror_array_cnt and dss_count.

Fixes: d67ae825a59d ("pnfs/flexfiles: Add the FlexFile Layout Driver")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 4 ++++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 5 +++++
 2 files changed, 9 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index a5bd00f69e82..d024b8db4ce0 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -23,6 +23,10 @@
 
 #define NFS4_FLEXFILE_LAYOUT_MAX_STRIPE_CNT 4096
 
+/* Filter out insanely large multipath address counts, which would
+ * otherwise let a server spin the GETDEVICEINFO decode loop. */
+#define NFS4_FLEXFILE_LAYOUT_MAX_MULTIPATH_CNT 4096
+
 /* LAYOUTSTATS report interval in ms */
 #define FF_LAYOUTSTATS_REPORT_INTERVAL (60000L)
 #define FF_LAYOUTSTATS_MAXDEV 4
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 1109462a9699..659a2bf7b502 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -79,6 +79,11 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	mp_count = be32_to_cpup(p);
 	dprintk("%s: multipath ds count %d\n", __func__, mp_count);
 
+	if (mp_count > NFS4_FLEXFILE_LAYOUT_MAX_MULTIPATH_CNT) {
+		ret = -EINVAL;
+		goto out_err_drain_dsaddrs;
+	}
+
 	for (i = 0; i < mp_count; i++) {
 		/* multipath ds */
 		da = nfs4_decode_mp_ds_addr(net, &stream, gfp_flags);

-- 
2.51.2


