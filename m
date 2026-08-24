Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1CD0367298
	for <linux-nfs@vger.kernel.org>; Mon, 24 Aug 2026 14:41:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787582518; cv=none; b=lek2JEoDORlwChxAy5pafgVw+JhZ11TWDDJ1JN6NXryUKLGpo4C7P8tbzonHPAApJ53gYj1uKZTL9lX0pDaPH7JAUDZmT5K8Ul5VF4nApO9VvnafN27brTE2OERPXvCAIO+NICIXvNiDx+4z/hrhSPjBt9mIOdftNGLAeLj93TA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787582518; c=relaxed/simple;
	bh=lonbMxztg08QxpzvsmoJNND9tg7mECAofij6zB0OJkc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ldmRrFnaIm7Zsft3sO9ePwdkU0SPy+DOKdoSSrfAR9KzhyeMnS6Bct0AR1osnQZDqTZJzGgYD5hKNIDJTUBdR4ae58X9TvhJ/xjASd1WlmUu0Plech1+e6or1o/Z1MVZbyiSZyxZlNncb839533neDMJDilOx3FRsnVG0XuPjJ4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=BBYEXz3e; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="BBYEXz3e"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1787582513;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=oh4EjN3HCg2brkL1WXwAd/dTZmdsgmLr+0n4k9Ofn6Q=;
	b=BBYEXz3ea7DoxWb0hOBrnmjduLqWMyENjWvvQeawrS6YJp6pHjlipVTb9alofW/qasq8OU
	6PCHUHUdG4dmLnwcY06f6BIzMZ1UE0K70NDIs8ttmENjwqRVPV4mIZMC0g8oilsFIAfARC
	pJ1bcbB7K4Co8mVKyMMb4OYqF6AdLRE=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-661-Vko1yqR0M5uFT-ip9_o1Mg-1; Mon,
 24 Aug 2026 10:41:50 -0400
X-MC-Unique: Vko1yqR0M5uFT-ip9_o1Mg-1
X-Mimecast-MFC-AGG-ID: Vko1yqR0M5uFT-ip9_o1Mg_1787582505
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 8D5021953961;
	Mon, 24 Aug 2026 14:41:42 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.15])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 4137B18005AD;
	Mon, 24 Aug 2026 14:41:33 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
	Matthew Wilcox <willy@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	Jens Axboe <axboe@kernel.dk>,
	Leon Romanovsky <leon@kernel.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v10 00/35] netfs: Keep track of folios in a segmented bio_vec[] chain
Date: Mon, 24 Aug 2026 15:40:53 +0100
Message-ID: <20260824144130.759997-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Hi Paulo,

Could you look these patches over please?

The patches get rid of folio_queue, rolling_buffer and ITER_FOLIOQ,
replacing the folio queue construct used to manage buffers in netfslib with
one based around a segmented chain of bio_vec arrays instead.  There are
three main aims here:

 (1) The kernel file I/O subsystem seems to be moving towards consolidating
     on the use of bio_vec arrays, so embrace this by moving netfslib to
     keep track of its buffers for buffered I/O in bio_vec[] form.

 (2) Netfslib already uses a bio_vec[] to handle unbuffered/DIO, so the
     number of different buffering schemes used can be reduced to just a
     single one.

 (3) Always send an entire filesystem RPC request message to a TCP socket
     with single kernel_sendmsg() call as this is faster, more efficient
     and doesn't require the use of corking as it puts the entire
     transmission loop inside of a single tcp_sendmsg().

For the replacement of folio_queue, a segmented chain of bio_vec arrays
rather than a single monolithic array is provided:

	struct bvecq {
		struct bvecq		*next;
		struct bvecq		*prev;
		refcount_t		ref;
		u32			priv;
		u16			nr_slots;
		u16			max_slots;
		enum bvecq_mem		mem_type:2;
		bool			inline_bv:1;
		bool			from_pool:1;
		struct bio_vec		*bv;
		struct bio_vec		__bv[];
	};

The fields are:

 (1) next, prev - Link segments together in a list.  I want this to be
     NULL-terminated linear rather than circular to make it possible to
     arbitrarily glue bits on the front.

 (2) ref - Refcount.  Each bvecq keeps a ref on the next.  I'm not sure
     this is entirely necessary, but it makes sharing slices easier.

 (3) priv - Private data for the owner.  Dispensible; currently only used
     for storing a debug ID for tracing in a patch not included here.

 (4) max_slots, nr_slots.  The size of bv[] and the number of slots used.
     I've assumed a maximum of 65535 bio_vecs in the array (which would
     represent a ~1MiB allocation).

 (5) bv, __bv, inline_bv.  bv points to the bio_vec[] array handled by
     this segment.  This may begin at __bv and if it does inline_bv should
     be set (otherwise it's impossible to distinguish a separately
     allocated bio_vec[] that follows immediately by coincidence).

 (6) mem_type.  Indicates how the memory attached to the bio_vecs should be
     disposed of when the bvecq is destroyed.  It can be one of:

	BVECQ_MEM_EXTERNAL	- Externally tracked ref; don't put
	BVECQ_MEM_PAGECACHE	- Pagecache; must be put
	BVECQ_MEM_GUP		- Pinned by from GUP; needs unpin
	BVECQ_MEM_ALLOCED	- Plain alloc'd pages; can be mempooled

     [!] I'm not sure that this is a good name for this member or for the
     	 enum values.

 (7) from_pool.  Set if the bvecq is allocated from netfslib's mempool and
     should be freed to it.

I've also defined an iov_iter iterator type ITER_BVECQ to walk this sort of
construct so that it can be passed directly to sendmsg() or block-based DIO
(as cachefiles does).


This series makes the following changes to netfslib:

 (1) Remove the writethrough code as the locking is really tricky to get
     right and it looks like it could deadlock with Ceph if snapshots are
     used.

 (2) The folio_queue chain used to hold folios for buffered I/O is replaced
     with a bvecq chain.  Each bio_vec then holds (a portion of) one folio.
     Each bvecq holds a contiguous sequence of folios, but adjacent bvecqs
     in a chain may be discontiguous.

 (3) For unbuffered/DIO, the source iov_iter is extracted into a bvecq
     chain.

 (4) An abstract position representation ('bvecq_pos') is created that can
     used to hold a position in a bvecq chain.  For the moment, this takes
     a ref on the bvecq it points to, but that may be excessive.

 (5) Buffer tracking is managed with three cursors:  The load_cursor, at
     which new folios are added as we go; the dispatch_cursor, at which new
     subrequests' buffers start when they're created; and the
     collect_cursor, the point at which folios are being unlocked.

     Not all cursors are necessarily needed in all situations and during
     buffered writeback, we need a dispatch cursor per stream (one for the
     network filesystem and one for the cache).

 (6) ->prepare_read(), buffer setting up and ->issue_read() are merged, as
     are the write variants, with the filesystem calling back up to
     netfslib to prepare its buffer.  This simplifies the process of
     setting up a subrequest.  It may even make sense to have the
     filesystem allocate the subrequest.

 (7) Retry dispatch tracking is added to netfs_io_request so that the
     buffer preparation functions can find it.  Retry requires an
     additional buffer cursor.

 (8) Netfslib dispatches I/O by accumulating enough bufferage to dispatch
     at least one subrequest, then looping to generate as many as the
     filesystem wants to (they may be limited by other constraints,
     e.g. max RDMA segment count or negotiated max size).  This loop could
     be moved down into the filesystem.  A new method is provided by which
     netfslib can ask the filesystem to provide an estimate of the data
     that should be accumulated before dispatch begins.

 (9) Reading from the cache is now managed by querying the cache to provide
     a list of the next two data extents within the cache.

(10) AFS directories are switched to using a bvecq rather than a
     folio_queue to hold their contents.

(11) CIFS is switch to using a bvecq rather than a folio_queue for holding
     a temporary encryption buffer.

(12) CIFS RDMA is given the ability to extract ITER_BVECQ and support for
     extracting ITER_FOLIOQ is removed.

(13) All the folio_queue and rolling_buffer code is removed.

Cachefiles is also modified:

 (1) On-demand mode for Erofs is removed.

 (2) The object type in the cachefiles file xattr is now correctly set to
     CACHEFILES_CONTENT_{SINGLE,ALL,BACKFS_MAP} rather than just being 0,
     to indicate whether we have a single monolithic blob, all the data up
     to cache i_size with no holes or a sparse file with the data mapped by
     the backing file system (as currently upstream).

 (3) For "ALL" type files, the cache's i_size is used to track how much
     data is saved in the cache and no longer bears any relation to the
     netfs i_size.  The actual object size is stored in the xattr.

 (4) For most typical files which are contiguous and written progressively,
     the object type is now set to "ALL".  For anything else, cachefiles
     uses SEEK_DATA/HOLE to find extent outlines at before (this is the
     current behaviour and needs to be fixed, but in a separate set of
     patches as it's not trivial).

 (5) Preset the xattr on a cachefile to try to avoid having to deal with
     ENOSPC from setxattr when committing the object.

Two further things that I'm working on (but not in this branch) are:

 (1) Make it so that a filesystem can be given a copy of a subchain which
     it can then tack header and trailer protocol elements upon to form a
     single message (I have this working for cifs) and even join copies
     together with intervening protocol elements to form compounds.

 (2) Make it so that a filesystem can 'splice' out the contents of the TCP
     receive queue into a bvecq chain.  This allows the socket lock to be
     dropped much more quickly and the copying of data read to the
     destination buffers to happen without the lock.  I have this working
     for cifs too.  Kernel recvmsg() doesn't then block kernel sendmsg()
     for anywhere near as long.

There are also some things I want to consider for the future:

 (1) Create one or more batched iteration functions to 'unlock' all the
     folios in a bio_vec[], where 'unlock' is the appropriate action for
     ending a read or a write.  Batching should hopefully also improve the
     efficiency of wrangling the marks on the xarray.  Very often these
     marks are going to be represented by contiguous bits, so there may be
     a way to change them in bulk.

 (2) Rather than walking the bvecq chain to get each individual folio out
     via bv_page, use the file position stored on the bvecq and the sum of
     bv_len to iterate over the appropriate range in i_pages.

 (3) Change iov_iter to store the initial starting point and for
     iov_iter_revert() to reset to that and advance.  This would (a) help
     prevent over-reversion and (b) dispense with the need for a prev
     pointer.

 (4) Use bvecq to replace scatterlist.  One problem with replacing
     scatterlist is that crypto drivers like to glue bits on the front of
     the scatterlists they're given (something trivial with that API) - and
     this is one way to achieve it.

The patches can also be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=netfs-next

Thanks,
David

Changes
=======
ver #10)
- Rebased on v7.2
- Pushed the cachefiles ondemand sunset patch separately.
- Pushed the patch to fix read progress handling separately.
- Changed some umin() to min().
- Changed netfs writeback to hold the list of regions that need unlocking
  separately from the bvecq holding the folios to write.
- Added a patch to convert unsigned long long to uoff_t throughout
  netfslib, fscache and cachefiles and to convert loff_t where appropriate.
- Split some bits out of the larger patches into smaller patches,
  including:
  - Made some minor adjustments to tracepoints.
  - Provided helper functions to handle the barriering around setting
    NETFS_RREQ_ALL_QUEUED.
  - Made the use of the PG_private_2 flag optional, requiring anything
    wanting to use it (NFS, Ceph) to select it in Kconfig.
  - Added a new function to estimate the amount to write.
- Fixed a number of issues reported by Sashiko[8]:
  - Fixed initialisation of ->progress_at to be 0, not ULONG_MAX, when
    request is allocated otherwise netfs_prepare_read_iterator() won't set
    it.
  - Pass gfp into rolling_buffer_bulk_load_from_ra().
  - Fixes iter_get_kernel_pages() to use folio_test_large_kmalloc() as well
    as folio_test_slab() when deciding to take a ref.
  - Fixed iter_count_bvecq_pages() and iov_iter_extract_bvecq_pages() to
    assume that bio_vecs with bv_page==NULL and bv_len>0 are not allowed.
  - Fixed iov_iter_extract_bvecq_pages() to check if the result of
    iter_count_bvecq_pages() is zero, not less than zero.
  - Fixed bvecq_pos_advance(), bvecq_zero(), bvecq_slice(),
    bvecq_extract(), bvecq_pos_step() and bvecq_pos_nudge() to recheck the
    slot count of the current bvecq after reading the next pointer in order
    to advance to the next bvecq.
  - Made bvecq_delete_spent() retain spent->next and instead take a ref on
    what spend->next points to (so that putting spent doesn't delete the
    entire chain) thereby avoiding breaking the chain.
  - Fixed bvecq_alloc_one() to strip off __GFP_THISNODE as well as
    GFP_ZONEMASK when turning a gfp for allocating folios into a gfp for
    allocating bvecq objects.
  - Change cachefiles_collect_write() to set CACHEFILES_CONTENT_NO_DATA if
    a cache write fails and the cache content is truncated away.
  - Fixed stream->cancelled boolean to be a 3-state enum instead for
    tracking gap, data or cancelled writes to the cache.
  - Fixed netfs_writeback_single() to take two lengths: one for the whole
    buffer and one for the data content in that buffer to allow DIO
    rounding to use extra buffer.
  - Fixed netfs_collect_read_results() to set -EIO on the request when
    abandoning it due to subreq over-read
  - Fixed netfs_writeback_single() to pre-expand the buffer to include all
    available buffer space, even beyond the data, and fixed
    netfs_prepare_write_single_buffer() to do no rounding.
  - Fixed netfs_alloc_read_subrequest() to not set stream->collected_to as
    that's set when the object is initialised and subreq->start isn't set
    yet.
  - Fixed netfs_unbuffered_write() to not skip cleanup if it fails to
    allocate a subreq.
  - Fixed netfs_unbuffered_write() to fail immediately if ->issue_write()
    returns an error rather than going for a retry.
  - Changed netfs_unbuffered_write() to not get subreq->error if
    netfs_wait_for_in_progress_subreq() fails as it returns that.
  - Added a comment to netfs_writeback_single() to indicate that it doesn't
    normally write to the server.
  - Split the cachefiles_trace_write_nospace to distinguish the two users.
  - Fixed the cachefiles file xattr set/get functions to make sure that the
    storage for the cachefiles_xattr::data is at least 8 bytes and that
    it's initialised to 0 so that the tracepoint doesn't cause a KASAN
    error.
  - Fixed missing export of the netfs_rreq tracepoint.

ver #9)
- Fixed a number of issues reported by Sashiko[7]:
  - Fixed netfs_unlock_abandoned_read_pages() to make sure the refs are
    dropped before unlocking.
  - Fixed iov_iter_extract_bvecq_pages() to immediately return 0 if
    there are no pages to be extracted from the iterator (e.g. if maxpages
    is 0).
  - Pass a flag into bvecq_alloc_one() to indicate if we can access
    writeback memory pools rather than trying to divine this from gfp.
  - Fixed bvecq_alloc_one() to use the same gfp adjustments as
    mempool_alloc() when prospectively allocating what the caller asked for
    during writeback.
  - Simplified the bvecq-based rolling buffer in writeback by always adding
    whole folios and then setting the offset appropriately.  The offset and
    length of the part added can then be aligned at that point when
    tracking the new folio in the cache stream rather than copying and
    rounding out later.
  - Changed the writeback loop to ignore ENOMEM.  There are now backup
    memory pools for writeback.
  - Simplified the writeback loop to update stream tracking as folios are
    added and to flush at that point too if needed.
  - Removed the warning given by netfs_extract_iter() if max_len or
    max_pages is 0.
  - Made netfs_extract_iter() set the fpos on the blank bvecq it allocates
    in the alloc_empty path.
  - Fixed netfs_writeback_single() to test NETFS_RREQ_UPLOAD_TO_SERVER
    rather than test-and-setting it (nothing currently wants to
    writeback-single to the server anyway, only to the cache).
  - Removed cachefiles ondemand pincount.
  - Fixed netfs_collect_write_results() to get the cancel/data flags to
    netfs_collect_write_results() the right way round.
  - Fixed netfs_writeback_unlock_folios() to just warn and oops in the
    unlikely event that it sees a NULL (ie. already unlocked) folio
    pointer.
  - Moved some common initialisation of fields to rreq->start to
    netfs_alloc_request().
  - Fixed bvecq_load_from_ra() to set bq->fpos.
  - Fixed read progress reporting to use an offset from rreq->start
    (unchanging) rather than trying to use rreq->clean_to (tearable) as a
    base.

ver #8)
- Removed the fix patches to their own branches and posted separately.
- Rebased on v7.2-rc6 as a number of fixes went in.
- Fixed cachefiles_collect_write() to handle cres->cache_priv2 (file) being
  NULL due to failure to create an object (e.g. due to ENOSPC).
- Added a patch to cachefiles to preset the xattr on a cachefiles to avoid
  dealing with ENOSPC from setxattr when committing an object.
- Fixed a number of bugs reported by Sashiko[6]:
  - Fixed bvecq_alloc_buffer2() to break out of the loop if pre_slots > 0
    and size == 0.
  - Made netfs_extract_iter() limit max_pages to protect iov_iter_npages().
  - Remove include/uapi/linux/cachefiles.h when ondemand mode is removed.
  - Remove more ondemand-related trace bits.
  - Remove ondemand-related BPF bits.
  - Fixed a missing ENOMEM check in netfs_pgpriv2_begin_copy_to_cache().
  - Fixed netfs_retry_read_subrequests() to unset dispatch_cursor on the
    "abandon_after" error path.
  - Fixed netfs_issue_write() to clear stream->construct if a subreq is
    terminated due to ENOMEM.
  - Fixed netfs_collect_read_results() to unpause the app if it decides to
    abandon the read.
  - Fixed cachefiles_issue_read() to not wait for the object state to match
    FSCACHE_WANT_READ as cachefiles_query_occupancy() should have done that
    already.
  - Fixed netfs_retry_write_stream() to handle superfluous subreqs
    correctly (borrowing from read retry).

ver #7)
- Rebased on v7.2-rc4.
- Added three fix patches to the front from Yichong Chen that conflict with
  other patches in the series.
- Fixed a number of bugs reported by Sashiko[5].
  - Fixed double page put in iov_kunit_destroy_bvecq().
  - Fixed bvecq_alloc_buffer2() to handle pre_slots>0 and size==0
    correctly.
  - Fixes bvecq_expand_buffer() to use a barrer to set tail->nr_slots.
  - Added functions to insert barriers when reading or setting bvecq::next
    and fixed some places to use them.
  - Fixed more meta block mapping in afs_edit_dir_remove().
  - Added a patch to fix missing unmap in afs_dir_search_bucket().
  - Removed the writethrough stat counter as the code gets removed.
  - Cleaned up the cachefiles-ondemand removal patch:
    - Fix removal of code that's conditional on !ONDEMAND.
    - Removed msg_id_next field.
    - Removed ondemand trace elements.
    - Removed documentation.
  - Fixed cachefiles_resize_cookie() to only consider a resize a shrink if
    the new size is less than the object size.
  - Fixed cachefiles_resize_cookie() to update object->object_size on
    expansion.
  - Add a comment on exclusion in cachefiles_collect_write().
  - Fixed netfs_single_dispatch_read() to allow for the cache to have
    rounded out the stored data to DIO size.
  - Fixed netfs_prepare_read_iterator() to clamp subreq len to sreq_max_len
    (obsoleted by last patch).
  - Changed write subreq collection to never retry cache writes.  Shouldn't
    see them in the retry path either then.
  - Fixed netfs_pgpriv2_unlock_copied_folios() to return made_progress
    instead of false if we hit the end of the bvecq chain.
  - Modified buffered read collection to abandon the rest of a read request
    if a subreq over-reads as the buffer may have been corrupted.  The read
    termination function no longer winds subreq->transferred back.
  - Fixed netfs_issue_read() to call the right termination func in the fail
    path.
  - Fixed netfs_dispatch_unbuffered_reads(), netfs_single_dispatch_read()
    and netfs_retry_read_subrequests() to handle failed ->issue_read().
  - Fixed afs_issue_read() to return after calling afs_end_read() as this
    op is then released.
  - Fixed cifs_issue_write() to always release credits on failure.
  - Fixed cifs_issue_read() to not release credits twice.
  - Fixed netfs_issue_writes() to advance stream->issued_to and
    stream->dispatch_cursor on early failure of ->issue_write().
  - Fixed netfs_issue_read() to only call netfs_all_subreqs_queued() if
    stream->buffered is zero.
  - Fixed ceph_netfs_issue_op_inline() to do a retry if file got uninlined
    by someone else.
  - Fixed ceph_netfs_issue_op_inline() to not return an error directly
    once it's got a prepared buffer.
  - Fixed nfs_netfs_issue_read() to return an int.

ver #6)
- Rebased on v7.2-rc3.
- Added a patch to remove erofs on-demand support from cachefiles.
- Added a patch to remove the writethrough code as it's really tricky to
  get the locking right and it looks like can deadlock itself with Ceph.
- Fixed a number of bugs reported by Sashiko[4].
  - Fixed iov_iter_single_seg_count(), iov_iter_alignment_bvecq() and
    iov_npages_bvecq() to handle zero-length segments and segments with no
    stuff remaining.
  - Fixed bvecq_extract() to use GFP_NOFS rather than GFP_KERNEL.
  - Fixed bvecq_alloc_buffer2()'s use of alloc_pages_bulk().
  - Fixed netfs_extract_iter() to break out of the inner loop if max_pages
    hits zero.
  - Added a patch to fix meta block mapping in afs_edit_dir_remove().
  - Fixed afs_init_new_symlink() to clear the tail of the symlink page.
  - Fixed cachefiles_begin_operation() to deal with a NULL file.
  - Fixed slot check in netfs_read_gaps() to be >=, not >.
  - Fixed netfs_pgpriv2_copy_folio() to update creq->last_end.
  - Fixed netfs_read_single() to return -EIO if the buffer isn't big
    enough.
  - Add a comment to netfs_write_folio() to indicate that truncate must
    not run concurrently with writeback and must exclude/wait for it.
  - In netfs_read_subreq_terminated(), move the netfs_sreq_trace_too_much
    trace line earlier before ->transferred is clobbered.
  - In netfs_read_subreq_terminated(), make the transfer-too-long case
    avoid retrying and just end with EIO (in case data further along in the
    buffer got corrupted).
  - Fixed netfs_collect_read_results() if it sees front->transferred >
    front->len, to just use front->len instead.
  - Fixed ceph_netfs_issue_op_inline() to prep the buffer before setting
    NETFS_SREQ_HIT_EOF so that subreq->content is set.
  - Alter netfs_read_to_pagecache() to not round up reading from
    zero-containing cache granules as no I/O is required.
  - Made ->issue_write() return an error so that errors before any buffer
    is sliced off don't result in an infinite loop in netfs_issue_writes().
  - Made ->issue_read() return an error also for similiar reasons.
  - In netfs_writepages(), handle -ENOMEM from bvecq prealloc before
    caling netfs_queue_wb_folio() rather than doing it on the combined
    error return of that and netfs_issue_streams() which can result in a
    double unlock.
  - Fix netfs_writeback_single() to write nothing if len == 0.

ver #5)
- Rebased on v7.2-rc2 as that has a bunch of outstanding netfs and afs
  bugfixes included.

ver #4)
- Fixed a number of bugs reported by Sashiko[3].
  - Added a patch to fix an underflow in iov_iter_extract_xarray_pages().
  - Added a patch to fix alloc failure in iov_iter_extract_bvec_pages().
  - Added a patch to remove an unused var in kunit code.
  - Added a patch to fix the folio offset in extract_xarray_to_sg().
  - Added a patch to fix the exclusion over writeback to make it cover
    collection too.
  - Fixed double fput() in cachefiles.
  - Fixed the collection of cache writes to handle cancellation better.
  - Fixed iterate_bvecq() to skip bvecq structs with nr_slots==0.
  - Add a comment into iterate_bvecq() that a slot with bv_len>0 must have a
    valid bv_page.
  - Fixed iov_iter_bvecq_advance(), iov_iter_bvecq_revert(),
    iter_count_bvecq_pages(), iov_iter_extract_bvecq_pages() and
    extract_bvecq_to_sg() to correctly handle empty bvecqs.
  - Fixed extract_bvecq_to_sg() to be limited by iter->count.
  - Fixed bvecq_expand_buffer() to take an unsigned size param.
  - Fixed bvecq_expand_buffer() to not mix memory types in alloc'd bvecqs.
  - Fixed bvecq_shorten_buffer() occasional retention of zero-length slots.
  - Fixed slot validity check polarity in bvecq_pos_advance(); also don't use
    inner loop otherwise break then exits the wrong loop.
  - Fixed bvecq_zero(), bvecq_slice() and bvecq_extract to use a barrier when
    checking bq->nr_slots.
  - Restructured bvecq_zero() to be similar to bvecq_pos_advance().
  - Fixed an off-by-one error in bvecq_pos_step() and added a missing slot
    reset.
  - Fixed a break in netfs_extract_iter() that should have been a goto.
  - Fixed netfs_extract_iter() to limit number of pages extracted to remnant
    of max_pages.
  - Fixed an uninit var in afs_do_read_symlink().
  - Fixed netfs_read_gaps() to fill a multipart bvecq chain correctly.
  - Fixed netfs_dispatch_unbuffered_reads() to initialise collect_cursor as
    netfs_rreq_assess_dio() uses it to flush the data read.
  - Fixed netfs_extract_iter() to init the slot counter outside the extract
    loop to avoid overwriting already loaded slots.
  - Fixed callers of bvecq_delete_spent() to update bvecq_pos::slot before
    calling.
  - Fixed netfs_reissue_write() to make sure subreq->content is unset before
    setting.
  - Altered netfs_extract_iter() to free any allocated bvecq chain if no pages
    were extracted and an error occurred  (and to initialise the return
    pointer to NULL).  Also, made it return an empty bvecq if nothing was
    extracted, but no error occurred.
  - Fixed ceph_netfs_issue_read() to just return if
    ceph_netfs_issue_op_inline() returns anything other than 1 to avoid a
    double termination.
  - Fixed ceph_netfs_issue_read() to do the size calculation in the right
    order to avoid the op expanding to larger than the buffer.
  - Fixed netfs_issue_read(), in the NETFS_FILL_WITH_ZEROES case, to deduct
    subreq->len from stream->buffered rather than just setting it to 0.
  - Fixed netfs_perform_write() to put the folio if netfs_advance_writethrough()
    fails.
  - Restored the old ->prepare_write op specifically for
    fscache_write_to_cache() which is still used by Ceph.
  - Fixed undefined return in netfs_pgpriv2_issue_stream().
  - Fixed netfs_collect_write_results() to try to make sure a request isn't
    left paused if there are no further server-bound subreqs.
  - Fixed netfs_queue_wb_folio() to redirty the folio before unlocking it if
    it can't allocate a bvecq.
  - Fixed netfs_writepages() to cancel the pagecache iteration after ENOMEM.
  - Fixed netfs_advance/end_writethrough() to advance the dispatch cursor.
  - Fixed netfs_retry_read_subrequests() to use barriers when walking
    stream->subrequests as the app may add another subreq before pausing.
  - Fixed netfs_prepare_write_retry_buffer() to use ->retry_start and
    ->retry_buffered rather than ->issue_from and ->buffered.
  - Fixed netfs_retry_write_stream() to use barriers when walking
    stream->subrequests as the app may add another subreq before pausing.
  - Fixed netfs_retry_write_stream() to check the correct length when adding
    additional subreqs.
  - Fixed nfs_netfs_issue_read() to set -ENOMEM, not 0, on alloc failure.
  - Fixed nfs_netfs_issue_read() to only terminate the subreq once.
  - Fixed cifs_issue_read() to release the credits if cifs_reopen_file()
    fails.
- Rebased on v7.1.

ver #3)
- Rebased to -rc7 as the patches wouldn't apply for Christian.
- Prepended a fix for a warning from generic/464 (the problem also exists
  upstream, just not the warning).
- Renamed kmap_local_bvec() to bvec_kmap_partial() as requested by
  Christoph.
- Adjusted smbdirect patch descriptions as requested by Stefan Metzmacher.

ver #2)
- Fixed a number of bugs reported by Sashiko[1].
- Split a bunch of fixes out and posted them separately[2].

[1] https://sashiko.dev/#/patchset/20260326104544.509518-1-dhowells%40redhat.com
[2] https://lore.kernel.org/linux-fsdevel/20260512-infozentrum-becher-7f86c47c96c8@brauner/T/#t
[3] https://sashiko.dev/#/patchset/20260608145432.681865-1-dhowells%40redhat.com
[4] https://sashiko.dev/#/patchset/20260706153408.1231650-1-dhowells%40redhat.com
[5] https://sashiko.dev/#/patchset/20260716103030.3065561-1-dhowells%40redhat.com
[6] https://sashiko.dev/#/patchset/20260722130218.78958-1-dhowells%40redhat.com
[7] https://sashiko.dev/#/patchset/20260804100224.2748935-1-dhowells%40redhat.com
[8] https://sashiko.dev/#/patchset/20260810144746.574036-1-dhowells%40redhat.com

David Howells (33):
  netfs: Fix read progress reporting
  cachefiles: Fix potential UAF/KASAN warning
  netfs: Use uoff_t instead of unsigned long long and loff_t
  mm: Make readahead store folio count in readahead_control
  netfs: Bulk load the readahead-provided folios up front
  Add a function to kmap one page of a multipage bio_vec
  iov_iter: Make iov_iter_get_pages*() wrap iov_iter_extract_pages()
  iov_iter: Add a segmented queue of bio_vec[]
  netfs: Add some tools for managing bvecq chains
  netfs: Make mempool available for bvecq
  netfs: Add a function to extract from an iter into a bvecq
  afs: Use a bvecq to hold dir content rather than folioq
  cifs: Use a bvecq for buffering instead of a folioq
  smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
  netfs: Remove the writethrough code
  netfs: trace: Change the "clear" folio traces to "endwb"
  netfs: trace: Rejig a couple of the tracepoints
  netfs: Add some functions to wrap the all-queued handling
  netfs: Make deprecated PG_private_2 support optional
  cachefiles: Don't rely on backing fs storage map for most use cases
  netfs: Add the cache object ID to netfs_read/write tracepoints
  netfs: Switch to using bvecq rather than folio_queue and
    rolling_buffer
  smbdirect: Remove support for ITER_FOLIOQ from
    smbdirect_map_sges_from_iter()
  netfs: Remove netfs_alloc/free_folioq_buffer()
  netfs: Remove netfs_extract_user_iter()
  iov_iter: Remove ITER_FOLIOQ
  netfs: Remove folio_queue and rolling_buffer
  netfs: Simplify read abandonment
  netfs: Check for too much data being read
  netfs: Add a method to get an estimate of the amount that can be
    written
  netfs: Rework writeback to use a separate list of regions to be
    unlocked
  netfs: Combine prepare and issue ops and grab the buffers on request
  netfs: Clean up now-unused code

Gao Xiang (1):
  cachefiles,netfs: sunset ondemand mode

Karl Mehltretter (1):
  netfs: Fix uninitialized return value in netfs_unbuffered_write()

 Documentation/core-api/folio_queue.rst        |  209 ----
 Documentation/core-api/index.rst              |    1 -
 .../filesystems/caching/cachefiles.rst        |  179 ---
 Documentation/filesystems/netfs_library.rst   |    2 +-
 fs/9p/vfs_addr.c                              |   61 +-
 fs/afs/dir.c                                  |   38 +-
 fs/afs/dir_edit.c                             |   43 +-
 fs/afs/dir_search.c                           |   33 +-
 fs/afs/file.c                                 |   35 +-
 fs/afs/fsclient.c                             |    8 +-
 fs/afs/inode.c                                |    2 +-
 fs/afs/internal.h                             |   14 +-
 fs/afs/symlink.c                              |   36 +-
 fs/afs/write.c                                |   36 +-
 fs/afs/yfsclient.c                            |    6 +-
 fs/cachefiles/Kconfig                         |   12 -
 fs/cachefiles/Makefile                        |    1 -
 fs/cachefiles/daemon.c                        |   96 +-
 fs/cachefiles/interface.c                     |  104 +-
 fs/cachefiles/internal.h                      |  151 +--
 fs/cachefiles/io.c                            |  603 +++++++---
 fs/cachefiles/namei.c                         |   27 +-
 fs/cachefiles/ondemand.c                      |  761 ------------
 fs/cachefiles/xattr.c                         |   35 +-
 fs/ceph/Kconfig                               |    1 +
 fs/ceph/addr.c                                |  127 +-
 fs/netfs/Kconfig                              |    3 +
 fs/netfs/Makefile                             |    4 +-
 fs/netfs/buffered_read.c                      |  555 +++++----
 fs/netfs/buffered_write.c                     |   69 +-
 fs/netfs/bvecq.c                              |  857 ++++++++++++++
 fs/netfs/direct_read.c                        |  115 +-
 fs/netfs/direct_write.c                       |  178 +--
 fs/netfs/fscache_cookie.c                     |    8 +-
 fs/netfs/fscache_io.c                         |   12 +-
 fs/netfs/internal.h                           |  119 +-
 fs/netfs/iterator.c                           |  387 ++-----
 fs/netfs/main.c                               |   21 +-
 fs/netfs/misc.c                               |  176 +--
 fs/netfs/objects.c                            |   63 +-
 fs/netfs/read_collect.c                       |  417 ++++---
 fs/netfs/read_pgpriv2.c                       |  211 ++--
 fs/netfs/read_retry.c                         |  261 ++---
 fs/netfs/read_single.c                        |  184 ++-
 fs/netfs/rolling_buffer.c                     |  226 ----
 fs/netfs/stats.c                              |   10 +-
 fs/netfs/write_collect.c                      |  345 ++++--
 fs/netfs/write_issue.c                        | 1024 ++++++++---------
 fs/netfs/write_retry.c                        |  189 +--
 fs/nfs/Kconfig                                |    1 +
 fs/nfs/fscache.c                              |   24 +-
 fs/smb/client/cifsglob.h                      |    2 +-
 fs/smb/client/cifssmb.c                       |   13 +-
 fs/smb/client/file.c                          |  148 +--
 fs/smb/client/smb2ops.c                       |   84 +-
 fs/smb/client/smb2pdu.c                       |   28 +-
 fs/smb/client/transport.c                     |   15 +-
 fs/smb/smbdirect/connection.c                 |  135 ++-
 include/linux/bvec.h                          |   18 +
 include/linux/bvecq.h                         |  361 ++++++
 include/linux/folio_queue.h                   |  282 -----
 include/linux/fscache-cache.h                 |    2 +-
 include/linux/fscache.h                       |   53 +-
 include/linux/iov_iter.h                      |   87 +-
 include/linux/netfs.h                         |  261 +++--
 include/linux/pagemap.h                       |   10 +
 include/linux/rolling_buffer.h                |   61 -
 include/linux/uio.h                           |   17 +-
 include/trace/events/cachefiles.h             |  254 +---
 include/trace/events/fscache.h                |   10 +-
 include/trace/events/netfs.h                  |  296 +++--
 include/uapi/linux/cachefiles.h               |   68 --
 kernel/bpf/btf.c                              |    9 -
 lib/iov_iter.c                                |  556 ++++-----
 lib/scatterlist.c                             |   82 +-
 lib/tests/kunit_iov_iter.c                    |  131 +--
 mm/readahead.c                                |    5 +
 net/9p/client.c                               |    8 +-
 78 files changed, 5519 insertions(+), 5557 deletions(-)
 delete mode 100644 Documentation/core-api/folio_queue.rst
 delete mode 100644 fs/cachefiles/ondemand.c
 create mode 100644 fs/netfs/bvecq.c
 delete mode 100644 fs/netfs/rolling_buffer.c
 create mode 100644 include/linux/bvecq.h
 delete mode 100644 include/linux/folio_queue.h
 delete mode 100644 include/linux/rolling_buffer.h
 delete mode 100644 include/uapi/linux/cachefiles.h

