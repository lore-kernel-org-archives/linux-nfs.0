Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:60597 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755272Ab2C0WgH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Mar 2012 18:36:07 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFSv4: Fix two infinite loops in the mount code
Date: Tue, 27 Mar 2012 18:35:42 -0400
Message-Id: <1332887744-4222-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We can currently loop forever in nfs4_lookup_root() and in
nfs41_proc_secinfo_no_name(), if the first iteration returns a
NFS4ERR_DELAY or something else that causes exception.retry to get
set.

Reported-by: Dros Adamson <Weston.Adamson@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/nfs4proc.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 45df7d4..ee9ca19 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2290,11 +2290,12 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 		switch (err) {
 		case 0:
 		case -NFS4ERR_WRONGSEC:
-			break;
+			goto out;
 		default:
 			err = nfs4_handle_exception(server, err, &exception);
 		}
 	} while (exception.retry);
+out:
 	return err;
 }
 
@@ -6229,11 +6230,12 @@ nfs41_proc_secinfo_no_name(struct nfs_server *server, struct nfs_fh *fhandle,
 		case 0:
 		case -NFS4ERR_WRONGSEC:
 		case -NFS4ERR_NOTSUPP:
-			break;
+			goto out;
 		default:
 			err = nfs4_handle_exception(server, err, &exception);
 		}
 	} while (exception.retry);
+out:
 	return err;
 }
 
-- 
1.7.7.6

