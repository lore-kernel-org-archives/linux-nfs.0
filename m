Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 19184490BF0
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 14:20:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791382854; cv=none; b=CnqNH02D05QewUmirSeenheMNJF0yv0p/WtBMx0wuFZo+NZz1uxb4gHVy+6JuqSkUZSksC1biPzf5iEUoYD5bd4QTSLdSlkKWTsQ/yb5TmCM8jt07xlTljXHxJjZ1SUCIH2LSFLoi8oI/c9uiEviEfq3WI3yZffs63jhyGrXg+Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791382854; c=relaxed/simple;
	bh=Img5ceWy3Ij5+EzwqTMQrksyAsso0ppmZ+Upiv789nQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=FH8nKhjhk4Ru/RreHGN8kbkLyeaysH+SJg2FoM+3iMhiRCp0NNgKtBeqPGh0FiHpcLme86zf5MlvkQx/D4fUg9PSzPPyjT8ufi0ArxwsQ1ZXdDV3Cd4aCye50458Emf3Gpoyek74qvjV+ZSY0FzPd+reXFtqJ6zyzYPzvxLSVzU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=LldpNNeO; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="LldpNNeO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791382843;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=OFr91dh5MiEqI6gHFvhW8bYz6YakTcwxHJ7Vnu5msnM=;
	b=LldpNNeOrqK4guQWeWRnmsfnyaGz+0h2NuRIDOygnjMkP2XQkCE2crdID3M+HIsXEBgMOR
	1pjFbX/0YZxEODvZCkTd80fvy9wnutYQO/uRMg8JhGxWwpfV1RTnCE/Ukf1nDjw5UkGYWT
	Widl45iUB2lYWTl+2KgeseF4z9sXDv4=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-622-f9bdVKTKOA-xg0Cmg1QDxw-1; Wed,
 07 Oct 2026 10:20:38 -0400
X-MC-Unique: f9bdVKTKOA-xg0Cmg1QDxw-1
X-Mimecast-MFC-AGG-ID: f9bdVKTKOA-xg0Cmg1QDxw_1791382835
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0BF72188B015;
	Wed,  7 Oct 2026 14:20:16 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A2E0F19373D8;
	Wed,  7 Oct 2026 14:20:04 +0000 (UTC)
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
Subject: [PATCH v14 0/8] netfs: Use a bvecq chain position abstraction
Date: Wed,  7 Oct 2026 15:19:51 +0100
Message-ID: <20261007142001.851620-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

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
 fs/netfs/bvecq.c               | 321 +++++++++++++++++++++++++++
 fs/netfs/direct_read.c         |  77 +++----
 fs/netfs/direct_write.c        |  67 +++---
 fs/netfs/internal.h            |   4 +-
 fs/netfs/iterator.c            | 395 ++++++++++-----------------------
 fs/netfs/misc.c                |  18 --
 fs/netfs/objects.c             |  16 +-
 fs/netfs/read_collect.c        | 106 +++++----
 fs/netfs/read_pgpriv2.c        |  87 +++++---
 fs/netfs/read_retry.c          |  86 ++++---
 fs/netfs/read_single.c         |  16 +-
 fs/netfs/rolling_buffer.c      | 182 ---------------
 fs/netfs/write_collect.c       |  55 ++---
 fs/netfs/write_issue.c         | 166 +++++++++-----
 fs/netfs/write_retry.c         |  61 +++--
 include/linux/bvecq.h          | 184 +++++++++++++++
 include/linux/netfs.h          |  25 ++-
 include/linux/pagemap.h        |  10 +
 include/linux/rolling_buffer.h |  47 ----
 include/trace/events/netfs.h   |  32 ++-
 mm/readahead.c                 |   5 +
 26 files changed, 1225 insertions(+), 941 deletions(-)
 delete mode 100644 fs/netfs/rolling_buffer.c
 delete mode 100644 include/linux/rolling_buffer.h

