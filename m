Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40071 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751930Ab1JSWJ0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 Oct 2011 18:09:26 -0400
Date: Wed, 19 Oct 2011 18:09:15 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: agruen@kernel.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk,
        dhowells@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH -V7 09/26] vfs: Add delete child and delete self
 permission flags
Message-ID: <20111019220915.GA1874@fieldses.org>
References: <1318951981-5508-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1318951981-5508-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1318951981-5508-10-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 18, 2011 at 09:02:44PM +0530, Aneesh Kumar K.V wrote:
> From: Andreas Gruenbacher <agruen@kernel.org>
> 
> Normally, deleting a file requires write access to the parent directory.
> Some permission models use a different permission on the parent
> directory to indicate delete access.  In addition, a process can have
> per-file delete access even without delete access on the parent
> directory.
> 
> Introduce two new inode_permission() mask flags and use them in
> may_delete()
> 
> Acked-by: David Howells <dhowells@redhat.com>
> Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/namei.c         |   42 ++++++++++++++++++++++++++++--------------
>  include/linux/fs.h |    2 ++
>  2 files changed, 30 insertions(+), 14 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index f6184b8..7bf42e8 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
>   * are used for other things.
>   *
>   * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
> - * MAY_WRITE must also be set in @mask.
> + * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
>   */
>  int inode_permission(struct inode *inode, int mask)
>  {
> @@ -1853,7 +1853,7 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
>  		return 0;
>  
>  other_userns:
> -	return !ns_capable(inode_userns(inode), CAP_FOWNER);
> +	return 1;
>  }
>  
>  /*
> @@ -1875,30 +1875,44 @@ other_userns:
>   * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
>   *     nfs_async_unlink().
>   */
> -static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
> +static int may_delete(struct inode *dir, struct dentry *victim,
> +		      int isdir, int replace)
>  {
> -	int error;
> +	struct inode *inode = victim->d_inode;
> +	int mask, replace_mask = 0, error, is_sticky;
> +
>  
> -	if (!victim->d_inode)
> +	if (!inode)
>  		return -ENOENT;
>  
>  	BUG_ON(victim->d_parent->d_inode != dir);
>  	audit_inode_child(victim, dir);
>  
> -	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
> +	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
> +	if (replace)
> +		replace_mask = S_ISDIR(inode->i_mode) ?
> +				MAY_CREATE_DIR : MAY_CREATE_FILE;
> +	is_sticky = check_sticky(dir, inode);
> +	error = inode_permission(dir, mask | replace_mask);
> +	if ((error || is_sticky) && IS_RICHACL(inode) &&
> +	    (inode_permission(dir, MAY_EXEC | replace_mask) == 0) &&
> +	    (inode_permission(inode, MAY_DELETE_SELF) == 0))
> +		error = 0;
> +	else if (!error && is_sticky &&
> +		 !ns_capable(inode_userns(inode), CAP_FOWNER))
> +		error = -EPERM;

Maybe I'm dense, but that big if-else-if is still giving me a headache.

The point is just to delay the ns_capable() check to avoid setting
PF_SUPERPRIV in cases where we weren't before?

How about putting using a helper function for the richacl check, and
calling it from check_sticky instead? That makes the above:

	error = inode_permission(dir, mask | replace_mask);
	if (error && !richacl_may_delete(dir, inode, replace_mask))
		return error;
	if (check_sticky(dir, inode, replace_mask))
		return -EPERM;

(As in the following--totally untested and possibly wrong.)

Also: the comment before may_delete() needs updating.

--b.

commit 7fe4b12ba6b914167ed1f1bc617af04eecbce7d1
Author: Andreas Gruenbacher <agruen@kernel.org>
Date:   Tue Oct 18 15:17:50 2011 +0530

    vfs: Add delete child and delete self permission flags
    
    Normally, deleting a file requires write access to the parent directory.
    Some permission models use a different permission on the parent
    directory to indicate delete access.  In addition, a process can have
    per-file delete access even without delete access on the parent
    directory.
    
    Introduce two new inode_permission() mask flags and use them in
    may_delete()
    
    Acked-by: David Howells <dhowells@redhat.com>
    Signed-off-by: Andreas Gruenbacher <agruen@kernel.org>
    Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

diff --git a/fs/namei.c b/fs/namei.c
index f6184b8..f0cccd9 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -337,7 +337,7 @@ static inline int do_inode_permission(struct inode *inode, int mask)
  * are used for other things.
  *
  * When checking for MAY_APPEND, MAY_CREATE_FILE, MAY_CREATE_DIR,
- * MAY_WRITE must also be set in @mask.
+ * MAY_DELETE_CHILD, MAY_DELETE_SELF, MAY_WRITE must also be set in @mask.
  */
 int inode_permission(struct inode *inode, int mask)
 {
@@ -1835,11 +1835,18 @@ static int user_path_parent(int dfd, const char __user *path,
 	return error;
 }
 
+static bool richacl_may_delete(struct inode *dir, struct inode *inode, int replace_mask)
+{
+	return IS_RICHACL(inode)
+		&& (inode_permission(dir, MAY_EXEC | replace_mask) == 0)
+		&& (inode_permission(inode, MAY_DELETE_SELF) == 0);
+}
+
 /*
  * It's inline, so penalty for filesystems that don't use sticky bit is
  * minimal.
  */
-static inline int check_sticky(struct inode *dir, struct inode *inode)
+static inline int check_sticky(struct inode *dir, struct inode *inode, int replace_mask)
 {
 	uid_t fsuid = current_fsuid();
 
@@ -1851,7 +1858,8 @@ static inline int check_sticky(struct inode *dir, struct inode *inode)
 		return 0;
 	if (dir->i_uid == fsuid)
 		return 0;
-
+	if (richacl_may_delete(dir, inode, replace_mask))
+		return 0;
 other_userns:
 	return !ns_capable(inode_userns(inode), CAP_FOWNER);
 }
@@ -1875,30 +1883,38 @@ other_userns:
  * 10. We don't allow removal of NFS sillyrenamed files; it's handled by
  *     nfs_async_unlink().
  */
-static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
+static int may_delete(struct inode *dir, struct dentry *victim,
+		      int isdir, int replace)
 {
-	int error;
+	struct inode *inode = victim->d_inode;
+	int mask, replace_mask = 0, error;
+
 
-	if (!victim->d_inode)
+	if (!inode)
 		return -ENOENT;
 
 	BUG_ON(victim->d_parent->d_inode != dir);
 	audit_inode_child(victim, dir);
 
-	error = inode_permission(dir, MAY_WRITE | MAY_EXEC);
-	if (error)
+	mask = MAY_WRITE | MAY_EXEC | MAY_DELETE_CHILD;
+	if (replace)
+		replace_mask = S_ISDIR(inode->i_mode) ?
+				MAY_CREATE_DIR : MAY_CREATE_FILE;
+	error = inode_permission(dir, mask | replace_mask);
+	if (error && !richacl_may_delete(dir, inode, replace_mask))
 		return error;
+	if (check_sticky(dir, inode, replace_mask))
+		return -EPERM;
 	if (IS_APPEND(dir))
 		return -EPERM;
-	if (check_sticky(dir, victim->d_inode)||IS_APPEND(victim->d_inode)||
-	    IS_IMMUTABLE(victim->d_inode) || IS_SWAPFILE(victim->d_inode))
+	if (IS_APPEND(inode) || IS_IMMUTABLE(inode) || IS_SWAPFILE(inode))
 		return -EPERM;
 	if (isdir) {
-		if (!S_ISDIR(victim->d_inode->i_mode))
+		if (!S_ISDIR(inode->i_mode))
 			return -ENOTDIR;
 		if (IS_ROOT(victim))
 			return -EBUSY;
-	} else if (S_ISDIR(victim->d_inode->i_mode))
+	} else if (S_ISDIR(inode->i_mode))
 		return -EISDIR;
 	if (IS_DEADDIR(dir))
 		return -ENOENT;
@@ -2605,7 +2621,7 @@ void dentry_unhash(struct dentry *dentry)
 
 int vfs_rmdir(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 1);
+	int error = may_delete(dir, dentry, 1, 0);
 
 	if (error)
 		return error;
@@ -2700,7 +2716,7 @@ SYSCALL_DEFINE1(rmdir, const char __user *, pathname)
 
 int vfs_unlink(struct inode *dir, struct dentry *dentry)
 {
-	int error = may_delete(dir, dentry, 0);
+	int error = may_delete(dir, dentry, 0, 0);
 
 	if (error)
 		return error;
@@ -3096,14 +3112,14 @@ int vfs_rename(struct inode *old_dir, struct dentry *old_dentry,
 	if (old_dentry->d_inode == new_dentry->d_inode)
  		return 0;
  
-	error = may_delete(old_dir, old_dentry, is_dir);
+	error = may_delete(old_dir, old_dentry, is_dir, 0);
 	if (error)
 		return error;
 
 	if (!new_dentry->d_inode)
 		error = may_create(new_dir, new_dentry, is_dir);
 	else
-		error = may_delete(new_dir, new_dentry, is_dir);
+		error = may_delete(new_dir, new_dentry, is_dir, 1);
 	if (error)
 		return error;
 
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 60361c6..ccece40 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -69,6 +69,8 @@ struct inodes_stat_t {
 #define MAY_NOT_BLOCK		0x00000080
 #define MAY_CREATE_FILE		0x00000100
 #define MAY_CREATE_DIR		0x00000200
+#define MAY_DELETE_CHILD	0x00000400
+#define MAY_DELETE_SELF		0x00000800
 
 /*
  * flags in file.f_mode.  Note that FMODE_READ and FMODE_WRITE must correspond
