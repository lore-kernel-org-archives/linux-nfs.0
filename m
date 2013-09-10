Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64850 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751561Ab3IJWoi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 18:44:38 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 0/4] NFSv4.1: sp4_mach_cred cleanup (v2)
Date: Tue, 10 Sep 2013 18:44:29 -0400
Message-ID: <1378853073-13256-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Version 2 takes a new approach that Trond requested: we rely on the
cl_machine_cred to have a reference held for the life of the nfs_client
structure, so the sp4 stuff doesn't need to do any get/put_rpccred.

There's also two new patches:
 - "fix SECINFO* use of put_rpccred" - recent changes (by me!) called
   put_rpccred of rpc_message.rpc_cred, but this value can change when
   nfs4_state_protect() is called. I searched through the rest of the client
   source and couldn't find another place where this happens.

 - WARN_ON -> WARN_ON_ONCE - oops.

Weston Andros Adamson (4):
  NFSv4.1: sp4_mach_cred: ask for WRITE and COMMIT
  NFSv4.1: fix SECINFO* use of put_rpccred
  NFSv4.1: sp4_mach_cred: no need to ref count creds
  NFSv4.1: sp4_mach_cred: WARN_ON -> WARN_ON_ONCE

 fs/nfs/nfs4_fs.h  | 10 +++++-----
 fs/nfs/nfs4proc.c | 22 ++++++++++++++--------
 2 files changed, 19 insertions(+), 13 deletions(-)

-- 
1.7.12.4 (Apple Git-37)

