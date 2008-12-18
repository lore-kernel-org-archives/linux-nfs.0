From: "lioupayphone" <lioupayphone@gmail.com>
Subject: why there is a complex sync between /var/lib/nfs/etab in user-mode and  export_table in kernel mode?
Date: Thu, 18 Dec 2008 14:34:03 +0800
Message-ID: <200812181433568806030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
To: "linux-nfs" <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:65245 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751248AbYLRGeH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Dec 2008 01:34:07 -0500
Received: by ti-out-0910.google.com with SMTP id b6so135203tic.23
        for <linux-nfs@vger.kernel.org>; Wed, 17 Dec 2008 22:34:05 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, linux-nfs

i found that an entry in /var/lib/nfs/etab (etab for abbr)  was written to exprot_table of kernel-mode via a proc-file when a client requests mnt this entry.                                       
when the entry in export_table of kernel-mode was expired (eg : reached its expiration time), an upcall machanism is able to make sure that the newly entry from etab of user-mode was written to export_table of kernel-mode. ie, the entry in export_table of kernel-mode was updated by the one of user-mode.

if the content listed above is true, i think linux nfs is too complex. and why not remove the etab from user-mode?
in a word, i think it is easy to just maintain export_table of kernel-mode. we can directly scan /etc/exports and make up a complete export-entry, then write it to the export_table of kernel-mode. the entries in export_table of kernel-mode would never be expired unless we explicitly remove it from the export_table of kernel-mode (a proc MUST be provided for meeting this requirement).

when the server is rebooted and nfsd proc-filesystem is ready, just re-do "scanning the /etc/exports and make up complete export-entries, then write them into export_table of kernel-mode".  

i aims to 1) remove the complex upcall machanism ,  2) get rid of the couple of /var/lib/nfs/etab in user-mode and export_table in kernel-mode.

anyone can give me some suggestions? or points out what's wrong i am.
thank you!
 				
Best Regards! 
lioupayphone


