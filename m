From: "Kashyap Ashwin (Princeton Intern)" <Ashwin.Kashyap@thomson.net>
Subject: Cross compiling nfs-utils
Date: Thu, 14 Aug 2003 16:16:55 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <8FC831532CEE564AB88AC1D999C29DEB03B080@prinsmail01.am.thmulti.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from dmzraw2.extranet.tce.com ([157.254.234.138])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19nPT6-0006YV-00
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 14:17:12 -0700
Received: from smtprelay2.indy.tce.com ([157.254.96.95])
	by dmzraw2.extranet.tce.com (8.12.5/8.12.5) with ESMTP id h7ELH64h027249
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 21:17:06 GMT
Received: from indymsxcs02.indy.tce.com (localhost [127.0.0.1])
	by smtprelay2.indy.tce.com (8.12.9/8.12.8) with ESMTP id h7ELGwHp017727
	for <nfs@lists.sourceforge.net>; Thu, 14 Aug 2003 21:16:59 GMT
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

Hi,
I downloaded the nfs-utils tar ball and I need to cross compile it for an
embedded platform. 

1. I exported the proper CC, LD etc to the shell and did a ./configure
2. did make
3. fails because rpcgen is also built for the embedded platform. i fixed
this by copying the correct rpcgen
4. did make again: i get nfsctl.c: undefined reference to syscall

I am using the hitachi sh4 processor and uClibc. Please help!

Thanks,
Ashwin



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
