Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33307 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753688AbbCPLfN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Mar 2015 07:35:13 -0400
Received: by pagr17 with SMTP id r17so62569913pag.0
        for <linux-nfs@vger.kernel.org>; Mon, 16 Mar 2015 04:35:12 -0700 (PDT)
From: Omar Sandoval <osandov@osandov.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        linux-btrfs@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, osd-dev@open-osd.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        fuse-devel@lists.sourceforge.net, cluster-devel@redhat.com,
        jfs-discussion@lists.sourceforge.net, HPDD-discuss@ml01.01.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        ocfs2-devel@oss.oracle.com, reiserfs-devel@vger.kernel.org,
        v9fs-developer@lists.sourceforge.net, xfs@oss.sgi.com
Cc: linux-kernel@vger.kernel.org, Chris Mason <clm@fb.com>,
        Josef Bacik <jbacik@fb.com>, David Sterba <dsterba@suse.cz>,
        "Yan Zheng" <zyan@redhat.com>, Sage Weil <sage@redhat.com>,
        Steve French <sfrench@samba.org>, Boaz Harrosh <ooo@electrozaur.com>,
        Benny Halevy <bhalevy@primarydata.com>, Jan Kara <jack@suse.cz>,
        "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Changman Lee <cm224.lee@samsung.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        Steven Whitehouse <swhiteho@redhat.com>,
        Dave Kleikamp <shaggy@kernel.org>, Oleg Drokin <oleg.drokin@intel.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Van Hensbergen <ericvh@gmail.com>,
        Ron Minnich <rminnich@sandia.gov>, Latchesar Ionkov <lucho@ionkov.net>,
        Dave Chinner <david@fromorbit.com>,
        Omar Sandoval <osandov@osandov.com>
Subject: [RFC PATCH 1/5] new helper: iov_iter_rw()
Date: Mon, 16 Mar 2015 04:33:49 -0700
Message-Id: <34dc78b262546e9343e0ed872232a97f5eaa5f15.1426502566.git.osandov@osandov.com>
In-Reply-To: <cover.1426502566.git.osandov@osandov.com>
References: <cover.1426502566.git.osandov@osandov.com>
In-Reply-To: <cover.1426502566.git.osandov@osandov.com>
References: <cover.1426502566.git.osandov@osandov.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get either READ or WRITE out of iter->type.

Signed-off-by: Omar Sandoval <osandov@osandov.com>
---
 include/linux/uio.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/uio.h b/include/linux/uio.h
index 7188029..87a47b3 100644
--- a/include/linux/uio.h
+++ b/include/linux/uio.h
@@ -10,6 +10,7 @@
 #define __LINUX_UIO_H
 
 #include <linux/kernel.h>
+#include <linux/fs.h>
 #include <uapi/linux/uio.h>
 
 struct page;
@@ -111,6 +112,15 @@ static inline bool iter_is_iovec(struct iov_iter *i)
 }
 
 /*
+ * Get one of READ or WRITE out of iter->type without any other flags OR'd in
+ * with it.
+ */
+static inline int iov_iter_rw(const struct iov_iter *i)
+{
+	return i->type & RW_MASK;
+}
+
+/*
  * Cap the iov_iter by given limit; note that the second argument is
  * *not* the new size - it's upper limit for such.  Passing it a value
  * greater than the amount of data in iov_iter is fine - it'll just do
-- 
2.3.3

