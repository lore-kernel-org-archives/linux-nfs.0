From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 0/8] Mount XDR rewrite, and parser bugfix, take 2
Date: Sat, 13 Jun 2009 19:25:37 -0400
Message-ID: <20090613232149.3225.92143.stgit@isabey.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:20885 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbZFMX0f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 13 Jun 2009 19:26:35 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

Redriven based on your review comments.  The patches start with the
enc_dirpath patch, for reference.

The parser fix patch is larger now, but the resulting parser is
simpler.  There's no need to actually count errors; simply raise a
flag whenever an invalid option is encountered.  Invalid values
cause parsing to stop immediately.

---

Chuck Lever (8):
      NFS: Invalid mount option values should always fail, even with "sloppy"
      NFS: Remove unused XDR decoder functions
      NFS: Update MNT and MNT3 reply decoding functions
      NFS: add XDR decoder for mountd version 3 auth-flavor lists
      NFS: add new file handle decoders to in-kernel mountd client
      NFS: Add separate mountd status code decoders for each mountd version
      NFS: remove unused function in fs/nfs/mount_clnt.c
      NFS: Use xdr_stream-based XDR encoder for MNT's dirpath argument


 fs/nfs/internal.h   |    8 +
 fs/nfs/mount_clnt.c |  305 +++++++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfsroot.c    |    2 
 fs/nfs/super.c      |  159 +++++++++++----------------
 4 files changed, 340 insertions(+), 134 deletions(-)

-- 
Chuck Lever <chuck.lever@oracle.com>
