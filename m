Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:52847 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752632Ab2HAN3f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Aug 2012 09:29:35 -0400
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Subject: [PATCH 0/2] Fix bugs and clean code in __nfs4_get_acl_uncached
Date: Wed,  1 Aug 2012 14:29:29 +0100
Message-Id: <1343827771-6258-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Split the bug fixes and code cleanup into separate patches asi
requested in
http://www.spinics.net/lists/linux-nfs/msg31677.html

Fix bugs in function __nfs4_get_acl_uncached and clean up code to make
it easier to understand.

Sachin Prabhu (2):
  Fix array overflow in __nfs4_get_acl_uncached
  Simplify check for size of ACL returned in __nfs4_get_acl_uncached

 fs/nfs/nfs4proc.c       | 18 +++++++++---------
 fs/nfs/nfs4xdr.c        |  4 +++-
 include/linux/nfs_xdr.h |  2 +-
 3 files changed, 13 insertions(+), 11 deletions(-)

-- 
1.7.11.2

