From: Robert Rati <Robert.Rati@motorola.com>
Subject: rpc.mountd ports
Date: Wed, 12 Feb 2003 17:29:23 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E4AD8D3.3080603@motorola.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ftpbox.mot.com ([129.188.136.101])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18j6Ji-0002PI-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Feb 2003 15:29:26 -0800
Received: from pobox3.mot.com (pobox3.mot.com [10.64.251.242])
	by ftpbox.mot.com (Motorola/Ftpbox) with ESMTP id h1CNTOMj011826
	for <nfs@lists.sourceforge.net>; Wed, 12 Feb 2003 16:29:25 -0700 (MST)
Received: [from il02exm02.corp.mot.com (il02exm02.corp.mot.com [10.0.100.55]) by pobox3.mot.com (MOT-pobox3 2.0) with ESMTP id QAA20379 for <nfs@lists.sourceforge.net>; Wed, 12 Feb 2003 16:28:03 -0700 (MST)]
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

When I start rpc.mountd, I notice that it always registers 4 ports with 
portmapper.  2 TCP and 2 UDP, which corespond to two separate instances 
of mountd.  When I run exportfs, I see that no file systems are being 
exported.  If I export a file system, the only difference is exportfs 
shows a file system being exported.  This will obviously cause a problem 
if I try to specify a port for rpc.mountd to run on as both instances of 
mountd try to use the same port and the tcp bind for the second instance 
fails.  Why does rpc.mountd start two instances of mountd?

This issue comes from trying to allow an NFS export through a firewall. 
  Since mountd uses a different port each time it starts, it's nearly 
impossible to pass it through a firewall.  Does anyone have an alternate 
solution to this problem besides telling rpc.mountd to run on a 
specified port (as that isn't working as detailed above).  I'm stuck 
using kernel 2.2.17, so I've been unable to check out the nfs-utils 
ability to handle specifying a port for mountd.  TIA.

Rob



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
