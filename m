Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34415 "EHLO
	mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752784AbcE2RPA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2016 13:15:00 -0400
Received: by mail-pf0-f194.google.com with SMTP id c84so12122391pfc.1
        for <linux-nfs@vger.kernel.org>; Sun, 29 May 2016 10:15:00 -0700 (PDT)
From: Anne Marie Merritt <anne.marie.merritt@gmail.com>
To: trondmy@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Anne Marie Merritt <annemarie.merritt@primarydata.com>
Subject: [PATCH 0/6] nfs:  add support for additional attributes and ioctl to access
Date: Sun, 29 May 2016 10:14:46 -0700
Message-Id: <1464542092-19605-1-git-send-email-anne.marie.merritt@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Summary:

Add support for NFS attributes:
        timecreate
        hidden
        system
        archive
        timebackup

Add IOCTL to access these attributes. IOCTL client sample source is included in the ioctl patch for test purposes.  Note: These attributes can only be accessible if the remote nfsd supports them and underlying file system populates them.

This will permit the surfacing of these attributes via nfs for underlying filesystems that support them. SMB/Samba makes use of these attributes.


Signed-off-by: Anne Marie Merritt <annemarie.merritt@primarydata.com>

Anne Marie Merritt (6):
  nfs:  Add timecreate to nfs inode, along with corresponding bitfields,
    request, and decode xdr routines.
  nfs:  Add 'hidden' field to nfs inode, along with corresponding
    bitfields, request, and decode xdr routines.
  nfs:  Add 'system' field to nfs inode, along with corresponding
    bitfields, request, and decode xdr routines.
  nfs:  Add 'archive' field to nfs inode, along with corresponding
    bitfields, request, and decode xdr routines.
  nfs:  Add timebackup to nfs inode, along with corresponding bitfields,
    request, and decode xdr routines.
  nfs:  Add ioctl to retrieve timecreate, timebackup, 'hidden',
    'archive', and 'system' fields from inode.

 fs/nfs/inode.c            |  70 +++++++++++++++++++++++++
 fs/nfs/nfs4file.c         |  31 +++++++++++
 fs/nfs/nfs4proc.c         |  15 ++++++
 fs/nfs/nfs4xdr.c          | 130 ++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/nfs_fs.h    |   9 ++++
 include/linux/nfs_fs_sb.h |   5 ++
 include/linux/nfs_xdr.h   |  18 +++++++
 include/uapi/linux/nfs.h  |  13 +++++
 8 files changed, 291 insertions(+)

-- 
2.3.6

