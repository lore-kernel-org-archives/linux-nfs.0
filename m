Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:40246 "EHLO
        mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbeB0RJF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Feb 2018 12:09:05 -0500
Received: by mail-vk0-f42.google.com with SMTP id n82so8184606vkf.7
        for <linux-nfs@vger.kernel.org>; Tue, 27 Feb 2018 09:09:05 -0800 (PST)
MIME-Version: 1.0
From: Olga Kornievskaia <aglo@umich.edu>
Date: Tue, 27 Feb 2018 12:09:04 -0500
Message-ID: <CAN-5tyHmCj=OeC--a9d51oPZL1GXku-Oj=oPAM=_0040Qz6AHA@mail.gmail.com>
Subject: Looping on ERR_OLD_STATEID on LOCK
To: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi folks,

I'd like to understand why nfs4_do_handle_exception() for
ERR_OLD_STATEID just retries the operation. What happens is that the
client resends that same operation with the same stateid over to the
server and gets the same ERR_OLD_STATEID back which puts the client in
an infinite loop (and a hung state).

Shouldn't the client instead treat ERR_OLD_STATEID same as ERR_BAD_STATEID?

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c8b554a..2e006bc 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -411,6 +411,7 @@ static int nfs4_do_handle_exception(struct
nfs_server *server,
  case -NFS4ERR_ADMIN_REVOKED:
  case -NFS4ERR_EXPIRED:
  case -NFS4ERR_BAD_STATEID:
+ case -NFS4ERR_OLD_STATEID:
  if (inode != NULL && stateid != NULL) {
  nfs_inode_find_state_and_recover(inode,
  stateid);
@@ -477,7 +478,6 @@ static int nfs4_do_handle_exception(struct
nfs_server *server,
  return 0;

  case -NFS4ERR_RETRY_UNCACHED_REP:
- case -NFS4ERR_OLD_STATEID:
  exception->retry = 1;
  break;
  case -NFS4ERR_BADOWNER:

Or alternative, for the LOCK it should be:
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c8b554a..ce846faf 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6441,6 +6441,7 @@ static void nfs4_handle_setlk_error(struct
nfs_server *server, struct nfs4_lock_
  case -NFS4ERR_ADMIN_REVOKED:
  case -NFS4ERR_EXPIRED:
  case -NFS4ERR_BAD_STATEID:
+ case -NFS4ERR_OLD_STATEID:
  lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
  if (new_lock_owner != 0 ||
    test_bit(NFS_LOCK_INITIALIZED, &lsp->ls_flags) != 0)
