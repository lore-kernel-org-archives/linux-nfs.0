Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab0K3C5u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Nov 2010 21:57:50 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] NFSv4: If the server sends us a numeric uid/gid then accept it
Date: Mon, 29 Nov 2010 21:57:40 -0500
Message-Id: <1291085863-3234-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1291085863-3234-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/idmap.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 4e2d9b6..4281da6 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -33,6 +33,24 @@
  *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/kernel.h>
+
+static int nfs_map_string_to_numeric(const char *name, size_t namelen, __u32 *res)
+{
+	unsigned long val;
+	char buf[16];
+
+	if (memchr(name, '@', namelen) != NULL || namelen >= sizeof(buf))
+		return 0;
+	memcpy(buf, name, namelen);
+	buf[namelen] = '\0';
+	if (strict_strtoul(buf, 0, &val) != 0)
+		return 0;
+	*res = val;
+	return 1;
+}
 
 #ifdef CONFIG_NFS_USE_NEW_IDMAPPER
 
@@ -42,7 +60,6 @@
 #include <linux/keyctl.h>
 #include <linux/key-type.h>
 #include <linux/rcupdate.h>
-#include <linux/kernel.h>
 #include <linux/err.h>
 
 #include <keys/user-type.h>
@@ -221,11 +238,15 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen,
 
 int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)
 {
+	if (nfs_map_string_to_numeric(name, namelen, uid))
+		return 0;
 	return nfs_idmap_lookup_id(name, namelen, "uid", uid);
 }
 
 int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *gid)
 {
+	if (nfs_map_string_to_numeric(name, namelen, gid))
+		return 0;
 	return nfs_idmap_lookup_id(name, namelen, "gid", gid);
 }
 
@@ -243,7 +264,6 @@ int nfs_map_gid_to_group(struct nfs_client *clp, __u32 gid, char *buf, size_t bu
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/init.h>
-#include <linux/types.h>
 #include <linux/slab.h>
 #include <linux/socket.h>
 #include <linux/in.h>
@@ -699,6 +719,8 @@ int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen
 {
 	struct idmap *idmap = clp->cl_idmap;
 
+	if (nfs_map_string_to_numeric(name, namelen, uid))
+		return 0;
 	return nfs_idmap_id(idmap, &idmap->idmap_user_hash, name, namelen, uid);
 }
 
@@ -706,6 +728,8 @@ int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namele
 {
 	struct idmap *idmap = clp->cl_idmap;
 
+	if (nfs_map_string_to_numeric(name, namelen, uid))
+		return 0;
 	return nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, uid);
 }
 
-- 
1.7.3.2

