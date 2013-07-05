Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:3807 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751019Ab3GEVte (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jul 2013 17:49:34 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r65LnWax022575
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:33 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r65LnW5j029830
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:32 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r65LnW6x012294
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jul 2013 17:49:32 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r65LnV0u012293
	for linux-nfs@vger.kernel.org; Fri, 5 Jul 2013 17:49:31 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFS: Improve readdir performance
Date: Fri,  5 Jul 2013 17:49:29 -0400
Message-Id: <1373060971-12260-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently when we're reading a directory that is undergoing concurrent
modifications, we start re-reading from the beginning of the directory as soon
as we detect that a change has occurred.  On a LAN connection or in a directory
with a small number of entries, the impact isn't too noticeable... but reading
a directory with a large number of entries over a WAN connection gets pretty
bad.

For NFS v3, what happens is that after each on-the-wire READDIR we call
nfs_refresh_inode() and from there we get to nfs_update_inode(), where we wind
up setting NFS_INO_INVALID_DATA in the directory's cache_validity flags.  Then
on a subsequent call to nfs_readdir() we call nfs_revalidate_mapping(), and
seeing that NFS_INO_INVALIDATE_DATA is set we call nfs_invalidate_mapping(),
flushing all our cached data for the directory.

So for each nfs_readdir() call, we wind up redoing all of the on-the-wire
readdir operations just to get back where we were, and then we're able to get
just one more operation's worth of entries on top of that.  If the directory on
the NFS server is constantly being modified then this winds up being a lot of
extra READDIR ops. 

These patches change that behavior by only revalidating if we're at the
beginning of the directory or if the cached attributes for the directory have
expired.

For example, on a test environment of two VMs, I have a directory of 100,000
entries that takes 981 READDIR operations to read if no modifications being made
to the directory at the same time.  If I add a 35ms delay between the client and
the server and start a script on the server that repeatedly creates and removes
a file in the directory being listed I get the following results:

[root@localhost ~]# mount -t nfs -o nfsvers=3,nordirplus server:/export /mnt
[root@localhost ~]# time /bin/ls /mnt/bigdir >/dev/null

real    29m52.594s
user    0m0.376s
sys     0m2.191s
[root@localhost ~]# mountstats --rpc /mnt | grep -A3 READDIR
READDIR:
        49729 ops (99%)         0 retrans (0%)  0 major timeouts
        avg bytes sent per op: 144      avg bytes received per op: 4196
        backlog wait: 0.003620  RTT: 35.889501  total execute time: 35.925858 (milliseconds)
[root@localhost ~]#


With the patched kernel, that same test yields these results:

[root@localhost ~]# time /bin/ls /mnt/bigdir >/dev/null

real    0m35.952s
user    0m0.460s
sys     0m0.100s
[root@localhost ~]# mountstats --rpc /mnt | grep -A3 READDIR
READDIR:
        981 ops (98%)   0 retrans (0%)  0 major timeouts
        avg bytes sent per op: 144      avg bytes received per op: 4194
        backlog wait: 0.004077  RTT: 35.887870  total execute time: 35.926606 (milliseconds)
[root@localhost ~]#

-Scott

Scott Mayhew (2):
  NFS: Make nfs_attribute_cache_expired() non-static
  NFS: Make nfs_readdir revalidate less often

 fs/nfs/dir.c           | 5 +++--
 fs/nfs/inode.c         | 2 +-
 include/linux/nfs_fs.h | 1 +
 3 files changed, 5 insertions(+), 3 deletions(-)

-- 
1.7.11.7

