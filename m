Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57DAE3B71D1
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 16:49:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791564593; cv=none; b=Se9azAA5B0XKSv8W+OxWn08go4MSxqEef/Dkl+xZPRuBobM3V+1KC/MHyqTDC5xfCfnhbs9mo1F3sLXASr4YHb2riWrgQl5wgcCK39e72WqCGZvk8HTJQakTeOekq40G19IHZkMJGip0pf8L38A357kOa+3snssSBJO0MncRlGU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791564593; c=relaxed/simple;
	bh=0jXVhWGE7nF1HLX9arxdz521XSrxSWdBfJaQjodx3M0=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=INNjqB4GZOlkzGSkQP9cm9/rRqAgrJzsY4/n/8yU8lfHQQbVXtSmtKCRpL2Yxuqm8HUiU5WnZP0J29ujY7tM5bspNPSyA6slxmA54R1GCJDgQ2IUF6d4OAFc+zGa1HwUWx0mg97poCY4oUjCBxblXh7Qom2xaxSsCeO28EonTz4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=bNxR2f80; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="bNxR2f80"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791564588;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=EGp1nP1MOhXTinDdYneGixsmhnzN0Z/KBHwGuuFPNJU=;
	b=bNxR2f80w3CHaqDt43guZ7Pi3M7oNRqziCYCmUimSk/FxgGTnzTTM5UGO7PNG6rOKt8tnI
	ebs6wcKNSfS7279B2qDq+9Rz2OkjmVrEK7+jwPLny8F1uFA6Y3g8fYyzi4lmbNCX5nxVre
	1wY1bmX0NMo/TSpwIN83/4XJlPq5d7w=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-690-MEcRL3SNPvOI-11-hdY4rA-1; Fri,
 9 Oct 2026 16:49:37 +0000
X-MC-Unique: MEcRL3SNPvOI-11-hdY4rA-1
X-Mimecast-MFC-AGG-ID: MEcRL3SNPvOI-11-hdY4rA_1791564574
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 43AD41955D62;
	Fri,  9 Oct 2026 16:49:32 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.44.32.90])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id CCC3C471;
	Fri,  9 Oct 2026 16:49:22 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <asNeCzye-xas_Lt7@infradead.org>
References: <asNeCzye-xas_Lt7@infradead.org> <20261001091239.3343034-1-dhowells@redhat.com> <20261001091239.3343034-2-dhowells@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: dhowells@redhat.com, Christian Brauner <christian@brauner.io>,
    Paulo Alcantara <pc@manguebit.org>,
    Matthew Wilcox <willy@infradead.org>,
    Namjae Jeon <linkinjeon@kernel.org>,
    Marc Dionne <marc.dionne@auristor.com>,
    Stefan Metzmacher <metze@samba.org>,
    Eric Van Hensbergen <ericvh@kernel.org>,
    Dominique Martinet <asmadeus@codewreck.org>,
    Ilya Dryomov <idryomov@gmail.com>, netfs@lists.linux.dev,
    linux-afs@lists.infradead.org, linux-cifs@vger.kernel.org,
    linux-nfs@vger.kernel.org, ceph-devel@vger.kernel.org,
    v9fs@lists.linux.dev, linux-fsdevel@vger.kernel.org,
    linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>,
    linux-block@vger.kernel.org
Subject: Re: [PATCH v15 01/10] Add a function to kmap one page of a multipage bio_vec
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <1220023.1791564561.1@warthog.procyon.org.uk>
Content-Transfer-Encoding: quoted-printable
Date: Fri, 09 Oct 2026 17:49:21 +0100
Message-ID: <1220024.1791564561@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Christoph Hellwig <hch@infradead.org> wrote:

> I've now got 4 copies of this series in less than a week,

Sashiko is such fun.  =


> or rather partial copies as all of them seem to miss a cover letter.

Apologies for that.  I removed you from the list for the first two batches=
 of
patches because they were some internal netfs changes and cachefiles
improvements respectively, not core code; I forgot to add you back to the
cover letter for the third set.  I've attached the cover letter below so t=
hat
you can refer to it.

> Thus I still don't know how the core code in this series is tested

Four ways:

 (1) There's a kunit module, lib/tests/kunit_iov_iter.c.

 (2) -g quick xfstests on afs (with and without fscache) and cifs.

 (3) Git checkout and kernel compilation on afs (with and without fscache)=
 and
     cifs.

 (4) A bunch of different fio tests on afs (with and without fscache) and
     cifs.

The code is not directly accessible by userspace so adding xfstests to dri=
ve
it directly is not feasible.  It is also testable by 9p and to a lesser ex=
tent
nfs and ceph.

Paulo has also done some testing of these patch sets against a greater var=
iety
of cifs servers than I have available and Marc has also run tests against
Auristor's AFS servers.

> or why you've not considered using it for anything but your little corne=
r

Network filesystems are "my own little corner" and "niche"?  I explain bel=
ow
in the cover letter what I'm trying to achieve with this and where I want =
to
use it next.  It seems that I can probably achieve a 5% improvement in cif=
s
performance, for example.  There are links in the cover letter to patch se=
ts I
have for cifs and for ceph where I'm using this to improve the transport.

And I have considered rolling it out into other places - for example: pipe=
s
(instead of a ring buffer), the block layer, the networking layer (skbuff
memory lists as bvecq carries info on how to clean up the memory) and the
crypto layer (replacing scatterlists).

But I have to start somewhere - and that somewhere is in improving network
filesystems.  The main thing I'm working towards is being able to assemble=
 a
whole RPC message and then send it in one single sendmsg call without the =
need
for corking on TCP transports - where a message may be assembled as a comp=
ound
of other messages, may include sparse write data and may be huge (multiple
megabytes).

One alteration I've considered making to the bvecq (as mentioned in the
attached cover letter) is to add two additional fields, the first to add t=
o
the offset of the first slot and the second to subtract from the length of=
 the
last slot.  This would allow the use of a bvecq struct to point at a slice=
 of
someone else's bio_vec[] array without the need to copy that array.  This
might make it of more use in the block layer.

> and thus barely tested.
>
> Please slow down a bit and after the nth time please consider
> testability.  Make sure core code regular exercised uses it, or find
> a way to unit test it at least.

I wrote some kunit tests for iov_iter back in 2023 and extended them in th=
is
patch series.  May I also point out that you haven't added tests for
iov_iter_extract_bvecs() to lib/tests/kunit_iov_iter.c yet?

Granted the kunit tests could be more thorough as there's a number of thin=
gs
that aren't tested.

David
---
Cover letter:

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
the latter can only point to whole folios and cannot point to partial page=
s
that might be extracted from an ITER_IOVEC/ITER_UBUF for direct or
unbuffered I/O purposes.

These patches make a more or less straight swap between struct folio_queue
and struct bvecq.  The change is not quite trivial as the folio_queue
struct contains a folio_batch struct and is basically a list of whole
folios only, whereas the new bvecq struct is a chain of bio_vec arrays.

A further patchset will switch the netfslib unbuffered I/O code to using
bvecqs and then the bvecqs will be passed down into the filesystem rather
than passing an iterator.

The primary reason behind making this change is so that bvecq chains can b=
e
used in the assembly of network filesystem messages.  Netfslib can furnish
the filesystem with bvecq chains representing the data buffers that need t=
o
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

I have in-progress patch sets to rewrite the cifs transport[2] and the cep=
h
and rbd transport[3] to make use of bvecq chains.  With the cifs transport=
,
the idea is to extend the SMB message concept further up the stack and hav=
e
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
us firstly to avoid copying data with the socket lock held (thus holding u=
p
sendmsg) and secondly to avoid copying data in the I/O thread (copying can
be offloaded to the app thread).  The last time I benchmarked this, it
appeared to get fio reading tests on cifs a 5% speedup.

Unfortunately, this doesn't help AFS much as that uses a UDP transport, bu=
t
it might also help 9P, at least with its TCP transport.

The patches can also be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log=
/?h=3Dnetfs-next-3

Thanks,
David

Changes
=3D=3D=3D=3D=3D=3D=3D
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
  - In afs_do_read_single(), afs_dir_get_block() and afs_do_read_symlink()=
,
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

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com=
/
[2] https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/=
log/?h=3Dcifs-experimental
[3] https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/=
log/?h=3Dceph-iter
[4] https://lore.kernel.org/netdev/168979108540.1905271.972070884914979779=
3.stgit@morisot.1015granger.net/
[5] https://sashiko.dev/#/patchset/20260929075913.2740968-1-dhowells%40red=
hat.com
[6] https://sashiko.dev/#/patchset/20260929103412.2807494-1-dhowells%40red=
hat.com
[7] https://sashiko.dev/#/patchset/20260930125247.3232130-1-dhowells%40red=
hat.com

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

