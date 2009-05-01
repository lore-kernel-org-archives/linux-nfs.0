From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Series short description
Date: Fri, 01 May 2009 12:36:21 -0400
Message-ID: <20090501163507.25681.14463.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:25331 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbZEAQga (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 12:36:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

In-kernel MNT client changes proposed for 2.6.31.  Comments?

---

Chuck Lever (8):
      NFS: Remove unused XDR decoder functions
      NFS: Update MNT and MNT3 reply decoding functions
      NFS: add XDR decoder for mountd version 3 auth-flavor lists
      NFS: add new file handle decoders to in-kernel mountd client
      NFS: Add separate mountd status code decoders for each mountd version
      NFS: remove unused function in fs/nfs/mount_clnt.c
      NFS: Use xdr_stream-based XDR encoder for MNT's dirpath argument
      NFS: Clean up MNT program definitions


 fs/nfs/internal.h    |    8 +
 fs/nfs/mount_clnt.c  |  354 ++++++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfsroot.c     |    5 +
 fs/nfs/super.c       |    2 
 include/linux/nfs.h  |    5 -
 include/linux/nfs2.h |    7 -
 include/linux/nfs3.h |    5 -
 7 files changed, 331 insertions(+), 55 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
