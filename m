Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:21213 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753100AbdCBQIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:08:35 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <linux-fsdevel@vger.kernel.org>
CC: <hch@lst.de>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/3] VFS changes for NFSv4.2 "inter" server-to-server COPY op 
Date: Thu, 2 Mar 2017 11:02:08 -0500
Message-ID: <20170302160211.30451-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One patch adds a check for validity of arguments.

In another patch is crucial to the existance of NFSv4.2 inter SSC COPY.
In order to implement the "inter" SSC COPY that involves two files from
different superblock, it requires removal of the cross-devices check in VFS.
Given that in the future the "cp" command will be written to use
copy_file_range(), it would be important for "inter" SSC COPY to use the
same interface.

This patch has first been met with an objection from Christoph saying that
"no other VFS operation is supported between mountpoints" and another objection
that since been addressed that "no xfstest coverage". We argue that no other
VFS operation needed such support and now there exists one.

An alternative approach might be to define a new file system function
(eg., bool allow_cross_device_op() that a filesystem can define and NFS will
define it and return true. And based on the existence of that function and
its result the check could be relaxed)?

If that check were to be removed, it would be beneficial to check the
the superblocks for the clone operation so that it's not called unnecessarily.

Anna Schumaker (1):
  fs: Don't copy beyond the end of the file

Andy Adamson (1):
  VFS permit cross device vfs_copy_file_range

Olga Kornievskaia (1):
  VFS don't try clone if superblocks are different

 fs/read_write.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

-- 
1.8.3.1

