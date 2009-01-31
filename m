From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] text-based mount command: Fixed typo in  po_rightmost
Date: Sat, 31 Jan 2009 14:24:37 -0500
Message-ID: <4984A575.3000207@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48483 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751508AbZAaT1D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 31 Jan 2009 14:27:03 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0VJR3aD030367
	for <linux-nfs@vger.kernel.org>; Sat, 31 Jan 2009 14:27:03 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0VJR3Yx016963
	for <linux-nfs@vger.kernel.org>; Sat, 31 Jan 2009 14:27:03 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-19.bos.redhat.com [10.16.10.19])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0VJR3uM027007
	for <linux-nfs@vger.kernel.org>; Sat, 31 Jan 2009 14:27:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fixed typo in po_rightmost() that was cause options like nolock,
bg, udp, tcp, proto, v2, v3, vers, nfsvers to either be 
ignored or interrupted 

Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mount/parse_opt.c b/utils/mount/parse_opt.c
index 4934508..280f3e5 100644
--- a/utils/mount/parse_opt.c
+++ b/utils/mount/parse_opt.c
@@ -448,7 +448,7 @@ unsigned int po_rightmost(struct mount_options *options, const char *keys[])
 		for (option = options->tail; option; option = option->prev) {
 			for (i = 0; keys[i] != NULL; i++)
 				if (strcmp(option->keyword, keys[i]) == 0)
-					return i;
+					return i+1;
 		}
 	}
 
