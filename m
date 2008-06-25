From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: FQDNs in the rmtab causes exportfs to seg fault
Date: Tue, 24 Jun 2008 21:04:17 -0400
Message-ID: <48619991.5030704@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40575 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753470AbYFYBEk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Jun 2008 21:04:40 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id m5P14d1S003621
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2008 21:04:39 -0400
Received: from file.rdu.redhat.com (file.rdu.redhat.com [10.11.255.147])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id m5P14daL011367
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2008 21:04:39 -0400
Received: from [10.16.10.68] (vpn-10-68.bos.redhat.com [10.16.10.68])
	by file.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id m5P14c5M018584
	for <linux-nfs@vger.kernel.org>; Tue, 24 Jun 2008 21:04:38 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a FQDN exists in /var/lib/nfs/rmtab it causes 
the exportfs command to seg fault due to the nfs_export pointer 
not being allocated. Reworking the parentheses in rmtab_read() 
so the htype variable is evaluated correctly fix the problem.

Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/export/rmtab.c b/support/export/rmtab.c
index 0ce3682..e11a22a 100644
--- a/support/export/rmtab.c
+++ b/support/export/rmtab.c
@@ -31,10 +31,10 @@ rmtab_read(void)
 		int			htype;
 		
 		htype = client_gettype(rep->r_client);
-		if (htype == MCL_FQDN || (htype == MCL_SUBNETWORK
+		if ((htype == MCL_FQDN || htype == MCL_SUBNETWORK)
 		    && (hp = gethostbyname (rep->r_client))
 		    && (hp = hostent_dup (hp),
-			(exp = export_allowed (hp, rep->r_path))))) {
+			exp = export_allowed (hp, rep->r_path))) {
 			/* see if the entry already exists, otherwise this was an instantiated
 			 * wild card, and we must add it
 			 */
