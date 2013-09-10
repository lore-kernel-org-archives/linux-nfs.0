Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:14399 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088Ab3IJS4G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Sep 2013 14:56:06 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: <Trond.Myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Weston Andros Adamson <dros@netapp.com>
Subject: [PATCH 0/2] NFSv4.1: sp4_mach_cred cleanup
Date: Tue, 10 Sep 2013 14:55:56 -0400
Message-ID: <1378839358-10389-1-git-send-email-dros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These two patches do some final cleanup of SP4_MACH_CRED:
  - actually call put_rpccred() if we get_rpccred(clp->cl_machine_cred)
  - advertise to server that we support WRITE and COMMIT

Tested against a linux nfsd hacked to "support" sp4_mach_cred for the
client supported ops.  Also tested building with v4.1 disabled and v4 disabled.

Trond - it's (obviously) up to you if these get in during this merge window.
I think they're pretty straightforward.  Also, these patches are independent
from eachother, so it's ok to select one but not the other.


Weston Andros Adamson (2):
  NFSv4.1: clean up after using machine cred
  NFSv4.1: sp4_mach_cred: ask for WRITE and COMMIT

 fs/nfs/nfs4_fs.h  | 58 ++++++++++++++++++++++++++++++++++++-------------------
 fs/nfs/nfs4proc.c | 58 +++++++++++++++++++++++++++++++++++++------------------
 fs/nfs/write.c    | 18 +++++++++++------
 3 files changed, 89 insertions(+), 45 deletions(-)

-- 
1.7.12.4 (Apple Git-37)

