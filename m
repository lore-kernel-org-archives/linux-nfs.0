From: Neil Brown <neilb@suse.de>
Subject: NFS4ERR_FILE_OPEN handling in Linux
Date: Thu, 15 Oct 2009 11:35:28 +1100
Message-ID: <19158.28240.964203.341327@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, NFSv4@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:32853 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758406AbZJOAet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 20:34:49 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,

 Following up for a customer who had problem with NFSv4 when talking
 to a Solaris server with "nbman" enabled, I have questions about the
 handling of NFS4ERR_FILE_OPEN.
 In particular:
   1/ should commit c514983d8d2260020543a81589a2b8c7d4bdab4e be
      reverted, and
   2/ should nfs_errtbl map NFS4ERR_FILE_OPEN to -EBUSY rather than
      defaulting to -EIO

 That commit, included below for reference, causes the NFS client to
 retry indefinitely if NFS4ERR_FILE_OPEN is returned.  This
 contradicts the comment which suggests it will only "retry a few
 times" and cannot be correct as a file could be held open (thus
 causing the error) indefinitely.

 The problem that the patch claims to address (relating to ordering of
 async calls) is, I believe, addressed properly by the subsequent
 patch

commit a49c3c7736a2e77931dabc5bc4a83fb4b2da013e
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Thu Oct 18 18:03:27 2007 -0400

    NFSv4: Ensure that we wait for the CLOSE request to complete
    

 So I believe that first patch is both unnecessary and incorrect.


 When the server refuses to perform an action because the file is
 currently open, I think 'EIO' does not do justice to the situation at
 all.  EBUSY seems a lot more appropriate and does seem to be a
 permitted error code for e.g. rename(2) and unlink(2).  EACCES might
 be a possible alternate.  It doesn't really mean the same thing, but
 it is likely to be handled in an appropriate way.  Apparently the
 Solaris client returns EACCES.

 Thoughts?

Thanks,
NeilBrown



>From c514983d8d2260020543a81589a2b8c7d4bdab4e Mon Sep 17 00:00:00 2001
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Fri, 15 Sep 2006 08:25:04 -0400
Subject: [PATCH] NFSv4: Handle the condition NFS4ERR_FILE_OPEN

Retry a few times before we give up: the error is usually due to ordering
issues with asynchronous RPC calls.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index c218cc4..c49ac3e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2891,6 +2891,7 @@ int nfs4_handle_exception(const struct nfs_server *server, int errorcode, struct
 			if (ret == 0)
 				exception->retry = 1;
 			break;
+		case -NFS4ERR_FILE_OPEN:
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_DELAY:
 			ret = nfs4_delay(server->client, &exception->timeout);
-- 
1.6.4.3


