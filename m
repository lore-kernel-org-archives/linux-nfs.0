From: Jean-Christophe Ducom <jducom@nd.edu>
Subject: NFS clients hang
Date: Fri, 11 Jul 2003 09:49:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F0ECE77.1050703@nd.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from osgood.cc.nd.edu ([129.74.250.227])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19azGL-0001tu-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 07:52:41 -0700
Received: from nd.edu (frenchy.chem.nd.edu [129.74.74.11])
	by osgood.cc.nd.edu (Switch-3.0.4/Switch-3.0.0) with ESMTP id h6BEqXjQ011539
	for <nfs@lists.sourceforge.net>; Fri, 11 Jul 2003 09:52:33 -0500 (EST)
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hardware:
Dell Precision 530 Dual Xeon1.7GHz 1GB RDRAM

Redhat 7.2 distribution is used with kernel 2.4.21 patched with IngoMolnar IRQ 
balancing as there is a 'bug' with Xeon processors (only one would take care of 
all interrupts), configured with CONFIG_HIGHMEM option. nfs-utils-1.0.3-1 is used.
The mount option for the client is: 
rw,nosuid,nodev,hard,intr,bg,rsize=8192,wsize=8192,nfsvers=3,lock,udp

Sometimes the NFS client was hanging for no reason (usually when a medium size 
file (30MB+) was handled over NFS or a lot files were moved around).
The machine was then completely locked (no access at all to it, even thru serial 
console, no display on the monitor anymore). tcpdump files didn't show anything 
wrong but just stop to report traffic until the lock.
I reconfigured the kernel with CONFIG_DEBUG_SPINLOCK and CONFIG_SOFT_WATCHDOG to 
have access to some debug info. The client was still completely locked up and 
couldn't get out of the locked state.

I finally read in Chuck Lever's technical report "Customers that use 2.4 kernels 
on hardware with more than 896MB shoould know that a special kernel option, 
known as CONFIG_HIGHMEM, is required to access and use memory above 896M. The 
linux NFS client has a known problem in these configurations where an 
application or the whole client system can hang at random. This issue has been 
addressed in the 2.4.20 kernel, but still haunts kernels contained in 
distribution from RedHat and SUSE that are based on earlier kernels".

So I recompiled 2.4.21 without CONFIG_HIGHMEM and since the NFS clients have 
been rock solid. Not a single hang since but of course 100+MB of memory are 
'lost' now.
So is this problem still around or is it specific to Xeons?
Thanks

	JC



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
