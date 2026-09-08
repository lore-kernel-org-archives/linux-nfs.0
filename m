Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A9C1D4FC8D2
	for <linux-nfs@vger.kernel.org>; Tue,  8 Sep 2026 09:10:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788858652; cv=none; b=pv5w0+Exmnunk58YYFl0ivdxnmsK12UZWthK3FOWIg3AD6tx9+jmVqXqC05l+OESmVUQPeNAcBAsuu+Ivi8QvMUwpncnqgQ34ujDEMoPnD04B1dINerRiYWtNB1PqRqLPmCrxZTcyaWQml60gq7ZJFaot9j2ZqLqUwNHvgzNric=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788858652; c=relaxed/simple;
	bh=8tSqHlLIXJuWsBQYydJqqwZT5KxUO6DtIPiXjOTGxhs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=OFjZ/uNj9BHQYWKYTtEnRFtAnwmxG7tKNYJuc+CCjOAFr6zZ64akxaGuLz2wA+5abPkfjJBzf/GyHBw8bw/fc+RrgxMUmdEvn5xWH0QITF9lDfNIUW027qbCgofb8N1p32ovfJI9Jqda49r8f0HCgRcD2RFQgytJNpi+fS9VYjg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=KUjORkIJ; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="KUjORkIJ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788858649;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=C0xiqVZ1UP4oD+0sq73SGDSnEeFESxAGnTexw/YKrQk=;
	b=KUjORkIJa4E/ykNDHABHr13XRt+/APnq1Xjrg5KVEWNSPnyKjxOdctRSMBP3AsTSsj8QBR
	RHg5i5To/KgSZOmUibgbmIMBBezZS/BMmN77WDNaEJYTjxlmXhJwX5FCrKR9l1lcRLREme
	C7NFJ6jZWUJcNraEy69IDjBaPzvReFA=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-522-Z9G_OryfNLuOMVNfyLh3Ag-1; Tue,
 08 Sep 2026 05:10:46 -0400
X-MC-Unique: Z9G_OryfNLuOMVNfyLh3Ag-1
X-Mimecast-MFC-AGG-ID: Z9G_OryfNLuOMVNfyLh3Ag_1788858644
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4B2B31834595;
	Tue,  8 Sep 2026 09:10:43 +0000 (UTC)
Received: from warthog.com (unknown [10.44.32.158])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 3AA8430001A2;
	Tue,  8 Sep 2026 09:10:34 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Paulo Alcantara <pc@manguebit.org>
Cc: David Howells <dhowells@redhat.com>,
	Christian Brauner <christian@brauner.io>,
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
Subject: [PATCH v12 0/8] netfs: Miscellaneous preparatory changes
Date: Tue,  8 Sep 2026 10:10:21 +0100
Message-ID: <20260908091031.1506798-1-dhowells@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

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
ver #12)
- Split from v11 of "netfs: Keep track of folios in a segmented bio_vec[]
  chain"[1]

[1] https://lore.kernel.org/r/20260902173350.3468672-1-dhowells@redhat.com/

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
 fs/netfs/buffered_read.c          |  35 ++++----
 fs/netfs/buffered_write.c         |  66 +++------------
 fs/netfs/direct_read.c            |  14 ++--
 fs/netfs/direct_write.c           |   8 +-
 fs/netfs/fscache_cookie.c         |   8 +-
 fs/netfs/fscache_io.c             |  10 +--
 fs/netfs/internal.h               |  67 ++++++++++++---
 fs/netfs/iterator.c               |   2 +-
 fs/netfs/main.c                   |   1 -
 fs/netfs/misc.c                   |  10 +--
 fs/netfs/objects.c                |   6 +-
 fs/netfs/read_collect.c           |  14 ++--
 fs/netfs/read_pgpriv2.c           |  13 ++-
 fs/netfs/read_retry.c             |   5 +-
 fs/netfs/read_single.c            |  11 +--
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
 35 files changed, 324 insertions(+), 451 deletions(-)

