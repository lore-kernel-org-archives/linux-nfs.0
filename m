From: Steve Gonzales <gonzo@eng.lsu.edu>
Subject: It works, but it doesn't
Date: Thu, 07 Aug 2003 09:32:26 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1060266746.32702.13.camel@engw0002.eng.lsu.edu>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from engrsrv8.eng.lsu.edu ([130.39.27.4] helo=engmail01.eng.lsu.edu)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19klpo-00022n-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 07:33:44 -0700
Received: from engw0002.eng.lsu.edu (engw0002.eng.lsu.edu [130.39.28.2])
	by engmail01.eng.lsu.edu (8.12.10.Beta2/8.12.10.Beta2) with ESMTP id h77ETbgN011960
	for <nfs@lists.sourceforge.net>; Thu, 7 Aug 2003 09:29:37 -0500
To: NFS List <nfs@lists.sourceforge.net>
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

Hello all.

Situation:
One NFS server
One NFS mount client
One NFS installation client (for RedHat 9)

IPAddr1 = IP Address of Server
IPAddr2 = IP Address of NFS mount client
IPAddr3 = IP Address of NFS installation client

------------------------------------------------------

Server /etc/exports:
/install/RedHat/9	<IPAddr2>(ro,no_root_squash)
/install/RedHat/9	<IPAddr3>(ro,no_root_squash)

When I manually mount from <IPAddr2>, it works.

However, when I attempt to do an NFS installation of RedHat 9 to
<IPAddr3>, it fails.

IPAddr3 Error Message:
That directory could not be mounted from the server.

IPAddr1 /var/log/messages entry:
Aug 7 09:23:56: <servername> rpc.mountd: refused mount request from
<FQDN for IPAddr3> for /install/RedHat/9 (/): no export entry.

------------------------------------------------------

I hope it's not too confusing.  Any help would be greatly appreciated as
this is study for the big RHCE test.

Thanks.
Steve



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
