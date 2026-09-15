Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 64BAC39E6EB
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474952; cv=none; b=mPxMUo30GGnktBv8+TjHBhlldBBz91n8kwoewWjtGwCczTgOL44cF5G2bj74NBG+kETDbu8aZCfX4n6y9bqpltooiq06s3DOKEosEEJQgcduHesigzrwRJZIgWO5YV4TKEPgX35HSo6mHsV0dTTX3TOO3d6CsHVnYFcXE4dvs5w=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474952; c=relaxed/simple;
	bh=uRmju5ncsKtCkYSDAZ8gHyAFr0M0ZCB5Gwhgs6pMGfk=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=BFkmsfvz7wK6OwqhciWctNQn7wgdlz+d3TBXqY7egoqac7LXPw5fq1a1UDaeAjw1c7PYs4PrqvnQ8bj2NscuxfXgcaOUQYhQyQF+28RO/PvJgZXOz5AufK9IWlTic1h7rt3k0xeIgZ0kMzxIr5I2k31VVXjya04oW9/BUxzp5QY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=TX7GE0cL; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="TX7GE0cL"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4b5c61966d0so80659b6e.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474949; x=1790079749; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=yJMH3EIMfFiRUnkSNPPDtAc5HtRwimWJi2HTaneH39s=;
        b=TX7GE0cL/K25N2V+MSQb/IDERjSkQ4qtB2CQAsNwP7TQLMtCAmWC/8fIbgPX28oJYh
         s26kxPVChQhdGT46SB95KDSCUnSFVIJ12pqTi4RHvyZEnEbNTjZEuirSoN93M7k6bmbh
         sC314Q5gDmf3INg4dG7WL9B0Pz4xQScwLyYB+iJLkbDqVTX+iJQKLDWu7k0UUpZk/Fx6
         PRen9yOQ0ywpYDbQvAPNLgkFWtrmXmApwIpY2lu7Di55GoUe5E9+VVOggj1iAzMO+2iD
         cXJUsZ9XOan/kktMrYDqqxRH3KoiEcIr0/px+N5GEIzwUdFPR/TNfNJDnMfY2ZwmVpMB
         8u9w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474949; x=1790079749;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=yJMH3EIMfFiRUnkSNPPDtAc5HtRwimWJi2HTaneH39s=;
        b=yXip9Xx8/BhLAfHzzsM0bZItxb8r6aui+g7Y0qsOTm/X3xvvZNKAUvl5ook8rLez4x
         Hoo6seSDNE5l9MoO2jMuz8PPVaNfXIUoBDC1koCI8zvrRENizQBnKvvtNFmFo+8DlUfj
         JFotiLCmVLErX9l6SDqsWW3WLTqv4ytQFItkPHkaZJl4oVsGEefhUvCEOmInRLnfgBsp
         BxMknacWIWWNd00zDgeCnE+bs9SkFYiGzi/j3UZ5cvbbudOOQAtHrL4CEAx+dYgB5CLE
         92z2evnNlRDmUrPcrzv5uCRJhIzsF31a4s1gsBB80ctFSP4cMCMCf6tdWpp041wpn5/R
         MjWg==
X-Gm-Message-State: AFuF++mhrTRWFBMZvqynlKthXFT4JZFehvEcQ5g6LHWpt5UDjpziN4b+
	zNp/g3pcsE4nV5z8eNXhdNIgfsiIyuUkM8Blwgh7PefD9TUlcbKQZfFZi1EZqQ1EJk4=
X-Gm-Gg: AYBFou10GgxOInGcc47rMro1rJcs+9VhTyTzv/vXaApLCV/cYPlyxSTtBSc037OGIQb
	117nR/f8rBce6sHdIfzWZ9QnkrxdOQZSUJ0bpxMS4v/61h9ErOlalcPSLKHBQJF9HKBpSL6PRWW
	e0wmaT6vqxj2DbkbU72Nm1DsY5W+HYm0l8+q5dHPfmuvtpt/z3PC+xleTJJz1j/ygHNPxR7N/xG
	WOq/sd1yLZGEgvwh/asHwtFd5OIwm1zlN4gHbPN3tSYYRXClxvuOs5FgY5rF/QqhAeHtr9hSDyk
	s/RN5L/cHUiXj/cp7p4RhxPEtqBgyPyTLpwxnE+LttiPZYWcnUk3YYoV4bHrQn7ZP2ZADhEAae3
	b1/YqbMSG5oz3v37R/959zs5bKFKpFKwkfkmFMkIG5n0DAAdREp8hfok0s8fNmN6h9/gVs41kHF
	4y9J6kr0XGQAF3m714FwG/XqmAEMDJAWeTw4G2mb/10QSNe9ugWPCTlJYGigECil2OwgMUEyUcH
	ZWFWQdg7MbZu5l0jSa1XaJybr3a1BqIazOW
X-Received: by 2002:a05:6808:4f14:b0:4c3:1005:beaf with SMTP id 5614622812f47-4c9ab1b79b8mr511255b6e.15.1789474949032;
        Tue, 15 Sep 2026 05:22:29 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.27
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:28 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 00/24] NFS: flexfiles device notifications and caching for wide striped layouts
Date: Tue, 15 Sep 2026 08:22:02 -0400
Message-ID: <cover.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Striping deployments initially anticipate device counts scaling to 1024
or more devices, all in play for a single mount.  This series makes
the client's CB_NOTIFY_DEVICEID handling actually work under live
layouts, implements the deviceID-deletion race recovery RFC 8881 asks
for, and scales the device caches to that number of devices.

v3 posting:
  https://lore.kernel.org/linux-nfs/cover.1788530385.git.bcodding@hammerspace.com/

Changes since v3:

 - Rename the id member of struct pnfs_reresolve_deviceid_args and
   struct pnfs_deviceid_ref_args, and the walker parameters that fill
   them, to devid (patches 12 and 17), so their initializers no longer
   read like two assignments of the same value.

v2 posting:
  https://lore.kernel.org/linux-nfs/cover.1787327939.git.bcodding@hammerspace.com/

Changes from v2 to v3, in patch order:

 - Rebase onto v7.3-rc1.  Two commits landed there that this series
   touches: commit 13c23c5cb977 ("NFSv4/pnfs: key the data server cache
   on the NFS version") puts the NFS version in the data-server cache
   key, which patch 23 now folds into the bucket hash so that the whole
   key picks the bucket; and commit 92a885576fbc ("NFSv4/flexfiles:
   support loosely coupled data servers") adds a tightly_coupled
   argument to the DS connect path that patch 24 threads nconnect
   through.

 - Prepend one more preexisting fix (patch 1, Cc: stable): the four
   sites that drain a decoded data-server address list free
   da_remotestr and the entry but not da_netid.  Both layout drivers
   take that drain whenever nfs4_pnfs_ds_add() returned a data server
   already in the cache, which for a striping mount is nearly every
   GETDEVICEINFO.

 - Widen stripe_unit to 64 bits at its consumers rather than rejecting a
   value that does not fit in 32 (patch 2).  Both consumers now divide
   by the full value, with div64_u64() and div64_u64_rem().  The -EINVAL
   exit v2 added for the oversized case goes with it; the
   stripe_unit == 0 check is unchanged.

 - Trim the comment above the hashed-ness test (patch 15).  The lockless
   argument it summarized is in the commit message already.

 - Filter the deviceid reference query on NFS_I()->layout == lo, as the
   collection walker does (patch 17).  It compared lo->plh_inode against
   the inode it had just read out of that field, which is always true,
   so a detached layout could report a reference and wake the state
   manager for nothing.

 - Let a layout whose inode is being freed end the collection walk
   (patch 17).  NFS_LAYOUT_INODE_FREEING records an igrab() that has
   already failed, which is exactly the case the walk promises to abort
   with -EAGAIN, so skipping it silently shortened the list instead.

 - Re-arm the state manager after the deviceID delete recovery (patch
   20), as the delegation return in the same block does.  The recovery
   issues synchronous RPCs, and a manager thread that starts and exits
   while it runs clears NFS4CLNT_RUN_MANAGER on its way out.

Patches 1-7 are standalone fixes (Cc: stable).  Beyond the netid leak
and the stripe_unit width above: the CB_NOTIFY_DEVICEID decoder gated
consuming ndc_immediate on the layout type instead of the notification
type, so the flag was silently lost and any multi-item cnda_changes<>
array misaligned after the first entry, and it handed the array count
to the allocator without bounding it against the remaining XDR stream.
Read data-server selection truncated the file offset to 32 bits,
picking the wrong stripe's DS for availability probing and coalescing
above 4 GiB.  And page coalescing was bounded on a segment-relative
offset in both the flexfiles and files layouts, so an unaligned segment
let a coalesced I/O straddle a stripe boundary and send the bytes past
it to the wrong data server.

Patches 8-16 make CHANGE notifications work under live layouts.  RFC 8881
Section 12.2.10 has CB_NOTIFY_DEVICEID CHANGE exist precisely so a server
can re-point a deviceID without recalling the layouts that reference it,
but the client's only response today is to unhash the cached device --
which never reaches the references pinned inside the layout driver's
segments, so I/O keeps going to the old mapping until the layouts are
freed.  Each in-flight I/O is given its own device-node reference, the
mirror's pinned pointer becomes RCU-managed, and a new layout-driver
hook re-resolves the device in place, honoring ndc_immediate.  A
GETDEVICEINFO reply that raced a CHANGE is discarded rather than
installed stale, up to a bounded number of retries -- the epoch is
bumped once per notification, so an unbounded retry would let a server
drive GETDEVICEINFO traffic without limit.  Re-resolution is best
effort: a lookup that hit the cache just before the unhash can still
install that node after the walk has passed the stripe, which keeps a
valid-but-superseded mapping until the next notification.

Patches 17-20 implement the deviceID-deletion race of RFC 8881 Section
18.40.4: layouts still referencing a deleted deviceID are tested with
TEST_STATEID, revoked state is recovered, and the deletion is confirmed
with GETDEVICEINFO before the client ID is re-established.  A DELETE
that no live layout references keeps today's cheap path.

A conformant server reaches this path.  Section 20.12 lets it send the
DELETE once it has revoked every layout referring to the deviceID, and
a revocation is never announced, so the client's view of which layouts
are live is simply older than the server's.  The one case that is a
server fault is a GETDEVICEINFO reporting the device gone under a
layout the server still calls valid, and that is the one that
re-establishes the client ID; since that discards all state, it is
announced with a warning naming the server.

Patches 21-24 scale the device caches.  The global deviceid hash grows
from 32 to 256 buckets -- four deep at that scale rather than 32 -- for
2KB of BSS in nfsv4.ko, paid by every NFSv4 client rather than only by
striping deployments; and the per-net data-server cache moves from a
single list to hash buckets
keyed by the DS address set and NFS version, a second 256-entry table
costing 2KB per network namespace.  Keying on the set requires the
comparator to test set equality rather than the subset it tested before,
which also corrects an aliasing bug: because the caller passes the
cached list first, a cached data server whose address set was contained
in an incoming one was returned for that incoming set (one-directional
-- the reverse arrival order did not alias).  Its effect was lost path
diversity and a truncated remote string, not misdirected I/O, since
every address on a device's multipath list names the same server.
Last, the flexfiles driver gains a dataserver_nconnect module parameter
alongside its existing dataserver_timeo and dataserver_retrans knobs:
data-server clients otherwise inherit the MDS nconnect, which at 1024
data servers and nconnect=16 means 16k sockets and their slot tables,
for little gain on a workload striping across them anyway.  It defaults
to 0, preserving today's inherit-from-MDS behavior.

Tested against reffs, a notification-capable reference server, on a
7.3.0-rc1 kernel with KASAN, lockdep and PROVE_RCU, with the LAYOUTGET
reply-buffer series below also applied.  Every figure here is an exact
wire count from mountstats, or a record-by-record check of the
data-server backing files.

Striping: at W=2, placement is record-exact -- DS1 holds stripe 0 and
DS2 stripe 1, 1024/1024 blocks each, and the two backing files differ
with DS1's extent map landing on even logical blocks only, so the
stripe unit is confirmed at the byte level rather than inferred.  8 MiB
verifies clean at 131072 records.  The W=1 control shows the RFC 8435
Section 5.1 "W == 1 implies stripe_unit == 0" requirement through its
client-visible consequence: with no stripe boundary to chop on, writes
coalesce to 8 WRITEs of 1 MiB where W=2 issues 2048 of 4 KiB.

Notifications: each CHANGE variant (ndc_immediate true and false)
produces exactly one re-resolve and leaves the other device untouched,
with the superseded node freed on a workqueue and the device
re-resolved in place by the I/O thread itself.  A DELETE naming an
unreferenced deviceID takes the cheap path, freeing the node inline in
the callback thread with no TEST_STATEID.  A DELETE against a held
layout runs the Section 18.40.4 recovery -- TEST_STATEID, a confirming
GETDEVICEINFO, the device correctly kept -- while roughly 257,000 I/O
operations continue through it.  A 120-second storm of 30 triggers
racing 1,055,232 I/O operations drove 37 re-resolves and 12 race
recoveries with FREE_STATEID 0 and LAYOUTRETURN 0: re-resolution
happens in place under live layouts, with no recall and no layout
return.

Scale: 256 deviceIDs over 16 addresses cache exactly, stay cached
across a full cold re-read, decouple onto 16 data-server clients, and a
256-item batched CB_NOTIFY_DEVICEID chunks into 3 to fit the client's
back channel; a CHANGE naming every device refetches exactly 256.  The
same 256 deviceIDs on 256 distinct addresses instead give one
data-server client each, and that is where dataserver_nconnect earns
its place: at nconnect=4 the inherited setting opens 1280 sockets to
the data servers, and capping it at 1 opens 512 -- four data
connections per client against one -- with the same 256 exact device
lookups and no I/O errors either way.

No KASAN, lockdep or RCU splat in any phase, including teardown.
Lockdep stayed armed throughout: it never disabled itself, and its
tables grew under load (2147 to 2428 lock classes, 20808 to 27202
direct dependencies).

Not covered by that run: the 1000-device topology; a stripe_unit above
4 GiB, though the 64-bit divide is exercised on every striped I/O; and
targeted tests for patches 1 and 3, which were judged correct by
inspection.

A related series, "NFS: size the LAYOUTGET reply buffer for wide
flexfiles layouts", lifts the single-page LAYOUTGET reply buffer that
today caps a segment at roughly 28 stripes.  The two are independent and
apply cleanly in either order.

Benjamin Coddington (24):
  NFSv4/pnfs: Free the netid when draining a data-server address list
  NFSv4/flexfiles: Use the full 64-bit stripe_unit
  NFSv4/pnfs: bound the CB_NOTIFY_DEVICEID array count before allocating
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
  NFSv4/pnfs: Key the data-server cache by its address set and version
  NFSv4/flexfiles: Add a dataserver_nconnect cap

 fs/nfs/callback_proc.c                    |  21 +-
 fs/nfs/callback_xdr.c                     |   9 +-
 fs/nfs/client.c                           |   6 +-
 fs/nfs/filelayout/filelayout.c            |   8 +-
 fs/nfs/filelayout/filelayoutdev.c         |  19 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 385 ++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  46 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 199 ++++++-----
 fs/nfs/internal.h                         |   3 +-
 fs/nfs/netns.h                            |   5 +-
 fs/nfs/nfs3client.c                       |   9 +-
 fs/nfs/nfs4_fs.h                          |   3 +
 fs/nfs/nfs4client.c                       |   8 +-
 fs/nfs/nfs4proc.c                         | 128 +++++++
 fs/nfs/nfs4state.c                        |   7 +-
 fs/nfs/pnfs.c                             | 290 ++++++++++++++++
 fs/nfs/pnfs.h                             |  88 ++++-
 fs/nfs/pnfs_dev.c                         |  30 +-
 fs/nfs/pnfs_nfs.c                         | 108 ++++--
 include/linux/nfs_fs_sb.h                 |   4 +
 include/linux/nfs_xdr.h                   |   2 +
 21 files changed, 1088 insertions(+), 290 deletions(-)

base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
-- 
2.53.0

