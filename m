Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50129 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750976Ab1ADXXf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jan 2011 18:23:35 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] nfsd4: remove outdated pathname-comments
Date: Tue,  4 Jan 2011 18:23:29 -0500
Message-Id: <1294183410-14688-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1294178391.5896.31.camel@heimdal.trondhjem.org>
References: <1294178391.5896.31.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/acl.h   |    2 --
 fs/nfsd/idmap.h |    2 --
 2 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/acl.h b/fs/nfsd/acl.h
index c9c05a7..34e5c40 100644
--- a/fs/nfsd/acl.h
+++ b/fs/nfsd/acl.h
@@ -1,6 +1,4 @@
 /*
- *  include/linux/nfs4_acl.c
- *
  *  Common NFSv4 ACL handling definitions.
  *
  *  Copyright (c) 2002 The Regents of the University of Michigan.
diff --git a/fs/nfsd/idmap.h b/fs/nfsd/idmap.h
index d4a2ac1..5147589 100644
--- a/fs/nfsd/idmap.h
+++ b/fs/nfsd/idmap.h
@@ -1,6 +1,4 @@
 /*
- *  include/linux/nfsd_idmap.h
- *
  *  Mapping of UID to name and vice versa.
  *
  *  Copyright (c) 2002, 2003 The Regents of the University of
-- 
1.7.1

