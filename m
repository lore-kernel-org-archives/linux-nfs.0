From: Rick Blocker <rblocker@uchicago.edu>
Subject: error says "Permission denied" but logs say "authenticated mount
 request"
Date: Tue, 27 Jul 2004 15:18:18 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <p06010211bd2c68efd475@[128.135.150.250]>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii" ; format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpYMt-0007Gp-Q8
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 13:16:11 -0700
Received: from relay00.uchicago.edu ([128.135.12.75])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1BpYMt-0004f1-Cl
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 13:16:11 -0700
Received: from [128.135.150.250] (galapagos.uchicago.edu [128.135.150.250])
	by relay00.uchicago.edu (8.12.10/8.12.9) with ESMTP id i6RKG9Xr005170
	for <nfs@lists.sourceforge.net>; Tue, 27 Jul 2004 15:16:10 -0500 (CDT)
To: nfs@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello,

I have a very frustrating problem that I hope someone can help me 
with.  I have a file server running Linux kernel version 2.6.7 on 
RedHat Enterprise Linux 3 for x86_64 (single AMD Opteron CPU).  I 
have set up my /etc/exports file with the single line:

	/export/md0/home        client.mydomain(rw)

and run

	/usr/sbin/exportfs -a

The nfsd and rpc.mountd daemons are running on the server. I have 
edited /etc/hosts.allow on the server to allow portmap from the 
client machine. However, whenever I issue the mount command:

    [root@client /]# mount /nfs/mountpoint/home
    mount: server.mydomain:/export/md0/home failed, reason given by 
server: Permission denied

I get the "Permission denied" error.  But, on the server in the logs I see:

    Jul 27 14:56:40 server rpc.mountd: authenticated mount request 
from client.mydomain:1009 for /export/md0/home (/export/md0/home)

I have tried this from multiple clients with the same error.  I even 
went so far as to re-compile a new kernel, but no luck.

Does anyone have a clue what this could be?

Thanks.


-- 




Richard Blocker
Information Systems Manager
Ecology and Evolution
Organismal Biology and Anatomy
University of Chicago
Zoology 114B
1101 E. 57th Street
Chicago, IL 60637
rblocker@uchicago.edu
telephone: 773-702-5135
facsimile: 773-702-9740


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
