Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:49809 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaKXXCR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 18:02:17 -0500
From: Pieter Smith <pieter@boesman.nl>
To: pieter@boesman.nl
Cc: Josh Triplett <josh@joshtriplett.org>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        Alexei Starovoitov <ast@plumgrid.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Bertrand Jacquin <beber@meleeweb.net>,
        Catalina Mocanu <catalina.mocanu@gmail.com>,
        Daniel Borkmann <dborkman@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        "Eric W. Biederman" <ebiederm@xmission.com>,
        Fabian Frederick <fabf@skynet.be>,
        fuse-devel@lists.sourceforge.net (open list:FUSE: FILESYSTEM...),
        Geert Uytterhoeven <geert@linux-m68k.org>,
        Hugh Dickins <hughd@google.com>, Iulia Manda <iulia.manda21@gmail.com>,
        Jan Beulich <JBeulich@suse.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-api@vger.kernel.org (open list:ABI/API),
        linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org (open list),
        linux-nfs@vger.kernel.org (open list:KERNEL NFSD, SUNR...),
        "Luis R. Rodriguez" <mcgrof@suse.com>,
        Matt Turner <mattst88@gmail.com>, Mel Gorman <mgorman@suse.de>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        Miklos Szeredi <miklos@szeredi.hu>,
        netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
        Oleg Nesterov <oleg@redhat.com>,
        Paul Durrant <Paul.Durrant@citrix.com>,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        Peter Foley <pefoley2@pefoley.com>, Thomas Graf <tgraf@suug.ch>,
        Tom Herbert <therbert@google.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Willem de Bruijn <willemb@google.com>,
        Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>,
        =?UTF-8?q?=E8=94=A1=E6=AD=A3=E9=BE=99?= <zhenglong.cai@cs2c.com.cn>
Subject: [PATCH v4 2/7] fs: moved kernel_write to fs/read_write
Date: Tue, 25 Nov 2014 00:01:01 +0100
Message-Id: <1416870079-15254-3-git-send-email-pieter@boesman.nl>
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

kernel_write shares infrastructure with the read_write translation unit but not
with the splice translation unit. Grouping kernel_write with the read_write
translation unit is more logical. It also paves the way to compiling out the
splice group of syscalls for embedded systems that do not need them.

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/read_write.c | 16 ++++++++++++++++
 fs/splice.c     | 16 ----------------
 2 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index d9451ba..f4c8d8b 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1191,3 +1191,19 @@ COMPAT_SYSCALL_DEFINE5(pwritev, compat_ulong_t, fd,
 }
 #endif
 
+ssize_t kernel_write(struct file *file, const char *buf, size_t count,
+			    loff_t pos)
+{
+	mm_segment_t old_fs;
+	ssize_t res;
+
+	old_fs = get_fs();
+	set_fs(get_ds());
+	/* The cast to a user pointer is valid due to the set_fs() */
+	res = vfs_write(file, (__force const char __user *)buf, count, &pos);
+	set_fs(old_fs);
+
+	return res;
+}
+EXPORT_SYMBOL(kernel_write);
+
diff --git a/fs/splice.c b/fs/splice.c
index c1a2861..44b201b 100644
--- a/fs/splice.c
+++ b/fs/splice.c
@@ -583,22 +583,6 @@ static ssize_t kernel_readv(struct file *file, const struct iovec *vec,
 	return res;
 }
 
-ssize_t kernel_write(struct file *file, const char *buf, size_t count,
-			    loff_t pos)
-{
-	mm_segment_t old_fs;
-	ssize_t res;
-
-	old_fs = get_fs();
-	set_fs(get_ds());
-	/* The cast to a user pointer is valid due to the set_fs() */
-	res = vfs_write(file, (__force const char __user *)buf, count, &pos);
-	set_fs(old_fs);
-
-	return res;
-}
-EXPORT_SYMBOL(kernel_write);
-
 ssize_t default_file_splice_read(struct file *in, loff_t *ppos,
 				 struct pipe_inode_info *pipe, size_t len,
 				 unsigned int flags)
-- 
2.1.0

