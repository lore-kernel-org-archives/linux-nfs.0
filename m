From: David Howells <dhowells@redhat.com>
Subject: [PATCH 01/18] Mark arguments to certain syscalls as being const [ver
	#6]
Date: Thu, 15 Jul 2010 03:17:11 +0100
Message-ID: <20100715021710.5544.32701.stgit@warthog.procyon.org.uk>
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

Mark arguments to certain system calls as being const where they should be but
aren't.  The list includes:

 (*) The filename arguments of various stat syscalls, execve(), various utimes
     syscalls and some mount syscalls.

 (*) The filename arguments of some syscall helpers relating to the above.

 (*) The buffer argument of various write syscalls.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 arch/alpha/kernel/osf_sys.c             |    6 +++---
 arch/alpha/kernel/process.c             |    2 +-
 arch/arm/kernel/sys_arm.c               |    4 ++--
 arch/arm/kernel/sys_oabi-compat.c       |    6 +++---
 arch/avr32/include/asm/syscalls.h       |    2 +-
 arch/avr32/kernel/process.c             |    3 ++-
 arch/blackfin/kernel/process.c          |    2 +-
 arch/frv/kernel/process.c               |    3 ++-
 arch/h8300/kernel/process.c             |    2 +-
 arch/ia64/include/asm/unistd.h          |    2 +-
 arch/ia64/kernel/process.c              |    2 +-
 arch/m32r/kernel/process.c              |    3 ++-
 arch/m68k/kernel/process.c              |    2 +-
 arch/m68knommu/kernel/process.c         |    2 +-
 arch/microblaze/kernel/sys_microblaze.c |    2 +-
 arch/mips/kernel/syscall.c              |    2 +-
 arch/mn10300/kernel/process.c           |    2 +-
 arch/parisc/hpux/fs.c                   |    7 ++++---
 arch/powerpc/kernel/process.c           |    2 +-
 arch/powerpc/kernel/sys_ppc32.c         |    2 +-
 arch/s390/kernel/compat_linux.c         |   10 +++++-----
 arch/s390/kernel/compat_linux.h         |   10 +++++-----
 arch/s390/kernel/entry.h                |    2 +-
 arch/s390/kernel/process.c              |    2 +-
 arch/sh/include/asm/syscalls_32.h       |    2 +-
 arch/sh/include/asm/syscalls_64.h       |    2 +-
 arch/sh/kernel/process_64.c             |    2 +-
 arch/sparc/kernel/sys_sparc32.c         |    7 ++++---
 arch/um/kernel/exec.c                   |    6 +++---
 arch/um/kernel/internal.h               |    2 +-
 arch/um/kernel/syscall.c                |    2 +-
 arch/x86/ia32/sys_ia32.c                |   14 +++++++-------
 arch/x86/include/asm/sys_ia32.h         |   12 ++++++------
 arch/x86/include/asm/syscalls.h         |    2 +-
 arch/x86/kernel/entry_64.S              |    4 ++--
 arch/x86/kernel/process.c               |    2 +-
 arch/xtensa/kernel/process.c            |    2 +-
 fs/compat.c                             |   23 +++++++++++++----------
 fs/stat.c                               |   29 ++++++++++++++++++-----------
 fs/utimes.c                             |    7 ++++---
 include/linux/compat.h                  |    6 +++---
 include/linux/fs.h                      |    6 +++---
 include/linux/syscalls.h                |   20 ++++++++++----------
 include/linux/time.h                    |    2 +-
 44 files changed, 125 insertions(+), 109 deletions(-)

diff --git a/arch/alpha/kernel/osf_sys.c b/arch/alpha/kernel/osf_sys.c
index de9d397..1719fe3 100644
--- a/arch/alpha/kernel/osf_sys.c
+++ b/arch/alpha/kernel/osf_sys.c
@@ -244,7 +244,7 @@ do_osf_statfs(struct dentry * dentry, struct osf_statfs __user *buffer,
 	return error;	
 }
 
-SYSCALL_DEFINE3(osf_statfs, char __user *, pathname,
+SYSCALL_DEFINE3(osf_statfs, const char __user *, pathname,
 		struct osf_statfs __user *, buffer, unsigned long, bufsiz)
 {
 	struct path path;
@@ -358,7 +358,7 @@ osf_procfs_mount(char *dirname, struct procfs_args __user *args, int flags)
 	return do_mount("", dirname, "proc", flags, NULL);
 }
 
-SYSCALL_DEFINE4(osf_mount, unsigned long, typenr, char __user *, path,
+SYSCALL_DEFINE4(osf_mount, unsigned long, typenr, const char __user *, path,
 		int, flag, void __user *, data)
 {
 	int retval;
@@ -932,7 +932,7 @@ SYSCALL_DEFINE3(osf_setitimer, int, which, struct itimerval32 __user *, in,
 
 }
 
-SYSCALL_DEFINE2(osf_utimes, char __user *, filename,
+SYSCALL_DEFINE2(osf_utimes, const char __user *, filename,
 		struct timeval32 __user *, tvs)
 {
 	struct timespec tv[2];
diff --git a/arch/alpha/kernel/process.c b/arch/alpha/kernel/process.c
index 395a464..88e608a 100644
--- a/arch/alpha/kernel/process.c
+++ b/arch/alpha/kernel/process.c
@@ -387,7 +387,7 @@ EXPORT_SYMBOL(dump_elf_task_fp);
  * sys_execve() executes a new program.
  */
 asmlinkage int
-do_sys_execve(char __user *ufilename, char __user * __user *argv,
+do_sys_execve(const char __user *ufilename, char __user * __user *argv,
 	      char __user * __user *envp, struct pt_regs *regs)
 {
 	int error;
diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
index c235018..5b7c541 100644
--- a/arch/arm/kernel/sys_arm.c
+++ b/arch/arm/kernel/sys_arm.c
@@ -62,7 +62,7 @@ asmlinkage int sys_vfork(struct pt_regs *regs)
 /* sys_execve() executes a new program.
  * This is called indirectly via a small wrapper
  */
-asmlinkage int sys_execve(char __user *filenamei, char __user * __user *argv,
+asmlinkage int sys_execve(const char __user *filenamei, char __user * __user *argv,
 			  char __user * __user *envp, struct pt_regs *regs)
 {
 	int error;
@@ -84,7 +84,7 @@ int kernel_execve(const char *filename, char *const argv[], char *const envp[])
 	int ret;
 
 	memset(&regs, 0, sizeof(struct pt_regs));
-	ret = do_execve((char *)filename, (char __user * __user *)argv,
+	ret = do_execve(filename, (char __user * __user *)argv,
 			(char __user * __user *)envp, &regs);
 	if (ret < 0)
 		goto out;
diff --git a/arch/arm/kernel/sys_oabi-compat.c b/arch/arm/kernel/sys_oabi-compat.c
index 33ff678..4ad8da1 100644
--- a/arch/arm/kernel/sys_oabi-compat.c
+++ b/arch/arm/kernel/sys_oabi-compat.c
@@ -141,7 +141,7 @@ static long cp_oldabi_stat64(struct kstat *stat,
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
-asmlinkage long sys_oabi_stat64(char __user * filename,
+asmlinkage long sys_oabi_stat64(const char __user * filename,
 				struct oldabi_stat64 __user * statbuf)
 {
 	struct kstat stat;
@@ -151,7 +151,7 @@ asmlinkage long sys_oabi_stat64(char __user * filename,
 	return error;
 }
 
-asmlinkage long sys_oabi_lstat64(char __user * filename,
+asmlinkage long sys_oabi_lstat64(const char __user * filename,
 				 struct oldabi_stat64 __user * statbuf)
 {
 	struct kstat stat;
@@ -172,7 +172,7 @@ asmlinkage long sys_oabi_fstat64(unsigned long fd,
 }
 
 asmlinkage long sys_oabi_fstatat64(int dfd,
-				   char __user *filename,
+				   const char __user *filename,
 				   struct oldabi_stat64  __user *statbuf,
 				   int flag)
 {
diff --git a/arch/avr32/include/asm/syscalls.h b/arch/avr32/include/asm/syscalls.h
index 66a1972..ab608b7 100644
--- a/arch/avr32/include/asm/syscalls.h
+++ b/arch/avr32/include/asm/syscalls.h
@@ -21,7 +21,7 @@ asmlinkage int sys_clone(unsigned long, unsigned long,
 			 unsigned long, unsigned long,
 			 struct pt_regs *);
 asmlinkage int sys_vfork(struct pt_regs *);
-asmlinkage int sys_execve(char __user *, char __user *__user *,
+asmlinkage int sys_execve(const char __user *, char __user *__user *,
 			  char __user *__user *, struct pt_regs *);
 
 /* kernel/signal.c */
diff --git a/arch/avr32/kernel/process.c b/arch/avr32/kernel/process.c
index 2d76515..e5daddf 100644
--- a/arch/avr32/kernel/process.c
+++ b/arch/avr32/kernel/process.c
@@ -383,7 +383,8 @@ asmlinkage int sys_vfork(struct pt_regs *regs)
 		       0, NULL, NULL);
 }
 
-asmlinkage int sys_execve(char __user *ufilename, char __user *__user *uargv,
+asmlinkage int sys_execve(const char __user *ufilename,
+			  char __user *__user *uargv,
 			  char __user *__user *uenvp, struct pt_regs *regs)
 {
 	int error;
diff --git a/arch/blackfin/kernel/process.c b/arch/blackfin/kernel/process.c
index 93ec07d..a566f61 100644
--- a/arch/blackfin/kernel/process.c
+++ b/arch/blackfin/kernel/process.c
@@ -209,7 +209,7 @@ copy_thread(unsigned long clone_flags,
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char __user *name, char __user * __user *argv, char __user * __user *envp)
+asmlinkage int sys_execve(const char __user *name, char __user * __user *argv, char __user * __user *envp)
 {
 	int error;
 	char *filename;
diff --git a/arch/frv/kernel/process.c b/arch/frv/kernel/process.c
index 21d0fd1..428931c 100644
--- a/arch/frv/kernel/process.c
+++ b/arch/frv/kernel/process.c
@@ -250,7 +250,8 @@ int copy_thread(unsigned long clone_flags,
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char __user *name, char __user * __user *argv, char __user * __user *envp)
+asmlinkage int sys_execve(const char __user *name, char __user * __user *argv,
+			  char __user * __user *envp)
 {
 	int error;
 	char * filename;
diff --git a/arch/h8300/kernel/process.c b/arch/h8300/kernel/process.c
index 8c8b0ff..8b7b78d 100644
--- a/arch/h8300/kernel/process.c
+++ b/arch/h8300/kernel/process.c
@@ -212,7 +212,7 @@ int copy_thread(unsigned long clone_flags,
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char *name, char **argv, char **envp,int dummy,...)
+asmlinkage int sys_execve(const char *name, char **argv, char **envp,int dummy,...)
 {
 	int error;
 	char * filename;
diff --git a/arch/ia64/include/asm/unistd.h b/arch/ia64/include/asm/unistd.h
index bb8b0ff..46f36fc 100644
--- a/arch/ia64/include/asm/unistd.h
+++ b/arch/ia64/include/asm/unistd.h
@@ -353,7 +353,7 @@ asmlinkage unsigned long sys_mmap2(
 				int fd, long pgoff);
 struct pt_regs;
 struct sigaction;
-long sys_execve(char __user *filename, char __user * __user *argv,
+long sys_execve(const char __user *filename, char __user * __user *argv,
 			   char __user * __user *envp, struct pt_regs *regs);
 asmlinkage long sys_ia64_pipe(void);
 asmlinkage long sys_rt_sigaction(int sig,
diff --git a/arch/ia64/kernel/process.c b/arch/ia64/kernel/process.c
index 53f1648..a879c03 100644
--- a/arch/ia64/kernel/process.c
+++ b/arch/ia64/kernel/process.c
@@ -633,7 +633,7 @@ dump_fpu (struct pt_regs *pt, elf_fpregset_t dst)
 }
 
 long
-sys_execve (char __user *filename, char __user * __user *argv, char __user * __user *envp,
+sys_execve (const char __user *filename, char __user * __user *argv, char __user * __user *envp,
 	    struct pt_regs *regs)
 {
 	char *fname;
diff --git a/arch/m32r/kernel/process.c b/arch/m32r/kernel/process.c
index bc8c8c1..8665a4d 100644
--- a/arch/m32r/kernel/process.c
+++ b/arch/m32r/kernel/process.c
@@ -288,7 +288,8 @@ asmlinkage int sys_vfork(unsigned long r0, unsigned long r1, unsigned long r2,
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char __user *ufilename, char __user * __user *uargv,
+asmlinkage int sys_execve(const char __user *ufilename,
+			  char __user * __user *uargv,
 			  char __user * __user *uenvp,
 			  unsigned long r3, unsigned long r4, unsigned long r5,
 			  unsigned long r6, struct pt_regs regs)
diff --git a/arch/m68k/kernel/process.c b/arch/m68k/kernel/process.c
index 1a6be27..221d0b7 100644
--- a/arch/m68k/kernel/process.c
+++ b/arch/m68k/kernel/process.c
@@ -315,7 +315,7 @@ EXPORT_SYMBOL(dump_fpu);
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char __user *name, char __user * __user *argv, char __user * __user *envp)
+asmlinkage int sys_execve(const char __user *name, char __user * __user *argv, char __user * __user *envp)
 {
 	int error;
 	char * filename;
diff --git a/arch/m68knommu/kernel/process.c b/arch/m68knommu/kernel/process.c
index 6aa6613..6350f68 100644
--- a/arch/m68knommu/kernel/process.c
+++ b/arch/m68knommu/kernel/process.c
@@ -350,7 +350,7 @@ void dump(struct pt_regs *fp)
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char *name, char **argv, char **envp)
+asmlinkage int sys_execve(const char *name, char **argv, char **envp)
 {
 	int error;
 	char * filename;
diff --git a/arch/microblaze/kernel/sys_microblaze.c b/arch/microblaze/kernel/sys_microblaze.c
index f4e00b7..6abab6e 100644
--- a/arch/microblaze/kernel/sys_microblaze.c
+++ b/arch/microblaze/kernel/sys_microblaze.c
@@ -47,7 +47,7 @@ asmlinkage long microblaze_clone(int flags, unsigned long stack, struct pt_regs
 	return do_fork(flags, stack, regs, 0, NULL, NULL);
 }
 
-asmlinkage long microblaze_execve(char __user *filenamei, char __user *__user *argv,
+asmlinkage long microblaze_execve(const char __user *filenamei, char __user *__user *argv,
 			char __user *__user *envp, struct pt_regs *regs)
 {
 	int error;
diff --git a/arch/mips/kernel/syscall.c b/arch/mips/kernel/syscall.c
index dd81b0f..6322c39 100644
--- a/arch/mips/kernel/syscall.c
+++ b/arch/mips/kernel/syscall.c
@@ -207,7 +207,7 @@ asmlinkage int sys_execve(nabi_no_regargs struct pt_regs regs)
 	int error;
 	char * filename;
 
-	filename = getname((char __user *) (long)regs.regs[4]);
+	filename = getname((const char __user *) (long)regs.regs[4]);
 	error = PTR_ERR(filename);
 	if (IS_ERR(filename))
 		goto out;
diff --git a/arch/mn10300/kernel/process.c b/arch/mn10300/kernel/process.c
index 82b817c..762eb32 100644
--- a/arch/mn10300/kernel/process.c
+++ b/arch/mn10300/kernel/process.c
@@ -268,7 +268,7 @@ asmlinkage long sys_vfork(void)
 		       0, NULL, NULL);
 }
 
-asmlinkage long sys_execve(char __user *name,
+asmlinkage long sys_execve(const char __user *name,
 			   char __user * __user *argv,
 			   char __user * __user *envp)
 {
diff --git a/arch/parisc/hpux/fs.c b/arch/parisc/hpux/fs.c
index 6935123..1444875 100644
--- a/arch/parisc/hpux/fs.c
+++ b/arch/parisc/hpux/fs.c
@@ -36,7 +36,7 @@ int hpux_execve(struct pt_regs *regs)
 	int error;
 	char *filename;
 
-	filename = getname((char __user *) regs->gr[26]);
+	filename = getname((const char __user *) regs->gr[26]);
 	error = PTR_ERR(filename);
 	if (IS_ERR(filename))
 		goto out;
@@ -169,7 +169,7 @@ static int cp_hpux_stat(struct kstat *stat, struct hpux_stat64 __user *statbuf)
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
-long hpux_stat64(char __user *filename, struct hpux_stat64 __user *statbuf)
+long hpux_stat64(const char __user *filename, struct hpux_stat64 __user *statbuf)
 {
 	struct kstat stat;
 	int error = vfs_stat(filename, &stat);
@@ -191,7 +191,8 @@ long hpux_fstat64(unsigned int fd, struct hpux_stat64 __user *statbuf)
 	return error;
 }
 
-long hpux_lstat64(char __user *filename, struct hpux_stat64 __user *statbuf)
+long hpux_lstat64(const char __user *filename,
+		  struct hpux_stat64 __user *statbuf)
 {
 	struct kstat stat;
 	int error = vfs_lstat(filename, &stat);
diff --git a/arch/powerpc/kernel/process.c b/arch/powerpc/kernel/process.c
index 773424d..3ef6ed4 100644
--- a/arch/powerpc/kernel/process.c
+++ b/arch/powerpc/kernel/process.c
@@ -991,7 +991,7 @@ int sys_execve(unsigned long a0, unsigned long a1, unsigned long a2,
 	int error;
 	char *filename;
 
-	filename = getname((char __user *) a0);
+	filename = getname((const char __user *) a0);
 	error = PTR_ERR(filename);
 	if (IS_ERR(filename))
 		goto out;
diff --git a/arch/powerpc/kernel/sys_ppc32.c b/arch/powerpc/kernel/sys_ppc32.c
index 19471a1..20fd701 100644
--- a/arch/powerpc/kernel/sys_ppc32.c
+++ b/arch/powerpc/kernel/sys_ppc32.c
@@ -546,7 +546,7 @@ compat_ssize_t compat_sys_pread64(unsigned int fd, char __user *ubuf, compat_siz
 	return sys_pread64(fd, ubuf, count, ((loff_t)poshi << 32) | poslo);
 }
 
-compat_ssize_t compat_sys_pwrite64(unsigned int fd, char __user *ubuf, compat_size_t count,
+compat_ssize_t compat_sys_pwrite64(unsigned int fd, const char __user *ubuf, compat_size_t count,
 			      u32 reg6, u32 poshi, u32 poslo)
 {
 	return sys_pwrite64(fd, ubuf, count, ((loff_t)poshi << 32) | poslo);
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 73b624e..1e6449c 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -436,7 +436,7 @@ sys32_rt_sigqueueinfo(int pid, int sig, compat_siginfo_t __user *uinfo)
  * sys32_execve() executes a new program after the asm stub has set
  * things up for us.  This should basically do what I want it to.
  */
-asmlinkage long sys32_execve(char __user *name, compat_uptr_t __user *argv,
+asmlinkage long sys32_execve(const char __user *name, compat_uptr_t __user *argv,
 			     compat_uptr_t __user *envp)
 {
 	struct pt_regs *regs = task_pt_regs(current);
@@ -570,7 +570,7 @@ static int cp_stat64(struct stat64_emu31 __user *ubuf, struct kstat *stat)
 	return copy_to_user(ubuf,&tmp,sizeof(tmp)) ? -EFAULT : 0; 
 }
 
-asmlinkage long sys32_stat64(char __user * filename, struct stat64_emu31 __user * statbuf)
+asmlinkage long sys32_stat64(const char __user * filename, struct stat64_emu31 __user * statbuf)
 {
 	struct kstat stat;
 	int ret = vfs_stat(filename, &stat);
@@ -579,7 +579,7 @@ asmlinkage long sys32_stat64(char __user * filename, struct stat64_emu31 __user
 	return ret;
 }
 
-asmlinkage long sys32_lstat64(char __user * filename, struct stat64_emu31 __user * statbuf)
+asmlinkage long sys32_lstat64(const char __user * filename, struct stat64_emu31 __user * statbuf)
 {
 	struct kstat stat;
 	int ret = vfs_lstat(filename, &stat);
@@ -597,7 +597,7 @@ asmlinkage long sys32_fstat64(unsigned long fd, struct stat64_emu31 __user * sta
 	return ret;
 }
 
-asmlinkage long sys32_fstatat64(unsigned int dfd, char __user *filename,
+asmlinkage long sys32_fstatat64(unsigned int dfd, const char __user *filename,
 				struct stat64_emu31 __user* statbuf, int flag)
 {
 	struct kstat stat;
@@ -655,7 +655,7 @@ asmlinkage long sys32_read(unsigned int fd, char __user * buf, size_t count)
 	return sys_read(fd, buf, count);
 }
 
-asmlinkage long sys32_write(unsigned int fd, char __user * buf, size_t count)
+asmlinkage long sys32_write(unsigned int fd, const char __user * buf, size_t count)
 {
 	if ((compat_ssize_t) count < 0)
 		return -EINVAL; 
diff --git a/arch/s390/kernel/compat_linux.h b/arch/s390/kernel/compat_linux.h
index cb97afc..9635d75 100644
--- a/arch/s390/kernel/compat_linux.h
+++ b/arch/s390/kernel/compat_linux.h
@@ -193,7 +193,7 @@ long sys32_rt_sigprocmask(int how, compat_sigset_t __user *set,
 			  compat_sigset_t __user *oset, size_t sigsetsize);
 long sys32_rt_sigpending(compat_sigset_t __user *set, size_t sigsetsize);
 long sys32_rt_sigqueueinfo(int pid, int sig, compat_siginfo_t __user *uinfo);
-long sys32_execve(char __user *name, compat_uptr_t __user *argv,
+long sys32_execve(const char __user *name, compat_uptr_t __user *argv,
 		  compat_uptr_t __user *envp);
 long sys32_init_module(void __user *umod, unsigned long len,
 		       const char __user *uargs);
@@ -207,16 +207,16 @@ long sys32_sendfile(int out_fd, int in_fd, compat_off_t __user *offset,
 		    size_t count);
 long sys32_sendfile64(int out_fd, int in_fd, compat_loff_t __user *offset,
 		      s32 count);
-long sys32_stat64(char __user * filename, struct stat64_emu31 __user * statbuf);
-long sys32_lstat64(char __user * filename,
+long sys32_stat64(const char __user * filename, struct stat64_emu31 __user * statbuf);
+long sys32_lstat64(const char __user * filename,
 		   struct stat64_emu31 __user * statbuf);
 long sys32_fstat64(unsigned long fd, struct stat64_emu31 __user * statbuf);
-long sys32_fstatat64(unsigned int dfd, char __user *filename,
+long sys32_fstatat64(unsigned int dfd, const char __user *filename,
 		     struct stat64_emu31 __user* statbuf, int flag);
 unsigned long old32_mmap(struct mmap_arg_struct_emu31 __user *arg);
 long sys32_mmap2(struct mmap_arg_struct_emu31 __user *arg);
 long sys32_read(unsigned int fd, char __user * buf, size_t count);
-long sys32_write(unsigned int fd, char __user * buf, size_t count);
+long sys32_write(unsigned int fd, const char __user * buf, size_t count);
 long sys32_fadvise64(int fd, loff_t offset, size_t len, int advise);
 long sys32_fadvise64_64(struct fadvise64_64_args __user *args);
 long sys32_sigaction(int sig, const struct old_sigaction32 __user *act,
diff --git a/arch/s390/kernel/entry.h b/arch/s390/kernel/entry.h
index eb15c12..e2c048b 100644
--- a/arch/s390/kernel/entry.h
+++ b/arch/s390/kernel/entry.h
@@ -42,7 +42,7 @@ long sys_clone(unsigned long newsp, unsigned long clone_flags,
 	       int __user *parent_tidptr, int __user *child_tidptr);
 long sys_vfork(void);
 void execve_tail(void);
-long sys_execve(char __user *name, char __user * __user *argv,
+long sys_execve(const char __user *name, char __user * __user *argv,
 		char __user * __user *envp);
 long sys_sigsuspend(int history0, int history1, old_sigset_t mask);
 long sys_sigaction(int sig, const struct old_sigaction __user *act,
diff --git a/arch/s390/kernel/process.c b/arch/s390/kernel/process.c
index 1039fde..7eafaf2 100644
--- a/arch/s390/kernel/process.c
+++ b/arch/s390/kernel/process.c
@@ -267,7 +267,7 @@ asmlinkage void execve_tail(void)
 /*
  * sys_execve() executes a new program.
  */
-SYSCALL_DEFINE3(execve, char __user *, name, char __user * __user *, argv,
+SYSCALL_DEFINE3(execve, const char __user *, name, char __user * __user *, argv,
 		char __user * __user *, envp)
 {
 	struct pt_regs *regs = task_pt_regs(current);
diff --git a/arch/sh/include/asm/syscalls_32.h b/arch/sh/include/asm/syscalls_32.h
index 8b30200..be201fd 100644
--- a/arch/sh/include/asm/syscalls_32.h
+++ b/arch/sh/include/asm/syscalls_32.h
@@ -19,7 +19,7 @@ asmlinkage int sys_clone(unsigned long clone_flags, unsigned long newsp,
 asmlinkage int sys_vfork(unsigned long r4, unsigned long r5,
 			 unsigned long r6, unsigned long r7,
 			 struct pt_regs __regs);
-asmlinkage int sys_execve(char __user *ufilename, char __user * __user *uargv,
+asmlinkage int sys_execve(const char __user *ufilename, char __user * __user *uargv,
 			  char __user * __user *uenvp, unsigned long r7,
 			  struct pt_regs __regs);
 asmlinkage int sys_sigsuspend(old_sigset_t mask, unsigned long r5,
diff --git a/arch/sh/include/asm/syscalls_64.h b/arch/sh/include/asm/syscalls_64.h
index 751fd88..ee519f4 100644
--- a/arch/sh/include/asm/syscalls_64.h
+++ b/arch/sh/include/asm/syscalls_64.h
@@ -21,7 +21,7 @@ asmlinkage int sys_vfork(unsigned long r2, unsigned long r3,
 			 unsigned long r4, unsigned long r5,
 			 unsigned long r6, unsigned long r7,
 			 struct pt_regs *pregs);
-asmlinkage int sys_execve(char *ufilename, char **uargv,
+asmlinkage int sys_execve(const char *ufilename, char **uargv,
 			  char **uenvp, unsigned long r5,
 			  unsigned long r6, unsigned long r7,
 			  struct pt_regs *pregs);
diff --git a/arch/sh/kernel/process_64.c b/arch/sh/kernel/process_64.c
index d4ca648..68d128d 100644
--- a/arch/sh/kernel/process_64.c
+++ b/arch/sh/kernel/process_64.c
@@ -483,7 +483,7 @@ asmlinkage int sys_vfork(unsigned long r2, unsigned long r3,
 /*
  * sys_execve() executes a new program.
  */
-asmlinkage int sys_execve(char *ufilename, char **uargv,
+asmlinkage int sys_execve(const char *ufilename, char **uargv,
 			  char **uenvp, unsigned long r5,
 			  unsigned long r6, unsigned long r7,
 			  struct pt_regs *pregs)
diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index c0ca875..e6375a7 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -162,7 +162,7 @@ static int cp_compat_stat64(struct kstat *stat,
 	return err;
 }
 
-asmlinkage long compat_sys_stat64(char __user * filename,
+asmlinkage long compat_sys_stat64(const char __user * filename,
 		struct compat_stat64 __user *statbuf)
 {
 	struct kstat stat;
@@ -173,7 +173,7 @@ asmlinkage long compat_sys_stat64(char __user * filename,
 	return error;
 }
 
-asmlinkage long compat_sys_lstat64(char __user * filename,
+asmlinkage long compat_sys_lstat64(const char __user * filename,
 		struct compat_stat64 __user *statbuf)
 {
 	struct kstat stat;
@@ -195,7 +195,8 @@ asmlinkage long compat_sys_fstat64(unsigned int fd,
 	return error;
 }
 
-asmlinkage long compat_sys_fstatat64(unsigned int dfd, char __user *filename,
+asmlinkage long compat_sys_fstatat64(unsigned int dfd,
+		const char __user *filename,
 		struct compat_stat64 __user * statbuf, int flag)
 {
 	struct kstat stat;
diff --git a/arch/um/kernel/exec.c b/arch/um/kernel/exec.c
index 97974c1..59b20d9 100644
--- a/arch/um/kernel/exec.c
+++ b/arch/um/kernel/exec.c
@@ -44,7 +44,7 @@ void start_thread(struct pt_regs *regs, unsigned long eip, unsigned long esp)
 	PT_REGS_SP(regs) = esp;
 }
 
-static long execve1(char *file, char __user * __user *argv,
+static long execve1(const char *file, char __user * __user *argv,
 		    char __user *__user *env)
 {
 	long error;
@@ -61,7 +61,7 @@ static long execve1(char *file, char __user * __user *argv,
 	return error;
 }
 
-long um_execve(char *file, char __user *__user *argv, char __user *__user *env)
+long um_execve(const char *file, char __user *__user *argv, char __user *__user *env)
 {
 	long err;
 
@@ -71,7 +71,7 @@ long um_execve(char *file, char __user *__user *argv, char __user *__user *env)
 	return err;
 }
 
-long sys_execve(char __user *file, char __user *__user *argv,
+long sys_execve(const char __user *file, char __user *__user *argv,
 		char __user *__user *env)
 {
 	long error;
diff --git a/arch/um/kernel/internal.h b/arch/um/kernel/internal.h
index 3bda43c..1303a10 100644
--- a/arch/um/kernel/internal.h
+++ b/arch/um/kernel/internal.h
@@ -1 +1 @@
-extern long um_execve(char *file, char __user *__user *argv, char __user *__user *env);
+extern long um_execve(const char *file, char __user *__user *argv, char __user *__user *env);
diff --git a/arch/um/kernel/syscall.c b/arch/um/kernel/syscall.c
index 4393173..7427c0b 100644
--- a/arch/um/kernel/syscall.c
+++ b/arch/um/kernel/syscall.c
@@ -58,7 +58,7 @@ int kernel_execve(const char *filename, char *const argv[], char *const envp[])
 
 	fs = get_fs();
 	set_fs(KERNEL_DS);
-	ret = um_execve((char *)filename, (char __user *__user *)argv,
+	ret = um_execve(filename, (char __user *__user *)argv,
 			(char __user *__user *) envp);
 	set_fs(fs);
 
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index 626be15..1baddad 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -51,7 +51,7 @@
 #define AA(__x)		((unsigned long)(__x))
 
 
-asmlinkage long sys32_truncate64(char __user *filename,
+asmlinkage long sys32_truncate64(const char __user *filename,
 				 unsigned long offset_low,
 				 unsigned long offset_high)
 {
@@ -96,7 +96,7 @@ static int cp_stat64(struct stat64 __user *ubuf, struct kstat *stat)
 	return 0;
 }
 
-asmlinkage long sys32_stat64(char __user *filename,
+asmlinkage long sys32_stat64(const char __user *filename,
 			     struct stat64 __user *statbuf)
 {
 	struct kstat stat;
@@ -107,7 +107,7 @@ asmlinkage long sys32_stat64(char __user *filename,
 	return ret;
 }
 
-asmlinkage long sys32_lstat64(char __user *filename,
+asmlinkage long sys32_lstat64(const char __user *filename,
 			      struct stat64 __user *statbuf)
 {
 	struct kstat stat;
@@ -126,7 +126,7 @@ asmlinkage long sys32_fstat64(unsigned int fd, struct stat64 __user *statbuf)
 	return ret;
 }
 
-asmlinkage long sys32_fstatat(unsigned int dfd, char __user *filename,
+asmlinkage long sys32_fstatat(unsigned int dfd, const char __user *filename,
 			      struct stat64 __user *statbuf, int flag)
 {
 	struct kstat stat;
@@ -408,8 +408,8 @@ asmlinkage long sys32_pread(unsigned int fd, char __user *ubuf, u32 count,
 			 ((loff_t)AA(poshi) << 32) | AA(poslo));
 }
 
-asmlinkage long sys32_pwrite(unsigned int fd, char __user *ubuf, u32 count,
-			     u32 poslo, u32 poshi)
+asmlinkage long sys32_pwrite(unsigned int fd, const char __user *ubuf,
+			     u32 count, u32 poslo, u32 poshi)
 {
 	return sys_pwrite64(fd, ubuf, count,
 			  ((loff_t)AA(poshi) << 32) | AA(poslo));
@@ -449,7 +449,7 @@ asmlinkage long sys32_sendfile(int out_fd, int in_fd,
 	return ret;
 }
 
-asmlinkage long sys32_execve(char __user *name, compat_uptr_t __user *argv,
+asmlinkage long sys32_execve(const char __user *name, compat_uptr_t __user *argv,
 			     compat_uptr_t __user *envp, struct pt_regs *regs)
 {
 	long error;
diff --git a/arch/x86/include/asm/sys_ia32.h b/arch/x86/include/asm/sys_ia32.h
index 3ad4217..c8a052a 100644
--- a/arch/x86/include/asm/sys_ia32.h
+++ b/arch/x86/include/asm/sys_ia32.h
@@ -18,13 +18,13 @@
 #include <asm/ia32.h>
 
 /* ia32/sys_ia32.c */
-asmlinkage long sys32_truncate64(char __user *, unsigned long, unsigned long);
+asmlinkage long sys32_truncate64(const char __user *, unsigned long, unsigned long);
 asmlinkage long sys32_ftruncate64(unsigned int, unsigned long, unsigned long);
 
-asmlinkage long sys32_stat64(char __user *, struct stat64 __user *);
-asmlinkage long sys32_lstat64(char __user *, struct stat64 __user *);
+asmlinkage long sys32_stat64(const char __user *, struct stat64 __user *);
+asmlinkage long sys32_lstat64(const char __user *, struct stat64 __user *);
 asmlinkage long sys32_fstat64(unsigned int, struct stat64 __user *);
-asmlinkage long sys32_fstatat(unsigned int, char __user *,
+asmlinkage long sys32_fstatat(unsigned int, const char __user *,
 			      struct stat64 __user *, int);
 struct mmap_arg_struct32;
 asmlinkage long sys32_mmap(struct mmap_arg_struct32 __user *);
@@ -49,12 +49,12 @@ asmlinkage long sys32_rt_sigpending(compat_sigset_t __user *, compat_size_t);
 asmlinkage long sys32_rt_sigqueueinfo(int, int, compat_siginfo_t __user *);
 
 asmlinkage long sys32_pread(unsigned int, char __user *, u32, u32, u32);
-asmlinkage long sys32_pwrite(unsigned int, char __user *, u32, u32, u32);
+asmlinkage long sys32_pwrite(unsigned int, const char __user *, u32, u32, u32);
 
 asmlinkage long sys32_personality(unsigned long);
 asmlinkage long sys32_sendfile(int, int, compat_off_t __user *, s32);
 
-asmlinkage long sys32_execve(char __user *, compat_uptr_t __user *,
+asmlinkage long sys32_execve(const char __user *, compat_uptr_t __user *,
 			     compat_uptr_t __user *, struct pt_regs *);
 asmlinkage long sys32_clone(unsigned int, unsigned int, struct pt_regs *);
 
diff --git a/arch/x86/include/asm/syscalls.h b/arch/x86/include/asm/syscalls.h
index 5c044b4..feb2ff9 100644
--- a/arch/x86/include/asm/syscalls.h
+++ b/arch/x86/include/asm/syscalls.h
@@ -23,7 +23,7 @@ long sys_iopl(unsigned int, struct pt_regs *);
 /* kernel/process.c */
 int sys_fork(struct pt_regs *);
 int sys_vfork(struct pt_regs *);
-long sys_execve(char __user *, char __user * __user *,
+long sys_execve(const char __user *, char __user * __user *,
 		char __user * __user *, struct pt_regs *);
 long sys_clone(unsigned long, unsigned long, void __user *,
 	       void __user *, struct pt_regs *);
diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index 0697ff1..77f5986 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -1185,13 +1185,13 @@ END(kernel_thread_helper)
  * execve(). This function needs to use IRET, not SYSRET, to set up all state properly.
  *
  * C extern interface:
- *	 extern long execve(char *name, char **argv, char **envp)
+ *	 extern long execve(const char *name, char **argv, char **envp)
  *
  * asm input arguments:
  *	rdi: name, rsi: argv, rdx: envp
  *
  * We want to fallback into:
- *	extern long sys_execve(char *name, char **argv,char **envp, struct pt_regs *regs)
+ *	extern long sys_execve(const char *name, char **argv,char **envp, struct pt_regs *regs)
  *
  * do_sys_execve asm fallback arguments:
  *	rdi: name, rsi: argv, rdx: envp, rcx: fake frame on the stack
diff --git a/arch/x86/kernel/process.c b/arch/x86/kernel/process.c
index e7e3521..f5c816e 100644
--- a/arch/x86/kernel/process.c
+++ b/arch/x86/kernel/process.c
@@ -300,7 +300,7 @@ EXPORT_SYMBOL(kernel_thread);
 /*
  * sys_execve() executes a new program.
  */
-long sys_execve(char __user *name, char __user * __user *argv,
+long sys_execve(const char __user *name, char __user * __user *argv,
 		char __user * __user *envp, struct pt_regs *regs)
 {
 	long error;
diff --git a/arch/xtensa/kernel/process.c b/arch/xtensa/kernel/process.c
index f167e0f..7c2f38f 100644
--- a/arch/xtensa/kernel/process.c
+++ b/arch/xtensa/kernel/process.c
@@ -318,7 +318,7 @@ long xtensa_clone(unsigned long clone_flags, unsigned long newsp,
  */
 
 asmlinkage
-long xtensa_execve(char __user *name, char __user * __user *argv,
+long xtensa_execve(const char __user *name, char __user * __user *argv,
                    char __user * __user *envp,
                    long a3, long a4, long a5,
                    struct pt_regs *regs)
diff --git a/fs/compat.c b/fs/compat.c
index 6490d21..d72591a 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -76,7 +76,8 @@ int compat_printk(const char *fmt, ...)
  * Not all architectures have sys_utime, so implement this in terms
  * of sys_utimes.
  */
-asmlinkage long compat_sys_utime(char __user *filename, struct compat_utimbuf __user *t)
+asmlinkage long compat_sys_utime(const char __user *filename,
+				 struct compat_utimbuf __user *t)
 {
 	struct timespec tv[2];
 
@@ -90,7 +91,7 @@ asmlinkage long compat_sys_utime(char __user *filename, struct compat_utimbuf __
 	return do_utimes(AT_FDCWD, filename, t ? tv : NULL, 0);
 }
 
-asmlinkage long compat_sys_utimensat(unsigned int dfd, char __user *filename, struct compat_timespec __user *t, int flags)
+asmlinkage long compat_sys_utimensat(unsigned int dfd, const char __user *filename, struct compat_timespec __user *t, int flags)
 {
 	struct timespec tv[2];
 
@@ -105,7 +106,7 @@ asmlinkage long compat_sys_utimensat(unsigned int dfd, char __user *filename, st
 	return do_utimes(dfd, filename, t ? tv : NULL, flags);
 }
 
-asmlinkage long compat_sys_futimesat(unsigned int dfd, char __user *filename, struct compat_timeval __user *t)
+asmlinkage long compat_sys_futimesat(unsigned int dfd, const char __user *filename, struct compat_timeval __user *t)
 {
 	struct timespec tv[2];
 
@@ -124,7 +125,7 @@ asmlinkage long compat_sys_futimesat(unsigned int dfd, char __user *filename, st
 	return do_utimes(dfd, filename, t ? tv : NULL, 0);
 }
 
-asmlinkage long compat_sys_utimes(char __user *filename, struct compat_timeval __user *t)
+asmlinkage long compat_sys_utimes(const char __user *filename, struct compat_timeval __user *t)
 {
 	return compat_sys_futimesat(AT_FDCWD, filename, t);
 }
@@ -168,7 +169,7 @@ static int cp_compat_stat(struct kstat *stat, struct compat_stat __user *ubuf)
 	return err;
 }
 
-asmlinkage long compat_sys_newstat(char __user * filename,
+asmlinkage long compat_sys_newstat(const char __user * filename,
 		struct compat_stat __user *statbuf)
 {
 	struct kstat stat;
@@ -180,7 +181,7 @@ asmlinkage long compat_sys_newstat(char __user * filename,
 	return cp_compat_stat(&stat, statbuf);
 }
 
-asmlinkage long compat_sys_newlstat(char __user * filename,
+asmlinkage long compat_sys_newlstat(const char __user * filename,
 		struct compat_stat __user *statbuf)
 {
 	struct kstat stat;
@@ -193,7 +194,8 @@ asmlinkage long compat_sys_newlstat(char __user * filename,
 }
 
 #ifndef __ARCH_WANT_STAT64
-asmlinkage long compat_sys_newfstatat(unsigned int dfd, char __user *filename,
+asmlinkage long compat_sys_newfstatat(unsigned int dfd,
+		const char __user *filename,
 		struct compat_stat __user *statbuf, int flag)
 {
 	struct kstat stat;
@@ -836,9 +838,10 @@ static int do_nfs4_super_data_conv(void *raw_data)
 #define NCPFS_NAME      "ncpfs"
 #define NFS4_NAME	"nfs4"
 
-asmlinkage long compat_sys_mount(char __user * dev_name, char __user * dir_name,
-				 char __user * type, unsigned long flags,
-				 void __user * data)
+asmlinkage long compat_sys_mount(const char __user * dev_name,
+				 const char __user * dir_name,
+				 const char __user * type, unsigned long flags,
+				 const void __user * data)
 {
 	char *kernel_type;
 	unsigned long data_page;
diff --git a/fs/stat.c b/fs/stat.c
index c4ecd52..12e90e2 100644
--- a/fs/stat.c
+++ b/fs/stat.c
@@ -68,7 +68,8 @@ int vfs_fstat(unsigned int fd, struct kstat *stat)
 }
 EXPORT_SYMBOL(vfs_fstat);
 
-int vfs_fstatat(int dfd, char __user *filename, struct kstat *stat, int flag)
+int vfs_fstatat(int dfd, const char __user *filename, struct kstat *stat,
+		int flag)
 {
 	struct path path;
 	int error = -EINVAL;
@@ -91,13 +92,13 @@ out:
 }
 EXPORT_SYMBOL(vfs_fstatat);
 
-int vfs_stat(char __user *name, struct kstat *stat)
+int vfs_stat(const char __user *name, struct kstat *stat)
 {
 	return vfs_fstatat(AT_FDCWD, name, stat, 0);
 }
 EXPORT_SYMBOL(vfs_stat);
 
-int vfs_lstat(char __user *name, struct kstat *stat)
+int vfs_lstat(const char __user *name, struct kstat *stat)
 {
 	return vfs_fstatat(AT_FDCWD, name, stat, AT_SYMLINK_NOFOLLOW);
 }
@@ -147,7 +148,8 @@ static int cp_old_stat(struct kstat *stat, struct __old_kernel_stat __user * sta
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
-SYSCALL_DEFINE2(stat, char __user *, filename, struct __old_kernel_stat __user *, statbuf)
+SYSCALL_DEFINE2(stat, const char __user *, filename,
+		struct __old_kernel_stat __user *, statbuf)
 {
 	struct kstat stat;
 	int error;
@@ -159,7 +161,8 @@ SYSCALL_DEFINE2(stat, char __user *, filename, struct __old_kernel_stat __user *
 	return cp_old_stat(&stat, statbuf);
 }
 
-SYSCALL_DEFINE2(lstat, char __user *, filename, struct __old_kernel_stat __user *, statbuf)
+SYSCALL_DEFINE2(lstat, const char __user *, filename,
+		struct __old_kernel_stat __user *, statbuf)
 {
 	struct kstat stat;
 	int error;
@@ -234,7 +237,8 @@ static int cp_new_stat(struct kstat *stat, struct stat __user *statbuf)
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
-SYSCALL_DEFINE2(newstat, char __user *, filename, struct stat __user *, statbuf)
+SYSCALL_DEFINE2(newstat, const char __user *, filename,
+		struct stat __user *, statbuf)
 {
 	struct kstat stat;
 	int error = vfs_stat(filename, &stat);
@@ -244,7 +248,8 @@ SYSCALL_DEFINE2(newstat, char __user *, filename, struct stat __user *, statbuf)
 	return cp_new_stat(&stat, statbuf);
 }
 
-SYSCALL_DEFINE2(newlstat, char __user *, filename, struct stat __user *, statbuf)
+SYSCALL_DEFINE2(newlstat, const char __user *, filename,
+		struct stat __user *, statbuf)
 {
 	struct kstat stat;
 	int error;
@@ -257,7 +262,7 @@ SYSCALL_DEFINE2(newlstat, char __user *, filename, struct stat __user *, statbuf
 }
 
 #if !defined(__ARCH_WANT_STAT64) || defined(__ARCH_WANT_SYS_NEWFSTATAT)
-SYSCALL_DEFINE4(newfstatat, int, dfd, char __user *, filename,
+SYSCALL_DEFINE4(newfstatat, int, dfd, const char __user *, filename,
 		struct stat __user *, statbuf, int, flag)
 {
 	struct kstat stat;
@@ -355,7 +360,8 @@ static long cp_new_stat64(struct kstat *stat, struct stat64 __user *statbuf)
 	return copy_to_user(statbuf,&tmp,sizeof(tmp)) ? -EFAULT : 0;
 }
 
-SYSCALL_DEFINE2(stat64, char __user *, filename, struct stat64 __user *, statbuf)
+SYSCALL_DEFINE2(stat64, const char __user *, filename,
+		struct stat64 __user *, statbuf)
 {
 	struct kstat stat;
 	int error = vfs_stat(filename, &stat);
@@ -366,7 +372,8 @@ SYSCALL_DEFINE2(stat64, char __user *, filename, struct stat64 __user *, statbuf
 	return error;
 }
 
-SYSCALL_DEFINE2(lstat64, char __user *, filename, struct stat64 __user *, statbuf)
+SYSCALL_DEFINE2(lstat64, const char __user *, filename,
+		struct stat64 __user *, statbuf)
 {
 	struct kstat stat;
 	int error = vfs_lstat(filename, &stat);
@@ -388,7 +395,7 @@ SYSCALL_DEFINE2(fstat64, unsigned long, fd, struct stat64 __user *, statbuf)
 	return error;
 }
 
-SYSCALL_DEFINE4(fstatat64, int, dfd, char __user *, filename,
+SYSCALL_DEFINE4(fstatat64, int, dfd, const char __user *, filename,
 		struct stat64 __user *, statbuf, int, flag)
 {
 	struct kstat stat;
diff --git a/fs/utimes.c b/fs/utimes.c
index e4c75db..179b586 100644
--- a/fs/utimes.c
+++ b/fs/utimes.c
@@ -126,7 +126,8 @@ out:
  * must be owner or have write permission.
  * Else, update from *times, must be owner or super user.
  */
-long do_utimes(int dfd, char __user *filename, struct timespec *times, int flags)
+long do_utimes(int dfd, const char __user *filename, struct timespec *times,
+	       int flags)
 {
 	int error = -EINVAL;
 
@@ -170,7 +171,7 @@ out:
 	return error;
 }
 
-SYSCALL_DEFINE4(utimensat, int, dfd, char __user *, filename,
+SYSCALL_DEFINE4(utimensat, int, dfd, const char __user *, filename,
 		struct timespec __user *, utimes, int, flags)
 {
 	struct timespec tstimes[2];
@@ -188,7 +189,7 @@ SYSCALL_DEFINE4(utimensat, int, dfd, char __user *, filename,
 	return do_utimes(dfd, filename, utimes ? tstimes : NULL, flags);
 }
 
-SYSCALL_DEFINE3(futimesat, int, dfd, char __user *, filename,
+SYSCALL_DEFINE3(futimesat, int, dfd, const char __user *, filename,
 		struct timeval __user *, utimes)
 {
 	struct timeval times[2];
diff --git a/include/linux/compat.h b/include/linux/compat.h
index 168f7da..9ddc878 100644
--- a/include/linux/compat.h
+++ b/include/linux/compat.h
@@ -331,7 +331,7 @@ asmlinkage long compat_sys_epoll_pwait(int epfd,
 			const compat_sigset_t __user *sigmask,
 			compat_size_t sigsetsize);
 
-asmlinkage long compat_sys_utimensat(unsigned int dfd, char __user *filename,
+asmlinkage long compat_sys_utimensat(unsigned int dfd, const char __user *filename,
 				struct compat_timespec __user *t, int flags);
 
 asmlinkage long compat_sys_signalfd(int ufd,
@@ -348,9 +348,9 @@ asmlinkage long compat_sys_move_pages(pid_t pid, unsigned long nr_page,
 				      const int __user *nodes,
 				      int __user *status,
 				      int flags);
-asmlinkage long compat_sys_futimesat(unsigned int dfd, char __user *filename,
+asmlinkage long compat_sys_futimesat(unsigned int dfd, const char __user *filename,
 				     struct compat_timeval __user *t);
-asmlinkage long compat_sys_newfstatat(unsigned int dfd, char __user * filename,
+asmlinkage long compat_sys_newfstatat(unsigned int dfd, const char __user * filename,
 				      struct compat_stat __user *statbuf,
 				      int flag);
 asmlinkage long compat_sys_openat(unsigned int dfd, const char __user *filename,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 68ca1b0..f5e7cf2 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2349,10 +2349,10 @@ void inode_set_bytes(struct inode *inode, loff_t bytes);
 
 extern int vfs_readdir(struct file *, filldir_t, void *);
 
-extern int vfs_stat(char __user *, struct kstat *);
-extern int vfs_lstat(char __user *, struct kstat *);
+extern int vfs_stat(const char __user *, struct kstat *);
+extern int vfs_lstat(const char __user *, struct kstat *);
 extern int vfs_fstat(unsigned int, struct kstat *);
-extern int vfs_fstatat(int , char __user *, struct kstat *, int);
+extern int vfs_fstatat(int , const char __user *, struct kstat *, int);
 
 extern int do_vfs_ioctl(struct file *filp, unsigned int fd, unsigned int cmd,
 		    unsigned long arg);
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 7f614ce..8812a63 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -393,7 +393,7 @@ asmlinkage long sys_umount(char __user *name, int flags);
 asmlinkage long sys_oldumount(char __user *name);
 asmlinkage long sys_truncate(const char __user *path, long length);
 asmlinkage long sys_ftruncate(unsigned int fd, unsigned long length);
-asmlinkage long sys_stat(char __user *filename,
+asmlinkage long sys_stat(const char __user *filename,
 			struct __old_kernel_stat __user *statbuf);
 asmlinkage long sys_statfs(const char __user * path,
 				struct statfs __user *buf);
@@ -402,21 +402,21 @@ asmlinkage long sys_statfs64(const char __user *path, size_t sz,
 asmlinkage long sys_fstatfs(unsigned int fd, struct statfs __user *buf);
 asmlinkage long sys_fstatfs64(unsigned int fd, size_t sz,
 				struct statfs64 __user *buf);
-asmlinkage long sys_lstat(char __user *filename,
+asmlinkage long sys_lstat(const char __user *filename,
 			struct __old_kernel_stat __user *statbuf);
 asmlinkage long sys_fstat(unsigned int fd,
 			struct __old_kernel_stat __user *statbuf);
-asmlinkage long sys_newstat(char __user *filename,
+asmlinkage long sys_newstat(const char __user *filename,
 				struct stat __user *statbuf);
-asmlinkage long sys_newlstat(char __user *filename,
+asmlinkage long sys_newlstat(const char __user *filename,
 				struct stat __user *statbuf);
 asmlinkage long sys_newfstat(unsigned int fd, struct stat __user *statbuf);
 asmlinkage long sys_ustat(unsigned dev, struct ustat __user *ubuf);
 #if BITS_PER_LONG == 32
-asmlinkage long sys_stat64(char __user *filename,
+asmlinkage long sys_stat64(const char __user *filename,
 				struct stat64 __user *statbuf);
 asmlinkage long sys_fstat64(unsigned long fd, struct stat64 __user *statbuf);
-asmlinkage long sys_lstat64(char __user *filename,
+asmlinkage long sys_lstat64(const char __user *filename,
 				struct stat64 __user *statbuf);
 asmlinkage long sys_truncate64(const char __user *path, loff_t length);
 asmlinkage long sys_ftruncate64(unsigned int fd, loff_t length);
@@ -756,7 +756,7 @@ asmlinkage long sys_linkat(int olddfd, const char __user *oldname,
 			   int newdfd, const char __user *newname, int flags);
 asmlinkage long sys_renameat(int olddfd, const char __user * oldname,
 			     int newdfd, const char __user * newname);
-asmlinkage long sys_futimesat(int dfd, char __user *filename,
+asmlinkage long sys_futimesat(int dfd, const char __user *filename,
 			      struct timeval __user *utimes);
 asmlinkage long sys_faccessat(int dfd, const char __user *filename, int mode);
 asmlinkage long sys_fchmodat(int dfd, const char __user * filename,
@@ -765,13 +765,13 @@ asmlinkage long sys_fchownat(int dfd, const char __user *filename, uid_t user,
 			     gid_t group, int flag);
 asmlinkage long sys_openat(int dfd, const char __user *filename, int flags,
 			   int mode);
-asmlinkage long sys_newfstatat(int dfd, char __user *filename,
+asmlinkage long sys_newfstatat(int dfd, const char __user *filename,
 			       struct stat __user *statbuf, int flag);
-asmlinkage long sys_fstatat64(int dfd, char __user *filename,
+asmlinkage long sys_fstatat64(int dfd, const char __user *filename,
 			       struct stat64 __user *statbuf, int flag);
 asmlinkage long sys_readlinkat(int dfd, const char __user *path, char __user *buf,
 			       int bufsiz);
-asmlinkage long sys_utimensat(int dfd, char __user *filename,
+asmlinkage long sys_utimensat(int dfd, const char __user *filename,
 				struct timespec __user *utimes, int flags);
 asmlinkage long sys_unshare(unsigned long unshare_flags);
 
diff --git a/include/linux/time.h b/include/linux/time.h
index ea3559f..16346c0 100644
--- a/include/linux/time.h
+++ b/include/linux/time.h
@@ -135,7 +135,7 @@ extern void do_gettimeofday(struct timeval *tv);
 extern int do_settimeofday(struct timespec *tv);
 extern int do_sys_settimeofday(struct timespec *tv, struct timezone *tz);
 #define do_posix_clock_monotonic_gettime(ts) ktime_get_ts(ts)
-extern long do_utimes(int dfd, char __user *filename, struct timespec *times, int flags);
+extern long do_utimes(int dfd, const char __user *filename, struct timespec *times, int flags);
 struct itimerval;
 extern int do_setitimer(int which, struct itimerval *value,
 			struct itimerval *ovalue);
