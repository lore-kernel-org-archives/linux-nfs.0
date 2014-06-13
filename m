Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:46528 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753097AbaFMSSL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 Jun 2014 14:18:11 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC] nfs:  ensure cached data is correct before using delegation
Date: Fri, 13 Jun 2014 14:18:07 -0400
Message-Id: <1402683488-23725-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

We're still having some problems with data corruption when multiple clients are
appending to a file and those clients are being granted write delegations on
open.

To reproduce:

Client A:
vi /mnt/`hostname -s`
while :; do echo "XXXXXXXXXXXXXXX" >>/mnt/file; sleep $(( $RANDOM % 5 )); done

Client B:
vi /mnt/`hostname -s`
while :; do echo "YYYYYYYYYYYYYYY" >>/mnt/file; sleep $(( $RANDOM % 5 )); done

The resulting data looks something like this:

XXXXXXXXXXXXXXX
XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@^@XXXXXXXXXXXXXXX
YYYYYYYYYYYYYYY
YYYYYYYYYYYYYYY

What's happening is that in nfs_update_inode() we're recognizing that the file
size has changed and we're setting NFS_INO_INVALID_DATA accordingly, but then we
ignore the cache_validity flags in nfs_write_pageuptodate() because we have a
delegation.  As a result, in nfs_updatepage() we're extending the write to cover
the full page even though we've not read in the data to begin with.

The attached patch fixes the issue by calling nfs_revalidate_mapping() whenever
we attach a delegation to an nfs_inode.  However, I'm not entirely sure that
calling nfs_revalidate_inode() in those places won't cause some other issues.  I
tested the change with all of the stock workloads in nfsometer except for
bonnie++.

An alternative would be to just revert c7559663 (NFS: Allow nfs_updatepage to
extend a write under additional circumstances), but then we'd lose the
performance benefits of that patch... which I'd like to avoid if possible.

-Scott

Scott Mayhew (1):
  nfs:  ensure cached data is correct before using delegation

 fs/nfs/delegation.c | 1 +
 fs/nfs/inode.c      | 1 +
 fs/nfs/nfs4proc.c   | 5 +++--
 3 files changed, 5 insertions(+), 2 deletions(-)

-- 
1.9.3

