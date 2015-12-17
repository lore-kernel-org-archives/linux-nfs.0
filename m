Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:56809 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755726AbbLQB6Y (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Dec 2015 20:58:24 -0500
From: NeilBrown <neilb@suse.com>
To: Steve Dickson <SteveD@redhat.com>
Date: Thu, 17 Dec 2015 12:56:34 +1100
Subject: [PATCH 1/2] Fix uninitialised variable usage in nfs_options2pmap
Cc: linux-nfs@vger.kernel.org, Andreas Schwab <schwab@suse.com>
Message-ID: <20151217015634.19978.77514.stgit@noble>
In-Reply-To: <20151217015524.19978.63114.stgit@noble>
References: <20151217015524.19978.63114.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andreas Schwab <schwab@suse.com>

Commit 5bea22e33b7a introduced a regression.  Prior to that commit
nfs_nfs_version would set *version to 0 if NFS version wasn't specified.
Since that commit, version.v_mode is set to V_DEFAULT if the NFS version
isn't specified, but nfs_options2pmap uses version.major without checking
v_mode.  This can lead to incorrect behaviour.
In particular fall-ack to v3 if server doesn't support v4 can fail.

So test v_mode before using version.major.

URL: https://bugzilla.opensuse.org/show_bug.cgi?id=956743
Fixes: 5bea22e33b7a ("mount.nfs: Add struct nfs_version and generalize version parsing")
Signed-off-by: NeilBrown <neilb@suse.com>
---
 utils/mount/network.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index ebc39d361e2c..8a9bf1476d51 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1631,7 +1631,10 @@ int nfs_options2pmap(struct mount_options *options,
 		return 0;
 	if (!nfs_nfs_version(options, &version))
 		return 0;
-	nfs_pmap->pm_vers = version.major;
+	if (version.v_mode == V_DEFAULT)
+		nfs_pmap->pm_vers = 0;
+	else
+		nfs_pmap->pm_vers = version.major;
 	if (!nfs_nfs_protocol(options, &nfs_pmap->pm_prot))
 		return 0;
 	if (!nfs_nfs_port(options, &nfs_pmap->pm_port))


