Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33713 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbcFIMVN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2016 08:21:13 -0400
Received: by mail-yw0-f194.google.com with SMTP id y6so4501298ywe.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jun 2016 05:21:12 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/3] pnfs/nfsd: have client and server support multiple layout types
Date: Thu,  9 Jun 2016 08:21:02 -0400
Message-Id: <1465474865-15285-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

v2:
- rework Tigran's patch to preserve existing selection behaviour
- simplify layout driver selection by sorting the list

This is v2 of the patchset. Most of the changes are to incorporate
Bruce's suggestions on the client code. Original cover letter follows:

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

 fs/nfs/client.c         |  2 +-
 fs/nfs/nfs4xdr.c        | 23 +++++++---------
 fs/nfs/pnfs.c           | 72 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/pnfs.h           |  4 +--
 fs/nfsd/export.c        |  4 +--
 fs/nfsd/export.h        |  2 +-
 fs/nfsd/nfs4layouts.c   |  6 ++---
 fs/nfsd/nfs4proc.c      |  4 +--
 fs/nfsd/nfs4xdr.c       | 30 ++++++++++-----------
 include/linux/nfs_xdr.h |  7 ++++-
 10 files changed, 101 insertions(+), 53 deletions(-)

-- 
2.5.5

