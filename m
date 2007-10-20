From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [NFS] [GIT] NFS client fixes for 2.6.23++
Date: Sat, 20 Oct 2007 13:22:37 -0400
Message-ID: <1192900957.7440.10.camel@heimdal.trondhjem.org>
References: <200710200219.l9K2JMI8015439@agora.fsl.cs.sunysb.edu>
	 <alpine.LFD.0.999.0710191929340.3794@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Erez Zadok <ezk@cs.sunysb.edu>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764137AbXJTRWe@vger.kernel.org>
In-Reply-To: <alpine.LFD.0.999.0710191929340.3794@woody.linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


On Fri, 2007-10-19 at 19:32 -0700, Linus Torvalds wrote:
> 
> On Fri, 19 Oct 2007, Erez Zadok wrote:
> > 
> > Trond, with Linus's latest tree, you need to #include <linux/sched.h> in
> > fs/nfs/unlink.c, else I get:
> > 
> >   CC [M]  fs/nfs/unlink.o
> > fs/nfs/unlink.c: In function 'nfs_dec_sillycount':
> > fs/nfs/unlink.c:67: error: 'TASK_UNINTERRUPTIBLE' undeclared (first use in this function)
> ...
> 
> Hmm? Which architecture?
> 
> That said, I do think that there is a distinct lack of proper includes in 
> that file. It seems to depend on getting much of the includes indirectly 
> from <linux/nfs_fs.h> and friends. And with different architectures having 
> different header files..
> 
> 		Linus

This ought to fix it.
----------------------------------------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 20 Oct 2007 13:21:04 -0400
NFS: Fix the include files needed by fs/nfs/unlink.c

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/unlink.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 6ecd46c..057e6ce 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -5,9 +5,14 @@
  *
  */
 
+#include <asm/atomic.h>
+#include <linux/dcache.h>
 #include <linux/slab.h>
 #include <linux/string.h>
-#include <linux/dcache.h>
+#include <linux/sched.h>
+#include <linux/spinlock.h>
+#include <linux/wait.h>
+#include <linux/sunrpc/auth.h>
 #include <linux/sunrpc/sched.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/nfs_fs.h>
