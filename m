Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D7C1A37CD3A
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 07:21:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788938499; cv=none; b=nN3j46L8II6dLiHNkY4dScxGTkabGrkYt5GSpgaG0qi1GCkQt8BXK7PYp5Q5AWPFvOG0f5jQyyF3VVGtFZjo+7c8eFwp7OumeTVLDVHOfwNIXFZPCqnyWLSXUr3BOYYYWhGxCvFSyfCdrMWAddGDmTtKK3+PKk3nx6aW4iC9XDY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788938499; c=relaxed/simple;
	bh=Dq9QzC4Rw+uS4zcZFxnG/iQOlbmorYFisIjxewZuk38=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Rbd2ckhknbC+FPAC8dOz9BiRLksJqpJWaRpvjr/nhMXeI6XyTfhQrFWXzL8Mq0X7AwSpk4JlKigK6YN0wqhFgIhn4ugnVkgQJlLXlKHdR6H329lW9CCbZ8RvrephnfbmTl29Nt0D26w+lte+4RLfnuHtB+WaugiXk537k8FSVQU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=OhMgmFoI; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="OhMgmFoI"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788938491;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=NwTohl+L3wBgxbiNt8Qf67OZRjLUf9WteY3EfU1JFtw=;
	b=OhMgmFoIu3SCWLjofDcycAHdxj6fMHF61pVluPaaBdM1jN3FM+hjyGw20Lac1TfsG+ivgN
	4J9thndbSpNrTIlfRdyfGdCks0+MgvGdvq52phD+6wsVZf/rk46LyOXXiCCC/jcKhthr2Z
	+gpMcZ6mtdACQc8lhRaOmOQhn445jNk=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-608-5zXez9ViMRWllKQjIz_I_A-1; Wed,
 09 Sep 2026 03:21:28 -0400
X-MC-Unique: 5zXez9ViMRWllKQjIz_I_A-1
X-Mimecast-MFC-AGG-ID: 5zXez9ViMRWllKQjIz_I_A_1788938486
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 97D8218005B3;
	Wed,  9 Sep 2026 07:21:24 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id C1CB01800446;
	Wed,  9 Sep 2026 07:21:16 +0000 (UTC)
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
	linux-erofs@lists.ozlabs.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v13 0/8] netfs: Miscellaneous preparatory changes
Date: Wed,  9 Sep 2026 08:20:54 +0100
Message-ID: <20260909072105.1663687-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 127.0.0.2

Hi Christian,

Could you pull these patches please for -next?  This is the first of four
batches.  This is based on your vfs.fixes as there are some prerequisite
patches there.  This was split from v11 of a larger series[1].

This a collection of miscellaneous modifications to netfslib that I want to
make ahead of bigger changes, including:

 (1) Convert "unsigned long long" to "uoff_t".  This makes it a little more
     obvious as to the meaning of the value.  Also convert some "loff_t" to
     "uoff_t" as most of the time it's used the value really should never
     be negative.

 (2) Remove the writethrough code as the locking is really tricky to get
     right and it looks like it could deadlock with Ceph if snapshots are
     used.

 (3) Adjust some tracepoints, including adding the cache object ID to
     certain tracepoinits.

 (4) Make use of PG_private_2 opt-in.  Use of PG_private_2 is deprecated
     and the MM people would like their page bit back, so we need to stop
     using it soon.

 (5) Add some helper functions to handle the barriering needed for the
     NETFS_RREQ_ALL_QUEUED flag.

 (6) Set the subrequest type at allocation time so that the allocation
     trace records the proposed type.

The patches can also be found here:

	https://git.kernel.org/pub/scm/linux/kernel/git/dhowells/linux-fs.git/log/?h=netfs-next-1

Thanks,
David

Changes
=======
ver #13)
- Fixed some sashiko-raised issues:
  - Fixed netfs_mark_copy_to_cache() to use netfs_using_pgpriv2() rather
    than checking NETFS_RREQ_USE_PGPRIV2.
  - Fixed netfs_all_subreqs_queued() to do smp_mb__after_atomic() after
    setting the NETFS_RREQ_ALL_QUEUED bit.
  - Fixed netfs_single_dispatch_read() to not immediately contradict its
    own initialisation of subreq->source.

ver #12)
- Split from v11 of "netfs: Keep track of folios in a segmented bio_vec[]
  chain"[1]

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com/
[2] https://sashiko.dev/#/patchset/20260908091031.1506798-1-dhowells%40redhat.com

David Howells (8):
  netfs: Use uoff_t instead of unsigned long long and loff_t
  netfs: Remove the writethrough code
  netfs: trace: Change the "clear" folio traces to "endwb"
  netfs: trace: Rejig a couple of the tracepoints
  netfs: Add the cache object ID to netfs_read/write tracepoints
  netfs: Make deprecated PG_private_2 support opt-in
  netfs: Add some functions to wrap the all-queued handling
  netfs: Set subrequest->source at alloc before trace emission

 fs/9p/vfs_addr.c                  |   1 -
 fs/afs/file.c                     |   5 +-
 fs/cachefiles/interface.c         |  10 +--
 fs/cachefiles/internal.h          |   4 +-
 fs/cachefiles/io.c                |  25 +++---
 fs/ceph/Kconfig                   |   1 +
 fs/ceph/addr.c                    |   4 +-
 fs/netfs/Kconfig                  |   3 +
 fs/netfs/Makefile                 |   2 +-
 fs/netfs/buffered_read.c          |  37 ++++-----
 fs/netfs/buffered_write.c         |  66 +++------------
 fs/netfs/direct_read.c            |  14 ++--
 fs/netfs/direct_write.c           |   8 +-
 fs/netfs/fscache_cookie.c         |   8 +-
 fs/netfs/fscache_io.c             |  10 +--
 fs/netfs/internal.h               |  68 ++++++++++++---
 fs/netfs/iterator.c               |   2 +-
 fs/netfs/main.c                   |   1 -
 fs/netfs/misc.c                   |  10 +--
 fs/netfs/objects.c                |   6 +-
 fs/netfs/read_collect.c           |  14 ++--
 fs/netfs/read_pgpriv2.c           |  13 ++-
 fs/netfs/read_retry.c             |   5 +-
 fs/netfs/read_single.c            |  12 +--
 fs/netfs/stats.c                  |   4 +-
 fs/netfs/write_collect.c          |  25 +++---
 fs/netfs/write_issue.c            | 123 ++-------------------------
 fs/netfs/write_retry.c            |   5 +-
 fs/nfs/Kconfig                    |   1 +
 include/linux/fscache-cache.h     |   2 +-
 include/linux/fscache.h           |  36 ++++----
 include/linux/netfs.h             |  80 +++++++++---------
 include/trace/events/cachefiles.h |  30 +++----
 include/trace/events/fscache.h    |  10 +--
 include/trace/events/netfs.h      | 134 +++++++++++++++---------------
 35 files changed, 326 insertions(+), 453 deletions(-)

