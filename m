Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39628 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750776AbaIIRiF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 13:38:05 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 9 Sep 2014 13:38:04 -0400
In-Reply-To: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
References: <1410274196-30841-1-git-send-email-Anna.Schumaker@Netapp.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-nfs-owner@vger.kernel.org,
        Trond.Myklebust@primarydata.com
MIME-Version: 1.0
Subject: Re: [PATCH 0/2] NFS: Add ALLOCATE and DEALLOCATE support
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OFCC7C8976.B925FBA7-ON88257D4E.00604587-88257D4E.0060D8A0@us.ibm.com>
Date: Tue, 9 Sep 2014 10:37:50 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Anna,

Did you get a chance to set up a git tree with all your changes, at least 
for the client side, maybe Trond will include it in his tree?

Thanks, Marc. 


From:   Anna Schumaker <Anna.Schumaker@netapp.com>
To:     <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>, 
Date:   09/09/2014 07:50 AM
Subject:        [PATCH 0/2] NFS: Add ALLOCATE and DEALLOCATE support
Sent by:        linux-nfs-owner@vger.kernel.org



These patches add client support for the ALLOCATE and DEALLOCATE 
operations
part of NFS v4.2.

These operations are triggered by a vfs_fallocate() call, and we determine
which to use based on if the FALLOC_FL_PUNCH_HOLE flag is set.

Anna Schumaker (2):
  nfs: Add ALLOCATE support
  nfs: Add DEALLOCATE support

 fs/nfs/nfs42proc.c        |  74 +++++++++++++++++++++++++
 fs/nfs/nfs42xdr.h         | 136 
++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h          |   3 +
 fs/nfs/nfs4client.c       |   2 +-
 fs/nfs/nfs4file.c         |  47 ++++++++++++++++
 fs/nfs/nfs4proc.c         |   2 +-
 fs/nfs/nfs4xdr.c          |   2 +
 include/linux/nfs4.h      |   2 +
 include/linux/nfs_fs_sb.h |   2 +
 include/linux/nfs_xdr.h   |  28 ++++++++++
 10 files changed, 296 insertions(+), 2 deletions(-)

-- 
2.1.0

--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



