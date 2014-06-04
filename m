Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40026 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751329AbaFDVe5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 17:34:57 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/4] miscellaneous patches for 3.16
Date: Wed,  4 Jun 2014 17:34:51 -0400
Message-Id: <1401917695-8309-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

This is some miscellaneous additional cleanup I intend to queue up for
3.16.

--b.

J. Bruce Fields (4):
  nfsd4: simplify server xdr->next_page use
  nfsd4: kill READ32
  nfsd4: kill READ64
  nfs4: remove unused CHANGE_SECURITY_LABEL

 fs/nfs/nfs4proc.c    |    2 +-
 fs/nfsd/nfs4proc.c   |    2 +-
 fs/nfsd/nfs4xdr.c    |  288 +++++++++++++++++++++++++-------------------------
 include/linux/nfs4.h |    2 -
 net/sunrpc/xdr.c     |    6 +-
 5 files changed, 148 insertions(+), 152 deletions(-)

-- 
1.7.9.5

