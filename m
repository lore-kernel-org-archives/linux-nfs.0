From: Waiman Long <Waiman.Long@hp.com>
Subject: [PATCH v2 4/4] dcache: don't need to take d_lock in prepend_path()
Date: Fri,  5 Apr 2013 12:57:41 -0400
Message-ID: <1365181061-30787-5-git-send-email-Waiman.Long__41521.3525099263$1366020508$gmane$org@hp.com>
References: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
Cc: Waiman Long <Waiman.Long@hp.com>, linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org, "Norton,
	Scott J" <scott.norton@hp.com>, autofs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	"Chandramouleeswaran, Aswin" <aswin@hp.com>,
	Andi Kleen <andi@firstfloor.org>, Dave Chinner <david@fromorbit.com>,
	linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org
Return-path: <samba-technical-bounces@lists.samba.org>
To: 
In-Reply-To: <1365181061-30787-1-git-send-email-Waiman.Long@hp.com>
To: Alexander Viro <viro@zeniv.linux.org.uk> , Jeff Layton <jlayton@redhat.com>,
	Miklos Szeredi <mszeredi@suse.cz>, Ian Kent <raven@themaw.net>,
	Sage Weil <sage@inktank.com>, Steve French <sfrench@samba.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Eric Paris <eparis@redhat.com>
List-Unsubscribe: <https://lists.samba.org/mailman/options/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/pipermail/samba-technical>
List-Post: <mailto:samba-technical@lists.samba.org>
List-Help: <mailto:samba-technical-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/samba-technical>,
	<mailto:samba-technical-request@lists.samba.org?subject=subscribe>
Sender: samba-technical-bounces@lists.samba.org
Errors-To: samba-technical-bounces@lists.samba.org
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
