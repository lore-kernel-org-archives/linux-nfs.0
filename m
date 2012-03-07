Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:17362 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965219Ab2CGWkz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Mar 2012 17:40:55 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH 0/2] RE: NFSv4: truncate returns I/O error
Date: Wed,  7 Mar 2012 17:40:47 -0500
Message-Id: <1331160049-3842-1-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
References: <87k42yjb0c.fsf@tucsk.pomaz.szeredi.hu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Miklos,

The base cause of the test failure was that the client was holding
onto a read delegation while trying to truncate the file. Whereas
some servers allow the client to do this (provided that nobody else
holds a read delegation), the Linux server does not, and returns
an error.
The fix is therefore to return the delegation if the server rejects
our attempt (see patch 2/2).

I've included patch 1/2 since it too was already queued for the
stable@vger.kernel.org queue, and so 2/2 has a dependency...

Thanks for the bug report!

Cheers
 Trond

Trond Myklebust (2):
  NFS: Properly handle the case where the delegation is revoked
  NFSv4: Return the delegation if the server returns NFS4ERR_OPENMODE

 fs/nfs/delegation.c |   11 +++++++++++
 fs/nfs/delegation.h |    1 +
 fs/nfs/nfs4_fs.h    |    3 +++
 fs/nfs/nfs4proc.c   |   31 ++++++++++++++++++++++++++++---
 fs/nfs/nfs4state.c  |   29 +++++++++++++++++++++++++++--
 5 files changed, 70 insertions(+), 5 deletions(-)

-- 
1.7.7.6

