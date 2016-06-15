Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:36137 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933127AbcFOSdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jun 2016 14:33:17 -0400
Received: by mail-yw0-f193.google.com with SMTP id w195so2706788ywd.3
        for <linux-nfs@vger.kernel.org>; Wed, 15 Jun 2016 11:33:17 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/3] pnfs/nfsd: have client and server support multiple layout types
Date: Wed, 15 Jun 2016 14:33:08 -0400
Message-Id: <1466015591-23818-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v3:
- use sort() from lib/sort.c to sort the list

v2:
- rework Tigran's patch to preserve existing selection behaviour
- simplify layout driver selection by sorting the list

This is v3 of the patchset. The main change is that this patch doesn't
use a hand-rolled bubble sort, but rather the heapsort library in
lib/sort.c. This is mostly for conciseness since the array sizes are
generally so small that it shouldn't make any perf difference.

Note that this does mean that we need to keep track on the number of
elements in the array that the server sends, so there are a few
ancillary changes to deal with that as well.

Only lightly tested by mounting a server that sends both flexfiles and
block layouts. The client successfully selected the block layout in most
cases, but if I blacklist blocklayoutdriver then it selects flexfiles
instead.

I'm sending these together, but I'd expect Bruce to pick up the nfsd
patches and Trond or Anna to pick up the client-side ones.

The nfsd patch is based on top of Tom's nfsd flexfile layout patches.

Jeff Layton (3):
  nfsd: allow nfsd to advertise multiple layout types
  pnfs: track multiple layout types in fsinfo structure
  pnfs: add a new mechanism to select a layout driver according to an
    ordered list

 fs/nfs/client.c         |  3 ++-
 fs/nfs/nfs4proc.c       |  3 ++-
 fs/nfs/nfs4xdr.c        | 40 +++++++++++++++--------------
 fs/nfs/pnfs.c           | 67 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/pnfs.h           |  5 ++--
 fs/nfsd/export.c        |  4 +--
 fs/nfsd/export.h        |  2 +-
 fs/nfsd/nfs4layouts.c   |  6 ++---
 fs/nfsd/nfs4proc.c      |  4 +--
 fs/nfsd/nfs4xdr.c       | 30 +++++++++++-----------
 include/linux/nfs_xdr.h |  8 +++++-
 11 files changed, 112 insertions(+), 60 deletions(-)

-- 
2.5.5

