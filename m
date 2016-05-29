Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34433 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282AbcE2RPF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:05 -0400
Received: by mail-pf0-f195.google.com with SMTP id c84so12122513pfc.1
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:05 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 6/6] nfs:  Add ioctl to retrieve timecreate, timebackup, 'hidden', 'archive', and 'system' fields from inode.
Date: Sun, 29 May 2016 10:14:52 -0700
Message-Id: <1464542092-19605-7-git-send-email-anne.marie.merritt@gmail.com>
In-Reply-To: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
References: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Summary:

Add IOCTL to retrieve attributes:
	timecreate
	timebackup
	hidden
	archive
	system

This will permit access to these attributes from user-level for software that requires them.  

Test code:

-=-=-

# cat ~/scripts/ioctl_attribs.c 
/*
 *  Author: Anne Marie Merritt (annemarie.merritt@primarydata.com)
 *  Test the ioctl to fetch a file's hidden, system,archive,
 *  timecreate, and timebackup attributes.
 *
 *  compile:  
 *    #> gcc -o attribstest ioctl_attribs.c
 *
 *  mount remote nfs share:
 *    #> mount -o vers=4.2 172.16.38.10:/ladybug /mnt/ladybug
 *  
 *  invoke:
 *    #> ./attribstest /mnt/ladybug/aphid.txt
 */

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <linux/types.h>
#include <memory.h>
#include <errno.h>
#include <stdbool.h>


/* from nfs header file */
#define NFS_IOC_FILE_DATES_FLAGS _IOR('N', 10, struct nfs_ioctl_file_dates_flags_args *)

struct nfs_ioctl_file_dates_flags_args {
        bool hidden;
        bool system;
        bool archive;
        __u64 timebackup_seconds;
        __u32 timebackup_nseconds;
        __u64 timecreate_seconds;
        __u32 timecreate_nseconds;
};

void ioctl_get_attribs(int file_desc, struct nfs_ioctl_file_dates_flags_args * args)
{
    int ret_val;
    struct nfs_ioctl_file_dates_flags_args tempargs;

    memset(&tempargs, 0, sizeof(struct nfs_ioctl_file_dates_flags_args));
  
    ret_val = ioctl(file_desc, NFS_IOC_FILE_DATES_FLAGS, &tempargs);

    if (ret_val < 0) {
      int errsv = errno;
      printf ("ioctl_get_attribs failed:returned [%d]\n", ret_val);
      printf("ERROR: [%d][%s]\n", errsv, strerror(errsv));
    } else {
        printf ("ioctl_get_attribs: hidden:[%s] system [%s] archive [%s]\n",
		(tempargs.hidden == 0 ? "false" : "true"), 
		(tempargs.system == 0 ? "false" : "true"), 
		(tempargs.archive == 0 ? "false" : "true"));
	printf ("timebackup-seconds:[%lld] timebackup-nseconds:[%d]\n", 
		tempargs.timebackup_seconds,
		tempargs.timebackup_nseconds);
	printf ("timecreate-seconds:[%lld] timecreate-nseconds:[%d]\n", 
		tempargs.timecreate_seconds,
		tempargs.timecreate_nseconds);

	*args = tempargs;
    }
}

/* Main - Invoke the ioctl function */
int main ( int argc, char **argv ) {

    char * filename;
    int file_desc;
    struct nfs_ioctl_file_dates_flags_args attribs;

    if (argc != 2)
    {
      printf("This test takes exactly one argument.\n");
    }

    filename = argv[1];

    file_desc = open(filename, O_RDWR);
    if (file_desc < 0) {
        printf ("Can't open file: %s\n", 
        filename);
        exit(-1);
    }

    ioctl_get_attribs(file_desc, &attribs);

    close(file_desc); 
    exit(0);
}


-=-=-


Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>

---
 fs/nfs/nfs4file.c        | 31 +++++++++++++++++++++++++++++++
 include/uapi/linux/nfs.h | 13 +++++++++++++
 2 files changed, 44 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 8ab34a7..076ca99 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -159,6 +159,35 @@ nfs4_file_fsync(struct file *file, loff_t start, loff_t end, int datasync)
 	return ret;
 }
 
+static long nfs4_ioctl_file_dates_flags(struct file *dst_file, void __user *argp)
+{
+	int ret = 0;
+	struct nfs_inode *nfsi;
+	struct nfs_ioctl_file_dates_flags_args args;
+	struct inode *dst_inode = file_inode(dst_file);
+	struct nfs_server *server = NFS_SERVER(dst_inode);
+
+	ret = nfs_revalidate_inode(server, dst_inode);
+	if (ret != 0)
+		return ret; 
+
+	nfsi = NFS_I(dst_inode);
+	args.hidden = nfsi->hidden;
+	args.system = nfsi->system;
+	args.archive = nfsi->archive;
+
+	args.timebackup_seconds = nfsi->timebackup.tv_sec;
+	args.timebackup_nseconds = nfsi->timebackup.tv_nsec;
+
+	args.timecreate_seconds = nfsi->timecreate.tv_sec;
+	args.timecreate_nseconds = nfsi->timecreate.tv_nsec;
+
+	if (copy_to_user(argp, &args, sizeof(args)))
+		return -EFAULT;
+
+	return 0;
+}
+
 #ifdef CONFIG_NFS_V4_2
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 {
@@ -306,6 +335,8 @@ long nfs4_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	void __user *argp = (void __user *)arg;
 
 	switch (cmd) {
+	case NFS_IOC_FILE_DATES_FLAGS:
+		return nfs4_ioctl_file_dates_flags(file, argp);
 #ifdef CONFIG_NFS_V4_2
 	case NFS_IOC_CLONE:
 		return nfs42_ioctl_clone(file, arg, 0, 0, 0);
diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
index c6b86cc..e14168a 100644
--- a/include/uapi/linux/nfs.h
+++ b/include/uapi/linux/nfs.h
@@ -7,6 +7,8 @@
 #ifndef _UAPI_LINUX_NFS_H
 #define _UAPI_LINUX_NFS_H
 
+#include <linux/types.h>
+
 #define NFS_PROGRAM	100003
 #define NFS_PORT	2049
 #define NFS_MAXDATA	8192
@@ -35,6 +37,7 @@
 /* Let's follow btrfs lead on CLONE to avoid messing userspace */
 #define NFS_IOC_CLONE		_IOW(0x94, 9, int)
 #define NFS_IOC_CLONE_RANGE	_IOW(0x94, 13, int)
+#define NFS_IOC_FILE_DATES_FLAGS	_IOR('N', 10, struct nfs_ioctl_file_dates_flags_args *) 
 
 struct nfs_ioctl_clone_range_args {
 	__s64 src_fd;
@@ -42,6 +45,16 @@ struct nfs_ioctl_clone_range_args {
 	__u64 dst_off;
 };
 
+struct nfs_ioctl_file_dates_flags_args {
+	bool hidden;
+	bool system;
+	bool archive;
+	__u64 timebackup_seconds;
+	__u32 timebackup_nseconds;
+	__u64 timecreate_seconds;
+	__u32 timecreate_nseconds;
+};
+
 /*
  * NFS stats. The good thing with these values is that NFSv3 errors are
  * a superset of NFSv2 errors (with the exception of NFSERR_WFLUSH which
-- 
2.3.6

