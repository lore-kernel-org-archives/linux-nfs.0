From: "Dennis, Richard" <Richard.Dennis@lehman.com>
Subject: NFS Debugging Tools
Date: Mon, 21 Jul 2003 13:43:46 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0073ECCF4F99D611810B0002A58F26560EB316DF@exnyc03.lehman.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail-ny2.bigfish.com ([63.161.60.93] helo=mail6-ny2-R.bigfish.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19eei5-0007tw-00
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 10:44:29 -0700
Received: from mail6-ny2.bigfish.com (localhost.localdomain [127.0.0.1])
	by mail6-ny2-R.bigfish.com (Postfix) with ESMTP id 8D47614A6F8
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 17:44:23 +0000 (UCT)
Received: from extrelay2.lehman.com (extrelay2.Lehman.COM [192.147.58.145])
	by mail6-ny2.bigfish.com (Postfix) with ESMTP id D36FF14A793
	for <nfs@lists.sourceforge.net>; Mon, 21 Jul 2003 17:44:00 +0000 (UCT)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

Does anyone know of some other helpful tools for debugging NFS on Linux?
(Things like "nfswatch" or "iostat -xPn" on Solaris.)

This is what I have so far:
	- Nfsstat
	- tcpdump, ethereal, 
	- ntop
	- /proc/sys/sunrpc/*

Thanks.

--Rick

------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the
designated recipient(s) named above.  If you are not the intended recipient of
this message you are hereby notified that any review, dissemination,
distribution or copying of this message is strictly prohibited.  This
communication is for information purposes only and should not be regarded as
an offer to sell or as a solicitation of an offer to buy any financial
product, an official confirmation of any transaction, or as an official
statement of Lehman Brothers.  Email transmission cannot be guaranteed to be
secure or error-free.  Therefore, we do not represent that this information is
complete or accurate and it should not be relied upon as such.  All
information is subject to change without notice.



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100006ave/direct;at.asp_061203_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
