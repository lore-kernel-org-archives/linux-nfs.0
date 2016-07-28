Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33710 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755622AbcG1SlM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jul 2016 14:41:12 -0400
From: Benjamin Coddington <bcodding@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "hch@infradead.org" <hch@infradead.org>
Subject: [PATCH 0/2] Two fixups for generic/207
Date: Thu, 28 Jul 2016 14:41:08 -0400
Message-Id: <cover.1469730653.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refer to the monster thread here:
http://marc.info/?t=146895837900002&r=1&w=2

Thanks very much for your help with this Trond.

Benjamin Coddington (2):
  pnfs/blocklayout: update last_write_offset in prepare_layoutcommit
  pNFS: Actively set attributes as invalid if LAYOUTCOMMIT is
    outstanding

 fs/nfs/blocklayout/extent_tree.c | 6 ++++--
 fs/nfs/inode.c                   | 8 +++++---
 2 files changed, 9 insertions(+), 5 deletions(-)

-- 
2.5.5

