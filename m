From: David Woodhouse <dwmw2@infradead.org>
Subject: [GIT *] fsid/uuid fixes
Date: Wed, 20 Aug 2008 11:56:27 +0100
Message-ID: <1219229787.2988.108.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:39868 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752175AbYHTK43 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2008 06:56:29 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please pull from git://git.infradead.org/users/dwmw2/nfs-utils.git

This fixes the handling of explicit 16-byte fsid given in exportfs
options, and also makes mountd find an fsid from statfs() where the
kernel provides one.

I wonder if we should use the fsid from statfs() in _preference_ to
using libblkid, since 

David Woodhouse (4):
      Fix handling of explicit uuid
      Explicit UUID handling doesn't require blkid; factor out get_uuid_blkdev()
      Use fsid from statfs for UUID if blkid can't cope (or not used)
      Stop exportfs warning about needing fsid, when we actually have one

 support/nfs/exports.c     |    2 +-
 utils/exportfs/exportfs.c |   10 +++++-
 utils/mountd/cache.c      |   89 +++++++++++++++++++++++++++------------------
 3 files changed, 63 insertions(+), 38 deletions(-)

-- 
David Woodhouse                            Open Source Technology Centre
David.Woodhouse@intel.com                              Intel Corporation



