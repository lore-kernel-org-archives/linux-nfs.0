From: David Howells <dhowells@redhat.com>
Subject: [PATCH 11/18] xstat: Make automounter filesystems return
	FS_AUTOMOUNT_FL [ver #6]
Date: Thu, 15 Jul 2010 03:17:22 +0100
Message-ID: <20100715021722.5544.803.stgit@warthog.procyon.org.uk>
References: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	samba-technical@lists.samba.org, linux-kernel@vger.kernel.org,
	dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
	linux-ext4@vger.kernel.org
To: viro@ZenIV.linux.org.uk
Return-path: <samba-technical-bounces@lists.samba.org>
In-Reply-To: <20100715021709.5544.64506.stgit@warthog.procyon.org.uk>
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

Make automounter filesystems return FS_AUTOMOUNT_FL in st_inode_flags to
xstat().

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/autofs/init.c  |    1 +
 fs/autofs4/init.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/autofs/init.c b/fs/autofs/init.c
index cea5219..2c06d4b 100644
--- a/fs/autofs/init.c
+++ b/fs/autofs/init.c
@@ -23,6 +23,7 @@ static int autofs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type autofs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "autofs",
+	.inode_flags	= FS_AUTOMOUNT_FL,
 	.get_sb		= autofs_get_sb,
 	.kill_sb	= autofs_kill_sb,
 };
diff --git a/fs/autofs4/init.c b/fs/autofs4/init.c
index 9722e4b..43df431 100644
--- a/fs/autofs4/init.c
+++ b/fs/autofs4/init.c
@@ -23,6 +23,7 @@ static int autofs_get_sb(struct file_system_type *fs_type,
 static struct file_system_type autofs_fs_type = {
 	.owner		= THIS_MODULE,
 	.name		= "autofs",
+	.inode_flags	= FS_AUTOMOUNT_FL,
 	.get_sb		= autofs_get_sb,
 	.kill_sb	= autofs4_kill_sb,
 };
