Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24594 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983Ab0FGF10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jun 2010 01:27:26 -0400
From: Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: bhalevy@panasas.com, Alexandros Batsakis <batsakis@netapp.com>
Subject: [PATCH 0/8] pnfs-submit: forgetful client v2
Date: Wed,  5 May 2010 10:00:50 -0700
Message-Id: <1273078858-1923-1-git-send-email-batsakis@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This set of patches (2.6.35-rc1) includes a first attempt to implement 
the forgetful client model for the pNFS client. The model 
is explained is patch 7.
It also includes some minor cleanups in the layout management code 
that help to improve the maintanability of the current code.

Passed cthon tests against the pyNFS server, and against a modified 
version of  pyNFS server that randomly issues layout recalls after opens.

Alexandros Batsakis (8):
  pnfs-submit: clean struct nfs_inode
  pnfs-submit: clean locking infrastructure
  pnfs-submit: remove lgetcount, lretcount (outstanding
    LAYOUTGETs/LAYOUTRETUNs)
  pnfs-submit: change stateid to be a union
  pnfs-submit: request whole file layouts only
  pnfs-submit: change layouts list to be similar to the other state
    list management
  pnfs-submit: forgetful client model
  pnfs-submit: support for cb_recall_any (layouts)

 fs/nfs/callback.h         |    7 +
 fs/nfs/callback_proc.c    |  231 +++++++++++++++++++++++++++++---------
 fs/nfs/callback_xdr.c     |    2 +-
 fs/nfs/client.c           |    2 +-
 fs/nfs/delegation.c       |   19 ++--
 fs/nfs/inode.c            |   16 ++-
 fs/nfs/nfs4_fs.h          |    1 +
 fs/nfs/nfs4proc.c         |   46 +++++---
 fs/nfs/nfs4state.c        |    4 +-
 fs/nfs/nfs4xdr.c          |   38 ++++---
 fs/nfs/pnfs.c             |  276 +++++++++++++++++++++------------------------
 fs/nfs/pnfs.h             |    3 +-
 fs/nfsd/nfs4callback.c    |    1 -
 include/linux/nfs4.h      |   16 +++-
 include/linux/nfs4_pnfs.h |    2 +-
 include/linux/nfs_fs.h    |   28 ++---
 include/linux/nfs_fs_sb.h |    2 +-
 17 files changed, 417 insertions(+), 277 deletions(-)

