Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-eopbgr70131.outbound.protection.outlook.com ([40.107.7.131]:24313
        "EHLO EUR04-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751569AbeFZH2C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 26 Jun 2018 03:28:02 -0400
Date: Tue, 26 Jun 2018 00:27:38 -0700
From: Andrei Vagin <avagin@virtuozzo.com>
To: David Howells <dhowells@redhat.com>
Cc: viro@zeniv.linux.org.uk, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        linux-security-module@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-afs@lists.infradead.org
Subject: Re: [12/24] proc: Add fs_context support to procfs [ver #7]
Message-ID: <20180626072736.GA31860@outlook.office365.com>
References: <152414474815.23902.6952548431423168966.stgit@warthog.procyon.org.uk>
 <20180619033450.GA11639@outlook.office365.com>
 <20180626061320.GA12548@outlook.office365.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
In-Reply-To: <20180626061320.GA12548@outlook.office365.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

On Mon, Jun 25, 2018 at 11:13:20PM -0700, Andrei Vagin wrote:
> On Mon, Jun 18, 2018 at 08:34:50PM -0700, Andrei Vagin wrote:
> > Hi David,
> > 
> > We run CRIU tests for vfs/for-next, and today a few of these test failed. I
> > found that the problem appears after this patch..
> > 
> > >  int pid_ns_prepare_proc(struct pid_namespace *ns)
> > >  {
> > > +	struct proc_fs_context *ctx;
> > > +	struct fs_context *fc;
> > >  	struct vfsmount *mnt;
> > > +	int ret;
> > > +
> > > +	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0,
> > > +				FS_CONTEXT_FOR_KERNEL_MOUNT);
> > > +	if (IS_ERR(fc))
> > > +		return PTR_ERR(fc);
> > > +
> > > +	ctx = container_of(fc, struct proc_fs_context, fc);
> > > +	if (ctx->pid_ns != ns) {
> > > +		put_pid_ns(ctx->pid_ns);
> > > +		get_pid_ns(ns);
> > > +		ctx->pid_ns = ns;
> > > +	}
> > > +
> > > +	ret = vfs_get_tree(fc);
> > > +	if (ret < 0) {
> > > +		put_fs_context(fc);
> > > +		return ret;
> > > +	}
> > >  
> > > -	mnt = kern_mount_data(&proc_fs_type, ns, 0);
> 
> Here ns->user_ns and get_current_cred()->user_ns are not always equal

What do you think about the attached patch?

> 
> > > +	mnt = vfs_create_mount(fc);
> > > +	put_fs_context(fc);
> > >  	if (IS_ERR(mnt))
> > >  		return PTR_ERR(mnt);
> > >  
> 
> > #define _GNU_SOURCE
> > #include <sys/types.h>
> > #include <sched.h>
> > #include <unistd.h>
> > #include <stdio.h>
> > #include <sys/mount.h>
> > #include <sys/wait.h>
> > #include <sys/stat.h>
> > #include <fcntl.h>
> > #include <stdlib.h>
> > #include <grp.h>
> > #include <linux/limits.h>
> > 
> > 
> > #define NS_STACK_SIZE	4096
> > 
> > #define __stack_aligned__	__attribute__((aligned(16)))
> > 
> > /* All arguments should be above stack, because it grows down */
> > struct ns_exec_args {
> > 	char stack[NS_STACK_SIZE] __stack_aligned__;
> > 	char stack_ptr[0];
> > 	int pfd[2];
> > };
> > 
> > static int ns_exec(void *_arg)
> > {
> > 	struct ns_exec_args *args = (struct ns_exec_args *) _arg;
> > 	int ret;
> > 
> > 	close(args->pfd[1]);
> > 	if (read(args->pfd[0], &ret, sizeof(ret)) != sizeof(ret))
> > 		return -1;
> > 
> > 	setsid();
> > 
> > 	if (setuid(0) || setgid(0) || setgroups(0, NULL)) {
> > 		fprintf(stderr, "set*id failed: %m\n");
> > 		return -1;
> > 	}
> > 
> > 	if (mount("proc", "/mnt", "proc", MS_MGC_VAL | MS_NOSUID | MS_NOEXEC | MS_NODEV, NULL)) {
> > 		fprintf(stderr, "mount(/proc) failed: %m\n");
> > 		return -1;
> > 	}
> > 
> > 	return 0;
> > }
> > 
> > #define UID_MAP "0 100000 100000\n100000 200000 50000"
> > #define GID_MAP "0 400000 50000\n50000 500000 100000"
> > int main()
> > {
> > 	pid_t pid;
> > 	int ret, status;
> > 	struct ns_exec_args args;
> > 	int flags;
> > 	char pname[PATH_MAX];
> > 	int fd, pfd[2];
> > 
> > 	if (pipe(pfd))
> > 		return 1;
> > 
> > 	args.pfd[0] = pfd[0];
> > 	args.pfd[1] = pfd[1];
> > 
> > 	flags = CLONE_NEWPID | CLONE_NEWNS | CLONE_NEWUTS |
> > 		CLONE_NEWNET | CLONE_NEWIPC | CLONE_NEWUSER | SIGCHLD;
> > 
> > 	pid = clone(ns_exec, args.stack_ptr, flags, &args);
> > 	if (pid < 0) {
> > 		fprintf(stderr, "clone() failed: %m\n");
> > 		exit(1);
> > 	}
> > 
> > 
> > 	snprintf(pname, sizeof(pname), "/proc/%d/uid_map", pid);
> > 	fd = open(pname, O_WRONLY);
> > 	if (fd < 0) {
> > 		fprintf(stderr, "open(%s): %m\n", pname);
> > 		exit(1);
> > 	}
> > 	if (write(fd, UID_MAP, sizeof(UID_MAP)) < 0) {
> > 		fprintf(stderr, "write(" UID_MAP "): %m\n");
> > 		exit(1);
> > 	}
> > 	close(fd);
> > 
> > 	snprintf(pname, sizeof(pname), "/proc/%d/gid_map", pid);
> > 	fd = open(pname, O_WRONLY);
> > 	if (fd < 0) {
> > 		fprintf(stderr, "open(%s): %m\n", pname);
> > 		exit(1);
> > 	}
> > 	if (write(fd, GID_MAP, sizeof(GID_MAP)) < 0) {
> > 		fprintf(stderr, "write(" GID_MAP "): %m\n");
> > 		exit(1);
> > 	}
> > 	close(fd);
> > 
> > 	if (write(pfd[1], &ret, sizeof(ret)) != sizeof(ret))
> > 		return 1;
> > 
> > 	if (waitpid(pid, &status, 0) != pid)
> > 		return 1;
> > 	if (status)
> > 		return 1;
> > 
> > 	return 0;
> > }
> 

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename=p

diff --git a/fs/fs_context.c b/fs/fs_context.c
index 97e8c1dc4e3b..ad2db7504031 100644
--- a/fs/fs_context.c
+++ b/fs/fs_context.c
@@ -235,10 +235,11 @@ EXPORT_SYMBOL(generic_parse_monolithic);
  * another superblock (referred to by @reference) is supplied, may have
  * parameters such as namespaces copied across from that superblock.
  */
-struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
+struct fs_context *vfs_new_fs_context_userns(struct file_system_type *fs_type,
 				      struct dentry *reference,
 				      unsigned int sb_flags,
-				      enum fs_context_purpose purpose)
+				      enum fs_context_purpose purpose,
+				      struct user_namespace *user_ns)
 {
 	struct fs_context *fc;
 	int ret;
@@ -259,7 +260,7 @@ struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
 		fc->sb_flags |= SB_KERNMOUNT;
 		/* Fallthrough */
 	case FS_CONTEXT_FOR_USER_MOUNT:
-		fc->user_ns = get_user_ns(fc->cred->user_ns);
+		fc->user_ns = get_user_ns(user_ns ? : fc->cred->user_ns);
 		fc->net_ns = get_net(current->nsproxy->net_ns);
 		break;
 	case FS_CONTEXT_FOR_SUBMOUNT:
diff --git a/fs/proc/root.c b/fs/proc/root.c
index efbdc08a3c86..c832d67067d9 100644
--- a/fs/proc/root.c
+++ b/fs/proc/root.c
@@ -298,8 +298,8 @@ int pid_ns_prepare_proc(struct pid_namespace *ns)
 	struct vfsmount *mnt;
 	int ret;
 
-	fc = vfs_new_fs_context(&proc_fs_type, NULL, 0,
-				FS_CONTEXT_FOR_KERNEL_MOUNT);
+	fc = vfs_new_fs_context_userns(&proc_fs_type, NULL, 0,
+				FS_CONTEXT_FOR_KERNEL_MOUNT, ns->user_ns);
 	if (IS_ERR(fc))
 		return PTR_ERR(fc);
 
diff --git a/include/linux/fs_context.h b/include/linux/fs_context.h
index 04ea338ff490..283212cda1ff 100644
--- a/include/linux/fs_context.h
+++ b/include/linux/fs_context.h
@@ -92,10 +92,19 @@ struct fs_context_operations {
 /*
  * fs_context manipulation functions.
  */
-extern struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
+extern struct fs_context *vfs_new_fs_context_userns(struct file_system_type *fs_type,
 					     struct dentry *reference,
 					     unsigned int ms_flags,
-					     enum fs_context_purpose purpose);
+					     enum fs_context_purpose purpose,
+					     struct user_namespace *user_ns);
+static inline struct fs_context *vfs_new_fs_context(struct file_system_type *fs_type,
+					     struct dentry *reference,
+					     unsigned int ms_flags,
+					     enum fs_context_purpose purpose)
+{
+	return vfs_new_fs_context_userns(fs_type, reference, ms_flags, purpose, NULL);
+}
+
 extern struct fs_context *vfs_sb_reconfig(struct path *path, unsigned int ms_flags);
 extern struct fs_context *vfs_dup_fs_context(struct fs_context *src);
 extern int vfs_set_fs_source(struct fs_context *fc, const char *source, size_t len);

--UlVJffcvxoiEqYs2--
