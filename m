Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.179.29]:38097 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754576Ab0BQUFO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Feb 2010 15:05:14 -0500
Subject: [PATCH 0/2] commit_metadata export operation v6
To: bfields@fieldses.org
From: Ben Myers <bpm@sgi.com>
Cc: linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Date: Wed, 17 Feb 2010 14:05:05 -0600
Message-ID: <20100217200426.13409.32688.stgit@case>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Bruce,

Here is the latest version of the knfsd sync changes.  I have addressed the
suggestions provided by Christoph, Trond, Dave, and Alex.

In this latest version I have fixed up the few nits in the nfsd patch that
Christoph pointed out yesterday.  I also have simplified the xfs patch as
suggested by Dave.

Thanks,
	Ben
---

Ben Myers (2):
      commit_metadata export operation replacing nfsd_sync_dir
      xfs_export_operations.commit_metadata


 fs/nfsd/nfs4recover.c         |    4 --
 fs/nfsd/vfs.c                 |  106 ++++++++++++++++++++---------------------
 fs/xfs/linux-2.6/xfs_export.c |   20 ++++++++
 include/linux/exportfs.h      |    5 ++
 4 files changed, 78 insertions(+), 57 deletions(-)

-- 
Signature
