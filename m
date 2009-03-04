From: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Subject: [PATCH] Don't convert NFS4ERR_RESOURCE to EREMOTEIO
Date: Wed, 04 Mar 2009 13:42:30 -0500
Message-ID: <49AECB96.5010909@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.uvm.edu ([132.198.101.168]:59473 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755007AbZCDSmg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 13:42:36 -0500
Received: from planck.local ([132.198.107.214])
	(authenticated bits=0)
	by smtp1.uvm.edu (8.14.2/8.14.2) with ESMTP id n24IgUsf011298
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 4 Mar 2009 13:42:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixes a test in nfs4_proc_setclientid_confirm() which allows the client 
to retry an operation when the server returns NFS4ERR_RESOURCE, instead 
of returning EREMOTEIO to the user.

---
fs/nfs/nfs4xdr.c |    1 -
  1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d1e4c8f..61dda13 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4522,7 +4522,6 @@ static struct {
         { NFS4ERR_SERVERFAULT,  -ESERVERFAULT   },
         { NFS4ERR_BADTYPE,      -EBADTYPE       },
         { NFS4ERR_LOCKED,       -EAGAIN         },
-       { NFS4ERR_RESOURCE,     -EREMOTEIO      },
         { NFS4ERR_SYMLINK,      -ELOOP          },
         { NFS4ERR_OP_ILLEGAL,   -EOPNOTSUPP     },
         { NFS4ERR_DEADLOCK,     -EDEADLK        },

