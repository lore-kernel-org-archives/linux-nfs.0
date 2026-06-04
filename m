Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC05F1E3DDE
	for <linux-nfs@vger.kernel.org>; Thu,  4 Jun 2026 20:24:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780604648; cv=none; b=fv9iIRQSrOvfHhZ8SwxhYdDBnGhUHLFLQtbVmHgp+/Ewc2UFww8r3z6DIzOfw/YcCQMBmlThBJO7LKQr+EBdig6Spf594Hol+u7xzEa61MyzSdowUGOsYOB93GeZ+QHwLbq5EcuZIWO/FdRIEyDHIYv+vmmGSH0HlTSPoLUBzWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780604648; c=relaxed/simple;
	bh=f63D5BSJuB1/MEKSMk9cJnKPSIaWN+wb0wCyIwyVgx4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=HC1wlw4j0PUhqjpQWSyUDHhP4hZJM6RQjRh1qH9xvjB1+9SQ0HjSBpkcYmQdHjHkHmHLb1y1h5AQeUPk5fpYKWbu10OdDyW6tPty1mLFhv1vcBHG59f2MWwcJDBVPzdqGwG8UceUmm+uTwWDiGtcol//azm7uqnnNlW1LpeCYB0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iXOgZxBv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iXOgZxBv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4189F1F00898;
	Thu,  4 Jun 2026 20:24:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780604646;
	bh=C2UtE/UCemdPFjKl1HBzD/U4exwCIXDo7dUHWlbHTNk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iXOgZxBvhnxyMzyvc07HTFGaTQYG0JICgL5tlySndLcj2FmstK32IRpNUJqfZQq8n
	 xOnn0dN9vr7b6GIFrVgupteMARsdgVxze+zZ0aqbPJj3RY50ympx018YAHTNgCk9KM
	 +hdeyJOCTmFdDA53S84CXEKcu7yDizCJ3KWgV7tsWlKqb4BkhBhNWU+bh78uwA/Nax
	 OhIFYvis3pAEP7klawAVkzI3dprr45gaKn1SiBMKzDKEhG+LHyA5yNS+vtDnZVeJpc
	 2e01bk12UnhIXCn9mcV3AB7xq6NxZsmdeQNu3A5GxZ8pA1fDb3l3kX27z+NrH05cr4
	 cEQhDnohALJ+w==
From: Mike Snitzer <snitzer@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4/flexfiles: honor FF_FLAGS_NO_IO_THRU_MDS on fatal DS connect errors
Date: Thu,  4 Jun 2026 16:24:02 -0400
Message-ID: <20260604202403.20856-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260604202403.20856-1-snitzer@kernel.org>
References: <20260604202403.20856-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Commit f06bedfa62d5 ("pNFS/flexfiles: don't attempt pnfs on fatal DS
errors") teaches ff_layout_{read,write}_pagelist() to return
PNFS_NOT_ATTEMPTED when nfs4_ff_layout_prepare_ds() fails with a
nfs_error_is_fatal() errno (e.g. -ETIMEDOUT from a SOFTCONN connect
deadline, -ENOMEM, -ERESTARTSYS), so that the client gives up instead
of spinning.  pnfs_do_{read,write}() then dispatches the I/O through
pnfs_{read,write}_through_mds() → nfs_pageio_reset_{read,write}_mds().

That fallback is unconditional and silently violates FF_FLAGS_NO_IO_THRU_MDS:
when the layout segment carries the flag (typically single-mirror
appliance layouts where MDS I/O is explicitly forbidden), the
out_failed: path's \`&& !ds_fatal_error\` clause overrides the flag's
short-circuit through ff_layout_avoid_mds_available_ds() and routes
the I/O to the MDS file handle anyway.

This is reachable in practice during a data-server restart: SOFTCONN
exhaustion produces -ETIMEDOUT, which is fatal per nfs_error_is_fatal(),
which triggers PNFS_NOT_ATTEMPTED, which silently goes to MDS.

Preserve the upstream "don't spin on fatal errors" intent for layouts
that permit MDS fallback.  For layouts with FF_FLAGS_NO_IO_THRU_MDS
set, mark the layout for return and request PNFS_TRY_AGAIN instead;
if the server cannot supply a usable layout the failure now surfaces
cleanly via pnfs_update_layout(), rather than via silent MDS I/O that
contradicts the flag.

Fixes: f06bedfa62d5 ("pNFS/flexfiles: don't attempt pnfs on fatal DS errors")
Assisted-by: Claude:claude-opus-4-7
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4d142f1fdf61a..38bcd260e0a91 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2204,6 +2204,14 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 out_failed:
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
 		return PNFS_TRY_AGAIN;
+	if (ff_layout_no_fallback_to_mds(lseg)) {
+		/*
+		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
+		 * never fall through to MDS I/O.
+		 */
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		return PNFS_TRY_AGAIN;
+	}
 	trace_pnfs_mds_fallback_read_pagelist(hdr->inode,
 			hdr->args.offset, hdr->args.count,
 			IOMODE_READ, NFS_I(hdr->inode)->layout, lseg);
@@ -2289,6 +2297,14 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 out_failed:
 	if (ff_layout_avoid_mds_available_ds(lseg) && !ds_fatal_error)
 		return PNFS_TRY_AGAIN;
+	if (ff_layout_no_fallback_to_mds(lseg)) {
+		/*
+		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
+		 * never fall through to MDS I/O.
+		 */
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg);
+		return PNFS_TRY_AGAIN;
+	}
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
 			hdr->args.offset, hdr->args.count,
 			IOMODE_RW, NFS_I(hdr->inode)->layout, lseg);
-- 
2.44.0

