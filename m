From: Robert Rati <Robert.Rati@motorola.com>
Subject: mountd through a firewall?
Date: Wed, 19 Feb 2003 16:56:46 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E540BAE.9090903@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from motgate5.mot.com ([144.189.100.105])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ld9i-0000Hp-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 14:57:34 -0800
Received: from mothost.mot.com (mothost.mot.com [129.188.137.101])
	by motgate5.mot.com (Motorola/Motgate5) with ESMTP id h1JMvLmG017045
	for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 15:57:22 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by mothost.mot.com (MOT-pobox 2.0) with ESMTP id PAA18088 for <nfs@lists.sourceforge.net>; Wed, 19 Feb 2003 15:57:33 -0700 (MST)]
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

I post this question a few days ago, but go no response.  I hope someone 
on the list can help with this issue or point me in another direction.

When I start rpc.mountd, I notice that it always registers 4 ports with 
portmapper.  2 TCP and 2 UDP, which corespond to two separate instances 
of mountd.  When I run exportfs, I see that no file systems are being 
exported.  If I export a file system, the only difference is exportfs 
shows a file system being exported.  This will obviously cause a problem 
if I try to specify a port for rpc.mountd to run on as both instances of 
mountd try to use the same port and the tcp bind for the second instance 
fails.  Why does rpc.mountd start two instances of mountd?

This issue comes from trying to allow an NFS export through a firewall. 
  Since mountd uses different ports each time it starts, it's nearly 
impossible to pass it through a firewall.  Does anyone have an alternate 
solution to this problem besides telling rpc.mountd to run on a 
specified port (as that isn't working as detailed above).  I'm stuck 
using kernel 2.2.17, so I've been unable to check out the nfs-utils 
ability to handle specifying a port for mountd.

Rob



-------------------------------------------------------
This SF.net email is sponsored by: SlickEdit Inc. Develop an edge.
The most comprehensive and flexible code editor you can use.
Code faster. C/C++, C#, Java, HTML, XML, many more. FREE 30-Day Trial.
www.slickedit.com/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
