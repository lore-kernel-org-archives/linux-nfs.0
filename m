Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46860 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229AbbKCRZi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Nov 2015 12:25:38 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Cc: Andreas Gruenbacher <agruenba@redhat.com>
Subject: [PATCH 0/2] NFS fixes
Date: Tue,  3 Nov 2015 18:25:32 +0100
Message-Id: <1446571534-16286-1-git-send-email-agruenba@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Here are two NFS fixes that were posted as part of the richacl patch queue
before even though they are not richacl related.  Could you please review.

The initial version of the first patch was discussed in May
(http://marc.info/?l=linux-nfs&m=142987379905960&w=2).

Thanks,
Andreas

Andreas Gruenbacher (2):
  nfs: Fix GETATTR bitmap verification
  nfs: Remove unused xdr page offsets in getacl/setacl arguments

 fs/nfs/nfs4proc.c       |  5 ++---
 fs/nfs/nfs4xdr.c        | 27 +++++++++++++++++++++++++--
 include/linux/nfs_xdr.h |  2 --
 3 files changed, 27 insertions(+), 7 deletions(-)

-- 
2.5.0

