Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:61993 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932426AbaE2RZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 29 May 2014 13:25:54 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/1] nfs: Ensure NFS_MOUNT_TCP is correctly set for v4 mounts
Date: Thu, 29 May 2014 13:25:50 -0400
Message-Id: <1401384351-21993-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a 'mount -o remount...' is issued, the mount program reads the current
mount options from /etc/mtab so that it can pass them to the helper program.  On
newer distros where /etc/mtab is a symlink to /proc/mounts, this will result in
a call to nfs_show_mount_options(), which has the following snippet:

        seq_printf(m, ",proto=%s",
	                   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));

which in most cases will result in the mount program passing 'proto=tcp' to the
mount.nfs4 program, which mount.nfs4 then passes in the data field of the mount
syscall. 

nfs_remount() calls nfs_parse_mount_options(), where the NFS_MOUNT_TCP flag will
be set in the nfs_parsed_mount_data's flag field.  But nfs_remount() then calls
nfs_compare_remount_data(), where we will fail the very first check:

static int
nfs_compare_remount_data(struct nfs_server *nfss,
                         struct nfs_parsed_mount_data *data)
{
	        if (data->flags != nfss->flags ||
...
                return -EINVAL;
...

because NFS_MOUNT_TCP was never set in the nfs_server's flags field in the first
place.

As a result, the remount operation fails:
# mount -o remount,ro /mnt/t
mount.nfs4: an incorrect mount option was specified

The following patch corrects that issue by having nfs4_validate_mount_flags()
set the NFS_MOUNT_TCP flag when appropriate.


Scott Mayhew (1):
  nfs: Ensure NFS_MOUNT_TCP is correctly set for v4 mounts

 fs/nfs/super.c | 3 +++
 1 file changed, 3 insertions(+)

-- 
1.9.0

