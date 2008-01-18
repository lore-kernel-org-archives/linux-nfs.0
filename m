From: Peter Staubach <staubach@redhat.com>
Subject: [PATCH 0/3] enhanced ESTALE error handling
Date: Fri, 18 Jan 2008 10:35:50 -0500
Message-ID: <4790C756.2040704@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060506040603070603090405"
Cc: linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762580AbYARPgr@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060506040603070603090405
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi.

Here is a patch set which modifies the system to enhance the
ESTALE error handling for system calls which take pathnames
as arguments.

The error, ESTALE, was originally introduced to handle the
situation where a file handle, which NFS uses to uniquely
identify a file on the server, no longer refers to a valid file
on the server.  This can happen when the file is removed on the
server, either by an application on the server, some other
client accessing the server, or sometimes even by another
mounted file system from the same client.  It can also happen
when the file resides upon a file system which is no longer
exported.

The error, ESTALE, is usually seen when cached directory
information is used to convert a pathname to a dentry/inode pair.
The information is discovered to be out of date or stale when a
subsequent operation is sent to the NFS server.  This can easily
happen in system calls such as stat(2) when the pathname is
converted a dentry/inode pair using cached information, but then
a subsequent GETATTR call to the server discovers that the file
handle is no longer valid.

System calls which take pathnames as arguments should never see
ESTALE errors from situations like this.  These system calls
should either fail with an ENOENT error if the pathname can not
be successfully be translated to a dentry/inode pair or succeed
or fail based on their own semantics.

ESTALE errors which occur during the lookup process can be
handled by dropping the dentry which refers to the non-existent
file from the dcache and then restarting the lookup process.
Care can be taken to ensure that forward progress is always
being made in order to avoiding infinite loops.

ESTALE errors which occur during operations subsequent to the
lookup process can be handled by unwinding appropriately and
then performing the lookup process again.  Eventually, either
the lookup process will succeed or fail correctly or the
subsequent operation will succeed or fail on its own merits.

This support is desired in order to tighten up recovery from
discovering stale resources due to the loose cache consistency
semantics that file systems such as NFS employ.  In particular,
there are several large Red Hat customers, converting from
Solaris to Linux, who desire this support in order that their
applications environments continue to work.

Please note that system calls which do not take pathnames as
arguments or perhaps use file descriptors to identify the
file to be manipulated may still fail with ESTALE errors.
There is no recovery possible with these systems calls like
there is with system calls which take pathnames as arguments.

This support was tested using the attached programs and
running multiple copies on mounted file systems which do not
share superblocks.  When two or more copies of this program
are running, many ESTALE errors can be seen over the network.

Comments?

    Thanx...

       ps

--------------060506040603070603090405
Content-Type: text/x-csrc;
 name="syscallgen.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="syscallgen.c"

#
#define _XOPEN_SOURCE 500
#define _LARGEFILE64_SOURCE
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/statfs.h>
#include <sys/inotify.h>
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>

void mkdir_test(void);
void link_test(void);
void open_test(void);
void access_test(void);
void chmod_test(void);
void chown_test(void);
void readlink_test(void);
void utimes_test(void);
void chdir_test(void);
void chroot_test(void);
void rename_test(void);
void exec_test(void);
void mknod_test(void);
void statfs_test(void);
void truncate_test(void);
void xattr_test(void);
void inotify_test(void);

struct tests {
	void (*test)(void);
};

struct tests tests[] = {
	mkdir_test,
	link_test,
	open_test,
	access_test,
	chmod_test,
	chown_test,
	readlink_test,
	utimes_test,
	chdir_test,
	chroot_test,
	rename_test,
	exec_test,
	mknod_test,
	statfs_test,
	truncate_test,
	xattr_test,
	inotify_test
};

pid_t test_pids[sizeof(tests) / sizeof(tests[0])];

pid_t parent_pid;

void kill_tests(int);

int
main(int argc, char *argv[])
{
	int i;

	parent_pid = getpid();

	sigset(SIGINT, kill_tests);

	sighold(SIGINT);

	for (i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
		test_pids[i] = fork();
		if (test_pids[i] == 0) {
			for (;;)
				(*tests[i].test)();
			/* NOTREACHED */
		}
	}

	sigrelse(SIGINT);

	pause();
}

void
kill_tests(int sig)
{
	int i;

	for (i = 0; i < sizeof(tests) / sizeof(tests[0]); i++) {
		if (test_pids[i] != -1) {
			if (kill(test_pids[i], SIGTERM) < 0)
				perror("kill");
		}
	}

	exit(0);
}

void
check_error(int error, char *operation)
{

	if (error < 0 && errno == ESTALE) {
		perror(operation);
		kill(parent_pid, SIGINT);
		pause();
	}
}

void
check_error_child(int error, char *operation)
{

	if (error < 0 && errno == ESTALE) {
		perror(operation);
		kill(parent_pid, SIGINT);
		exit(1);
	}
}

void
do_stats(char *file)
{
	int error;
	struct stat stbuf;
	struct stat64 stbuf64;

	error = stat(file, &stbuf);
	check_error(error, "stat");

	error = stat64(file, &stbuf64);
	check_error(error, "stat64");

	error = lstat(file, &stbuf);
	check_error(error, "lstat");

	error = lstat64(file, &stbuf64);
	check_error(error, "lstat64");
}

void
do_stats_child(char *file)
{
	int error;
	struct stat stbuf;
	struct stat64 stbuf64;

	error = stat(file, &stbuf);
	check_error_child(error, "stat");

	error = stat64(file, &stbuf64);
	check_error_child(error, "stat64");

	error = lstat(file, &stbuf);
	check_error_child(error, "lstat");

	error = lstat64(file, &stbuf64);
	check_error_child(error, "lstat64");
}

char *mkdir_dirs[] = {
	"mkdir/a",
	"mkdir/a/b",
	"mkdir/a/b/c",
	"mkdir/a/b/c/d",
	"mkdir/a/b/c/d/e",
	"mkdir/a/b/c/d/e/f",
	"mkdir/a/b/c/d/e/f/g",
	"mkdir/a/b/c/d/e/f/g/h",
	"mkdir/a/b/c/d/e/f/g/h/i",
	"mkdir/a/b/c/d/e/f/g/h/i/j",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y",
	"mkdir/a/b/c/d/e/f/g/h/i/j/k/l/m/n/o/p/q/r/s/t/u/v/w/x/y/z",
	NULL
};

void
mkdir_test()
{
	int i;
	int error;

	error = mkdir("mkdir", 0755);
	check_error(error, "mkdir");

	for (i = 0; mkdir_dirs[i] != NULL; i++) {
		error = mkdir(mkdir_dirs[i], 0755);
		check_error(error, "mkdir");
		do_stats(mkdir_dirs[i]);
	}

	while (--i >= 0) {
		do_stats(mkdir_dirs[i]);
		error = rmdir(mkdir_dirs[i]);
		check_error(error, "rmdir");
	}

	error = rmdir("mkdir");
	check_error(error, "rmdir");
}

char *link_file_a = "link/a";
char *link_file_b = "link/b";

void
link_test()
{
	int error;
	int fd;

	error = mkdir("link", 0755);
	check_error(error, "mkdir");

	fd = open(link_file_a, O_CREAT, 0644);
	check_error(fd, "open");

	(void) close(fd);

	do_stats(link_file_a);

	error = link(link_file_a, link_file_b);
	check_error(error, "link");
	do_stats(link_file_a);
	do_stats(link_file_b);

	error = unlink(link_file_a);
	check_error(error, "unlink");
	do_stats(link_file_a);
	do_stats(link_file_b);

	error = link(link_file_b, link_file_a);
	check_error(error, "link");
	do_stats(link_file_a);
	do_stats(link_file_b);

	error = unlink(link_file_b);
	check_error(error, "unlink");
	do_stats(link_file_a);
	do_stats(link_file_b);

	error = unlink(link_file_a);
	check_error(error, "unlink");
	do_stats(link_file_a);
	do_stats(link_file_b);

	error = rmdir("link");
	check_error(error, "rmdir");
}

char *open_file = "open/a";

void
open_test()
{
	int error;
	int fd;

	error = mkdir("open", 0755);
	check_error(error, "mkdir");

	fd = open(open_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(open_file);

	fd = open(open_file, O_RDWR);
	check_error(fd, "open: O_RDWR");

	(void) close(fd);

	do_stats(open_file);

	error = unlink(open_file);
	check_error(error, "unlink");

	error = rmdir("open");
	check_error(error, "rmdir");
}

char *access_file = "access/a";

void
access_test()
{
	int error;
	int fd;

	error = mkdir("access", 0755);
	check_error(error, "mkdir");

	fd = open(access_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(access_file);

	error = access(access_file, F_OK);
	check_error(error, "access");

	do_stats(access_file);

	error = unlink(access_file);
	check_error(error, "unlink");

	error = rmdir("access");
	check_error(error, "rmdir");
}

char *chmod_file = "chmod/a";

void
chmod_test()
{
	int error;
	int fd;

	error = mkdir("chmod", 0755);
	check_error(error, "mkdir");

	fd = open(chmod_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(chmod_file);

	error = chmod(chmod_file, 0600);
	check_error(error, "chmod");

	do_stats(chmod_file);

	error = unlink(chmod_file);
	check_error(error, "unlink");

	error = rmdir("chmod");
	check_error(error, "rmdir");
}

char *chown_file = "chown/a";

void
chown_test()
{
	int error;
	int fd;

	error = mkdir("chown", 0755);
	check_error(error, "mkdir");

	fd = open(chown_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(chown_file);

	error = chown(chown_file, 4597, 4597);
	check_error(error, "chown");

	do_stats(chown_file);

	error = lchown(chown_file, 4596, 4596);
	check_error(error, "lchown");

	do_stats(chown_file);

	error = unlink(chown_file);
	check_error(error, "unlink");

	error = rmdir("chown");
	check_error(error, "rmdir");
}

char *readlink_file = "readlink/a";

void
readlink_test()
{
	int error;
	char buf[BUFSIZ];

	error = mkdir("readlink", 0755);
	check_error(error, "mkdir");

	error = symlink("b", readlink_file);
	check_error(error, "symlink");

	do_stats(readlink_file);

	error = readlink(readlink_file, buf, sizeof(buf));
	check_error(error, "readlink");

	do_stats(readlink_file);

	error = unlink(readlink_file);
	check_error(error, "unlink");

	error = rmdir("readlink");
	check_error(error, "rmdir");
}

char *utimes_file = "utimes/a";

void
utimes_test()
{
	int error;
	int fd;

	error = mkdir("utimes", 0755);
	check_error(error, "mkdir");

	fd = open(utimes_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(utimes_file);

	error = utime(utimes_file, NULL);
	check_error(error, "utime");

	do_stats(utimes_file);

	error = utimes(utimes_file, NULL);
	check_error(error, "utimes");

	do_stats(utimes_file);

	error = unlink(utimes_file);
	check_error(error, "unlink");

	error = rmdir("utimes");
	check_error(error, "rmdir");
}

char *chdir_dir = "chdir/dir";

void
chdir_test()
{
	int error;
	int pid;
	int status;

	error = mkdir("chdir", 0755);
	check_error(error, "mkdir");

	pid = fork();
	if (pid == 0) {
		error = mkdir(chdir_dir, 0755);
		check_error_child(error, "mkdir");

		do_stats_child(chdir_dir);

		error = chdir(chdir_dir);
		check_error_child(error, "chdir");

		do_stats_child(chdir_dir);

		exit(0);
	}

	(void) wait(&status);

	do_stats(chdir_dir);

	error = rmdir(chdir_dir);
	check_error(error, "rmdir");

	error = rmdir("chdir");
	check_error(error, "rmdir");
}

char *chroot_dir = "chroot/dir";

void
chroot_test()
{
	int error;
	int pid;
	int status;

	error = mkdir("chroot", 0755);
	check_error(error, "mkdir");

	pid = fork();
	if (pid == 0) {
		error = mkdir(chroot_dir, 0755);
		check_error_child(error, "mkdir");

		do_stats_child(chroot_dir);

		error = chroot(chroot_dir);
		check_error_child(error, "chroot");

		do_stats_child(chroot_dir);

		exit(0);
	}

	(void) wait(&status);

	do_stats(chroot_dir);

	error = rmdir(chroot_dir);
	check_error(error, "rmdir");

	error = rmdir("chroot");
	check_error(error, "rmdir");
}

char *rename_file_a = "rename/a";
char *rename_file_b = "rename/b";

void
rename_test()
{
	int error;
	int fd;

	error = mkdir("rename", 0755);
	check_error(error, "mkdir");

	fd = open(rename_file_a, O_CREAT, 0644);
	check_error(fd, "open");

	(void) close(fd);

	do_stats(rename_file_a);

	error = rename(rename_file_a, rename_file_b);
	check_error(error, "rename");

	do_stats(rename_file_a);
	do_stats(rename_file_b);

	error = rename(rename_file_b, rename_file_a);
	check_error(error, "rename");

	do_stats(rename_file_a);
	do_stats(rename_file_b);

	error = unlink(rename_file_a);
	check_error(error, "unlink");

	error = rmdir("rename");
	check_error(error, "rmdir");
}

char *exec_file = "exec/a";
char *exec_source_file = "exec_test";

void
exec_test()
{
	int error;
	int pid;
	int status;

	error = mkdir("exec", 0755);
	check_error(error, "mkdir");

	error = link(exec_source_file, exec_file);
	check_error(error, "link");
	do_stats(exec_file);

	pid = fork();
	if (pid == 0) {
		error = execl(exec_file, exec_file, NULL);
		check_error_child(error, "execl");

		exit(1);
	}

	wait(&status);

	do_stats(exec_file);

	error = unlink(exec_file);
	check_error(error, "unlink");

	error = rmdir("exec");
	check_error(error, "rmdir");
}

char *mknod_file = "mknod/a";

void
mknod_test()
{
	int error;

	error = mkdir("mknod", 0755);
	check_error(error, "mkdir");

	error = mknod(mknod_file, S_IFCHR | 0644, 0);
	check_error(error, "mknod");

	do_stats(mknod_file);

	error = unlink(mknod_file);
	check_error(error, "unlink");

	error = rmdir("mknod");
	check_error(error, "rmdir");
}

void
statfs_test()
{
	int error;
	struct statfs stbuf;
	struct statfs64 stbuf64;

	error = mkdir("statfs", 0755);
	check_error(error, "mkdir");

	do_stats("statfs");

	error = statfs("statfs", &stbuf);
	check_error(error, "statfs");

	error = statfs64("statfs", &stbuf64);
	check_error(error, "statfs64");

	error = rmdir("statfs");
	check_error(error, "rmdir");
}

char *truncate_file = "truncate/a";

void
truncate_test()
{
	int error;
	int fd;

	error = mkdir("truncate", 0755);
	check_error(error, "mkdir");

	fd = open(truncate_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(truncate_file);

	error = truncate(truncate_file, 1024);
	check_error(error, "truncate");

	do_stats(truncate_file);

	error = unlink(truncate_file);
	check_error(error, "unlink");

	error = rmdir("truncate");
	check_error(error, "rmdir");
}

char *xattr_file = "xattr/a";

#define ACL_USER_OBJ	(0x01)
#define ACL_USER	(0x02)
#define ACL_GROUP_OBJ	(0x04)
#define ACL_MASK	(0x10)
#define ACL_OTHER	(0x20)

struct posix_acl_xattr_entry {
	unsigned short e_tag;
	unsigned short e_perm;
	unsigned int e_id;
};

#define POSIX_ACL_XATTR_VERSION	0x0002

struct posix_acl_xattr_header {
	unsigned int a_version;
	struct posix_acl_xattr_entry a_entries[5];
};

void
xattr_test()
{
	int error;
	int fd;
	char buf[1024];
	struct posix_acl_xattr_header ents;

	error = mkdir("xattr", 0755);
	check_error(error, "mkdir");

	fd = open(xattr_file, O_CREAT | O_RDWR, 0444);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(xattr_file);

	error = getxattr(xattr_file, "system.posix_acl_access", buf,
			sizeof (buf));
	check_error(error, "getxattr");
	error = lgetxattr(xattr_file, "system.posix_acl_access", buf,
			sizeof (buf));
	check_error(error, "lgetxattr");

	ents.a_version = POSIX_ACL_XATTR_VERSION;
	ents.a_entries[0].e_tag = ACL_USER_OBJ;
	ents.a_entries[0].e_perm = 06;
	ents.a_entries[0].e_id = -1;
	ents.a_entries[1].e_tag = ACL_USER;
	ents.a_entries[1].e_perm = 06;
	ents.a_entries[1].e_id = 10;
	ents.a_entries[2].e_tag = ACL_GROUP_OBJ;
	ents.a_entries[2].e_perm = 06;
	ents.a_entries[2].e_id = -1;
	ents.a_entries[3].e_tag = ACL_MASK;
	ents.a_entries[3].e_perm = 06;
	ents.a_entries[3].e_id = -1;
	ents.a_entries[4].e_tag = ACL_OTHER;
	ents.a_entries[4].e_perm = 06;
	ents.a_entries[4].e_id = -1;

	error = setxattr(xattr_file, "system.posix_acl_access",
			&ents, sizeof (ents), 0);
	check_error(error, "setxattr");

	do_stats(xattr_file);

	error = lsetxattr(xattr_file, "system.posix_acl_access",
			&ents, sizeof (ents), 0);
	check_error(error, "lsetxattr");

	do_stats(xattr_file);

	error = getxattr(xattr_file, "system.posix_acl_access", buf,
			sizeof (buf));
	check_error(error, "getxattr");
	error = lgetxattr(xattr_file, "system.posix_acl_access", buf,
			sizeof (buf));
	check_error(error, "lgetxattr");

	error = listxattr(xattr_file, buf, sizeof (buf));
	check_error(error, "listxattr");
	error = llistxattr(xattr_file, buf, sizeof (buf));
	check_error(error, "llistxattr");

	error = removexattr(xattr_file, "system.posix_acl_access");
	check_error(error, "removexattr");

	do_stats(xattr_file);

	error = setxattr(xattr_file, "system.posix_acl_access",
			&ents, sizeof (ents), 0);
	check_error(error, "setxattr");

	do_stats(xattr_file);

	error = lremovexattr(xattr_file, "system.posix_acl_access");
	check_error(error, "lremovexattr");

	do_stats(xattr_file);

	error = unlink(xattr_file);
	check_error(error, "unlink");

	error = rmdir("xattr");
	check_error(error, "rmdir");
}

char *inotify_file = "inotify/a";

void
inotify_test()
{
	int error;
	int fd;
	int wd;

	error = mkdir("inotify", 0755);
	check_error(error, "mkdir");

	fd = open(inotify_file, O_CREAT | O_RDWR, 0644);
	check_error(fd, "open: O_CREAT");

	(void) close(fd);

	do_stats(inotify_file);

	fd = inotify_init();
	check_error(error, "inotify_init");

	do_stats(inotify_file);

	wd = inotify_add_watch(fd, inotify_file, IN_ALL_EVENTS);
	check_error(wd, "inotify_add_watch");

	do_stats(inotify_file);

	error = inotify_rm_watch(fd, wd);
	check_error(error, "inotify_rm_watch");

	(void) close(fd);

	do_stats(inotify_file);

	error = unlink(inotify_file);
	check_error(error, "unlink");

	error = rmdir("inotify");
	check_error(error, "rmdir");
}

--------------060506040603070603090405
Content-Type: text/x-csrc;
 name="exec_test.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="exec_test.c"

#include <stdlib.h>

main()
{
	exit(0);
}

--------------060506040603070603090405--
