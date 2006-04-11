From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: RFC [PATCH 2/6] VFS: Add shrink_submounts()
Date: Tue, 11 Apr 2006 14:05:32 -0400
Message-ID: <20060411180532.12579.11543.stgit@lade.trondhjem.org>
References: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: linux-fsdevel@vger.kernel.org
In-Reply-To: <20060411174543.12579.94699.stgit@lade.trondhjem.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

From: Trond Myklebust <Trond.Myklebust@netapp.com>

Allow a submount to be marked as being 'shrinkable' by means of the
vfsmount->mnt_flags, and then add a function 'shrink_submounts()' which
attempts to recursively unmount these submounts.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/namespace.c        |  124 +++++++++++++++++++++++++++++++++++++++----=
------
 include/linux/mount.h |    3 +
 2 files changed, 102 insertions(+), 25 deletions(-)

diff --git a/fs/namespace.c b/fs/namespace.c
index 2c5f1f8..7bff436 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -1166,13 +1166,46 @@ static void expire_mount(struct vfsmount
 }
=20
 /*
+ * go through the vfsmounts we've just consigned to the graveyard to
+ * - check that they're still dead
+ * - delete the vfsmount from the appropriate namespace under lock
+ * - dispose of the corpse
+ */
+static void expire_mount_list(struct list_head *graveyard, struct list_h=
ead *mounts)
+{
+	struct namespace *namespace;
+	struct vfsmount *mnt;
+
+	while (!list_empty(graveyard)) {
+		LIST_HEAD(umounts);
+		mnt =3D list_entry(graveyard->next, struct vfsmount, mnt_expire);
+		list_del_init(&mnt->mnt_expire);
+
+		/* don't do anything if the namespace is dead - all the
+		 * vfsmounts from it are going away anyway */
+		namespace =3D mnt->mnt_namespace;
+		if (!namespace || !namespace->root)
+			continue;
+		get_namespace(namespace);
+
+		spin_unlock(&vfsmount_lock);
+		down_write(&namespace_sem);
+		expire_mount(mnt, mounts, &umounts);
+		up_write(&namespace_sem);
+		release_mounts(&umounts);
+		mntput(mnt);
+		put_namespace(namespace);
+		spin_lock(&vfsmount_lock);
+	}
+}
+
+/*
  * process a list of expirable mountpoints with the intent of discarding=
 any
  * mountpoints that aren't in use and haven't been touched since last we=
 came
  * here
  */
 void mark_mounts_for_expiry(struct list_head *mounts)
 {
-	struct namespace *namespace;
 	struct vfsmount *mnt, *next;
 	LIST_HEAD(graveyard);
=20
@@ -1196,38 +1229,79 @@ void mark_mounts_for_expiry(struct list_
 		list_move(&mnt->mnt_expire, &graveyard);
 	}
=20
-	/*
-	 * go through the vfsmounts we've just consigned to the graveyard to
-	 * - check that they're still dead
-	 * - delete the vfsmount from the appropriate namespace under lock
-	 * - dispose of the corpse
-	 */
-	while (!list_empty(&graveyard)) {
-		LIST_HEAD(umounts);
-		mnt =3D list_entry(graveyard.next, struct vfsmount, mnt_expire);
-		list_del_init(&mnt->mnt_expire);
+	expire_mount_list(&graveyard, mounts);
=20
-		/* don't do anything if the namespace is dead - all the
-		 * vfsmounts from it are going away anyway */
-		namespace =3D mnt->mnt_namespace;
-		if (!namespace || !namespace->root)
+	spin_unlock(&vfsmount_lock);
+}
+
+EXPORT_SYMBOL_GPL(mark_mounts_for_expiry);
+
+/*
+ * Ripoff of 'select_parent()'
+ *
+ * search the list of submounts for a given mountpoint, and move any
+ * shrinkable submounts to the 'graveyard' list.
+ */
+static int select_submounts(struct vfsmount *parent, struct list_head *g=
raveyard)
+{
+	struct vfsmount *this_parent =3D parent;
+	struct list_head *next;
+	int found =3D 0;
+
+repeat:
+	next =3D this_parent->mnt_mounts.next;
+resume:
+	while (next !=3D &this_parent->mnt_mounts) {
+		struct list_head *tmp =3D next;
+		struct vfsmount *mnt =3D list_entry(tmp, struct vfsmount, mnt_child);
+
+		next =3D tmp->next;
+		if (!(mnt->mnt_flags & MNT_SHRINKABLE))
 			continue;
-		get_namespace(namespace);
+		/*
+		 * Descend a level if the d_mounts list is non-empty.
+		 */
+		if (!list_empty(&mnt->mnt_mounts)) {
+			this_parent =3D mnt;
+			goto repeat;
+		}
=20
-		spin_unlock(&vfsmount_lock);
-		down_write(&namespace_sem);
-		expire_mount(mnt, mounts, &umounts);
-		up_write(&namespace_sem);
-		release_mounts(&umounts);
-		mntput(mnt);
-		put_namespace(namespace);
-		spin_lock(&vfsmount_lock);
+		if (!propagate_mount_busy(mnt, 1)) {
+			mntget(mnt);
+			list_move_tail(&mnt->mnt_expire, graveyard);
+			found++;
+		}
 	}
+	/*
+	 * All done at this level ... ascend and resume the search
+	 */
+	if (this_parent !=3D parent) {
+		next =3D this_parent->mnt_child.next;
+		this_parent =3D this_parent->mnt_parent;
+		goto resume;
+	}
+	return found;
+}
+
+/*
+ * process a list of expirable mountpoints with the intent of discarding=
 any
+ * submounts of a specific parent mountpoint
+ */
+void shrink_submounts(struct vfsmount *mountpoint, struct list_head *mou=
nts)
+{
+	LIST_HEAD(graveyard);
+	int found;
=20
+	spin_lock(&vfsmount_lock);
+
+	/* extract submounts of 'mountpoint' from the expiration list */
+	while ((found =3D select_submounts(mountpoint, &graveyard)) !=3D 0)
+		expire_mount_list(&graveyard, mounts);
+
 	spin_unlock(&vfsmount_lock);
 }
=20
-EXPORT_SYMBOL_GPL(mark_mounts_for_expiry);
+EXPORT_SYMBOL_GPL(shrink_submounts);
=20
 /*
  * Some copy_from_user() implementations do not return the exact number =
of
diff --git a/include/linux/mount.h b/include/linux/mount.h
index aff68c3..9b4e007 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -23,6 +23,8 @@ #define MNT_NOEXEC	0x04
 #define MNT_NOATIME	0x08
 #define MNT_NODIRATIME	0x10
=20
+#define MNT_SHRINKABLE	0x100
+
 #define MNT_SHARED	0x1000	/* if the vfsmount is a shared mount */
 #define MNT_UNBINDABLE	0x2000	/* if the vfsmount is a unbindable mount *=
/
 #define MNT_PNODE_MASK	0x3000	/* propogation flag mask */
@@ -84,6 +86,7 @@ extern int do_add_mount(struct vfsmount=20
 			int mnt_flags, struct list_head *fslist);
=20
 extern void mark_mounts_for_expiry(struct list_head *mounts);
+extern void shrink_submounts(struct vfsmount *mountpoint, struct list_he=
ad *mounts);
=20
 extern spinlock_t vfsmount_lock;
 extern dev_t name_to_dev_t(char *name);
