From: Steve Dickson <SteveD@redhat.com>
Subject: Re: why there is a complex sync between /var/lib/nfs/etab in user-mode
 and  export_table in kernel mode?
Date: Thu, 18 Dec 2008 10:51:46 -0500
Message-ID: <494A7192.9080900@RedHat.com>
References: <200812181433568806030@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: lioupayphone <lioupayphone@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:52429 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750914AbYLRPx7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 10:53:59 -0500
In-Reply-To: <200812181433568806030@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lioupayphone wrote:
> Hello, linux-nfs
> 
> i found that an entry in /var/lib/nfs/etab (etab for abbr)  was written to exprot_table of kernel-mode via a proc-file when a client requests mnt this entry.                                       
> when the entry in export_table of kernel-mode was expired (eg : reached its expiration time), an upcall machanism is able to make sure that the newly entry from etab of user-mode was written to export_table of kernel-mode. ie, the entry in export_table of kernel-mode was updated by the one of user-mode.
> 
> if the content listed above is true, i think linux nfs is too complex. and why not remove the etab from user-mode?
> in a word, i think it is easy to just maintain export_table of kernel-mode. we can directly scan /etc/exports and make up a complete export-entry, then write it to the export_table of kernel-mode. the entries in export_table of kernel-mode would never be expired unless we explicitly remove it from the export_table of kernel-mode (a proc MUST be provided for meeting this requirement).
> 
> when the server is rebooted and nfsd proc-filesystem is ready, just re-do "scanning the /etc/exports and make up complete export-entries, then write them into export_table of kernel-mode".  
> 
> i aims to 1) remove the complex upcall machanism ,  2) get rid of the couple of /var/lib/nfs/etab in user-mode and export_table in kernel-mode.
> 
> anyone can give me some suggestions? or points out what's wrong i am.
The /var/lib/nfs/etab file is the way the exportfs command communicates 
with the mountd daemon. 'exportfs -ar' causes the exports in /etc/exports
to be parsed and written to the etab. When a mount request is received
mountd reads the etab to build its internal export table. Ultimately
when the mount is successful, the kernel writes the mount to
/proc/net/rpc/nfsd.export/content.

So that's how the etab fits in the grand scheme of things... 

I believe what you are suggesting is simply pumping down
all the exports in /etc/exports directly to the kernel.
This ideas has been discussed and I believe the conclusion
we came to was; why pump down thousands of exports that
may or may not used. Dynamically building the kernel export
data just seem to make more sense in our case...

I hope this helps...

steved.

