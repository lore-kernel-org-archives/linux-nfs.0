From: "Eno Compton" <Eno.Compton@Miltope.com>
Subject: nfs server tcp support
Date: Thu, 9 Oct 2003 13:38:47 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BB842FD5FFDA7A469ECF70CCF82B77E30255DC@boulder-mail.miltope.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A7gca-0003yw-00
	for <nfs@lists.sourceforge.net>; Thu, 09 Oct 2003 12:38:48 -0700
Received: from [12.41.168.50] (helo=[12.41.168.50])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1A7gcZ-0008Vh-Ua
	for nfs@lists.sourceforge.net; Thu, 09 Oct 2003 12:38:47 -0700
To: <nfs@lists.sourceforge.net>
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

The NFS project home page states, "The 2.4.19 kernel integrates server =
support for NFS over TCP", which makes me think nfs server support for =
tcp is present.

But the Linux NFS-HOWTO states, "A new feature, available for both 2.4 =
and 2.5 kernels but not yet integrated into the mainstream kernel at the =
time of this writing, is NFS over TCP", which makes me think nfs server =
support for tcp is absent.

make xconfig on kernel 2.4.21 has an option for, "Provide NFS Server =
over TCP support" grayed out, which confuses me.

I'm trying to get NFS server support going in RH 9 which uses kernel =
2.4.20 and striking out every way I turn.

Would anybody care to advise how I should proceed, please?

Eno Compton


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
