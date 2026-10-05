Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3FE037755A
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 07:12:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791184375; cv=none; b=uX4kBFggRmXmZeQy/H76u7P92skVgDB6hRWcQUv7bQd+ZGhbJb54Hx/VnHqfGmjIh2Db4vsvh1js8k2+ftGsS077gybkzKfnjg6WIduCaigQONuZXdn+Ugn72mclWvOevtoYYK+1lZSDTRna3EaJv6oMu+p0E+pQjEs1EdQy4e4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791184375; c=relaxed/simple;
	bh=0TFVNxlW3vvQr0CysToctEJKeYMjBvQLlIgyergyrlM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=b0NR46/XyrV74pPtmhB+B2IFKnG/5GXm2xegHXfG0Lu1PSLqZ1CABOZTxmIny/QnT8bmsOvbRMrHTAh1L7LO3LDPOePnYTDp6z+ISu6a2F33EDjIwp1y+LNHDl48m6IToE5Ttt9n9NWxTSso5QrT59dibp2HCs9ygwqvqjFVIf4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=fPFlxpxc; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="fPFlxpxc"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1791184373;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=un0sOdMzGIB0ugj0c9sRuvRA31Lh2M8UPL/TEXn4uR4=;
	b=fPFlxpxcAhsIFhQc/4tJdYCG4eMQD0iycILYXpEeJPqaJY1yZCFFKytzNrk1f3sAI3+a61
	sqImo7PVvmF07T1sI+zODM1YoI7jILJIyNtFcS+BT0y7hbk0Ycc17eQeo0zJKN1qed3fF+
	6NJoG2DoeqH0wD4kc1LfFX0FFKAxDzc=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-25-hbnd5JVLMZS7HNUkhIydkw-1; Mon,
 05 Oct 2026 03:12:47 -0400
X-MC-Unique: hbnd5JVLMZS7HNUkhIydkw-1
X-Mimecast-MFC-AGG-ID: hbnd5JVLMZS7HNUkhIydkw_1791184365
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 823841955BED;
	Mon,  5 Oct 2026 07:12:44 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.90])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9D51D1956087;
	Mon,  5 Oct 2026 07:12:37 +0000 (UTC)
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
Subject: [PATCH v12 0/8] netfs: Use a bvecq chain position abstraction
Date: Mon,  5 Oct 2026 08:12:17 +0100
Message-ID: <20261005071227.147182-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

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
ver #12)
- Split from v11 of "netfs: Keep track of folios in a segmented bio_vec[]
  chain"[1]

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com/

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
 fs/netfs/buffered_read.c       | 169 ++++++++------
 fs/netfs/bvecq.c               | 310 ++++++++++++++++++++++++++
 fs/netfs/direct_read.c         |  77 +++----
 fs/netfs/direct_write.c        |  67 +++---
 fs/netfs/internal.h            |   4 +-
 fs/netfs/iterator.c            | 392 ++++++++++-----------------------
 fs/netfs/misc.c                |  18 --
 fs/netfs/objects.c             |  16 +-
 fs/netfs/read_collect.c        |  92 ++++----
 fs/netfs/read_pgpriv2.c        |  87 +++++---
 fs/netfs/read_retry.c          |  86 ++++----
 fs/netfs/read_single.c         |  16 +-
 fs/netfs/rolling_buffer.c      | 182 ---------------
 fs/netfs/write_collect.c       |  55 ++---
 fs/netfs/write_issue.c         | 166 +++++++++-----
 fs/netfs/write_retry.c         |  61 +++--
 include/linux/bvecq.h          | 184 ++++++++++++++++
 include/linux/netfs.h          |  25 ++-
 include/linux/pagemap.h        |  10 +
 include/linux/rolling_buffer.h |  47 ----
 include/trace/events/netfs.h   |  32 ++-
 mm/readahead.c                 |   5 +
 26 files changed, 1195 insertions(+), 930 deletions(-)
 delete mode 100644 fs/netfs/rolling_buffer.c
 delete mode 100644 include/linux/rolling_buffer.h

