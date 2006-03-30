From: Justin Piszcz <jpiszcz@lucidpixels.com>
Subject: NFS/Kernel Problem: getfh failed: Operation not permitted
Date: Thu, 30 Mar 2006 08:19:59 -0500 (EST)
Message-ID: <Pine.LNX.4.64.0603300813270.18696@p34>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FOx4Q-0000oo-9f
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 05:20:14 -0800
Received: from lucidpixels.com ([66.45.37.187] ident=postfix)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FOx4O-0007Ji-Nc
	for nfs@lists.sourceforge.net; Thu, 30 Mar 2006 05:20:14 -0800
To: linux-kernel@vger.kernel.org
Sender: nfs-admin@lists.sourceforge.net
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

The error is: rpc.mountd: getfh failed: Operation not permitted

In order to fix this error, someone needs to run these commands on each 
nfs server.

    40  service nfs stop
    41  rm -f /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
/var/lib/xtab
    42  touch /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
/var/lib/xtab
    43  chmod 644 /var/lib/nfs/etab /var/lib/nfs/rmtab /var/lib/nfs/state 
/var/lib/xtab
    44  service nfs start

http://www.ccs.neu.edu/home/johan/personal/linux.html

This issue seems to be more of an NFS issue than a kernel one, but I was 
wondering what other people had to say about it.  There are a lot of 
responses and questions concerning this error on google, but VERY few 
people have a response or method of fixing it, much less finding a 
permanent fix.

Has anyone found a fix or work-around that does not require restarting 
NFS?

Please CC as I am not on either list.

Thanks,

Justin.


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
