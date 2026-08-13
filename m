Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76EB43314AC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653802; cv=none; b=AdLG4GfoofHYxfL7h6+DQuzQSJyl1k4E9b6J9sn6z0rMkFB2DwZiDsDwDakrdCeHGyeEhira2Gqk6lAnsyojsfrtDZim7p70XQyCiPx69KmMYD7NNu95udEmSeIDdsy2ba/NY7CymbxWzUDnAcN6IvhDOfLdcYihB1tBWKY6OMY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653802; c=relaxed/simple;
	bh=hcPRKIL3/CLXhTNFJSbyZm9iDl4RUEp8LQqCJqyzlOQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qaOAlIhQBTnV0MoTpp7jh3r0e0Xi9uooww+3t+opZcmJyW9KH2qSJZMTg65oe3rAobSQwIUkOJ3Su2BrGAAQNSB8+hghFXY+osLmzSlaRJPjx5mXf8ygaNAU12nkMtplC2DV4EoB0SlFSrYWfSUpx9gY6AbZhgPJpNlLHv//zPc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=d3IU0d4I; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="d3IU0d4I"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4a427e628a9so99571b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653799; x=1787258599; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Cbu0+WDebZ+3k3JWqO1B3jQCWhrKHe6YLwYNP6VOY0Y=;
        b=d3IU0d4IJAmkRSl/8n6pn71RQihiBudxEd/gi3LsaNs2yhCWiEI1at50nbykZC0HPm
         5KCSl2M2Ze12puacGprsrCgoy7X08RqBwxp53TAo4liqcKSdDbrKj4zGQ0y8PgIwA/9L
         tSASgucKvK3Y0WTl3wArIdKeE9xfwAT9hYWz+Uc6UZgzEO6Iys6qBdGO5xcljQLKzeKP
         8j9Rb+H6BlzIotOy/LyM7faXRC/jy0B5R3jWKYC3vHFDg9fjbUqumKLSKEhJHS0qCARz
         dG61H4M8nmBjFOsfCNOOzDHKU8xbchspNABV/wVts62UueIUWHcFbpAX1WtJmntWB0PB
         94fA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653799; x=1787258599;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Cbu0+WDebZ+3k3JWqO1B3jQCWhrKHe6YLwYNP6VOY0Y=;
        b=NaeV94MUQBA5gl0TF2y5g59yAnnMPDNDF3b+Mom/+wmyCmii33WfeVJQfYyRMflCFF
         gf9iE6FWVFa6pFiSgUB7mXC9o+xs3v+KjK6yQRsB76U83wg9sWGE1OKxBd8fvGMFXYml
         11ueOqnnb3D8IL3fPpm9F0sp2zdT0NdMGtCHt8D2ODXBGrh+/EpHM+wfxRQFhhHa42ZK
         WgqK/BO2hbcxq0B1X/JqnB2ZX7AvtPxp0S5bK59ygtFnWy+Aa//VC7jfdYzvzqANz2k+
         sroW9uQFJi7xOTF3OJdC5vSL9xHldh8U/dyDy9UcF17Gs3pRWmgf/WbWpYwYkUGwtLf/
         z5GQ==
X-Gm-Message-State: AOJu0Yzq1+lAhOfDe+WmChsvF3w1ID8rc/TFZSmjrgnXbfbUgY1PO37R
	c8mC+xY0aslIBHzsvbA7bWy+CnphAMOaQXYK4w20B+9MU2uNqbA5r5HUlIjJOpjxqtU=
X-Gm-Gg: AR+sD11w8hX4FJYuLsgJ0YA96kbDdm5uSCb36irnH/6JUtlR4DhsN4tbIQ/jF4FsOpg
	fSZ/dDQfmtai+UAGGgeSEDWMnxm4YB2UZn5hy0nByXsKZHggmkJuvtVg5D3aNjFwerXjmNNAmH+
	2u+AjmX8aPElmSBeGa++CTP/OgpgFMl+5GUZGpHPJfZGvIIgQGsQnlti1oFXAloO1y8luStc5w4
	8zvEtw6ou0ni3yHaKfucjWh3uDE3uFndPh8/zcRu84vFic0qjP0BBw9xaJRkAK09D1jZZdza0lQ
	sUA+BI2NuBdoymu0gU5no4+hTzWow1eUM67V0L3MECbwtm4Teuw22vgPhkT078/ZEl3XlVaB8VU
	GrZpCOEMrhXtcL/jWcJfEIaIWZQhoYsxVnjIj2U3M2oP/yJ6WG5MKsc8CVQH3NuoorzbyE8BNTV
	oC/YIGKGQJw1i6oBI0yhGAKpLoOEl92mSXPcQcJr0J1u1oo8MRot38MeunJ3JOV0I1rY1lslYxD
	F9hQH9ezq10gZqTyisbVzeM
X-Received: by 2002:a05:6808:bc6:b0:492:5684:7ab3 with SMTP id 5614622812f47-4b241f1bf85mr684869b6e.21.1786653799137;
        Thu, 13 Aug 2026 13:43:19 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:18 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 00/21] NFS: flexfiles device notifications and caching for wide striped layouts
Date: Thu, 13 Aug 2026 16:42:56 -0400
Message-ID: <cover.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

A flexfiles layout striped across many data servers puts hundreds to
~1000 distinct deviceIDs in play for a single mount.  This series makes
the client's CB_NOTIFY_DEVICEID handling actually work under live
layouts, implements the deviceID-deletion race recovery RFC 8881 asks
for, and scales the device caches to that number of devices.

Patches 1-4 are standalone fixes (Cc: stable) for latent bugs in the
striped-layout paths.  The CB_NOTIFY_DEVICEID decoder gated consuming
ndc_immediate on the layout type instead of the notification type, so
the flag was silently lost and any multi-item cnda_changes<> array
misaligned after the first entry.  Read data-server selection truncated
the file offset to 32 bits, picking the wrong stripe's DS for
availability probing and coalescing above 4 GiB.  And page coalescing
was bounded on a segment-relative offset in both the flexfiles and files
layouts, so an unaligned segment let a coalesced I/O straddle a stripe
boundary and send the bytes past it to the wrong data server.

Patches 5-13 make CHANGE notifications work under live layouts.  RFC 8881
Section 12.2.10 has CB_NOTIFY_DEVICEID CHANGE exist precisely so a server
can re-point a deviceID without recalling the layouts that reference it,
but the client's only response today is to unhash the cached device --
which never reaches the references pinned inside the layout driver's
segments, so I/O keeps going to the old mapping until the layouts are
freed.  Each in-flight I/O is given its own device-node reference, the
mirror's pinned pointer becomes RCU-managed, and a new layout-driver
hook re-resolves the device in place, honoring ndc_immediate.  A
GETDEVICEINFO reply that raced a CHANGE is discarded rather than
installed stale.

Patches 14-17 implement the deviceID-deletion race of RFC 8881 Section
18.40.4: layouts still referencing a deleted deviceID are tested with
TEST_STATEID, revoked state is recovered, and the deletion is confirmed
with GETDEVICEINFO before escalating to lease recovery.  A DELETE that
no live layout references keeps today's cheap path.

Patches 18-21 scale the device caches.  The global deviceid hash grows
from 32 to 256 buckets (a load factor of ~31 at 1000 devices today), and
the per-net data-server cache moves from a single list to hash buckets
keyed by the DS address set -- which also fixes a latent aliasing bug,
since the old comparator matched on subset rather than equality and
merged two data servers whenever one's address set contained the other's.
Last, the flexfiles driver gains a dataserver_nconnect module parameter
alongside its existing dataserver_timeo and dataserver_retrans knobs:
data-server clients otherwise inherit the MDS nconnect, which at ~1000
DSes and nconnect=16 means ~16k sockets and their slot tables for little
gain on a workload striping across the DSes anyway.  It defaults to 0,
preserving today's inherit-from-MDS behavior.

Tested end-to-end against reffs, a notification-capable reference
server, at 256 and 1000 devices, including KASAN and lockdep runs under
concurrent notification storms.

A related series, "NFS: size the LAYOUTGET reply buffer for wide
flexfiles layouts", lifts the single-page LAYOUTGET reply buffer that
today caps a segment at roughly 28 stripes.  The two are independent and
apply cleanly in either order.

Benjamin Coddington (21):
  pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
  NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
  NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
  NFSv4/filelayout: Anchor page coalescing on pattern_offset
  NFSv4/flexfiles: Reference the device node across DS setup
  NFSv4/flexfiles: Carry the device node reference across each I/O
  NFSv4/flexfiles: Hold a device node reference for layoutstats encoding
  NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
  pNFS: Add a reresolve_deviceid layout driver hook
  NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
  NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
  NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
  pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
  pNFS: Add deviceid reference query and collection walkers
  NFSv4/pnfs: Recover revoked layouts on a deleted deviceID
  NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
  NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
  NFSv4/pnfs: Grow the deviceid cache hash table
  NFSv4/pnfs: Re-home the data-server cache onto hash buckets
  NFSv4/pnfs: Key the data-server cache by its address set
  NFSv4/flexfiles: Add a dataserver_nconnect cap

 fs/nfs/callback_proc.c                    |  30 +-
 fs/nfs/callback_xdr.c                     |   2 +-
 fs/nfs/client.c                           |   6 +-
 fs/nfs/filelayout/filelayout.c            |   8 +-
 fs/nfs/filelayout/filelayoutdev.c         |   2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 383 ++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  44 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 193 +++++++----
 fs/nfs/internal.h                         |   3 +-
 fs/nfs/netns.h                            |   5 +-
 fs/nfs/nfs3client.c                       |   9 +-
 fs/nfs/nfs4_fs.h                          |   2 +
 fs/nfs/nfs4client.c                       |   7 +-
 fs/nfs/nfs4proc.c                         | 113 +++++++
 fs/nfs/nfs4state.c                        |   3 +
 fs/nfs/pnfs.c                             | 292 +++++++++++++++++
 fs/nfs/pnfs.h                             |  81 ++++-
 fs/nfs/pnfs_dev.c                         |  35 +-
 fs/nfs/pnfs_nfs.c                         |  93 +++++-
 include/linux/nfs_fs_sb.h                 |   2 +
 include/linux/nfs_xdr.h                   |   2 +
 21 files changed, 1069 insertions(+), 246 deletions(-)

base-commit: db2ddb87143519e20a95aa36c60b36107b736a58
-- 
2.53.0

