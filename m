Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792466707;
	b=IxAOW/ix92deeBzvvQ96dN1mRmueZCoHsB6sXeCtgPP4MzlFuOADOk6am7Maj/Xf0i8j
	 PsMNPosq+OApFHQ2yl+kQ1tt2lGqeh3kqfwmMbGNMjIjg2pRFc3xInuxj8VRxsDHwO0S2
	 Vz1U9yc6NFnsIYu+tAvkX6D9XdnZfinJboq/CnvafQTPT/+Z55f7fUq3XbHAFy/7ovEr4
	 v1Gb9OjQJdj6PsWvx4iR5YCKRXrsmod2wjrlssqprjL0h/sxbufEpFY0Abq7a2OM6X1Mr
	 LMxQZDxMJSXDRVWsXR7pyTh94/SZDk3HFnhvDEF8+xrYrnq90w7i+EVTL1v8aZwJfNw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792466707;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=FNE4gDI1BUcDx1gOC04y4qzKR1ouXNMi/Xg3zpGmxAE=;
	b=0ND8FXewCrbhSzoWZ2eZvCVIb+oddjkFvpxIyNgNCr+gUHiFlzg5nfpSzd+FjSEG23M0
	 BLSgq00wn3tf4qbASWJ1EEd6qZsXQmtnxOXrjZtWB3cBMngqGVCjVRUjh6DXOy3/PVP8t
	 0nudRyTBkxscOHfj6tNgqpgUKQH1Q41VHiRwvHLa7zgiDDSYtuvaXPzaFh9vBaNjLrETb
	 zwMfgvthWnMFZK+XCNMvoOStOSfZGOpOfxOAVWGNl4g/bi/hUgmWKGyYaFn6HKyWHdi5C
	 DWRkqusRWheX3hX3ey2B/RdnSoju9w/0NnwHrIv6GLCXN5Gf6ci2tlChVHWtnC05VIQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xv4fy6O2;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27270606A31A;
	Tue, 20 Oct 2026 03:25:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Xv4fy6O2
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5B76B1F000C5;
	Tue, 20 Oct 2026 03:25:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792466706;
	bh=FNE4gDI1BUcDx1gOC04y4qzKR1ouXNMi/Xg3zpGmxAE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=Xv4fy6O2j3QZXZbXjWjDpZoDxWOyx6WJZdEy3wRCjw5fQtKqdoEwwmnlAGMAxvTYG
	 1Z5aKKEmyjWz3ZIpxiHUnQGt0f9BOyGOWQpqYV40/pXuZXhrLTDrC8uyAy7Wdg4dwd
	 ILJukIug5bUa5bfxxRhBeUbRx88ln2UDMa+5RhfNhaJD5KmqNpJzA2vrCoJeHxnWIx
	 eRutIumJcINO7+ZJgy/OTxqVF9P9JUx4FiGMTwdJ8P94/JFb+ERw+oJl95Gdokqzsw
	 aYJr6Zwh8ABQg4oBvlNQgp1QelnDVsW5PerixE3Q7BRof/3HqG3uzxh3McdaSqYYc/
	 1pWsAOcC7reiA==
Date: Mon, 19 Oct 2026 23:25:05 -0400
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Christoph Hellwig <hch@lst.de>, Jens Axboe <axboe@kernel.dk>,
	Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org,
	linux-fsdevel@vger.kernel.org
Subject: [PATCH draft-v6 1/6] NFSD: add tracing for how direct-mode READ and
 WRITE are serviced
Message-ID: <atbfEbgMU6UGkn2X@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
 <20261019150725.1507-2-snitzer@kernel.org>
 <f39bfe92-8676-4241-bb4e-bccd838ab99b@slotpi15m67>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f39bfe92-8676-4241-bb4e-bccd838ab99b@slotpi15m67>

On Mon, Oct 19, 2026 at 02:33:47PM -0400, Chuck Lever wrote:
> On Mon, Oct 19, 2026, at 11:07 AM, Mike Snitzer wrote:
> > Add:
> >
> >  - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
> >    segment is issued.  It records the advertised offset and memory
> >    alignments, the payload's offset within its first page, the start,
> >    middle and end segment sizes, a disposition naming the path taken
> >    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
> >    whether buffered segments are issued IOCB_DONTCACHE.
> 
> Let's define a single event class and then use DEFINE_EVENT per outcome,
> rather than one event with a disposition field. You'll notice this
> pattern is used elsewhere in trace.h.
> 
> So nfsd_write_dio_class with the alignment and segment-size fields, and
> nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle,
> _mem_misaligned fired at the site that makes each decision. An admin
> chasing "why isn't this direct" then enables only the decline events.
> 
> Also, let's give the READ side the same treatment so admins can see
> the decisions that prevent reads from going direct.

Done for v6.  nfsd_write_dio_class has the alignment and segment-size
fields, and nfsd_write_dio_direct, _no_alignment, _too_small,
_no_middle and _mem_misaligned each fire where that decision is made.
For READs, nfsd_read_dio_class has nfsd_read_dio_no_alignment,
_too_small, _pages_in_use and _not_last_op, one for each way
nfsd_direct_read_ok() can decline; a READ that does go direct is
already reported by nfsd_read_direct.  The disposition enum is gone,
so nothing from vfs.h ends up in a TP_PROTO.
 
> With the per-outcome events in place, the dontcache field on the
> per-WRITE event is redundant: nfsd_write_direct/_dontcache/_vector
> already say how each segment was issued. As it stands it also
> misreports the direct middle, which carries dontcache_flags
> regardless of direct_misaligned_dontcache. Consider dropping that
> field.

Dropped.

> A few less critical items:
> 
> - nfsd_write_dontcache and nfsd_write_vector are emitted only from
>   nfsd_direct_write(). The io_cache_write=dontcache and =buffered
>   paths in nfsd_vfs_write() emit neither, so the new DONTCACHE event
>   never fires in DONTCACHE mode and the commit message's "now fires
>   only for normal buffered I/O" isn't right either. nfsd_iter_read()
>   covers all three modes; please make the WRITE side match.

nfsd_vfs_write() now emits them for io_cache_write=dontcache and
=buffered too, so the WRITE side matches nfsd_iter_read(), and the
commit message no longer says "only for normal buffered I/O".

> - mem_offset records bvec[0].bv_offset, but the mem_misaligned test
>   is on bv_offset + prefix. With prefix=100 the event shows
>   mem_offset=0 next to a mem_misaligned verdict. Record the quantity
>   that was actually tested.

It now records the offset that the test checks: for a WRITE whose
payload starts 132 bytes into its page with a 2144-byte start, the
event shows mem_offset=2276.  A decision made before the middle is
placed records the offset of the payload's start.
 
> - The doc says iomap_dio_invalidate_fail "reports an O_DIRECT middle
>   segment that the filesystem serviced with buffered IO instead". It
>   reports one cause of that, on iomap filesystems only. ext4's
>   fallbacks are silent. Let's narrow the wording.

Narrowed: it reports one reason for that, page cache over the segment
that could not be invalidated, and only filesystems that use iomap for
direct I/O emit it; other fallbacks, such as ext4's, are not traced.

> - The doc talks about start/middle/end segments while the event
>   prints prefix/middle/suffix. Let's pick one vocabulary.

The events now print start, middle and end, as the doc says.

> Jeff's comment about the ki_flags test in the hot path stands on its
> own. I'll leave that between you and Jeff.

Thanks to both of you for the review.

Please see the revised 1/6 below, which I would like to pre-check with
you and Jeff before posting the patchset in full again as v6 (with
this 1/6 applied, 2/6 to 5/6 are unchanged, and 6/6 only differs in
context, from its rebase on the new 1/6).  Feel free to pick it up it
looks good, either way I'll wait to hear back before posting v6.

I was curious about the resulting tracing output so I tested with 3
47008 IOs in NFSD io_cache_write modes 0, 1 and 2; here is the result:

io_cache_write=0 (buffered):
nfsd_write_start: xid=0xaf6f21f3 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_opened: xid=0xaf6f21f3 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_vector: xid=0xaf6f21f3 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_io_done: xid=0xaf6f21f3 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_done: xid=0xaf6f21f3 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_start: xid=0xb06f21f3 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_opened: xid=0xb06f21f3 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_vector: xid=0xb06f21f3 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_io_done: xid=0xb06f21f3 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_done: xid=0xb06f21f3 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_start: xid=0xb16f21f3 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_opened: xid=0xb16f21f3 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_vector: xid=0xb16f21f3 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_io_done: xid=0xb16f21f3 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_done: xid=0xb16f21f3 fh_hash=0xbb2b802f offset=94016 len=47008

io_cache_write=1 (DONTCACHE):
nfsd_write_start: xid=0xddf0249b fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_opened: xid=0xddf0249b fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_dontcache: xid=0xddf0249b fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_io_done: xid=0xddf0249b fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_done: xid=0xddf0249b fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_start: xid=0xdef0249b fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_opened: xid=0xdef0249b fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_dontcache: xid=0xdef0249b fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_io_done: xid=0xdef0249b fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_done: xid=0xdef0249b fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_start: xid=0xdff0249b fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_opened: xid=0xdff0249b fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_dontcache: xid=0xdff0249b fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_io_done: xid=0xdff0249b fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_done: xid=0xdff0249b fh_hash=0xbb2b802f offset=94016 len=47008

io_cache_write=2 (DIRECT):
nfsd_write_start: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_opened: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_dio_direct: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=47008 offset_align=4096 mem_align=4 mem_offset=132 start=0 middle=45056 end=1952
nfsd_write_direct: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=45056
nfsd_write_dontcache: xid=0x86990005 fh_hash=0xbb2b802f offset=45056 len=1952
nfsd_write_io_done: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_done: xid=0x86990005 fh_hash=0xbb2b802f offset=0 len=47008
nfsd_write_start: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_opened: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_dio_direct: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=47008 offset_align=4096 mem_align=4 mem_offset=2276 start=2144 middle=40960 end=3904
nfsd_write_dontcache: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=2144
nfsd_write_direct: xid=0x87990005 fh_hash=0xbb2b802f offset=49152 len=40960
nfsd_write_dontcache: xid=0x87990005 fh_hash=0xbb2b802f offset=90112 len=3904
nfsd_write_io_done: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_done: xid=0x87990005 fh_hash=0xbb2b802f offset=47008 len=47008
nfsd_write_start: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_opened: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_dio_direct: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=47008 offset_align=4096 mem_align=4 mem_offset=324 start=192 middle=45056 end=1760
nfsd_write_dontcache: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=192
nfsd_write_direct: xid=0x88990005 fh_hash=0xbb2b802f offset=94208 len=45056
nfsd_write_dontcache: xid=0x88990005 fh_hash=0xbb2b802f offset=139264 len=1760
nfsd_write_io_done: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=47008
nfsd_write_done: xid=0x88990005 fh_hash=0xbb2b802f offset=94016 len=47008

In DIRECT mode, mem_offset is where the middle starts within its
page: the payload starts 132 bytes in, so 132, 132 + 2144 = 2276 and
132 + 192 = 324.

Changes since v5:
- 1/6: the per-I/O events (nfsd_read_vector, nfsd_read_dontcache,
  nfsd_write_direct, nfsd_write_dontcache, nfsd_write_vector) take the
  kiocb flags and test them in TP_CONDITION(), so the flags are tested
  only while an event is enabled (Jeff Layton).
- 1/6: nfsd_write_dio_split, with its disposition and dontcache fields,
  is replaced by an event class with one event per direct-mode WRITE
  decision, emitted where the decision is made: nfsd_write_dio_direct,
  _no_alignment, _too_small, _no_middle and _mem_misaligned.  READs get
  the same: nfsd_read_dio_no_alignment, _too_small, _pages_in_use and
  _not_last_op.  The WRITE events now also fire for
  io_cache_write=dontcache and =buffered, mem_offset is the offset the
  memory alignment test checks, the events print start, middle and end
  as the documentation says, and the documentation of
  iomap_dio_invalidate_fail is narrowed to what it reports (Chuck
  Lever).
- 2/6 to 5/6: unchanged.
- 6/6: no change of its own; its context differs from the rebase on
  the new 1/6.

Thanks,
Mike

From: Mike Snitzer <snitzer@kernel.org>
Date: Thu, 17 Sep 2026 18:06:39 -0400
Subject: [PATCH draft-v6 1/6] NFSD: add tracing for how direct-mode READ and WRITE are serviced

In a direct I/O mode, a READ or a WRITE segment may still be issued
with DONTCACHE or normal buffered I/O.  nfsd_{read,write}_direct and
nfsd_{read,write}_vector neither tell those two apart nor say why a
request did not go direct.

Add:

 - nfsd_read_dontcache and nfsd_write_dontcache.
   nfsd_{read,write}_vector now report normal buffered I/O only, and
   the WRITE events fire in every io_cache_write mode, as the READ
   events do.  These events test the kiocb flags in TP_CONDITION(), so
   only while they are enabled.

 - An event per direct-mode WRITE decision, emitted where it is made:
   nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle and
   _mem_misaligned.  Each records the alignments, the start, middle and
   end segment sizes, and the memory offset the alignment test checks.

 - An event per reason a direct-mode READ is not issued as O_DIRECT:
   nfsd_read_dio_no_alignment, _too_small, _pages_in_use and
   _not_last_op.

Document them in nfsd-io-modes.rst, along with iomap's
iomap_dio_invalidate_fail.

Assisted-by: LLM
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 .../filesystems/nfs/nfsd-io-modes.rst         |  73 +++++++-
 fs/nfsd/trace.h                               | 174 +++++++++++++++++-
 fs/nfsd/vfs.c                                 |  91 ++++++---
 3 files changed, 307 insertions(+), 31 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index 0a5f4ef14a8a..0eef646a2423 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -143,10 +143,9 @@ Misaligned WRITE:
     direct_misaligned_dontcache is N (below). The flag has no effect on
     the O_DIRECT segment unless the filesystem services it with buffered
     IO instead, as XFS does when it cannot invalidate page cache that
-    overlaps the segment. The iomap_dio_invalidate_fail trace event
-    reports such a fallback. A split FILE_SYNC or DATA_SYNC WRITE is
-    persisted once, after all of its segments are written, not once per
-    segment.
+    overlaps the segment (see iomap_dio_invalidate_fail under Tracing).
+    A split FILE_SYNC or DATA_SYNC WRITE is persisted once, after all of
+    its segments are written, not once per segment.
 
     If NFSD does not split a WRITE, it issues the whole WRITE
     as a single DONTCACHE buffered IO (normal buffered IO if the
@@ -171,21 +170,81 @@ Misaligned WRITE:
 Tracing:
     The nfsd_read_direct trace event shows how NFSD expands any
     misaligned READ to the next DIO-aligned block (on either end of the
-    original READ, as needed).
+    original READ, as needed). A READ that is serviced with buffered IO
+    instead emits nfsd_read_dontcache (DONTCACHE buffered IO) or
+    nfsd_read_vector (normal buffered IO), in any IO mode.
+
+    In NFSD_IO_DIRECT mode, a READ that is not issued as O_DIRECT also
+    emits an event, where NFSD makes that decision, naming the reason::
+
+      nfsd_read_dio_no_alignment  the filesystem advertises no DIO read
+                                  alignment
+      nfsd_read_dio_too_small     smaller than the DIO read offset
+                                  alignment
+      nfsd_read_dio_pages_in_use  an earlier operation in the same
+                                  COMPOUND already put data in the
+                                  reply's pages
+      nfsd_read_dio_not_last_op   an NFSv4 READ that is not the last
+                                  operation of its COMPOUND
 
     This combination of trace events is useful for READs::
 
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_vector/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_dontcache/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_direct/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_io_done/enable
       echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_read/enable
+      for e in /sys/kernel/tracing/events/nfsd/nfsd_read_dio_*; do
+              echo 1 > $e/enable
+      done
 
-    The nfsd_write_direct trace event shows how NFSD splits a given
-    misaligned WRITE into a DIO-aligned middle segment.
+    In NFSD_IO_DIRECT mode, each WRITE emits one event, where NFSD
+    decides whether to split it, naming the outcome. Each records the
+    alignments the filesystem advertised, the sizes of the start,
+    middle and end segments (zero where not yet computed), and the
+    offset within its page at which the middle segment starts, which is
+    what the memory alignment test checks (for a decision made before
+    the middle is placed, the offset at which the payload starts)::
+
+      nfsd_write_dio_direct          split: the aligned middle segment
+                                     uses O_DIRECT
+      nfsd_write_dio_no_alignment    the filesystem advertises no DIO
+                                     alignment; not split
+      nfsd_write_dio_too_small       smaller than the larger of the
+                                     offset and memory alignments; not
+                                     split
+      nfsd_write_dio_no_middle       no aligned middle, or a misaligned
+                                     start or end with a middle smaller
+                                     than direct_misaligned_min_bytes
+                                     bytes; not split
+      nfsd_write_dio_mem_misaligned  the middle does not start at a
+                                     memory address aligned to the
+                                     block device's dma_alignment; not
+                                     split
+
+    Enabling all of them but nfsd_write_dio_direct shows only the WRITEs
+    that are not split, and why.
+
+    Each segment of a WRITE in NFSD_IO_DIRECT mode, and each WRITE in
+    the other modes, emits nfsd_write_direct (O_DIRECT),
+    nfsd_write_dontcache (DONTCACHE buffered IO) or nfsd_write_vector
+    (normal buffered IO).
 
     This combination of trace events is useful for WRITEs::
 
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_opened/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_direct/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dontcache/enable
+      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_vector/enable
       echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_io_done/enable
       echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_write/enable
+      echo 1 > /sys/kernel/tracing/events/iomap/iomap_dio_invalidate_fail/enable
+      for e in /sys/kernel/tracing/events/nfsd/nfsd_write_dio_*; do
+              echo 1 > $e/enable
+      done
+
+    iomap_dio_invalidate_fail reports one reason a filesystem services
+    an O_DIRECT segment with buffered IO instead: page cache over the
+    segment that it could not invalidate. Only a filesystem that uses
+    iomap for direct IO emits it, and other fallbacks, such as ext4's
+    own, are not traced.
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e0908cb21c4e..d41832e49a74 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -500,19 +500,187 @@ DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
 
 DEFINE_NFSD_IO_EVENT(read_start);
 DEFINE_NFSD_IO_EVENT(read_splice);
-DEFINE_NFSD_IO_EVENT(read_vector);
 DEFINE_NFSD_IO_EVENT(read_direct);
 DEFINE_NFSD_IO_EVENT(read_io_done);
 DEFINE_NFSD_IO_EVENT(read_done);
 DEFINE_NFSD_IO_EVENT(write_start);
 DEFINE_NFSD_IO_EVENT(write_opened);
-DEFINE_NFSD_IO_EVENT(write_direct);
-DEFINE_NFSD_IO_EVENT(write_vector);
 DEFINE_NFSD_IO_EVENT(write_io_done);
 DEFINE_NFSD_IO_EVENT(write_done);
+
+/*
+ * How a READ or a WRITE segment is issued, told apart by the kiocb flags it
+ * is issued with.  Each event's condition is evaluated only while that
+ * event is enabled.
+ */
+DECLARE_EVENT_CLASS(nfsd_io_kiocb_class,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh	*fhp,
+		 u64		offset,
+		 u32		len,
+		 int		ki_flags),
+	TP_ARGS(rqstp, fhp, offset, len, ki_flags),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(u64, offset)
+		__field(u32, len)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->len = len;
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%llu len=%u",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->len)
+)
+
+#define DEFINE_NFSD_IO_KIOCB_EVENT(name, cond)			\
+DEFINE_EVENT_CONDITION(nfsd_io_kiocb_class, nfsd_##name,	\
+	TP_PROTO(struct svc_rqst *rqstp,			\
+		 struct svc_fh	*fhp,				\
+		 u64		offset,				\
+		 u32		len,				\
+		 int		ki_flags),			\
+	TP_ARGS(rqstp, fhp, offset, len, ki_flags),		\
+	TP_CONDITION(cond))
+
+DEFINE_NFSD_IO_KIOCB_EVENT(read_vector, !(ki_flags & IOCB_DONTCACHE));
+DEFINE_NFSD_IO_KIOCB_EVENT(read_dontcache, ki_flags & IOCB_DONTCACHE);
+DEFINE_NFSD_IO_KIOCB_EVENT(write_direct, ki_flags & IOCB_DIRECT);
+DEFINE_NFSD_IO_KIOCB_EVENT(write_dontcache,
+			   (ki_flags & (IOCB_DIRECT | IOCB_DONTCACHE)) ==
+			   IOCB_DONTCACHE);
+DEFINE_NFSD_IO_KIOCB_EVENT(write_vector,
+			   !(ki_flags & (IOCB_DIRECT | IOCB_DONTCACHE)));
 DEFINE_NFSD_IO_EVENT(commit_start);
 DEFINE_NFSD_IO_EVENT(commit_done);
 
+/*
+ * Whether a direct-mode WRITE is split to issue its aligned middle
+ * O_DIRECT, and if not, why not: one event per outcome, each emitted where
+ * that decision is made.  start, middle and end are the sizes of the
+ * segments, zero where not yet computed.  mem_offset is the offset within
+ * its page at which the middle segment starts, which is what the memory
+ * alignment test checks; for a decision made before the middle is placed,
+ * the offset of the payload's start.
+ */
+DECLARE_EVENT_CLASS(nfsd_write_dio_class,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh *fhp,
+		 u64 offset,
+		 u32 len,
+		 u32 offset_align,
+		 u32 mem_align,
+		 u32 mem_offset,
+		 u32 start,
+		 u32 middle,
+		 u32 end),
+	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align, mem_offset,
+		start, middle, end),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(u64, offset)
+		__field(u32, len)
+		__field(u32, offset_align)
+		__field(u32, mem_align)
+		__field(u32, mem_offset)
+		__field(u32, start)
+		__field(u32, middle)
+		__field(u32, end)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->len = len;
+		__entry->offset_align = offset_align;
+		__entry->mem_align = mem_align;
+		__entry->mem_offset = mem_offset;
+		__entry->start = start;
+		__entry->middle = middle;
+		__entry->end = end;
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%llu len=%u "
+		  "offset_align=%u mem_align=%u mem_offset=%u "
+		  "start=%u middle=%u end=%u",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->len,
+		  __entry->offset_align, __entry->mem_align,
+		  __entry->mem_offset,
+		  __entry->start, __entry->middle, __entry->end)
+);
+
+#define DEFINE_NFSD_WRITE_DIO_EVENT(name)				\
+DEFINE_EVENT(nfsd_write_dio_class, nfsd_write_dio_##name,		\
+	TP_PROTO(struct svc_rqst *rqstp,				\
+		 struct svc_fh *fhp,					\
+		 u64 offset,						\
+		 u32 len,						\
+		 u32 offset_align,					\
+		 u32 mem_align,						\
+		 u32 mem_offset,					\
+		 u32 start,						\
+		 u32 middle,						\
+		 u32 end),						\
+	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align,	\
+		mem_offset, start, middle, end))
+
+DEFINE_NFSD_WRITE_DIO_EVENT(direct);
+DEFINE_NFSD_WRITE_DIO_EVENT(no_alignment);
+DEFINE_NFSD_WRITE_DIO_EVENT(too_small);
+DEFINE_NFSD_WRITE_DIO_EVENT(no_middle);
+DEFINE_NFSD_WRITE_DIO_EVENT(mem_misaligned);
+
+/*
+ * Why a direct-mode READ is not issued O_DIRECT: one event per reason,
+ * each emitted where that decision is made.  A READ that is issued
+ * O_DIRECT is reported by nfsd_read_direct.
+ */
+DECLARE_EVENT_CLASS(nfsd_read_dio_class,
+	TP_PROTO(struct svc_rqst *rqstp,
+		 struct svc_fh *fhp,
+		 u64 offset,
+		 u32 len,
+		 u32 offset_align),
+	TP_ARGS(rqstp, fhp, offset, len, offset_align),
+	TP_STRUCT__entry(
+		__field(u32, xid)
+		__field(u32, fh_hash)
+		__field(u64, offset)
+		__field(u32, len)
+		__field(u32, offset_align)
+	),
+	TP_fast_assign(
+		__entry->xid = be32_to_cpu(rqstp->rq_xid);
+		__entry->fh_hash = knfsd_fh_hash(&fhp->fh_handle);
+		__entry->offset = offset;
+		__entry->len = len;
+		__entry->offset_align = offset_align;
+	),
+	TP_printk("xid=0x%08x fh_hash=0x%08x offset=%llu len=%u "
+		  "offset_align=%u",
+		  __entry->xid, __entry->fh_hash,
+		  __entry->offset, __entry->len, __entry->offset_align)
+);
+
+#define DEFINE_NFSD_READ_DIO_EVENT(name)				\
+DEFINE_EVENT(nfsd_read_dio_class, nfsd_read_dio_##name,		\
+	TP_PROTO(struct svc_rqst *rqstp,				\
+		 struct svc_fh *fhp,					\
+		 u64 offset,						\
+		 u32 len,						\
+		 u32 offset_align),					\
+	TP_ARGS(rqstp, fhp, offset, len, offset_align))
+
+DEFINE_NFSD_READ_DIO_EVENT(no_alignment);
+DEFINE_NFSD_READ_DIO_EVENT(too_small);
+DEFINE_NFSD_READ_DIO_EVENT(pages_in_use);
+DEFINE_NFSD_READ_DIO_EVENT(not_last_op);
+
 DECLARE_EVENT_CLASS(nfsd_err_class,
 	TP_PROTO(struct svc_rqst *rqstp,
 		 struct svc_fh	*fhp,
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 32136cd32af9..9219f8eb386d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1238,24 +1238,39 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				eof, host_err);
 }
 
-static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file *nf,
+static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
+				struct nfsd_file *nf, loff_t offset,
 				unsigned long count)
 {
+	u32 offset_align = nf->nf_dio_read_offset_align;
+
 	/* When dio_read_offset_align is zero, dio is not supported */
-	if (!nf->nf_dio_read_offset_align)
+	if (!offset_align) {
+		trace_nfsd_read_dio_no_alignment(rqstp, fhp, offset, count,
+						 offset_align);
 		return false;
+	}
 	/* Not worth rounding a READ this small out to whole alignment units */
-	if (count < nf->nf_dio_read_offset_align)
+	if (count < offset_align) {
+		trace_nfsd_read_dio_too_small(rqstp, fhp, offset, count,
+					      offset_align);
 		return false;
-	if (rqstp->rq_res.page_len)
+	}
+	if (rqstp->rq_res.page_len) {
+		trace_nfsd_read_dio_pages_in_use(rqstp, fhp, offset, count,
+						 offset_align);
 		return false;
+	}
 #ifdef CONFIG_NFSD_V4
 	/*
 	 * The xdr_stream encoder ignores rq_res.page_base, so an operation
 	 * encoded after a direct read would overwrite the payload's tail.
 	 */
-	if (rqstp->rq_vers == 4 && !nfsd4_last_compound_op(rqstp))
+	if (rqstp->rq_vers == 4 && !nfsd4_last_compound_op(rqstp)) {
+		trace_nfsd_read_dio_not_last_op(rqstp, fhp, offset, count,
+						offset_align);
 		return false;
+	}
 #endif
 	return true;
 }
@@ -1298,7 +1313,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	case NFSD_IO_BUFFERED:
 		break;
 	case NFSD_IO_DIRECT:
-		if (nfsd_direct_read_ok(rqstp, nf, *count))
+		if (nfsd_direct_read_ok(rqstp, fhp, nf, offset, *count))
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, page, eof);
 		fallthrough;
@@ -1323,7 +1338,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 	rqstp->rq_next_page = page;
 
-	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
+	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total,
+			       kiocb.ki_flags);
+	trace_nfsd_read_dontcache(rqstp, fhp, offset, *count - total,
+				  kiocb.ki_flags);
 	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
 	host_err = vfs_iocb_iter_read(file, &kiocb, &iter);
 	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err);
@@ -1391,7 +1409,8 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *segment,
 }
 
 static unsigned int
-nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
+nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
+			  struct nfsd_file *nf, struct bio_vec *bvec,
 			  unsigned int nvecs, struct kiocb *iocb,
 			  unsigned long total,
 			  struct nfsd_write_dio_seg segments[3])
@@ -1399,6 +1418,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	u32 offset_align = nf->nf_dio_offset_align;
 	loff_t prefix_end, orig_end, middle_end;
 	u32 mem_align = nf->nf_dio_mem_align;
+	u32 mem_offset = nvecs ? bvec->bv_offset : 0;
 	size_t prefix, middle, suffix;
 	loff_t offset = iocb->ki_pos;
 	unsigned int dontcache_flags = 0;
@@ -1415,9 +1435,18 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * If alignments are not available, the write is too small,
 	 * or no alignment can be found, fall back to buffered I/O.
 	 */
-	if (unlikely(!mem_align || !offset_align) ||
-	    unlikely(total < max(offset_align, mem_align)))
+	if (unlikely(!mem_align || !offset_align)) {
+		trace_nfsd_write_dio_no_alignment(rqstp, fhp, offset, total,
+						  offset_align, mem_align,
+						  mem_offset, 0, 0, 0);
 		goto no_dio;
+	}
+	if (unlikely(total < max(offset_align, mem_align))) {
+		trace_nfsd_write_dio_too_small(rqstp, fhp, offset, total,
+					       offset_align, mem_align,
+					       mem_offset, 0, 0, 0);
+		goto no_dio;
+	}
 
 	orig_end = offset + total;
 
@@ -1443,8 +1472,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 
 	if (!middle ||
 	    ((prefix || suffix) &&
-	     middle < nfsd_direct_misaligned_min_bytes))
+	     middle < nfsd_direct_misaligned_min_bytes)) {
+		trace_nfsd_write_dio_no_middle(rqstp, fhp, offset, total,
+					       offset_align, mem_align,
+					       mem_offset, prefix, middle,
+					       suffix);
 		goto no_dio;
+	}
 
 	if (prefix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
@@ -1462,20 +1496,28 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
 	 * the first bvec, all subsequent bvecs start at bv_offset zero
 	 * (page-aligned). Therefore, only the first bvec is checked.
 	 */
-	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
+	mem_offset = iov_iter_bvec_offset(&segments[nsegs].iter);
+	if (mem_offset & (mem_align - 1)) {
+		trace_nfsd_write_dio_mem_misaligned(rqstp, fhp, offset, total,
+						    offset_align, mem_align,
+						    mem_offset, prefix, middle,
+						    suffix);
 		goto no_dio;
+	}
 	/*
 	 * IOCB_DONTCACHE matters only if the file system falls back to
 	 * buffered I/O (-ENOTBLK).
 	 */
 	segments[nsegs++].flags |= IOCB_DIRECT | dontcache_flags;
+	trace_nfsd_write_dio_direct(rqstp, fhp, offset, total, offset_align,
+				    mem_align, mem_offset, prefix, middle,
+				    suffix);
 
 	if (suffix) {
 		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
 					prefix + middle, suffix, iocb);
 		segments[nsegs++].flags |= buffered_flags;
 	}
-
 	return nsegs;
 
 no_dio:
@@ -1499,8 +1541,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	ssize_t host_err;
 	size_t expected;
 
-	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
-					  kiocb, *cnt, segments);
+	nsegs = nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
+					  nvecs, kiocb, *cnt, segments);
 
 	/*
 	 * Persist a split synchronous WRITE once, after all of its
@@ -1514,12 +1556,15 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
 		kiocb->ki_flags = segments[i].flags & ~sync_flags;
-		if (kiocb->ki_flags & IOCB_DIRECT)
-			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
-						segments[i].iter.count);
-		else
-			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
-						segments[i].iter.count);
+		trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
+					segments[i].iter.count,
+					kiocb->ki_flags);
+		trace_nfsd_write_dontcache(rqstp, fhp, kiocb->ki_pos,
+					   segments[i].iter.count,
+					   kiocb->ki_flags);
+		trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
+					segments[i].iter.count,
+					kiocb->ki_flags);
 
 		expected = iov_iter_count(&segments[i].iter);
 
@@ -1628,6 +1673,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			kiocb.ki_flags |= IOCB_DONTCACHE;
 		fallthrough;
 	case NFSD_IO_BUFFERED:
+		trace_nfsd_write_dontcache(rqstp, fhp, offset, *cnt,
+					   kiocb.ki_flags);
+		trace_nfsd_write_vector(rqstp, fhp, offset, *cnt,
+					kiocb.ki_flags);
 		iov_iter_bvec(&iter, ITER_SOURCE, rqstp->rq_bvec, nvecs, *cnt);
 		host_err = vfs_iocb_iter_write(file, &kiocb, &iter);
 		if (host_err < 0)
-- 
2.52.0

