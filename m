Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com [209.85.210.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DFDA8374E48
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:41:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653696; cv=none; b=UiBIm7aAZzzs4vPCXNrRXkW509AFB0bBrLGTdvwEbBquJr0aKFzEuaG3IG/UTkPQb0db1rVtfeE/dh3e56KxnxCEw4KVNiy4T3eLvvmks7g49xOmY/QPsTfA6ghDkH3leF/tNlo8qxH8IC//bprF884PWUfz8xhK/SmPwvfX2e8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653696; c=relaxed/simple;
	bh=blm3DEJAuTYyhcYX8hcxv8ecDTKBsaUO3jkGOK5k+8A=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=DxmOir8te2AM44h4A0yMYUvTJgewJJkd22gzsEPD3IrAwc99GjqHqsJxV/j8l30ab9LuYpDSmTIssI5pdWX7N0A2EigLgmmO+aF7UWQcWCQCfS6W9ybeDuqMi+Bby9QctMsJ5kI9WIw95z0pb5vLQlrwjRF/1KDfHwONRRjz/14=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=DKkB7xTu; arc=none smtp.client-ip=209.85.210.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DKkB7xTu"
Received: by mail-ot1-f52.google.com with SMTP id 46e09a7af769-7eb4d532e65so211972a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:41:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653694; x=1787258494; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=KTLYLxPZnL2SMMFyVHUM3lu87Ae8BA3fHhBwBoQzexw=;
        b=DKkB7xTuSOzMdXlyoEwEIO8lA/BwPVkonWp2XHZ5txi0PR9iUC11WUT9Ce7f4HNv8K
         dui5TdPLm+WX1g6NlJTSWTADTeksFckLAr2kdEqMDdk63n51uTXM9GCi5qmY2kEZbEzL
         DQpEYNDMUJTMVPSgJhC2GBeBOtZpueg2JJVZgdC6D4D0weq9R/5hb/nWvdEBY9CBMQOj
         dzVXfQ0SdYarYSBt+WawKYB55PE+ZlxvTNGNj2XRJFRedecs5PD8E0uKoi2wdPXChICe
         6FDdQsdrtmAmn8Tnc3J5ArEH+ZB45wfgFl0uNYs23DARGk1Tgb7zZsfctMayXojKAvRU
         6l5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653694; x=1787258494;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KTLYLxPZnL2SMMFyVHUM3lu87Ae8BA3fHhBwBoQzexw=;
        b=KQUYi9FOim6fp7tSDnWhvCTM5bkJ8bzMSs8fWhIRW7xMuCX8dY67kwI5LdHQ3zb1J/
         gK2SUhbBZV2RxN8IlYYKE7k2gz5YVzBZVq5L0tCoXdYAOo9mOMd0B48AZEEJ+5mv0BdT
         YFVTGAGk4pjjSoxrMEAY70HoSgSJMNJEzgEJmtlHP1E3yiW7G3OZaN+odqLXjrwWmqL/
         5fX3QPRb9HxDlstRrTC1V/Yn1Vs0IAq50u/niWODtUIwQ+/qJXxQtirxocF6zdHLYjq4
         UFmi+giYBJxub7uumL3uWC/sr00UIljfZOI+WE3iToXwVJptOitM/sMk+dSqgMAbXUxn
         iOYA==
X-Gm-Message-State: AOJu0YxBYH60wahuwIPFTlNvbPaA1Env5ugz2uw9NPp0TeH8guCTYNAA
	bjl57NGEVBZKuWOaJGkF5cay6YbPU5uQmDqtWYXj1ncHJ13XJe2BMIUd5V6wensy9OE=
X-Gm-Gg: AR+sD13qUCKlj6budFo++wzGKpfK4PoDYIQWV8goK/kXCo81hMDT2HIr5AK3DaMEUSt
	05BritEq6FSe2XbjSMLxrn5PkwQo32wlpE3+INzYxthJS24fRBGtqabn3s12kB1n71WJD7wrp4C
	3DA434QCK6f4FbSOfkwwBCOh4d0ZRuNZ8CGV9d9wGJOMaVXkbm1Jpw4ll2VcpgFRr5A5qFenWJ4
	DhdIrwjlhw3vXOXe9QSGwtOj5lHmf2rLy7E1pRg1c3wv4hIjwUv+S657Gs1CO7DW+10ZCi7y6Id
	OHGqxmoDMfW2EWPvvTO8Y1jpqLl0vAIEJqpTANfg09+ZoMdgHxjt6EhggxC1OYgtOIq2Pvdouey
	7sIifn3n0KdL0DLTccleZ0edZ0IV74M0lpqORXPpwTXijXIRGvTOcNvXdgceCTbnLUAPida6oIX
	S6Y7tEJKijmlMNPK9oP4Q5IeszKJt08LYtB/g9kMb/1UIrL0zvfYmnZd3aAcsKbkyZ15vza0nby
	SdkDCMAxNOAgm8nsaKZ7pdU
X-Received: by 2002:a05:6830:3694:b0:7eb:9464:ac2e with SMTP id 46e09a7af769-7f3de74131fmr478280a34.11.1786653693550;
        Thu, 13 Aug 2026 13:41:33 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3c9e23b6fsm3087958a34.25.2026.08.13.13.41.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:41:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 0/6] NFS: size the LAYOUTGET reply buffer for wide flexfiles layouts
Date: Thu, 13 Aug 2026 16:41:25 -0400
Message-ID: <cover.1786653456.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The flexfiles layout driver caps its LAYOUTGET reply buffer at a single
page, which limits a striped layout segment to roughly 28 ff_data_server4
entries -- far below the 4096-stripe decode limit the client otherwise
advertises.  A server striping wider than that has no way to hand the
client a layout: it returns NFS4ERR_TOOSMALL, the client falls back to
I/O through the MDS, and pNFS never engages for those files.

This series first makes the client behave sanely when a layout does not
fit the size it advertised in loga_maxcount, and then lets the reply
buffer grow on demand up to the session's maximum response size.

Patch 1 is a standalone fix (Cc: stable).  A server's NFS4ERR_TOOSMALL
is mapped to -ETOOSMALL at decode and then handled nowhere, so the
client falls back to the MDS for that one request and re-sends a doomed
LAYOUTGET on every subsequent pageio attempt.  Suspend pNFS via the
layout fail bit instead, the way NFS4ERR_LAYOUTUNAVAILABLE already does.

Patches 2-5 make wide layouts work.  loga_maxcount is derived from the
reply buffer actually allocated rather than a fixed 4096 (block and SCSI
layouts were advertising 4KB against a session-sized buffer, so a server
whose extent list encodes larger than a page got a needless TOOSMALL).
A TOOSMALL LAYOUTGET is then retried once with the buffer raised to the
session's maximum response size -- the same bound GETDEVICEINFO already
uses -- and a non-conformant server that ignores loga_maxcount and
overruns the buffer outright takes that same recovery path instead of
today's -EINVAL.  Finally the escalated size is remembered per-server, so
subsequent opens skip the attempt that is known to fail; this is also
what lets the LAYOUTGET attached to OPEN succeed against a wide-striping
server, since that path is best-effort and has no retry of its own.

The common path is unchanged throughout: the first LAYOUTGET for a
layout still goes out with the layout driver's default reply buffer, and
larger buffers are only ever allocated against servers that actually
hand out wide layouts.

Patch 6 moves the decoded per-mirror stripe array to kvzalloc_objs(), so
that a wide stripe array does not depend on a high-order allocation
succeeding.

Wire-validated against reffs at stripe widths 2 and 64, exercising both
the conformant NFS4ERR_TOOSMALL path and the buffer-overrun path.

Two known gaps are deliberately left for follow-up work:

  - The decoded per-stripe footprint is heavy: nfs4_ff_layout_ds_stripe
    is roughly 300 bytes and embeds localio and layoutstats state that
    most stripes never use.  Both the structure and its array container
    want rework before very large stripe counts are comfortable.

  - The client decodes only the first logr_layout entry of a LAYOUTGET
    reply and silently discards the rest, so it can accept less coverage
    than it asked for in loga_minlength, and cannot amortize a
    multi-segment reply.

A related series, "NFS: flexfiles device notifications and caching for
wide striped layouts", handles CB_NOTIFY_DEVICEID and scales the device
caches for the layouts this one makes fetchable.  The two are
independent and apply cleanly in either order.

Benjamin Coddington (6):
  NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from LAYOUTGET
  NFSv4.1/pnfs: derive loga_maxcount from the LAYOUTGET reply buffer
  NFSv4.1/pnfs: retry LAYOUTGET with a larger reply buffer on
    NFS4ERR_TOOSMALL
  NFSv4.1/pnfs: treat an oversized LAYOUTGET reply as -EMSGSIZE
  NFSv4.1/pnfs: remember when a server needs a larger LAYOUTGET reply
    buffer
  NFSv4/flexfiles: allocate the per-mirror stripe array with
    kvzalloc_objs

 fs/nfs/flexfilelayout/flexfilelayout.c |  6 +--
 fs/nfs/nfs4proc.c                      |  9 +++++
 fs/nfs/nfs4xdr.c                       |  2 +-
 fs/nfs/pnfs.c                          | 54 +++++++++++++++++++++++---
 include/linux/nfs_fs_sb.h              |  4 ++
 5 files changed, 65 insertions(+), 10 deletions(-)

base-commit: db2ddb87143519e20a95aa36c60b36107b736a58
-- 
2.53.0

