From: Jesse Colmenares <jcolmenares@cantv.net>
Subject: NFS servers and ACCESS procedure
Date: Tue, 05 Aug 2003 17:13:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F301DF5.4000002@cantv.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from panoramix.vasoftware.com
	([198.186.202.147] helo=externalmx.vasoftware.com ident=mail)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19k9dY-0005tp-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 14:46:32 -0700
Received: from rs25s12.datacenter.cha.cantv.net ([200.44.33.13]:41154)
	by externalmx.vasoftware.com with esmtp (Exim 4.20 #1 (Debian))
	id 19k9D1-0001Ut-9n
	for <nfs@lists.sourceforge.net>; Tue, 05 Aug 2003 14:19:07 -0700
Received: from cantv.net (ws-51.chacao-01.int.cantv.net [200.44.44.67])
	by rs25s12.datacenter.cha.cantv.net (8.12.9/8.12.6/3.0) with ESMTP id h75LHJs5003093
	for <nfs@lists.sourceforge.net.>; Tue, 5 Aug 2003 17:17:19 -0400
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

Hello.

   
    I have  about 15(fifteen) Red Hat Linux 7.3 (kernel 2.4.18) Servers 
working as NFS clients against a  NetApp 840 Server running as NFS 
Server, the statistics of our server show about 60% of operations from 
the ACCESS procedure of NFS protocol.

    We are not concern about security because the aplications that 
access the network NFS server are running with only one user(root), so 
permission checking over the files is no necessary. We are using 
actually NFS version 3.

    The question is: There are a way no disable the ACCESS cheching on 
NFS version 3 clients o servers?

Thanks!!!



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
