Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB0E547207A
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 08:47:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791449267; cv=none; b=p95H8VLKSnhP/7yG4evT5pKYV9cTeZqnQOb2d5sVislmL179vln0RmtOeSxM+5kKXCDeibT/bliPSW5SbzqqeEbyzK5lxngCipcdQv2rbH7RCNVC6Cdcx/g2fc4iZf13oK0q04wrMYpRQY79OJO9Jjpm13LW/Kz+6Vn5GI5f1G0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791449267; c=relaxed/simple;
	bh=1WMDWBddNxNL2oww1pXHRJ4rRd4Aawnc1bGQ875JeXs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Yh2CYhOq858qnUmY3Xs1Yem8QlTg89GVYoYb8fjPGaWPAMiidHIrdVDPg5wJYL1DUsnq6ERj1bPwUBkFVAhQsSJy3IVgGq06JXhF1pWJ1ZsuHGOUvDHEXps6aFsZbwWNw+JskjYayn4xuCs+3IgpAmRlIbVTvFYp/0mbb/t4iYI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=DlQZBMBC; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="DlQZBMBC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791449262;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=KpFJK4vkGRfH8FgpPwov7A4K25kXa/weKSZ5pJxpO+c=;
	b=DlQZBMBCJzUMNluIE0gB+d+6TY+7UhbEsAyeA5MsdL5glev1F3nKKdeBnizREgXAKP8KzV
	VEXbUaVnLLHS9UVBX6/qXcCKbQQPpS7qdhIP3qSOFysXN2OCDVliwrTstDKSeLwWvLkh2S
	qP5qu6z8U6R5p2Rw/5+pHzg0JNL9/ms=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-296-GZxdPCW2MfaHyx-NoXGPJg-1; Thu,
 08 Oct 2026 04:47:39 -0400
X-MC-Unique: GZxdPCW2MfaHyx-NoXGPJg-1
X-Mimecast-MFC-AGG-ID: GZxdPCW2MfaHyx-NoXGPJg_1791449256
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id D96691955F7A;
	Thu,  8 Oct 2026 08:47:35 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9164730001A2;
	Thu,  8 Oct 2026 08:47:28 +0000 (UTC)
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
Subject: [PATCH v16 0/8] netfs: Use a bvecq chain position abstraction
Date: Thu,  8 Oct 2026 09:47:12 +0100
Message-ID: <20261008084722.963948-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Hi Christian,

Could you pull these patches please into your vfs-7.4.netfs branch?  This
is the fourth of five batches.  The primary purpose of this batch is to add
an abstraction for a position in a bvecq chain and make use of it.

With that in mind, this patchset does the following:

 (1) Add a struct, bvecq_pos, to refer to a position in a bvecq chain.
     This is a tuple of ( bvecq pointer, slot and offset } and the position
     struct holds (for now) a ref on the bvecq pointed to.

 (2) Change unbuffered/DIO to extract the supplied user buffers into a
     bvecq chain rather than a bio_vec[] up front.  This means that
     netfslib then uses bvecq chains for everything.

 (3) Add a folio count to the readahead_control struct and then makes
     readahead pre-create its buffer using that count to determine how many
     slots are required.

 (4) Change netfslib to use the bvecq_pos struct to keep track of the whole
     request buffer and various points in it where loading, dispatch and
     collection are taking place and to also keep track of the slice given
     to each subrequest.

This was split from v11 of a larger netfslib series[1].

The patches can also be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=netfs-next-4

Thanks,
David

Changes
=======
ver #16)
- Fixed issues brought up by sashiko[4]:
  - In bvecq_pos_nudge(), recheck the old bvecq, not the new one.
  - In bvecq_slice(), recheck the old bvecq.
  - In bvecq_pos_step(), don't assume the new bvecq has slots, but rather
    check it.

ver #15)
- In netfs_extract_iter(), set BVECQ_MEM_EXTERNAL rather than
  BVECQ_MEM_PAGECACHE for unpinned memory.
- In netfs_clear_unread_dio(), don't need to update subreq->transferred
  as the caller overwrites it after.
- Fixed issues brought up by sashiko[3]:
  - In netfs_extract_iter(), remove redundant max_len check.
  - In bvecq_pos_nudge(), make sure the recheck is checking the old bvecq,
    not the new.
  - In netfs_unlock_abandoned_read_pages(), start from collect_cursor.slot,
    not from slot zero.
  - In netfs_pgpriv2_copy_to_cache(), cancel the caching also if we fail to
    allocate a bvecq.
  - In netfs_retry_write_stream(), use the same superfluity detection as
    the read side.
  - In netfs_write_subrequest_terminated(), only set the RETRY flag on
    short uploads, not short cache writes.

ver #14)
- Fixed issues brought up by sashiko[2]:
  - In netfs_extract_iter(), limit the number of slots per bvecq to what
    will fit inside a 4KiB allocation.
  - In netfs_rreq_assess_dio(), only set the page dirty if it's from GUP or
    it's from the pagecache.
  - In bvecq_zero(), skip the call to bvec_zero() if part == 0.
  - In bvecq_delete_spent(), prefer returning true because more slots got
    added to returning false because we hit the chain end.
  - In netfs_read_gaps(), fix a leak of already allocated sink folios if we
    get OOM when allocating a sink folios.
  - In netfs_clear_unread_dio(), fix double call to iov_iter_zero().

ver #13)
- Rebased on -rc6 to account for some conflicting fixes.
- Fixed a bug in netfs_prepare_read_iterator() where comparison was being
  made against the wrong thing when limiting a subreq's size.

ver #12)
- Split from v11 of "netfs: Keep track of folios in a segmented bio_vec[]
  chain"[1]

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com/
[2] https://sashiko.dev/#/patchset/20261006205947.608356-1-dhowells%40redhat.com
[3] https://sashiko.dev/#/patchset/20261007142001.851620-1-dhowells%40redhat.com
[4] https://sashiko.dev/#/patchset/20261008074346.936909-1-dhowells%40redhat.com

David Howells (8):
  mm: Make readahead store folio count in readahead_control
  netfs: Add a function to extract from an iter into a bvecq
  netfs: Make unbuffered/DIO read and write use bvecq
  netfs: Add some tools for managing a position in a bvecq chain
  netfs: Provide a func to load the readahead buffers into a bvecq chain
  netfs: Use bvecq_pos to hold the buffer positions
  netfs: Remove the rolling_buffer implementation
  netfs: Remove netfs_extract_user_iter()

 fs/afs/dir.c                   |   5 +-
 fs/afs/symlink.c               |   6 +-
 fs/cachefiles/io.c             |  12 -
 fs/netfs/Makefile              |   1 -
 fs/netfs/buffered_read.c       | 182 ++++++++-------
 fs/netfs/bvecq.c               | 322 ++++++++++++++++++++++++++
 fs/netfs/direct_read.c         |  77 +++----
 fs/netfs/direct_write.c        |  67 +++---
 fs/netfs/internal.h            |   4 +-
 fs/netfs/iterator.c            | 398 ++++++++++-----------------------
 fs/netfs/misc.c                |  18 --
 fs/netfs/objects.c             |  16 +-
 fs/netfs/read_collect.c        | 106 +++++----
 fs/netfs/read_pgpriv2.c        |  88 +++++---
 fs/netfs/read_retry.c          |  87 ++++---
 fs/netfs/read_single.c         |  16 +-
 fs/netfs/rolling_buffer.c      | 182 ---------------
 fs/netfs/write_collect.c       |  73 +++---
 fs/netfs/write_issue.c         | 166 +++++++++-----
 fs/netfs/write_retry.c         |  73 +++---
 include/linux/bvecq.h          | 185 +++++++++++++++
 include/linux/netfs.h          |  25 ++-
 include/linux/pagemap.h        |  10 +
 include/linux/rolling_buffer.h |  47 ----
 include/trace/events/netfs.h   |  32 ++-
 mm/readahead.c                 |   5 +
 26 files changed, 1253 insertions(+), 950 deletions(-)
 delete mode 100644 fs/netfs/rolling_buffer.c
 delete mode 100644 include/linux/rolling_buffer.h

