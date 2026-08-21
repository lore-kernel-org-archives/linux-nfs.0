Received: from mail-oi1-f182.google.com (mail-oi1-f182.google.com [209.85.167.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C466F493636
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329772; cv=none; b=MojiBzI1UuTki4IWQpnRa04Y/a21qAVSv1g63trdIt9ef1gHZ8e90a9PaOkDg1a7WUXyPgnzWTYtGIzWjq9iPhdtbrQproN/pfVrC7oZ9NTk/7Iy0LFEIkpwH1NFQBfDRB2kUO9PMl0Kb9U7DqiOp6gSn3DeSJBg26+cSDipbvg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329772; c=relaxed/simple;
	bh=cPANrzh0jdiYtvw0nLmHmwM4pTWx+zm7/9e5cyymlAg=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=bQhbTcigewKadd1Ihh5/oGUrzQlV47v0C9VRaPIm2zwDDaVtirH4i28/i+rOdhAT64FoM2/UUbpegwthwV8kPkNy/QZ5kNCEkmO55qAanmkpOgUSDyWih+Acw45skQ3WekvCj8NW+ZuIs5F65fuKKAy/j6SFD0h4C9RVfPacWDg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=gj3ZvM5U; arc=none smtp.client-ip=209.85.167.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gj3ZvM5U"
Received: by mail-oi1-f182.google.com with SMTP id 5614622812f47-4b2ff8ca537so332843b6e.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329769; x=1787934569; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=4Uu24Ur3K54MUZgw6hLVjk6iO+5zxm0eRopkz603VDg=;
        b=gj3ZvM5UZNxqni2znAFZrpF0zkit4Q2TYIeZReZjZV/7H0FVPNB0EP8akOoIinHZWg
         0DDRNLVEmXh1kJvG5XGfL4Z02iy0SZlyTRyu0rCzeDXfCJCwQ6TCA8R5JgVfMWjCHMcM
         PMvVoz5bB4AKXaiOrRdk5MiRCs5XwzdOUuS8S3bKSrbz7dW9nCf68ZMyGsCpz2StsUcC
         pEBbIHQ8+YN+cUD56sNSjVsQsHwoVsd4RBXfpQVwySVL/A9sjyZg/XCOijQk3yNkUhWT
         aSP5vfXzPTxgeQ2+y71IrhCG2tYrDUlrFLCFFI0zKZ3PhcpR/Ut+HJG2tIHWDyDjsaR+
         ulLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329769; x=1787934569;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4Uu24Ur3K54MUZgw6hLVjk6iO+5zxm0eRopkz603VDg=;
        b=KKU8l5jQCYyrvho9yxB5z7gKQHZlVe3WZ6E392+HqCZbRl6JqUaVwaPn8ebU1fFbga
         6xgJXrFcXq7VdxxtboScmdyUdXJFQR42ej6tB6r7uSsEeUaE0OuZ16UIHIAGHXNwpPyy
         bTdly9U5NLDSECXIEHkw10GjSzIwCdicQLNKIHLnrrkzprrs1zb5pV5+G2cuLCsKMxy9
         U1lVmLGcDsmU+MqNA+gG7vtjyI2jQSITjqX8kqXLXjNQClM8Ryh6P/+UTiQM/4wJRvOj
         hY32fbeCrvaGNvW+M3Ak+5Ct+nJpYErASYtum4UBmhYv6TqQ11LjtmiOie+0cmiuCFoD
         kPfQ==
X-Gm-Message-State: AOJu0YzUwqdqNEjC47O5Th+R/k3YWnn0MSoRqCLHXRwGAS7rgJ5mA6Xk
	5WSsI9u+vigNb5PH6vMK4aS/PtTBMOEiD0Dbr8g0MNyFjMro5pxg1Z1u29Lhhkz4gTA=
X-Gm-Gg: AR+sD133Ta9NGu7JJECwQ3NN6SOqXBvzw56ODVw1xxJMAOGCxpKXmaYEVCRICrkT3Kn
	agMuKTeBbPQhY6ynQ0F66UKwBDvvSUlpeRQcbxe7KtX2d2++Be3s4KcL9UU5pt10jhn5g/Oc1pb
	KZPlWzYLAjm1JWVCj8Pm2L/AnDEu4tdneZZf/FaxnV1Voyay5XYoVFUBWEBMgKiG7d03Wv4kjG/
	WlrK3tqS35x2gSeOq7dcASnF0a8RISc2rZ5/fw+hnxRZFKwisZhTXyaLvz5nFroXdiietT5Cy+V
	YXCLJJ47NBAROMZWiXl6AYa4KSUrcdCcYOBf0aauYRot679C23h2PRTUwpt/ISp5bNtFmBCLsEI
	36kPaYHFwmCXaaimO8JhWJb4LGbdD2Mp+bhjGmn0SjEm2WEs2Y20178iD64INlPKE4nxA9onPU/
	PdJ8szo2juEKzlNl3am+6mlHu8CHRAdk20mDgvJ8C1wi4G85UzDX7LaurRxA2L0Z8+YvbAGqx0h
	9a7DqvcZySnBNBm6YYYNR2p
X-Received: by 2002:a05:6808:2512:b0:4b2:8e51:aac2 with SMTP id 5614622812f47-4b2ef19137dmr7471921b6e.8.1787329769159;
        Fri, 21 Aug 2026 09:29:29 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:28 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 00/23] NFS: flexfiles device notifications and caching for wide striped layouts
Date: Fri, 21 Aug 2026 12:29:04 -0400
Message-ID: <cover.1787327939.git.bcodding@hammerspace.com>
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

v1 posting:
  https://lore.kernel.org/linux-nfs/cover.1786653063.git.bcodding@hammerspace.com/

Changes since v1, in patch order:

 - Prepend two standalone fixes (patches 1-2), both preexisting in the
   striped-layout paths:
     * flexfiles: reject a stripe_unit that does not fit 32 bits.  The
       read and write paths divide by a u32 stripe_unit via do_div(), so a
       non-zero multiple of 4 GiB truncated to a zero divisor;
       ff_layout_alloc_lseg() only rejected exactly zero.  Rejecting with
       -EINVAL rather than the -EIO the surrounding decode errors use
       discards the layout and falls back to the MDS instead of failing
       the I/O -- which also changes the existing stripe_unit == 0 case,
       since it shares that exit.
     * CB_NOTIFY_DEVICEID: bound the notification array count against the
       remaining XDR stream before allocating, so a bogus count from the
       server cannot ask the allocator for an enormous array.

 - Read the RCU-managed device pointer with rcu_dereference() under
   rcu_read_lock() in ff_layout_mirror_prepare_stats() (patch 10).  It
   used rcu_dereference_protected() naming i_lock, which does not exclude
   the resolve path's cmpxchg -- that runs from I/O submission.

 - Redesign the reresolve_deviceid deferred-put contract (patches 11-12,
   14).  A device node is a shared, refcounted object that one re-resolve
   pass can unpin more than once (multiple stripes, or multiple layouts
   over a common data server), which a single list_head embedded in the
   node cannot express -- a second list_add() corrupts the list and the
   drain leaks the extra references.  Each dropped reference is now a
   nfs4_deviceid_put entry that the hook allocates and the walker frees,
   taken before the pointer is exchanged out so an allocation failure
   leaves the reference pinned rather than lost.

 - Do not gate the re-resolve walk on pnfs_layout_is_valid() (patch 11).
   A header with NFS_LAYOUT_INVALID_STID set can still pin the stale node
   through draining lsegs, the cached device is already unhashed so
   nothing re-resolves it later, and a subsequent LAYOUTGET on that header
   can pick the mirror back up.  Un-pinning does not need the stateid.
   The collection walker keeps its check, which its layout-header
   reference does depend on.

 - Use hlist_unhashed_lockless() when testing whether a superseded node is
   still hashed (patch 14): the hook does not hold nfs4_deviceid_lock, and
   __hlist_del() stores a neighbour's pprev with WRITE_ONCE().

 - Scope the CHANGE/GETDEVICEINFO race epoch per-nfs_client instead of a
   single global counter (patch 15), so a CHANGE on one server no longer
   forces unrelated servers' in-flight device lookups to discard and
   refetch, and bound the refetch: the epoch moves at the server's rate,
   so an unbounded retry let a server drive GETDEVICEINFO traffic without
   limit.

 - Harden the deviceid-ref collection walker (patch 16): allocate the ref
   only after a layout matches, move pnfs_put_layout_hdr() out of the RCU
   read-side critical section (it can send a layoutreturn and sleep), and
   report a partial list rather than silently returning a short one the
   caller would read as "no references" -- -ENOMEM on allocation failure,
   -EAGAIN on an inode that can no longer be grabbed.  The layout-header
   reference is now justified by NFS_I()->layout == lo under i_lock, which
   pnfs_put_layout_hdr() clears in the same critical section that drops
   the count to zero; the previous argument, that a header reaches a zero
   refcount only once NFS_LAYOUT_INVALID_STID is set, is not true -- a
   full LAYOUTRETURN resets the stateid rather than invalidating it.

 - Fix deviceID delete recovery (patch 17): delete a deviceID that no
   layout references any more (the referring layouts were returned before
   recovery ran), and count only a layout actually invalidated as revoked
   -- a stale stateid that no longer matches its layout no longer confirms
   the delete on its own.  Treat NFS4ERR_OLD_STATEID as "not revoked" and
   block the delete on any answer that resolves neither way: Section
   18.48.3 lists OLD_STATEID among TEST_STATEID's answers, and it was
   falling into the default arm, so one revoked layout plus one
   OLD_STATEID answer deleted a deviceID a live layout still referenced,
   with no GETDEVICEINFO confirmation.  Pair the layout-stateid
   invalidation with nfs_commit_inode(), as every other such site does.

 - Re-establish the client ID with nfs4_reset_all_state() (patch 18).
   nfs4_schedule_lease_recovery() sets NFS4CLNT_CHECK_LEASE, which the
   state manager turns into a lease renewal; on the healthy session this
   recovery runs over, that renewal succeeds and the EXCHANGE_ID Section
   18.40.4 prescribes was never sent.  The escalation is now announced
   with a rate-limited warning, since it discards all client state.

 - Bump the deviceid change epoch for DELETE as well as CHANGE (patch 19),
   so a GETDEVICEINFO already in flight cannot re-cache a device the
   notification has just invalidated.

Patches 1-6 are standalone fixes (Cc: stable) for latent bugs in the
striped-layout paths.  Beyond the two above: the CB_NOTIFY_DEVICEID
decoder gated consuming ndc_immediate on the layout type instead of the
notification type, so the flag was silently lost and any multi-item
cnda_changes<> array misaligned after the first entry.  Read data-server
selection truncated the file offset to 32 bits, picking the wrong
stripe's DS for availability probing and coalescing above 4 GiB.  And
page coalescing was bounded on a segment-relative offset in both the
flexfiles and files layouts, so an unaligned segment let a coalesced I/O
straddle a stripe boundary and send the bytes past it to the wrong data
server.

Patches 7-15 make CHANGE notifications work under live layouts.  RFC 8881
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

Patches 16-19 implement the deviceID-deletion race of RFC 8881 Section
18.40.4: layouts still referencing a deleted deviceID are tested with
TEST_STATEID, revoked state is recovered, and the deletion is confirmed
with GETDEVICEINFO before the client ID is re-established.  A DELETE
that no live layout references keeps today's cheap path.

This is not faulty-server handling.  Section 20.12 forbids the DELETE
while the client holds a referring layout, but it is equally satisfied
once the server has revoked those layouts, and a revocation is never
announced -- so a conformant server does reach this path, and the
client's view of which layouts are live is simply older than the
server's.  Only the case where GETDEVICEINFO then reports the device
gone under a layout the server still calls valid is a server fault,
and that is the one that re-establishes the client ID; since that
discards all state, it is announced with a warning naming the server.

Patches 20-23 scale the device caches.  The global deviceid hash grows
from 32 to 256 buckets -- four deep at that scale rather than 32 -- for
2KB of BSS in nfsv4.ko, paid by every NFSv4 client rather than only by
striping deployments; and the per-net data-server cache moves from a
single list to hash buckets
keyed by the DS address set, a second 256-entry table costing 2KB per
network namespace.  Keying on the set requires the comparator
to test set equality rather than the subset it tested before, which also
corrects an aliasing bug: because the caller passes the cached list
first, a cached data server whose address set was contained in an
incoming one was returned for that incoming set (one-directional -- the
reverse arrival order did not alias).  Its effect was lost path
diversity and a truncated remote string, not misdirected I/O, since
every address on a device's multipath list names the same server.
Last, the flexfiles driver gains a dataserver_nconnect module parameter
alongside its existing dataserver_timeo and dataserver_retrans knobs:
data-server clients otherwise inherit the MDS nconnect, which at 1024
data servers and nconnect=16 means 16k sockets and their slot tables,
for little gain on a workload striping across them anyway.  It defaults
to 0, preserving today's inherit-from-MDS behavior.

Tested against reffs, a notification-capable reference server, on a
KASAN + lockdep + PROVE_RCU kernel.  Every figure here is an exact wire
count from mountstats, or a record-by-record check of the data-server
backing files.

Striping: at W=2, placement is record-exact -- DS1 holds stripe 0 and
DS2 stripe 1, 1024/1024 blocks each.  The W=1 control shows the RFC
8435 Section 5.1 "W == 1 implies stripe_unit == 0" requirement through
its client-visible consequence: with no stripe boundary to chop on,
writes coalesce to 8 WRITEs of exactly 1024 KiB where W=2 issues 4096
small ones.

Notifications: each CHANGE variant (ndc_immediate true and false)
produces exactly one re-resolve and leaves the other device untouched.
A DELETE naming an unreferenced deviceID takes the cheap path, with no
TEST_STATEID.  A DELETE against a held layout runs the Section 18.40.4
recovery -- TEST_STATEID twice, a confirming GETDEVICEINFO, the device
correctly kept -- while 436 I/O operations continue through it.  A
120-second storm of 30 triggers racing 4872 I/O operations drove 44
re-resolves and 24 race recoveries with FREE_STATEID 0 and LAYOUTRETURN
0: re-resolution happens in place under live layouts, with no recall
and no layout return.

Scale: 256 deviceIDs over 16 addresses cache exactly, stay cached
across a full cold re-read, decouple onto 16 data-server clients, and a
256-item batched CB_NOTIFY_DEVICEID chunks into 3 to fit the client's
back channel.

No KASAN, lockdep or RCU splat in any phase, including teardown.
Lockdep stayed armed throughout: it never disabled itself, and its
tables grew under load (2154 to 2366 lock classes, 21028 to 24880
direct dependencies).

Not covered by that run: the 256-distinct-address topology, which is
what exercises the nconnect socket multiplier and the
dataserver_nconnect cap of patch 23; the 1000-device topology; and
targeted tests for patches 1 and 2, which were judged correct by
inspection.

A related series, "NFS: size the LAYOUTGET reply buffer for wide
flexfiles layouts", lifts the single-page LAYOUTGET reply buffer that
today caps a segment at roughly 28 stripes.  The two are independent and
apply cleanly in either order.

Benjamin Coddington (23):
  NFSv4/flexfiles: reject a stripe_unit that does not fit 32 bits
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
  NFSv4/pnfs: Key the data-server cache by its address set
  NFSv4/flexfiles: Add a dataserver_nconnect cap

 fs/nfs/callback_proc.c                    |  21 +-
 fs/nfs/callback_xdr.c                     |   9 +-
 fs/nfs/client.c                           |   6 +-
 fs/nfs/filelayout/filelayout.c            |   8 +-
 fs/nfs/filelayout/filelayoutdev.c         |   2 +-
 fs/nfs/flexfilelayout/flexfilelayout.c    | 381 ++++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  44 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 180 ++++++----
 fs/nfs/internal.h                         |   3 +-
 fs/nfs/netns.h                            |   5 +-
 fs/nfs/nfs3client.c                       |   9 +-
 fs/nfs/nfs4_fs.h                          |   3 +
 fs/nfs/nfs4client.c                       |   7 +-
 fs/nfs/nfs4proc.c                         | 128 ++++++++
 fs/nfs/nfs4state.c                        |   5 +-
 fs/nfs/pnfs.c                             | 291 +++++++++++++++++
 fs/nfs/pnfs.h                             |  87 ++++-
 fs/nfs/pnfs_dev.c                         |  30 +-
 fs/nfs/pnfs_nfs.c                         |  86 ++++-
 include/linux/nfs_fs_sb.h                 |   4 +
 include/linux/nfs_xdr.h                   |   2 +
 21 files changed, 1065 insertions(+), 246 deletions(-)


base-commit: 8d3ae59288f1e7d58d76558a6ee96d533bc5019f
-- 
2.53.0

