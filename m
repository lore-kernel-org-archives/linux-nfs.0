From: Todd Woods <twoods@divms.uiowa.edu>
Subject: lockd dying
Date: Thu, 27 Jun 2002 13:23:35 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D1B5827.7060605@divms.uiowa.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from penguin.divms.uiowa.edu ([128.255.44.29])
	by usw-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Ndvi-0007AQ-00
	for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 11:23:42 -0700
Received: from divms.uiowa.edu (bester.divms.uiowa.edu [128.255.44.42]) by penguin.divms.uiowa.edu with id g5RINeO8017798 for <nfs@lists.sourceforge.net>; Thu, 27 Jun 2002 13:23:40 -0500
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

	Having a problem with lockd dying.  Using stock RH 7.2 2.4.9-21 
enterprise kernel right now on an IBM x350. We get this error message 
when lockd dies

Jun 27 12:32:43 server kernel: Unable to handle
kernel paging request at virtual address b9bd8060
Jun 27 12:32:43 server kernel: *pde = bffffebc

	Then the lockd kernel thread dies. The problem wouldn't be so bad if we 
could restart nfs/lockd etc. However once lockd dies nfsd's get very 
unhappy.  nfs services won't shut down, the nfsd kernel threads don't die.
	So we have to reboot the server and since the nfsd's don't die we can't 
even gracefully reboot the server, we have to power cycle it. Rebooting 
causes a problem on the clients (mix of linux/HPUX/IRIX machines). One 
reboot any existing mount point that was in use before the server 
shutdown has troubles.  Error is usually along lines of

NFS getattr failed for server server: RPC: Authentication error

	Simple remount of the NFS mount points on the clients usually fixes the 
problem.


So 3 questions

1) Any way to recover nfs services short of rebooting if the kernel 
lockd dies?

2) We are somewhat constrained by IBM's support for the hardware we're 
using so we can't just upgrade to the latest kernel.  Does anyone have 
any ideas as to the reason why lockd is dying or a fix that doesn't 
require applying the latest kernel and relevant patches?

3) What is needed to get the clients/server to gracefully recover NFS 
services from server crash?

	Any help would be greatly appreciated,
		thanks,
			Todd Woods



-------------------------------------------------------
Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
