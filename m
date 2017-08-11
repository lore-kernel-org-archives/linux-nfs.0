Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:35015 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753256AbdHKUk6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Aug 2017 16:40:58 -0400
From: Anna Schumaker <Anna.Schumaker@Netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: [GIT PULL] Please pull a few more NFS client fixes for 4.13
Message-ID: <4a7ac662-682c-85f4-d434-8a03929d407f@Netapp.com>
Date: Fri, 11 Aug 2017 16:40:46 -0400
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

The following changes since commit d9cb73300ac0001832c048a489c592263fc28193:                                                      

  NFSv4: Fix double frees in nfs4_test_session_trunk() (2017-08-02 09:45:55 -0400)                                                

are available in the git repository at:                          

  git://git.linux-nfs.org/projects/anna/linux-nfs.git tags/nfs-for-4.13-5                                                         

for you to fetch changes up to 8a9d6e964d318533ba3d2901ce153ba317c99a89:                                                          

  pnfs/blocklayout: require 64-bit sector_t (2017-08-11 14:10:13 -0400)                                                           

----------------------------------------------------------------
A few more bugfixes from me for rc5.  Dros has a stable fix for flexfiles to prevent
leaking the nfs4_ff_ds_version arrays when freeing a layout,  Trond fixed a potential
recovery loop situation with the TEST_STATEID operation, and Christoph fixed up the
pNFS blocklayout Kconfig options to prevent unsafe use with kernels that don't have
large block device support.

Have a good weekend!
Anna

---------------------------------------------------------------- 
Christoph Hellwig (1):          
      pnfs/blocklayout: require 64-bit sector_t                  

Trond Myklebust (1):            
      NFSv4: Ignore NFS4ERR_OLD_STATEID in nfs41_check_open_stateid()                                                             

Weston Andros Adamson (1):      
      nfs/flexfiles: fix leak of nfs4_ff_ds_version arrays       

 fs/nfs/Kconfig                            | 1 +                 
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 1 +                 
 fs/nfs/nfs4proc.c                         | 3 +--               
 3 files changed, 3 insertions(+), 2 deletions(-)      
