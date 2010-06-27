Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30080 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916Ab0F0P6T convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jun 2010 11:58:19 -0400
Subject: [GIT] Please pull NFS client fixes
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Date: Sun, 27 Jun 2010 11:58:01 -0400
Message-ID: <1277654281.3311.3.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/client.c       |  122 ++++++++++++++++++++----------------------------
 fs/nfs/getroot.c      |    2 +-
 fs/nfs/nfs4xdr.c      |    4 +-
 fs/nfs/super.c        |   22 +++++++--
 net/sunrpc/xprtsock.c |   38 +++++++++------
 5 files changed, 94 insertions(+), 94 deletions(-)

commit d3f6baaa34c54040b3ef30950e59b54ac0624b21
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Jun 22 08:52:39 2010 -0400

    NFSv4: Fix an embarassing typo in encode_attrs()
    
    Apparently, we have never been able to set the atime correctly from the
    NFSv4 client.
    
    Reported-by: 小倉一夫 <ka-ogura@bd6.so-net.ne.jp>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 0be8189f2c87fcc747d6a4a657a0b6e2161b2318
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Fri Jun 18 12:23:58 2010 -0400

    NFSv4: Ensure that /proc/self/mountinfo displays the minor version number
    
    Currently, we do not display the minor version mount parameter in the
    /proc mount info.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit 44950b67a6239b377a9e6fd52c498b310bcdd713
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Jun 17 11:45:12 2010 -0400

    NFSv4.1: Ensure that we initialise the session when following a referral
    
    Put the code that is common to both the referral and ordinary mount cases
    into a common helper routine.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit b76ce56192bcf618013fb9aecd83488cffd645cc
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Wed Jun 16 13:57:32 2010 -0400

    SUNRPC: Fix a re-entrancy bug in xs_tcp_read_calldir()
    
    If the attempt to read the calldir fails, then instead of storing the read
    bytes, we currently discard them. This leads to a garbage final result when
    upon re-entry to the same routine, we read the remaining bytes.
    
    Fixes the regression in bugzilla number 16213. Please see
        https://bugzilla.kernel.org/show_bug.cgi?id=16213
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org

commit f799bdb355edaabd81b778087613409a8932fbe9
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Jun 16 09:51:02 2010 -0400

    nfs4 use mandatory attribute file type in nfs4_get_root
    
    S_ISDIR(fsinfo.fattr->mode) checks the file type rather than the mode bits,
    so we should be checking for the NFS_ATTR_FATTR_TYPE fattr property.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
    Cc: stable@kernel.org


