Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:23292 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752292AbdG1Uhm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jul 2017 16:37:42 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
Subject: [GIT PULL] Please pull a few more NFS client fixes for 4.13
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Message-ID: <444eff18-a4fe-feb6-401f-e174b36a79dc@Netapp.com>
Date: Fri, 28 Jul 2017 16:37:35 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit 1ebf980127924c639e2b85c08468311ba1c95b70:           

  NFS/filelayout: Fix racy setting of fl->dsaddr in filelayout_check_deviceid() (2017-07-21 14:08:45 -0400)

are available in the git repository at:    

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-3              

for you to fetch changes up to b7dbcc0e433f0f61acb89ed9861ec996be4f2b38:               

  NFSv4.1: Fix a race where CB_NOTIFY_LOCK fails to wake a waiter (2017-07-28 15:35:30 -0400)

----------------------------------------------------------------
Most of these fix locking bugs that Ben and Neil noticed, but I also have a patch to fix one more access bug that was reported after last week.

Stable fixes:
- Fix a race where CB_NOTIFY_LOCK fails to wake a waiter
- Invalidate file size when taking a lock to prevent corruption

Other fixes:
- Don't excessively generate tiny writes with fallocate
- Use the raw NFS access mask in nfs4_opendata_access()

Thanks,
Anna

----------------------------------------------------------------
Anna Schumaker (1):  
      NFS: Use raw NFS access mask in nfs4_opendata_access()                           

Benjamin Coddington (1):                   
      NFSv4.1: Fix a race where CB_NOTIFY_LOCK fails to wake a waiter                  

NeilBrown (2):       
      NFS: invalidate file size when taking a lock.                                    
      NFS: Optimize fallocate by refreshing mapping when needed.                       

 fs/nfs/file.c     |  4 +++-               
 fs/nfs/nfs4proc.c | 14 +++++++++-----     
 2 files changed, 12 insertions(+), 6 deletions(-)   
