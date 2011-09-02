Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:33620 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab1IBQnv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2011 12:43:51 -0400
Received: by qyk15 with SMTP id 15so812163qyk.19
        for <linux-nfs@vger.kernel.org>; Fri, 02 Sep 2011 09:43:50 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/3] NFSD patches to support junctions
To: linux-nfs@vger.kernel.org
Date: Fri, 02 Sep 2011 12:38:13 -0400
Message-ID: <20110902162210.32190.5880.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sometime soon we are going to have easy-to-install user space FedFS
components.  Here are kernel patches needed to make server-side FedFS
support work.  Please consider these for the 3.2 kernel.

The third patch introduces a potentially expensive check to see if
a junction has been encountered during a mountpoint lookup.  An object
is a junction iff it has the requisite set of extended attributes.
However, reading an extended attribute is expensive on some file
systems.

To mitigate the cost of this check, junctions always have their sticky
bit set.  The expensive extended attribute part of the junction test
is done only if the sticky bit is present.

Note that today junctions are directories, but someday symlinks might
also act as junctions (for SMB2 support).  And very few files have the
sticky bit set.  So we avoid doing a directory test here.

Also, junctions ostensibly have all zero mode bits to hide their local
contents.  I don't think the kernel needs to be concerned about the
permissions as long as the sticky bit is set.  This allows some
flexibility in how junctions are represented.  However, Jeff thinks
that having nfsd4_is_junction() also consider mode bits would make the
expensive part of this test still less frequent.

Any thoughts about this?

---

Trond Myklebust (3):
      NFSD: Add a cache for fs_locations information
      NFSD: Remove the ex_pathname field from struct svc_export
      NFSD: Cleanup for nfsd4_path()


 fs/nfsd/export.c            |   15 +-----
 fs/nfsd/nfs4xdr.c           |  106 ++++++++++++++++++++++++++++++++-----------
 fs/nfsd/nfsd.h              |    7 +++
 fs/nfsd/vfs.c               |   16 ++++++
 include/linux/nfsd/export.h |    2 -
 5 files changed, 104 insertions(+), 42 deletions(-)

-- 
Chuck Lever
