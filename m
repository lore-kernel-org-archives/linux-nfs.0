Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f171.google.com ([209.85.221.171]:63658 "EHLO
	mail-qy0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101Ab0EQCpk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 16 May 2010 22:45:40 -0400
Received: by qyk1 with SMTP id 1so6350026qyk.5
        for <linux-nfs@vger.kernel.org>; Sun, 16 May 2010 19:45:39 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 00/24] Modernize NFSv2 XDR encoder/decoders
To: linux-nfs@vger.kernel.org
Date: Sun, 16 May 2010 22:45:36 -0400
Message-ID: <20100517023905.20258.86631.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This series backports patches I did 3 years ago that update the NFS
client's NFSv2 XDR encoders and decoders to use xdr_stream style
marshalling, similar to NFSv4.  The immediate advantage is better
bounds checking during marshalling and unmarshalling.

I've already done the kernel's MNT client, lockd's NSM client, and
the kernel's rpcbind client.  Eventually, we should convert NFSv3 and
NLM to use this style of marshalling XDR so that we can streamline
call_encode() and call_decode().

---

Chuck Lever (24):
      NFS: Replace old NFSv2 decoder functions with xdr_stream-based ones
      NFS: Decode NFSv2 statfs reply using an xdr_stream
      NFS: Decode NFSv2 readdir reply using an xdr_stream
      NFS: Decode NFSv2 write reply using an xdr_stream
      NFS: Decode NFSv2 read reply using an xdr_stream
      NFS: Decode NFSv2 readlink reply using an xdr_stream
      NFS: Decode NFSv2 dirop reply using an xdr_stream
      NFS: Decode NFSv2 attrstat reply using an xdr_stream
      NFS: Decode NFSv2 stat reply using an xdr_stream
      NFS: Use the "nfs_stat" enum for nfs_stat_to_errno()
      NFS: Replace old NFSv2 encoder functions with xdr_stream-based ones
      NFS: Encode NFSv2 readdir argument using an xdr_stream
      NFS: Encode NFSv2 symlink argument using an xdr_stream
      NFS: Encode NFSv2 link argument using an xdr_stream
      NFS: Encode NFSv2 rename argument using an xdr_stream
      NFS: Encode NFSv2 create argument using an xdr_stream
      NFS: Encode NFSv2 write argument using an xdr_stream
      NFS: Encode NFSv2 read argument using an xdr_stream
      NFS: Encode NFSv2 readlink argument using an xdr_stream
      NFS: Encode dirop argument using an xdr_stream
      NFS: Encode v2 setattr argument using an xdr_stream
      NFS: Encode NFSv2 fhandle argument using an xdr_stream
      NFS: Introduce XDR helpers for basic NFSv2 data types
      SUNRPC: Refactor logic to NUL-terminate strings in pages


 fs/nfs/internal.h          |    2 
 fs/nfs/nfs2xdr.c           | 1169 +++++++++++++++++++++++++++++---------------
 fs/nfs/nfs3xdr.c           |    6 
 fs/nfs/nfs4xdr.c           |    5 
 include/linux/sunrpc/xdr.h |    1 
 net/sunrpc/xdr.c           |   17 +
 6 files changed, 779 insertions(+), 421 deletions(-)

-- 
Chuck Lever
