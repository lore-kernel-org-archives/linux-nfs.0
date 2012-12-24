Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:37122 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753377Ab2LXXan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Dec 2012 18:30:43 -0500
Received: by mail-ie0-f175.google.com with SMTP id qd14so9367422ieb.34
        for <linux-nfs@vger.kernel.org>; Mon, 24 Dec 2012 15:30:43 -0800 (PST)
MIME-Version: 1.0
Date: Tue, 25 Dec 2012 00:30:42 +0100
Message-ID: <CALS3df0FR0XD9wnzVhCMDXbS-Q2OejH2TfgYf6uL8gF4cKDRng@mail.gmail.com>
Subject: [PATCH] nfsd: Don't overuse NFS?ERR_PERM error code
From: Pawel Dziepak <pdziepak@quarnos.org>
To: bfields@fieldses.org
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Pawel Dziepak <pdziepak@quarnos.org>

Unlike EPERM, NFS?ERR_PERM error code applies only when the operation could
not be completed because the caller is either not the owner or not a
privileged user. Actually, only OPEN, CREATE and SETATTR are supposed to
ever return such error code when a problem occurs when changing or setting
access permissions.

Generally, this patch replaces NFS?ERR_PERM with NFS?ERR_ACCESS which is a more
appropriate error code indicating that the caller is not allowed to perform the
requested operation.

In case of incorrect {file,directory} names either NFS?ERR_INVAL or
NFS4ERR_BADNAME is returned.

Opening for write files with append-only bit set or mandatory locking enabled
results in NFS4ERR_SHARE_DENIED.

Signed-off-by: Pawel Dziepak <pdziepak@quarnos.org>
---
 fs/nfsd/nfsfh.c |  2 +-
 fs/nfsd/vfs.c   | 28 ++++++++++++++++------------
 2 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index 814afaa..b18382c 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -91,7 +91,7 @@ static __be32 nfsd_setuser_and_check_port(struct
svc_rqst *rqstp,
  dprintk(KERN_WARNING
        "nfsd: request from insecure port %s!\n",
        svc_print_addr(rqstp, buf, sizeof(buf)));
- return nfserr_perm;
+ return nfserr_acces;
  }

  /* Set user creds for this exportpoint */
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index d586117..a9964de 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -777,7 +777,7 @@ nfsd_open(struct svc_rqst *rqstp, struct svc_fh
*fhp, umode_t type,
  /* Disallow write access to files with the append-only bit set
  * or any access when mandatory locking enabled
  */
- err = nfserr_perm;
+ err = nfserr_share_denied;
  if (IS_APPEND(inode) && (may_flags & NFSD_MAY_WRITE))
  goto out;
  /*
@@ -924,8 +924,6 @@ nfsd_vfs_read(struct svc_rqst *rqstp, struct
svc_fh *fhp, struct file *file,
  __be32 err;
  int host_err;

- err = nfserr_perm;
-
  if (file->f_op->splice_read && rqstp->rq_splice_ok) {
  struct splice_desc sd = {
  .len = 0,
@@ -1246,7 +1244,7 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
  __be32 err2;
  int host_err;

- err = nfserr_perm;
+ err = nfserr_inval;
  if (!flen)
  goto out;
  err = nfserr_exist;
@@ -1387,7 +1385,7 @@ do_nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
  int host_err;
  __u32 v_mtime=0, v_atime=0;

- err = nfserr_perm;
+ err = nfserr_inval;
  if (!flen)
  goto out;
  err = nfserr_exist;
@@ -1675,7 +1673,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ffhp,
  err = nfserr_isdir;
  if (S_ISDIR(tfhp->fh_dentry->d_inode->i_mode))
  goto out;
- err = nfserr_perm;
+ err = nfserr_inval;
  if (!len)
  goto out;
  err = nfserr_exist;
@@ -1761,8 +1759,11 @@ nfsd_rename(struct svc_rqst *rqstp, struct
svc_fh *ffhp, char *fname, int flen,
  if (ffhp->fh_export != tfhp->fh_export)
  goto out;

- err = nfserr_perm;
- if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
+ err = nfserr_inval;
+ if (!flen || !tlen)
+ goto out;
+ err = nfsd_v4client(rqstp) ? nfserr_badname : nfserr_inval;
+ if (isdotent(fname, flen) || isdotent(tname, tlen))
  goto out;

  host_err = fh_want_write(ffhp);
@@ -1850,8 +1851,11 @@ nfsd_unlink(struct svc_rqst *rqstp, struct
svc_fh *fhp, int type,
  __be32 err;
  int host_err;

- err = nfserr_acces;
- if (!flen || isdotent(fname, flen))
+ err = nfserr_inval;
+ if (!flen)
+ goto out;
+ err = nfsd_v4client(rqstp) ? nfserr_badname : nfserr_inval;
+ if (isdotent(fname, flen))
  goto out;
  err = fh_verify(rqstp, fhp, S_IFDIR, NFSD_MAY_REMOVE);
  if (err)
@@ -2120,10 +2124,10 @@ nfsd_permission(struct svc_rqst *rqstp, struct
svc_export *exp,
     __mnt_is_readonly(exp->ex_path.mnt))
  return nfserr_rofs;
  if (/* (acc & NFSD_MAY_WRITE) && */ IS_IMMUTABLE(inode))
- return nfserr_perm;
+ return nfserr_acces;
  }
  if ((acc & NFSD_MAY_TRUNC) && IS_APPEND(inode))
- return nfserr_perm;
+ return nfserr_acces;

  if (acc & NFSD_MAY_LOCK) {
  /* If we cannot rely on authentication in NLM requests,
--
1.7.11.7
