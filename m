From: Jim Rees <rees@umich.edu>
Subject: Re: [PATCH] NFS: Fix build failure on !CONFIG_NFS_V3 &&
 !CONFIG_NFS_V3
Date: Sun, 1 Aug 2010 11:33:35 -0400
Message-ID: <20100801153335.GB5376@merit.edu>
References: <1280519035.12852.32.camel@heimdal.trondhjem.org>
 <20100801064415.GA10523@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from magus.merit.edu ([198.108.1.13]:48927 "EHLO magus.merit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757420Ab0HAPdh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 1 Aug 2010 11:33:37 -0400
Received: from localhost (localhost [127.0.0.1])
	by magus.merit.edu (Postfix) with ESMTP id 00D4A22528E
	for <linux-nfs@vger.kernel.org>; Sun,  1 Aug 2010 11:33:37 -0400 (EDT)
Received: from magus.merit.edu ([127.0.0.1])
	by localhost (magus.merit.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id kk7MOvqUnHDA for <linux-nfs@vger.kernel.org>;
	Sun,  1 Aug 2010 11:33:36 -0400 (EDT)
Received: from merit.edu (dsl093-001-248.det1.dsl.speakeasy.net [66.93.1.248])
	by magus.merit.edu (Postfix) with ESMTPSA id 8E1F422523A
	for <linux-nfs@vger.kernel.org>; Sun,  1 Aug 2010 11:33:36 -0400 (EDT)
In-Reply-To: <20100801064415.GA10523@elte.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ingo Molnar wrote:

  The nfs_commit_inode() prototype:
  
   #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
   extern int  nfs_commit_inode(struct inode *, int);
   extern struct nfs_write_data *nfs_commitdata_alloc(void);
   extern void nfs_commit_free(struct nfs_write_data *wdata);
   #endif
  
  is missing if the kernel is configured for legacy NFS:
  
   CONFIG_NFS_FS=y
   # CONFIG_NFS_V3 is not set
   # CONFIG_NFS_V4 is not set

I didn't even know you could do that.  Is it useful?  Should we just
disallow it?
