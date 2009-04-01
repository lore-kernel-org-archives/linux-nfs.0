From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/6] nfs-utils: make getnameinfo() required for --enable-gss
Date: Wed,  1 Apr 2009 10:24:00 -0400
Message-ID: <1238595845-2186-2-git-send-email-jlayton@redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: linux-nfs@vger.kernel.org,
	nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
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
 configure.ac |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/configure.ac b/configure.ac
index e34b7e2..00aee35 100644
--- a/configure.ac
+++ b/configure.ac
@@ -207,6 +207,8 @@ if test "$enable_nfsv4" = yes; then
   dnl but we need to make sure we get the right version
   if test "$enable_gss" = yes; then
     AC_RPCSEC_VERSION
+    AC_CHECK_FUNC([getnameinfo], ,
+		  [AC_MSG_ERROR([Function 'getnameinfo' not found.])])
   fi
 fi
 
-- 
1.6.0.6
