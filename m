Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60553 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756545Ab0GHPn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jul 2010 11:43:56 -0400
Received: by iwn7 with SMTP id 7so1001207iwn.19
        for <linux-nfs@vger.kernel.org>; Thu, 08 Jul 2010 08:43:54 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFSD: Return full WCC data for NFSv3 metadata operations
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Jul 2010 11:43:46 -0400
Message-ID: <20100708154037.2820.51702.stgit@ellison.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFSv3 WCC data, or "weak cache consistency" data, is an attempt to
reduce the number of on-the-wire transactions needed by NFS clients
to keep their caches up to date.  WCC data consists of two parts:

  o  pre-op data, which is a subset of file metadata as it was before
     a procedure starts, and

  o  post-op data, which is a full set of NFSv3 file attribute data as
     it is after a procedure finishes.

For an NFSv3 procedure that returns wcc_data, an NFSv3 server is free
to return either, both, or neither of these.  Define "full WCC data"
as a reply that contains both pre-op and post-op data.

To make this data useful, a server must ensure that file metadata is
captured atomically around the requested operation.  If the pre-op
data in a reply matches the file metadata that the client already has
cached, the client can assume that no other operation on that file
occurred while the server was fulfilling the current request, and that
therefore the post-op metadata is the latest version, and can be
cached.

Conversely, NFSv3 clients invalidate their metadata caches when they
receive replies to metadata altering operations that do not contain
full WCC data.  When a server presents a reply that does not have both
pre-op and post-op WCC data, clients must employ extra LOOKUP and
GETATTR requests to ensure their metadata caches are up to date,
causing performance to suffer needlessly.  For example, untarring a
large tar file can take almost an order of magnitude longer in this
case, depending on the client implementation.

In the Linux NFS server implementation, to ensure that WCC data
reflects only changes made during the current file system operation,
the file's inode mutex is held in order to serialize metadata altering
operations on that inode.  Our server saves pre-op data for a file
handle just after the target inode's mutex is taken, and saves post-op
data just before the inode's mutex is dropped (see fh_lock() and
fh_unlock()).

In order to return full WCC data to clients, our server must have both
the saved pre-op and the saved post-op attribute data for a file
handle filled in before it starts XDR encoding the reply.
Unfortunately, for the NFSv3 MKDIR, MKNOD, REMOVE, RMDIR procedures,
our server does not unlock the parent directory inode until well after
the reply has been XDR encoded.

In these cases, encode_wcc_data() does have saved pre-op WCC data
available, since the fh is locked, but does not have saved post-op WCC
data for the parent directory, since it hasn't yet been unlocked.  In
this situation, encode_wcc_data() simply grabs the parent's current
metadata, uses that as the post-op WCC data, and returns no pre-op
WCC data to the client.

By instead unlocking the parent directory file handle immediately
after the internal operations for each of these NFS procedures is
complete, saved post-op WCC data for the file handle is filled in
before XDR encoding starts, so full WCC data for that procedure can
be returned to clients.

Note that the NFSv4 CREATE and REMOVE procedures already invoke
fh_unlock() explicitly on the parent directory in order to fill in the
NFSv4 post change attribute.

Note also that NFSv3 CREATE, RENAME, SETATTR, and SYMLINK already
perform explicit file handle unlocking.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Bruce-

This patch is mechanically the same as the previous one, but the patch
description has a more accurate and clearly stated rationale for the
change.

Please use this one instead of the previous one.


 fs/nfsd/nfs3proc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 3d68f45..9ae9331 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -271,7 +271,7 @@ nfsd3_proc_mkdir(struct svc_rqst *rqstp, struct nfsd3_createargs *argp,
 	fh_init(&resp->fh, NFS3_FHSIZE);
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, S_IFDIR, 0, &resp->fh);
-
+	fh_unlock(&resp->dirfh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -327,7 +327,7 @@ nfsd3_proc_mknod(struct svc_rqst *rqstp, struct nfsd3_mknodargs *argp,
 	type = nfs3_ftypes[argp->ftype];
 	nfserr = nfsd_create(rqstp, &resp->dirfh, argp->name, argp->len,
 				    &argp->attrs, type, rdev, &resp->fh);
-
+	fh_unlock(&resp->dirfh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -348,6 +348,7 @@ nfsd3_proc_remove(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
 	/* Unlink. -S_IFDIR means file must not be a directory */
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, -S_IFDIR, argp->name, argp->len);
+	fh_unlock(&resp->fh);
 	RETURN_STATUS(nfserr);
 }
 
@@ -367,6 +368,7 @@ nfsd3_proc_rmdir(struct svc_rqst *rqstp, struct nfsd3_diropargs *argp,
 
 	fh_copy(&resp->fh, &argp->fh);
 	nfserr = nfsd_unlink(rqstp, &resp->fh, S_IFDIR, argp->name, argp->len);
+	fh_unlock(&resp->fh);
 	RETURN_STATUS(nfserr);
 }
 

