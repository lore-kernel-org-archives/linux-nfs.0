From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/5] nfs-utils: make getnameinfo() required for --enable-gss
Date: Tue,  7 Apr 2009 11:25:42 -0400
Message-ID: <1239117946-7535-2-git-send-email-jlayton@redhat.com>
References: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1239117946-7535-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Systems that are so old that they don't have getnameinfo() in glibc are
probably also running kernels that are so old that they don't support
gssapi upcalls anyway.

Make --enable-gss dependent on the presence of the getnameinfo()
function.  This allows us to reduce some conditional compilation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 configure.ac |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index e34b7e2..611798d 100644
--- a/configure.ac
+++ b/configure.ac
@@ -236,6 +236,9 @@ AC_SUBST(LIBBSD)
 AC_SUBST(LIBBLKID)
 
 if test "$enable_gss" = yes; then
+  dnl 'gss' requires getnameinfo - at least for gssd_proc.c
+  AC_CHECK_FUNC([getnameinfo], , [AC_MSG_ERROR([GSSAPI support requires 'getnameinfo' function])])
+
   dnl 'gss' also depends on nfsidmap.h - at least for svcgssd_proc.c
   AC_LIBNFSIDMAP
 
-- 
1.6.0.6
