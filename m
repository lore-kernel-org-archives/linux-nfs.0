From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] mount: segmentation faults on UDP mounts
Date: Tue, 17 Feb 2009 15:43:33 -0500
Message-ID: <499B2175.8030203@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35810 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752858AbZBQUqF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2009 15:46:05 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n1HKk4JG008540
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 15:46:04 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n1HKk5tI019833
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 15:46:05 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-30.bos.redhat.com [10.16.10.30])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n1HKk3R5017126
	for <linux-nfs@vger.kernel.org>; Tue, 17 Feb 2009 15:46:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This came in over the weekend... when a server only supports 
UDP mounts, mount seg faults... this patch fixes the problem...

steved.

commit 52ec1b5fceece8f63b97afc6d6b78bfabff12669
Author: Steve Dickson <steved@redhat.com>
Date:   Tue Feb 17 15:33:58 2009 -0500

    The mount sockaddr len (mnt_salen) is not be set in
    nfs_extract_server_addresses() which causes the mount.nfs
    command to segmentation fault when a NFS server only
    supports UDP mounts.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 770b5b5..c369136 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -331,9 +331,10 @@ static int nfs_extract_server_addresses(struct mount_options *options,
 		return 0;
 
 	option = po_get(options, "mountaddr");
-	if (option == NULL)
+	if (option == NULL) {
 		memcpy(mnt_saddr, nfs_saddr, *nfs_salen);
-	else if (!nfs_string_to_sockaddr(option, strlen(option),
+		*mnt_salen = *nfs_salen;
+	} else if (!nfs_string_to_sockaddr(option, strlen(option),
 						mnt_saddr, mnt_salen))
 		return 0;
 
