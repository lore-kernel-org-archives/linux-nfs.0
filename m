Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f51.google.com ([74.125.82.51]:35711 "EHLO
	mail-wg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751799AbaKXXCe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 18:02:34 -0500
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
Subject: [PATCH v4 4/7] fs/fuse: support compiling out splice
Date: Tue, 25 Nov 2014 00:01:03 +0100
Message-Id: <1416870079-15254-5-git-send-email-pieter@boesman.nl>
In-Reply-To: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To implement splice support, fs/fuse makes use of nosteal_pipe_buf_ops. This
struct is exported by fs/splice. The goal of the larger patch set is to
completely compile out fs/splice, so uses of the exported struct need to be
compiled out along with fs/splice.

This patch therefore compiles out splice support in fs/fuse when
CONFIG_SYSCALL_SPLICE is undefined.

Signed-off-by: Pieter Smith <pieter@boesman.nl>
---
 fs/fuse/dev.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/fuse/dev.c b/fs/fuse/dev.c
index ca88731..e984302 100644
--- a/fs/fuse/dev.c
+++ b/fs/fuse/dev.c
@@ -1191,8 +1191,9 @@ __releases(fc->lock)
  * request_end().  Otherwise add it to the processing list, and set
  * the 'sent' flag.
  */
-static ssize_t fuse_dev_do_read(struct fuse_conn *fc, struct file *file,
-				struct fuse_copy_state *cs, size_t nbytes)
+static ssize_t __maybe_unused
+fuse_dev_do_read(struct fuse_conn *fc, struct file *file,
+		 struct fuse_copy_state *cs, size_t nbytes)
 {
 	int err;
 	struct fuse_req *req;
@@ -1291,6 +1292,7 @@ static ssize_t fuse_dev_read(struct kiocb *iocb, const struct iovec *iov,
 	return fuse_dev_do_read(fc, file, &cs, iov_length(iov, nr_segs));
 }
 
+#ifdef CONFIG_SYSCALL_SPLICE
 static ssize_t fuse_dev_splice_read(struct file *in, loff_t *ppos,
 				    struct pipe_inode_info *pipe,
 				    size_t len, unsigned int flags)
@@ -1368,6 +1370,9 @@ out:
 	kfree(bufs);
 	return ret;
 }
+#else /* CONFIG_SYSCALL_SPLICE */
+#define fuse_dev_splice_read NULL
+#endif
 
 static int fuse_notify_poll(struct fuse_conn *fc, unsigned int size,
 			    struct fuse_copy_state *cs)
-- 
2.1.0

