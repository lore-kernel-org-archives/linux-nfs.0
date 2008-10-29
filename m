From: "Phil Endecott" <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>
Subject: Make sm-notify faster if there are no servers to notify
Date: Wed, 29 Oct 2008 00:13:20 +0000
Message-ID: <1225239200402@dmwebmail.dmwebmail.chezphil.org>
Mime-Version: 1.0
Content-Type: text/plain; format="fixed"
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from japan.chezphil.org ([77.240.5.4]:1430 "EHLO japan.chezphil.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753006AbYJ2ANX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2008 20:13:23 -0400
Received: from localhost ([127.0.0.1] helo=chezphil.org)
	by japan.chezphil.org with esmtp (Exim 4.69)
	(envelope-from <phil_bnaqb_endecott-wZDNlLIRyE5g9hUCZPvPmw@public.gmane.org>)
	id 1Kuygb-0002eK-F5
	for linux-nfs@vger.kernel.org; Wed, 29 Oct 2008 00:13:21 +0000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dear Experts,

sm-notify was taking a long time while my laptop booted.  This was odd because I 
use NFS only rarely - via autofs - on that machine, and sm-notify actually has 
no-one to notify most of the time.  So I have patched it as follows.  Is this a 
legitimate thing to do?


diff -ur nfs-utils-1.1.3.orig/utils/statd/sm-notify.c nfs-utils-1.1.3/utils/statd/sm-notify.c
--- nfs-utils-1.1.3.orig/utils/statd/sm-notify.c	2008-07-27 22:01:45.000000000 +0100
+++ nfs-utils-1.1.3/utils/statd/sm-notify.c	2008-10-13 19:02:54.000000000 +0100
@@ -169,6 +169,10 @@
 	backup_hosts(_SM_DIR_PATH, _SM_BAK_PATH);
 	get_hosts(_SM_BAK_PATH);
 
+	if (!hosts) {
+		return 0;
+	}
+
 	/* Get and update the NSM state. This will call sync() */
 	nsm_state = nsm_get_state(opt_update_state);
 	set_kernel_nsm_state(nsm_state);



Regards,  Phil.
(Please Cc: me in any replies.)

