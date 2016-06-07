Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f171.google.com ([209.85.161.171]:34361 "EHLO
	mail-yw0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbcFGKiS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2016 06:38:18 -0400
Received: by mail-yw0-f171.google.com with SMTP id c127so165463326ywb.1
        for <linux-nfs@vger.kernel.org>; Tue, 07 Jun 2016 03:38:17 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org, anna.schumaker@netapp.com, trondmy@primarydata.com
Cc: tigran.mkrtchyan@desy.de, thomas.haynes@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 0/3] pnfs/nfsd: have client and server support multiple layout types
Date: Tue,  7 Jun 2016 06:38:08 -0400
Message-Id: <1465295891-4952-1-git-send-email-jlayton@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a follow-up to the RFC set that I sent a week ago.

The basic idea is to allow the client to handle lists of layout types,
and for the server to provide them when there are multiple layout types
available for a particular filesystem.

The main change since the RFC set is to change how the client-side
layout driver selection code works. I dropped the patch that I had
written for the client and picked up Tigran's instead, and added a
patch on top to change the selection order.

Only lightly tested by mounting a server that sends both flexfiles and
block layouts. The client successfully selected the block layout in most
cases, but if I blacklist blocklayoutdriver then it selects flexfiles
instead.

I'm sending these together, but I'd expect Bruce to pick up the nfsd
patches and Trond or Anna to pick up the client-side ones.

The nfsd patch is based on top of Tom's nfsd flexfile layout patches.
Probably we should squash patches 2 and 3 before merging, but I left
them apart for now so you can see the change on top of what Tigran
originally proposed.

Jeff Layton (2):
  nfsd: allow nfsd to advertise multiple layout types
  pnfs: add a new mechanism to select a layout driver according to an
    ordered list

Tigran Mkrtchyan (1):
  pnfs support servers with multiple layout types

 fs/nfs/client.c         |  2 +-
 fs/nfs/nfs4xdr.c        | 23 +++++++--------
 fs/nfs/pnfs.c           | 76 ++++++++++++++++++++++++++++++++++++++++---------
 fs/nfs/pnfs.h           |  2 +-
 fs/nfsd/export.c        |  4 +--
 fs/nfsd/export.h        |  2 +-
 fs/nfsd/nfs4layouts.c   |  6 ++--
 fs/nfsd/nfs4proc.c      |  4 +--
 fs/nfsd/nfs4xdr.c       | 30 +++++++++----------
 include/linux/nfs_xdr.h |  8 +++++-
 10 files changed, 103 insertions(+), 54 deletions(-)

-- 
2.5.5

