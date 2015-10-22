Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55183 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301AbbJVQhu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Oct 2015 12:37:50 -0400
Date: Fri, 23 Oct 2015 00:36:55 +0800
From: kbuild test robot <lkp@intel.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: kbuild-all@01.org, Jeff Layton <jlayton@poochiereds.net>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Latchesar Ionkov <lucho@ionkov.net>, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        devel@driverdev.osuosl.org, Yan Zheng <zyan@redhat.com>,
        cluster-devel@redhat.com, Sage Weil <sage@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Christoph Hellwig <hch@infradead.org>,
        fuse-devel@lists.sourceforge.net,
        Christine Caulfield <ccaulfie@redhat.com>,
        v9fs-developer@lists.sourceforge.net,
        Ilya Dryomov <idryomov@gmail.com>, linux-cifs@vger.kernel.org,
        Eric Van Hensbergen <ericvh@gmail.com>, Mark Fasheh <mfasheh@suse.com>,
        Oleg Drokin <oleg.drokin@intel.com>,
        Julia Lawall <Julia.Lawall@lip6.fr>,
        David Teigland <teigland@redhat.com>, Joel Becker <jlbec@evilplan.org>,
        ceph-devel@vger.kernel.org, Abdul Hussain <habdul@visteon.com>,
        Steven Whitehouse <swhiteho@redhat.com>, linux-nfs@vger.kernel.org,
        Andreas Dilger <andreas.dilger@intel.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
        Steve French <sfrench@samba.org>, Bob Peterson <rpeterso@redhat.com>,
        Ron Minnich <rminnich@sandia.gov>,
        Anna Schumaker <anna.schumaker@netapp.com>, ocfs2-devel@oss.oracle.com,
        lustre-devel@lists.lustre.org
Subject: [RFC PATCH] locks: posix_lock_inode_wait() can be static
Message-ID: <20151022163655.GA111096@roam>
References: <201510230020.vZvDxsE7%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ded792d8fdcba562a1c74fd14fefcb387debc4b1.1445524157.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 locks.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index daf4664..0d2b326 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -1173,7 +1173,7 @@ EXPORT_SYMBOL(posix_lock_file);
  *
  * Apply a POSIX style lock request to an inode.
  */
-int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int posix_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep ();
@@ -1860,7 +1860,7 @@ int fcntl_setlease(unsigned int fd, struct file *filp, long arg)
  *
  * Apply a FLOCK style lock request to an inode.
  */
-int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
+static int flock_lock_inode_wait(struct inode *inode, struct file_lock *fl)
 {
 	int error;
 	might_sleep();
