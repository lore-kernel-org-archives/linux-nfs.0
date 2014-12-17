Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:7211 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750949AbaLQWfI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2014 17:35:08 -0500
From: <Anna.Schumaker@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/4] NFS: Add READ_PLUS support
Date: Wed, 17 Dec 2014 17:35:00 -0500
Message-ID: <1418855704-14127-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

These patches add server support for the NFS v4.2 operation READ_PLUS.

I noticed a race condition in the 3rd patch when I start needing vfs_llseek()
to determine if I should encode the next segment as either data or a hole.  It
is possible that the file could change on us between each of the seek calls,
so we don't know if we are actually at a hole or data segment.  I don't want to
add new locks to the NFS server for this case, so instead I've decided to
encode any "quantum data" segments as if they were actually data.

I tested these patches using xfstests, specificially generic/075, generic/091,
generic/112, generic/127, generic/210, and generic/263.  Additionally, three
new tests are run once READ_PLUS support has been added: generic/213,
generic/214, and generic/228.

These patches and the corresponding client changes are available in the
[read_plus] branch of

	git://git.linux-nfs.org/projects/anna/linux-nfs.git

Questions?  Comments?  Thoughts?

Anna


Anna Schumaker (4):
  NFSD: nfsd4_encode_read() should encode eof and maxcount
  NFSD: Add READ_PLUS support for data segments
  NFSD: Add support for encoding holes in files
  NFSD: Add support for encoding multiple segments

 fs/nfsd/nfs4proc.c |  16 +++++
 fs/nfsd/nfs4xdr.c  | 174 +++++++++++++++++++++++++++++++++++++++++------------
 2 files changed, 152 insertions(+), 38 deletions(-)

-- 
2.1.3

