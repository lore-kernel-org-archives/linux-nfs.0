From: Paul Jimenez <pj@place.org>
Subject: directory depth limit?
Date: Thu, 07 Aug 2003 15:56:33 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030807205633.DC0861833A@zachs.place.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from place.org
	([65.163.18.18] helo=zachs.place.org ident=postfix)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19kroI-00059h-00
	for <nfs@lists.sourceforge.net>; Thu, 07 Aug 2003 13:56:35 -0700
Received: from place.org (localhost [127.0.0.1])
	by zachs.place.org (Postfix) with ESMTP id DC0861833A
	for <nfs@lists.sourceforge.net>; Thu,  7 Aug 2003 15:56:33 -0500 (CDT)
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

  I'm using kernel 2.4.20 under debian stable ('woody') and the
user-land nfs server, and I can't seem to traverse more than about 23 or
24 levels deep into a directory structure over NFS.  Works fine on a local
ext2 or ext3 fs, but not when that fs is exported via the abovementioned
userland server.  And it's definitely related to directory depth and
not PATHLEN because it fails even with single-char directory names for
the entire depth.  So is this limit on the client, the server, or in the
protocol?  And is it a bug or just a design limit?

Thanks for your help,

  --pj




-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
