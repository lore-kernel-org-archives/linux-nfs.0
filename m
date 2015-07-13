Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:34203 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970AbbGMFvU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 01:51:20 -0400
Received: by pdbep18 with SMTP id ep18so219253605pdb.1
        for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2015 22:51:19 -0700 (PDT)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH 0/7] nfs: minor cleanups and NFSv42 CLONE support
Date: Mon, 13 Jul 2015 13:50:48 +0800
Message-Id: <1436766655-10696-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi all,

The first two patches are minor cleanups. The rest 5 added NFSv42 CLONE support via
a new ioctl interface. There's a minor conflict between the cleanup and new functionality.
So I ended up sending them together.

Tested with following program. cp command in coreutils can be patched similarly,
which currently only supports btrfs CLONE ioctl.

Cheers,
Tao

[lear@tests]$cat copy_reflink.c
#include <sys/ioctl.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

void usage(const char *cmd)
{
	printf("%s: <src_file_name> <dst_file_name>\n", cmd);
}

int main(char argc, char** argv)
{
	int srcfd, dstfd;

	if (argc < 3) {
		usage(argv[0]);
		return -1;
	}

	srcfd = open(argv[1], O_RDONLY);
	if (srcfd < 0) {
		perror("open failed");
		return -1;
	}
	dstfd = open(argv[2], O_WRONLY|O_CREAT, 0644);
	if (dstfd < 0) {
		perror("open failed");
		return -1;
	}

#ifndef NFS_IOC_CLONE
#define NFS_IOC_CLONE _IOW('n', 1, int)
#endif
	if (ioctl(dstfd, NFS_IOC_CLONE, srcfd) < 0)
		perror("ioctl CLONE failed\n");

	close(srcfd);
	close(dstfd);
	return 0;
}

Peng Tao (7):
  nfs42: decode_layoutstats does not need res parameter
  nfs42: remove unused declaration
  nfs42: add CLONE xdr functions
  nfs42: add CLONE proc functions
  nfs42: add NFS_IOC_CLONE ioctl
  nfs: get clone_blksize when probing fsinfo
  nfs42: respect clone_blksize

 fs/nfs/client.c           |   1 +
 fs/nfs/nfs42.h            |   3 +-
 fs/nfs/nfs42proc.c        |  71 +++++++++++++++++++++++++++++
 fs/nfs/nfs42xdr.c         | 102 +++++++++++++++++++++++++++++++++++++++--
 fs/nfs/nfs4file.c         | 113 ++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4proc.c         |   4 +-
 fs/nfs/nfs4xdr.c          |  26 +++++++++++
 include/linux/nfs4.h      |   3 ++
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  20 ++++++++
 include/uapi/linux/nfs.h  |   4 ++
 11 files changed, 342 insertions(+), 7 deletions(-)

-- 
1.8.3.1

