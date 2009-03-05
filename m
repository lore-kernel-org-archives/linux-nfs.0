From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] gssd: Use same style for including config.h that rest of
	nfs-utils uses
Date: Wed, 04 Mar 2009 19:03:00 -0500
Message-ID: <20090305000300.28749.93815.stgit@ingres.1015granger.net>
References: <20090304234711.28749.7018.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet13.oracle.com ([148.87.113.125]:26849 "EHLO
	rgminet13.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799AbZCEAF0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 19:05:26 -0500
In-Reply-To: <20090304234711.28749.7018.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/context.c           |    5 ++++-
 utils/gssd/context_heimdal.c   |    4 +++-
 utils/gssd/context_lucid.c     |    4 +++-
 utils/gssd/context_mit.c       |    4 +++-
 utils/gssd/context_spkm3.c     |    5 ++++-
 utils/gssd/err_util.c          |    4 ++++
 utils/gssd/gss_clnt_send_err.c |    4 ++++
 utils/gssd/gss_oids.c          |    4 ++++
 utils/gssd/gss_util.c          |    6 +++++-
 utils/gssd/gssd.c              |    4 +++-
 utils/gssd/gssd_main_loop.c    |    5 +++++
 utils/gssd/gssd_proc.c         |    6 +++++-
 utils/gssd/krb5_util.c         |    6 +++++-
 utils/gssd/svcgssd.c           |    4 +++-
 utils/gssd/svcgssd_main_loop.c |    4 ++++
 utils/gssd/svcgssd_mech2file.c |    4 +++-
 utils/gssd/svcgssd_proc.c      |    4 ++++
 17 files changed, 66 insertions(+), 11 deletions(-)

diff --git a/utils/gssd/context.c b/utils/gssd/context.c
index 0ca7079..1e50bbf 100644
--- a/utils/gssd/context.c
+++ b/utils/gssd/context.c
@@ -28,7 +28,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
diff --git a/utils/gssd/context_heimdal.c b/utils/gssd/context_heimdal.c
index fc241e3..ddf064d 100644
--- a/utils/gssd/context_heimdal.c
+++ b/utils/gssd/context_heimdal.c
@@ -28,7 +28,9 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #ifndef HAVE_LUCID_CONTEXT_SUPPORT
 #ifdef HAVE_HEIMDAL
diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index 94403af..3243d53 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -28,7 +28,9 @@
  * SUCH DAMAGES.
  */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #ifdef HAVE_LUCID_CONTEXT_SUPPORT
 
diff --git a/utils/gssd/context_mit.c b/utils/gssd/context_mit.c
index e76a8b1..709a903 100644
--- a/utils/gssd/context_mit.c
+++ b/utils/gssd/context_mit.c
@@ -28,7 +28,9 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #ifndef HAVE_LUCID_CONTEXT_SUPPORT
 #ifdef HAVE_KRB5
diff --git a/utils/gssd/context_spkm3.c b/utils/gssd/context_spkm3.c
index 5b387bd..b927475 100644
--- a/utils/gssd/context_spkm3.c
+++ b/utils/gssd/context_spkm3.c
@@ -28,7 +28,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <stdio.h>
 #include <syslog.h>
 #include <string.h>
diff --git a/utils/gssd/err_util.c b/utils/gssd/err_util.c
index 2583e06..fe09eda 100644
--- a/utils/gssd/err_util.c
+++ b/utils/gssd/err_util.c
@@ -28,6 +28,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <stdio.h>
 #include <stdarg.h>
 #include <string.h>
diff --git a/utils/gssd/gss_clnt_send_err.c b/utils/gssd/gss_clnt_send_err.c
index 5260b53..4800a01 100644
--- a/utils/gssd/gss_clnt_send_err.c
+++ b/utils/gssd/gss_clnt_send_err.c
@@ -30,6 +30,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <sys/param.h>
 #include <sys/socket.h>
 #include <sys/types.h>
diff --git a/utils/gssd/gss_oids.c b/utils/gssd/gss_oids.c
index c569b0c..a59c4a6 100644
--- a/utils/gssd/gss_oids.c
+++ b/utils/gssd/gss_oids.c
@@ -28,6 +28,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <sys/types.h>
 #include <gssapi/gssapi.h>
 
diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 2d66be9..99aceb3 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -57,7 +57,11 @@
  * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
  * PERFORMANCE OF THIS SOFTWARE.
  */
-#include "config.h"
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <errno.h>
 #include <stdio.h>
 #include <ctype.h>
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 6d8f3b9..f6949db 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -36,7 +36,9 @@
 
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #include <sys/param.h>
 #include <sys/socket.h>
diff --git a/utils/gssd/gssd_main_loop.c b/utils/gssd/gssd_main_loop.c
index b9f3a06..917b662 100644
--- a/utils/gssd/gssd_main_loop.c
+++ b/utils/gssd/gssd_main_loop.c
@@ -28,9 +28,14 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #ifndef _GNU_SOURCE
 #define _GNU_SOURCE
 #endif
+
 #include <sys/param.h>
 #include <sys/socket.h>
 #include <sys/poll.h>
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 91fc8d2..d0d3f7f 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -38,10 +38,14 @@
 
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #ifndef _GNU_SOURCE
 #define _GNU_SOURCE
 #endif
-#include "config.h"
+
 #include <sys/param.h>
 #include <rpc/rpc.h>
 #include <sys/stat.h>
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index d4ee631..8923b3b 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -91,10 +91,14 @@
 
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #ifndef _GNU_SOURCE
 #define _GNU_SOURCE
 #endif
-#include "config.h"
+
 #include <sys/param.h>
 #include <rpc/rpc.h>
 #include <sys/stat.h>
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 4aa157d..f97dcd3 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -37,7 +37,9 @@
 
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #include <sys/param.h>
 #include <sys/types.h>
diff --git a/utils/gssd/svcgssd_main_loop.c b/utils/gssd/svcgssd_main_loop.c
index 280816d..2b4111c 100644
--- a/utils/gssd/svcgssd_main_loop.c
+++ b/utils/gssd/svcgssd_main_loop.c
@@ -28,6 +28,10 @@
   SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <sys/param.h>
 #include <sys/socket.h>
 #include <sys/poll.h>
diff --git a/utils/gssd/svcgssd_mech2file.c b/utils/gssd/svcgssd_mech2file.c
index 22c3ed8..65de8d0 100644
--- a/utils/gssd/svcgssd_mech2file.c
+++ b/utils/gssd/svcgssd_mech2file.c
@@ -34,7 +34,9 @@
 
 */
 
-#include "config.h"
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
 
 #include <gssapi/gssapi.h>
 #include <string.h>
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 1d13532..b390bea 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -33,6 +33,10 @@
 
 */
 
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif	/* HAVE_CONFIG_H */
+
 #include <sys/param.h>
 #include <sys/stat.h>
 #include <rpc/rpc.h>

