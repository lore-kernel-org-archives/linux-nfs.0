Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F3EE4BF950
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 09:13:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790845989; cv=none; b=mdDXkl7pGXNR/Vu9Fv6uqhhnHJdULY9j4/AJBLzFjy1PkONprMZ34SjrJNjE08XrAQwyG6gUj8eUADvLnkSOJ/sAkVEZ0KLEhgB2EZB4HKQmZ6QlB7H5oOtmCbU7z2Ai3qgGHvpW8/Wjf3+jr5xoEIppQq01FWDGS8DiAttjiMo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790845989; c=relaxed/simple;
	bh=OtNyHMIlfqayS5vu/6EFuXbsPFE+h0JEysiOF4htPwA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=WhxSiX/0Qkh+xCRHt+Tr91qg43eybY4FufomGP4SxY2Hk5oWqOoC2kJumc9NCyWrKkwFu9Rrwg9ygy8x1de2VVJCaeC+ylKE86Cu+iLSI528xE/OR0eQjOPKbnttFWWLiI/D/OB7tzlw+eTHOIMsL1u0BvjjV6wdL2Qq2bfcTQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EbQyo+uQ; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EbQyo+uQ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1790845985;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=TULl+IUUaJc6iYKbMI8b/ucaf+xZze09Nd2rMNDad6s=;
	b=EbQyo+uQNQBtZSQ9nHCqN2ace3bkJYm8OBJh5010JT+uGVqpXYAmzN6dOsPTB/BmImc2L0
	CSCK8Orwp1nd80kZ8ncrWZZv8sZzJlnr+YThQO6jCc7c68lWk4qo4raXUAAQf6H8OKZTBd
	U/WexHDJaHXVnqcL21+sZWhADH0qwoU=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-122-bAkuhX88Ne2Jcga1417YVQ-1; Thu,
 01 Oct 2026 05:12:59 -0400
X-MC-Unique: bAkuhX88Ne2Jcga1417YVQ-1
X-Mimecast-MFC-AGG-ID: bAkuhX88Ne2Jcga1417YVQ_1790845971
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7F5911843AD3;
	Thu,  1 Oct 2026 09:12:49 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.54])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id C7DAB1800348;
	Thu,  1 Oct 2026 09:12:42 +0000 (UTC)
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
Subject: [PATCH v15 00/10] netfs, iov_iter: Use a chain of bio_vec arrays instead of folio_queue
Date: Thu,  1 Oct 2026 10:12:28 +0100
Message-ID: <20261001091239.3343034-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Hi Christian,

Could you pull these patches please into your vfs-7.4.netfs branch?  This
is the third of four (maybe five) batches, in this case replacing the
folio_queue struct with a bvecq struct, and is based upon the
aforementioned branch.  This was split from v11 of a larger netfslib
series[1].  I've fixed some issues spotted by sashiko[5-7].

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
and rbd transport[3] to make use of bvecq chains.  With the cifs transport,
the idea is to extend the SMB message concept further up the stack and have
the PDU creation routines attach individual RPC requests blobs that can
then be automatically chained by the transport when a compound is being
assembled for transmission.

With the ceph transport, the idea is to convert all the different data
containers it has into just passing around bvecqs.  These can then be
chained together in order to transmit them.

This improves efficiency in the TCP stack as we no longer need to cork the
TCP socket, call sendmsg() multiple times and then uncork; rather we can
preassemble the message in a bvecq chain and just send the entire messsage
in one shot with a single sendmsg() and reduce the number of places doing
loops.  This got an improvement in nfsd performance[4].

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
  - In bvecq_expand_buffer(), don't apply __GFP_NORETRY|__GFP_WARN for
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

David Howells (10):
  Add a function to kmap one page of a multipage bio_vec
  iov_iter: Add a segmented queue of bio_vec[]
  netfs: Add some tools for managing bvecq chains
  afs: Use a bvecq to hold dir content rather than folioq
  cifs: Use a bvecq for buffering instead of a folioq
  smbdirect: Support ITER_BVECQ in smbdirect_map_sges_from_iter()
  netfs: Switch folioq to bvecq
  smbdirect: Remove support for ITER_FOLIOQ from
    smbdirect_map_sges_from_iter()
  iov_iter: Remove ITER_FOLIOQ
  netfs: Remove folio_queue

 Documentation/core-api/folio_queue.rst      | 209 --------
 Documentation/core-api/index.rst            |   1 -
 Documentation/filesystems/netfs_library.rst |   2 +-
 fs/afs/dir.c                                |  36 +-
 fs/afs/dir_edit.c                           |  43 +-
 fs/afs/dir_search.c                         |  33 +-
 fs/afs/inode.c                              |   2 +-
 fs/afs/internal.h                           |   6 +-
 fs/afs/symlink.c                            |  38 +-
 fs/netfs/Makefile                           |   1 +
 fs/netfs/buffered_read.c                    |  34 +-
 fs/netfs/bvecq.c                            | 344 +++++++++++++
 fs/netfs/internal.h                         |   7 +-
 fs/netfs/iterator.c                         |  33 +-
 fs/netfs/main.c                             |  13 +-
 fs/netfs/misc.c                             |  96 ----
 fs/netfs/read_collect.c                     |  48 +-
 fs/netfs/read_pgpriv2.c                     |  26 +-
 fs/netfs/read_retry.c                       |  29 +-
 fs/netfs/rolling_buffer.c                   | 189 +++----
 fs/netfs/stats.c                            |   6 +-
 fs/netfs/write_collect.c                    |  26 +-
 fs/netfs/write_issue.c                      | 191 ++------
 fs/smb/client/cifsglob.h                    |   2 +-
 fs/smb/client/smb2ops.c                     |  78 ++-
 fs/smb/smbdirect/connection.c               | 135 +++--
 include/linux/bvec.h                        |  18 +
 include/linux/bvecq.h                       | 166 +++++++
 include/linux/folio_queue.h                 | 282 -----------
 include/linux/iov_iter.h                    |  87 ++--
 include/linux/netfs.h                       |  16 +-
 include/linux/rolling_buffer.h              |  42 +-
 include/linux/uio.h                         |  17 +-
 include/trace/events/netfs.h                |  37 +-
 kernel/bpf/btf.c                            |   2 -
 lib/iov_iter.c                              | 516 ++++++++++++++------
 lib/scatterlist.c                           |  82 ++--
 lib/tests/kunit_iov_iter.c                  | 131 +++--
 38 files changed, 1453 insertions(+), 1571 deletions(-)
 delete mode 100644 Documentation/core-api/folio_queue.rst
 create mode 100644 fs/netfs/bvecq.c
 create mode 100644 include/linux/bvecq.h
 delete mode 100644 include/linux/folio_queue.h

