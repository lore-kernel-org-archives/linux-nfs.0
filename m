Return-Path: linux-nfs-owner@vger.kernel.org
Received: from g4t0014.houston.hp.com ([15.201.24.17]:14631 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1162134Ab3DEQ6R (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Apr 2013 12:58:17 -0400
From: Waiman Long <Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, autofs@vger.kernel.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, linux-nfs@vger.kernel.org,
        "Chandramouleeswaran, Aswin" <aswin@hp.com>,
        "Norton, Scott J" <scott.norton@hp.com>,
        Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>
Subject: [PATCH v2 4/4] dcache: don't need to take d_lock in prepend_path()
Date: Fri,  5 Apr 2013 12:57:41 -0400
Message-Id: <1365181061-30787-5-git-send-email-Waiman.Long@hp.com>
In-Reply-To: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
References: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Jeff Layton <jlayton@redhat.com>,
        Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
        Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Eric Paris <eparis@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The d_lock was used in prepend_path() to protect dentry->d_name from
being changed under the hood. As the caller of prepend_path() has
to take the rename_lock before calling into it, there is no chance
that d_name will be changed. The d_lock lock is only needed when the
rename_lock is not taken.

Signed-off-by: Waiman Long <Waiman.Long@hp.com>
---
 fs/dcache.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/fs/dcache.c b/fs/dcache.c
index 9477d80..e3d6543 100644
--- a/fs/dcache.c
+++ b/fs/dcache.c
@@ -2529,6 +2529,7 @@ static int prepend_name(char **buffer, int *buflen, struct qstr *name)
  * @buflen: pointer to buffer length
  *
  * Caller holds the rename_lock.
+ * There is no need to lock the dentry as its name cannot be changed.
  */
 static int prepend_path(const struct path *path,
 			const struct path *root,
@@ -2555,9 +2556,7 @@ static int prepend_path(const struct path *path,
 		}
 		parent = dentry->d_parent;
 		prefetch(parent);
-		spin_lock(&dentry->d_lock);
 		error = prepend_name(buffer, buflen, &dentry->d_name);
-		spin_unlock(&dentry->d_lock);
 		if (!error)
 			error = prepend(buffer, buflen, "/", 1);
 		if (error)
-- 
1.7.1

