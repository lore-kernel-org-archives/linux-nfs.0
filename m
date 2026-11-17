Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794936029;
	b=B1Su4HcywE6pzaFjqDYuusYNlsgbr3JJeWDY77CJsF7rXbuoIxkmyuFgKGQjogWZ0XoC
	 bmR4GEh2t4p6g1Xl6ET1pHbGpWjs9rc0NtRSf//1M20y+3l8fQg2UsMJyn24w/3cvLEJe
	 vkt1NA+op8mu0grlG/tLvv6TNRXi2hKKkrbV3D40qDHO6fyLXr86WnpBp/JdV9ntprNF9
	 YRWMKmdIQ859+j/zz+zThDd2WJ6RmGeDrUlEjomHPxcTVuSurN0AoRPc8s0/orFpAsXZq
	 Uq99UppC401kT4JDBC6yDXQjyCWi92o2pgeDNp4PTHlXZb5nu+dg4XhPVbwU/M7XAGQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794936029;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=qA4EiwiblQZZCKffcHzmahJj0FAvJhdXgqguQB+9SlM=;
	b=nbsCdJulMJbKtdOVdLxHFhBOIHWqIAfsI4XkeBRi/NuhmBQlkG0T6WwrzsZiP3Xxq63s
	 lyci9Su1YdbVMR1WySuPmOQ9KVNroAFJ7xBfIMMAvv6wBLl1zTtqu9zRTs2LyMISF2+mv
	 i14eVi4oF64F7hgK6buZPeGWQQ4kNDEraYwemZrYXgmins2016t2bQRG6GapIXqjlzRYW
	 wvZ3UrKfoEFfA6mKytw/2lsufEftHpxSuwwGAFxKUdWgzDSPx+JRv0wCm7sFEPIA5VRPi
	 AU+aiSYJJxaM0buB9PrUhNNtwuEro7yvCVGUpD68befazT3Rag4qlrX1Ih6GyJN/Sbw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=AegUcoNL;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49550606A335
	for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2026 17:20:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 49550606A335
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=AegUcoNL
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794936026;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=qA4EiwiblQZZCKffcHzmahJj0FAvJhdXgqguQB+9SlM=;
	b=AegUcoNLt5/d7J2RdkpyRGeGGoLRQ/a0g8dPNKoWa+ScGCt+dGdQBJqC3aUBCqIUwcLVtN
	sKxsf5mOV4dw/fEND/ov6kK95iBqSXxlf3T2r50ybYZ0hDQYZzKEncrz+3NcF55LUbx11J
	NGB/gCokGlcPTnu7+YUkgKOCBZZ7hH4=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-256-MZPuOTnmPdCngz4zO8KaIA-1; Tue,
 17 Nov 2026 12:20:22 -0500
X-MC-Unique: MZPuOTnmPdCngz4zO8KaIA-1
X-Mimecast-MFC-AGG-ID: MZPuOTnmPdCngz4zO8KaIA_1794936020
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 47B51195605A;
	Tue, 17 Nov 2026 17:20:19 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1B4161800543;
	Tue, 17 Nov 2026 17:20:13 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v18 00/17] netfs, iov_iter: Use a chain of bio_vec arrays instead of folio_queue
Date: Tue, 17 Nov 2026 17:18:58 +0000
Message-ID: <20261117171958.2982801-1-dhowells@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

Hi Christian,

Could you pull these patches please into your vfs-7.5.netfs branch?  This
is the third of five batches (two already having gone upstream), in this
case replacing the folio_queue struct with a bvecq struct.  It has been
rebased on v7.4-rc3.  This was split from v11 of a larger netfslib
series[1].

This series adds a new type, struct bvecq.  This points to a bounded array
of bio_vecs with information about how to clean up the memory they point
to.  A number of bvecq structs can be linked together to form a chain and
an iterator type, ITER_BVECQ, is provided that can be pointed at the chain
and can walk it.  Netfslib is then switched to use the new type and
folio_queue is removed along with ITER_FOLIOQ.

This is intended as a more flexible replacement for struct folio_queue as
the latter can only point to whole folios and cannot point to partial pages
that might be extracted from an ITER_IOVEC/ITER_UBUF for direct or
unbuffered I/O purposes.

These patches make a more or less straight swap between struct folio_queue
and struct bvecq.  The change is not quite trivial as the folio_queue
struct contains a folio_batch struct and is basically a list of whole
folios only, whereas the new bvecq struct is a chain of bio_vec arrays.

The patches also add a pair of gated memory pools for allocating bvecqs in
writeback under low memory conditions.  One is for use by requests and the
other by subrequests.  The two pools have different lifetime and typical
allocation amount expectations and avoid deadlocking between the two
levels.  To avoid overrunning pool capacity, access is controlled by
semaphore for each pool.

A further patchset will switch the netfslib unbuffered I/O code to using
bvecqs and then the bvecqs will be passed down into the filesystem rather
than passing an iterator.

The primary reason behind making this change is so that bvecq chains can be
used in the assembly of network filesystem messages.  Netfslib can furnish
the filesystem with bvecq chains representing the data buffers that need to
be read or written and then, for example, for a write RPC, the filesystem
can add protocol headers and trailers onto the chain without the need to
copy it and can also glue multiple buffers together to form compound
operations and/or perform sparse operations.

One option here is to add two more fields to the bvecq struct, one to
increase the offset of the first bio_vec and one to decrease the length of
the last, thereby allowing a bvecq struct to point at a slice of another
bio_vec array without having to copy the array - but at the cost of adding
one or two extra conditional ops when getting the offset or length of a
segment.

I have in-progress patch sets to rewrite the cifs transport[2] and the ceph
and rbd transport[3] to make use of bvecq chains.  For the cifs transport,
the idea is to extend the SMB message concept further up the stack, where
the PDU-marshalling routines will create individual RPC request blobs that
the transport can then automatically chain together when it is assembling
a compound SMB request for transmission.

With the ceph transport, the idea is to convert all the different data
containers it has into just passing around bvecqs.  These can then be
chained together in order to transmit them.

This improves efficiency in the TCP stack as we no longer need to cork the
TCP socket, call sendmsg() multiple times and then uncork; rather we can
preassemble the message in a bvecq chain and just send the entire message
in one shot with a single sendmsg() and reduce the number of places doing
loops.  Using a single sendmsg got an improvement in nfsd performance[4].

I also have some changes on the TCP receive side for the cifs transport
(which is also likely applicable to the ceph TCP transport) whereby the
receive buffers are 'spliced' out into a bvecq in the cifs I/O thread
rather than being copied.  Using a bvecq chain here is advantageous as we
don't know in advance how many segments we're going to have.  This allows
us firstly to avoid copying data with the socket lock held (thus holding up
sendmsg) and secondly to avoid copying data in the I/O thread (copying can
be offloaded to the app thread).  The last time I benchmarked this, it
appeared to get fio reading tests on cifs a 5% speedup.

Unfortunately, this doesn't help AFS much as that uses a UDP transport, but
it might also help 9P, at least with its TCP transport.

The patches can also be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=netfs-next-3

Thanks,
David

Changes
=======
ver #18)
- Rebase on v7.4-rc3.
- Fixed issues found by Sashiko[9]:
  - Fixed the bvecq mempool handling:
    - Changed the bvecq_alloc_*() functions to take a set of updateable
      flags instead of a true/false writeback indicator.  This allows the
      caller to be notified that an OOM occurred and to keep persistent
      state.
      - The allocation funcs set BVECQ_HIT_OOM if an out of memory
        condition occurred, even if it is dealt with through a mempool.
      - The alloc funcs set BVECQ_HOLD_POOL_SEM if they return holding a
        count on the semaphore.
      - Added a function to clean up the state (including releasing the
        semaphore).
    - Split the bvecq mempool so that there's one pool for request-level
      and one for subrequest-level.  These allocations have different
      characteristics and lifetimes and a process might deadlock against
      itself if using a single pool for both.
      - The req-level pool allows up to 50 procs to share a pool of 100.
      - The subreq-level pool allows 2 procs to have enough bvecqs each on
        average to track 16MiB worth of pages.
    - Gate the pools with semaphores to control access to the pools,
      thereby making sure that at least some reqs/subreqs can make progress
      by having sufficient available.  The semaphore count must be
      significantly less than the capacity of the pool.
    - Added a flag to allow the caller to say that they are fine with a
      buffer or chain allocation being shortened if OOM occurs.
  - Made cifs use the subreq pool for its encryption buffer.  This really
    needs to be restricted to just writeback and reconnect during
    writeback, but that's not easy without restructuring the cifs transport
    (I have patches for that).  Further, we really want to shorten the
    subrequest - but cifs can't do that at the point it currently allocates
    its enc buffer.
  - Fixed kunit_bvecq release on abort as kunit_add_action_or_reset() just
    returns an error on OOM rather than aborting.
  - Fixed the 'can I revert?' bounds checking in kunit_bvecq.
  - Made afs dir and symlink writeback check the inode validity after
    taking the callback lock (cb_lock).
- Fixed issues found by local review with claude-opus-5-5:
  - Fixed some issues in the above changes for sashiko.
  - Made the bvecq chain advance functions advance to the next occupied
    slot in the next occupied bvecq before returning rather than leaving
    the iterator on a non-terminal spent bvecq.
  - Fixed the bvecq test to abort rather than fail and continue.
  - Increased the subreq-level bvecq pool to handle 16MiB-worth of pages to
    support CIFS_MAX_WSIZE.
  - Recheck ->nr_slots and ->next before deleting spent bvecq.

ver #17)
- Fixed issues found by Sashiko[8]:
  - Fix bvecq_alloc_buffer2() to set mem_type if zero slots requested.
  - Fix folio leak in the kunit tests.
  - Don't mark kunit functions as __init.
  - Make subreqs pin the bvecq chain to avoid retry of a partially complete
    subreq seeing released memory.
  - Fix handling of concurrent writeback of a single-type object and afs
    vnode status update.
- Fixed issues found by local review with claude-opus-5-5:
  - Pass len from netfs_create_write_req() to netfs_alloc_request().
  - Added a patch to pass the request length in for unbuffered/DIO writes
    and single-type object writeback to request creation, to set wreq->len.
  - In netfs_writeback_single() set wreq->len to the specified length, not
    padded buffer size.
  - Added a fix patch to remove __init and __refdata marks from
    kunit_iov_iter.c.
  - Removed __refdata from kunit_bvecq.c too.
  - Extended the bvecq chain pinning to the retry functions too.

ver #16)
- Rebase on v7.4-rc1.
- Add docs for the bvecq tools.
- Add some kunit tests for the bvecq iterator.
- Fixed issues found by local review with claude-opus-5-5:
  - Added missing linux/mempool.h inclusion.
  - Fix bvecq_alloc_one() to check the rounded-up allocation size against
    the pool allocation size, not the struct+array size which may have a
    gap.
  - Fix bvecq_alloc_one() to limit the max slots to USHRT_MAX to not
    overrun the slot counters.
  - Make bvec_kmap_partial()'s bvec pointer const.
  - Added an iter_to_sg kunit test for bvecq.
  - Added a patch to make afs symlink's use of ->directory_size
    consistent.
  - In netfs_writeback_single(), fix the value ->submit_extendable_to is
    set to (though a future patch series will remove this).
  - Split the afs dir bvecq patch into three:
    - A patch to pass the content length to netfs_writeback_single(),
      separately from the buffer size in the iov_iter.  The filesystem is
      then responsible for providing zeroed padding.
      - A check is added to make sure the buffer is not smaller than the
        content.
      - The API doc is updated.
    - A patch to simplify netfs_writeback_single():
      - No looking inside the iov_iter.
      - Effectively do DIO rather than buffered I/O (pagecache not used).
      - Pass a single op to the cache.
      - Wait synchronously for op completion for now as the calling
        filesystem should otherwise do a wait.
      - Removed the bits to set up a write to the server since it should
        only write to the cache.
    - A patch to switch afs dir (and symlink) buffering to use bvecq
      instead of folio_queue.
  - Clear new pages as added and clear the tail if shrunk by a third party
    for AFS directories.
  - Clear the buffer tail before calling netfs_writeback_single() for AFS
    symlinks.
  - Fix netfs_limit_bvecq() to handle empty bvecqs and short chains.
  - Added missing SPDX to new doc.
  - Added new files to MAINTAINERS.

ver #15)
- Fix issues from Sashiko[7]:
  - Don't need to set page counts after calling alloc_pages_bulk().
  - Adjust netfs_writeback_single() to return 0 on success, not the amount
    written.
  - Remove a couple of unused constants.

ver #14)
- Fix issues from Sashiko[6]:
  - In iter_bvecq_get_pages(), use folio_get() not get_pages.
  - In netfs_read_set_unlock_at(), netfs_read_unlock_folios(),
    netfs_pgpriv2_unlock_copied_folios() and
    netfs_writeback_unlock_folios(), skip wholly unoccupied bvecqs.
  - Remove some now-unused trace bits.

ver #13)
- Fix issues from Sashiko[5]:
  - In iter_bvecq_get_pages(), need to add bv_offset when calling
    want_pages_array().
  - In iter_bvecq_get_pages(), make the getting of a ref on the page
    dependent on the page being non-slab.
  - In bvecq_alloc_one(), use mempool_alloc(), not
     mempool_alloc_noreserve().
  - In bvecq_expand_buffer(), don't add __GFP_NORETRY|__GFP_WARN for
    order 0 allocations.
  - Drop the netfs_bv_slot tracepoint as it's not used in these patches.
  - In afs_do_read_single(), afs_dir_get_block() and afs_do_read_symlink(),
    use mapping_gfp_mask() rather than GFP_KERNEL.
  - In netfs_writeback_single(), set ->submitted so that
    netfs_wait_for_write() doesn't then just return -EIO.
  - In netfs_unlock_abandoned_read_pages(), reset ->first_tail_slot when
    moving on to next node.
  - Remove netfs_folioq_trace(s) trace info enum and string set as their
    tracepoint got removed.

ver #12)
- Split from v11 of "netfs: Keep track of folios in a segmented bio_vec[]
  chain"[1]

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com/
[2] https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=cifs-experimental
[3] https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=ceph-iter
[4] https://lore.kernel.org/netdev/168979108540.1905271.9720708849149797793.stgit@morisot.1015granger.net/
[5] https://sashiko.dev/#/patchset/20260929075913.2740968-1-dhowells%40redhat.com
[6] https://sashiko.dev/#/patchset/20260929103412.2807494-1-dhowells%40redhat.com
[7] https://sashiko.dev/#/patchset/20260930125247.3232130-1-dhowells%40redhat.com
[8] https://sashiko.dev/#/patchset/20261107160823.1465553-1-dhowells%40redhat.com
[9] https://sashiko.dev/#/patchset/20261111203034.2126314-1-dhowells%40redhat.com

David Howells (17):
  iov_iter: Fix kunit test to remove __init and __refdata marks
  Add a function to kmap one page of a multipage bio_vec
  iov_iter: Add a segmented queue of bio_vec[]
  netfs: Add some tools for managing bvecq chains
  iov_iter: Add an API document for the bvecq structure
  iov_iter: Add a bvecq kunit test
  afs: Fix an inconsistency in the symlink code
  netfs: Explicitly pass tail padding to netfs_writeback_single()
  netfs: Change netfs_writeback_single() to not look inside the iterator
  netfs: Pass the write length to request creation where appropriate
  afs: Use a bvecq to hold dir content rather than folioq
  cifs: Use a bvecq for buffering instead of a folioq
  smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
  netfs: Switch folioq to bvecq
  smbdirect: Remove support for ITER_FOLIOQ from
    smbdirect_map_sges_from_iter()
  iov_iter: Remove ITER_FOLIOQ
  netfs: Remove folio_queue

 Documentation/core-api/bvecq.rst            | 250 ++++++++
 Documentation/core-api/folio_queue.rst      | 209 -------
 Documentation/core-api/index.rst            |   2 +-
 Documentation/filesystems/netfs_library.rst |  47 +-
 MAINTAINERS                                 |   3 +
 fs/afs/dir.c                                |  56 +-
 fs/afs/dir_edit.c                           |  44 +-
 fs/afs/dir_search.c                         |  33 +-
 fs/afs/inode.c                              |   2 +-
 fs/afs/internal.h                           |   6 +-
 fs/afs/symlink.c                            |  64 ++-
 fs/netfs/Makefile                           |   1 +
 fs/netfs/buffered_read.c                    |  36 +-
 fs/netfs/bvecq.c                            | 416 ++++++++++++++
 fs/netfs/direct_write.c                     |   4 +-
 fs/netfs/internal.h                         |  12 +-
 fs/netfs/iterator.c                         |  42 +-
 fs/netfs/main.c                             |  50 +-
 fs/netfs/misc.c                             |  96 ----
 fs/netfs/objects.c                          |   6 +-
 fs/netfs/read_collect.c                     |  48 +-
 fs/netfs/read_pgpriv2.c                     |  41 +-
 fs/netfs/read_retry.c                       |  53 +-
 fs/netfs/rolling_buffer.c                   | 193 ++-----
 fs/netfs/stats.c                            |   8 +-
 fs/netfs/write_collect.c                    |  39 +-
 fs/netfs/write_issue.c                      | 221 +++----
 fs/netfs/write_retry.c                      |  15 +-
 fs/smb/client/cifsglob.h                    |   2 +-
 fs/smb/client/smb2ops.c                     |  97 ++--
 fs/smb/smbdirect/connection.c               | 135 +++--
 include/linux/bvec.h                        |  18 +
 include/linux/bvecq.h                       | 197 +++++++
 include/linux/folio_queue.h                 | 282 ---------
 include/linux/iov_iter.h                    |  94 +--
 include/linux/netfs.h                       |  19 +-
 include/linux/rolling_buffer.h              |  42 +-
 include/linux/uio.h                         |  17 +-
 include/trace/events/netfs.h                |  37 +-
 kernel/bpf/btf.c                            |   2 -
 lib/Kconfig.debug                           |  13 +
 lib/iov_iter.c                              | 519 ++++++++++++-----
 lib/scatterlist.c                           |  82 ++-
 lib/tests/Makefile                          |   1 +
 lib/tests/kunit_bvecq.c                     | 603 ++++++++++++++++++++
 lib/tests/kunit_iov_iter.c                  | 208 +++----
 46 files changed, 2722 insertions(+), 1643 deletions(-)
 create mode 100644 Documentation/core-api/bvecq.rst
 delete mode 100644 Documentation/core-api/folio_queue.rst
 create mode 100644 fs/netfs/bvecq.c
 create mode 100644 include/linux/bvecq.h
 delete mode 100644 include/linux/folio_queue.h
 create mode 100644 lib/tests/kunit_bvecq.c

