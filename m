From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] [NFSD] Typo in nfsd_vers()
Date: Thu, 17 Jan 2008 07:16:47 -0500
Message-ID: <478F472F.9050800@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751839AbYAQMRh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Jan 2008 07:17:37 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

During my travels I found a small typo in nfsd_vers() (the routine
used by rpc.nfsd to set the protocol version(s) in NFS server)

When testing to see which versions are available, nfsd_vers() should
use nfsd_versions[] not nfsd_version[]. The reason this typo is
not noticeable is due to the fact this availability info is used in
a reply that rpc.nfsd ignores.

steved.


Author: Steve Dickson <steved@redhat.com>
Date:   Thu Jan 17 06:50:57 2008 -0500

    In nfsd_vers() the NFSD_AVAIL command should be using nfsd_versions[]
    not nfsd_version[]

    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 1190aea..f0c66e0 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -134,7 +134,7 @@ int nfsd_vers(int vers, enum vers_op change)
    case NFSD_TEST:
        return nfsd_versions[vers] != NULL;
    case NFSD_AVAIL:
-       return nfsd_version[vers] != NULL;
+       return nfsd_versions[vers] != NULL;
    }
    return 0;
 }
