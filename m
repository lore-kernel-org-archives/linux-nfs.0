Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f181.google.com ([209.85.223.181]:57508 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754375AbaAaU7c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jan 2014 15:59:32 -0500
Received: by mail-ie0-f181.google.com with SMTP id to1so4849595ieb.12
        for <linux-nfs@vger.kernel.org>; Fri, 31 Jan 2014 12:59:32 -0800 (PST)
Message-ID: <1391201970.6978.1.camel@leira.trondhjem.org>
Subject: Re: NFS client broken in Linus' tip
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>, linux-arm-kernel@lists.infradead.org
Date: Fri, 31 Jan 2014 15:59:30 -0500
In-Reply-To: <20140130153812.GA15937@n2100.arm.linux.org.uk>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
	 <20140130141405.GA23985@infradead.org>
	 <20140130142752.GX15937@n2100.arm.linux.org.uk>
	 <20140130143208.GB9573@infradead.org>
	 <20140130153812.GA15937@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2014-01-30 at 15:38 +0000, Russell King - ARM Linux wrote:
> On Thu, Jan 30, 2014 at 06:32:08AM -0800, Christoph Hellwig wrote:
> > On Thu, Jan 30, 2014 at 02:27:52PM +0000, Russell King - ARM Linux wrote:
> > > Yes and no.  I still end up with an empty /etc/mtab, but the file now
> > > exists.  However, I can create and echo data into /etc/mtab, but it seems
> > > that can't happen at boot time.
> > 
> > Odd.  Can you disable CONFIG_NFSD_V3_ACL for now to isolate the issue?
> 
> Unfortunately, that results in some problem at boot time, which
> ultimately ends up with the other three CPUs being stopped, and
> hence the original reason scrolls off the screen before it can be
> read... even at 1920p.
> 
Hi Russell,

The following patch fixes the issue for me.

Cheers
  Trond

8<-------------------------------------------------------------
>From 59bc20fe862bd85fcad61427e8669603e789d163 Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 31 Jan 2014 14:25:19 -0500
Subject: [PATCH] fs: get_acl() must be allowed to return EOPNOTSUPP

posix_acl_xattr_get requires get_acl() to return EOPNOTSUPP if the
filesystem cannot support acls. This is needed for NFS, which can't
know whether or not the server supports acls until it tries to get/set
one.
This patch converts posix_acl_chmod and posix_acl_create to deal with
EOPNOTSUPP return values from get_acl().

Reported-by: Russell King <linux@arm.linux.org.uk>
Link: http://lkml.kernel.org/r/20140130140834.GW15937@n2100.arm.linux.org.uk
Cc: Christoph Hellwig <hch@lst.de>
Cc: Al Viro viro@zeniv.linux.org.uk>
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/posix_acl.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/fs/posix_acl.c b/fs/posix_acl.c
index 38bae5a0ea25..11c54fd51e16 100644
--- a/fs/posix_acl.c
+++ b/fs/posix_acl.c
@@ -521,8 +521,11 @@ posix_acl_chmod(struct inode *inode, umode_t mode)
 		return -EOPNOTSUPP;
 
 	acl = get_acl(inode, ACL_TYPE_ACCESS);
-	if (IS_ERR_OR_NULL(acl))
+	if (IS_ERR_OR_NULL(acl)) {
+		if (acl == ERR_PTR(-EOPNOTSUPP))
+			return 0;
 		return PTR_ERR(acl);
+	}
 
 	ret = __posix_acl_chmod(&acl, GFP_KERNEL, mode);
 	if (ret)
@@ -544,14 +547,15 @@ posix_acl_create(struct inode *dir, umode_t *mode,
 		goto no_acl;
 
 	p = get_acl(dir, ACL_TYPE_DEFAULT);
-	if (IS_ERR(p))
+	if (IS_ERR(p)) {
+		if (p == ERR_PTR(-EOPNOTSUPP))
+			goto apply_umask;
 		return PTR_ERR(p);
-
-	if (!p) {
-		*mode &= ~current_umask();
-		goto no_acl;
 	}
 
+	if (!p)
+		goto apply_umask;
+
 	*acl = posix_acl_clone(p, GFP_NOFS);
 	if (!*acl)
 		return -ENOMEM;
@@ -575,6 +579,8 @@ posix_acl_create(struct inode *dir, umode_t *mode,
 	}
 	return 0;
 
+apply_umask:
+	*mode &= ~current_umask();
 no_acl:
 	*default_acl = NULL;
 	*acl = NULL;
-- 
1.8.5.3



-- 
Trond Myklebust
Linux NFS client maintainer

