From: "Mikkelborg, Kjetil" <kjetil.mikkelborg@kongsberg.com>
Subject: NFS directory caching
Date: Tue, 24 Jun 2003 11:06:02 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <75587E33AC778145AACCE1601EEABF420D496F@kda-beexc-02.kda.kongsberg.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [193.71.180.106] (helo=Kda-mailgw-01.KONGSBERG.COM)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19UjiO-0006Mu-00
	for <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 02:03:48 -0700
Received: from kda-beexc-06.kda.kongsberg.com (unverified) by
    Kda-mailgw-01.KONGSBERG.COM (Content Technologies SMTPRS 4.3.6) with
    ESMTP id <T6305e6992bc147b46a994@Kda-mailgw-01.KONGSBERG.COM> for
    <nfs@lists.sourceforge.net>; Tue, 24 Jun 2003 11:06:00 +0200
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

How is it with directory caching in standard nfs client for linux? Is it
existent at all? And if so, is there any way I can modify its timeout
values for spesific mountpoint? The reason I want to do this is since i
have several /tools and alike mountpoints wich regular users often has
references to in their PATH's, and these mountpoint seldom has any
changes to them, since it is mainly just a public way to reach common
tools for our developers.

It would be nice to eliminate the issue with extensive NFS directories
in path problem, without altering the existing PATH setting, since for
managment reasons it is much more easier to have most of the common
tools on a NFS volume than installed on each workstation.

Kjetil Mikkelborg


**********************************************************************
This email and any files transmitted with it are confidential and
intended solely for the use of the individual or entity to whom they
are addressed. If you have received this email in error please notify
the system manager.

This footnote also confirms that this email message has been swept by
MAILsweeper for the presence of computer viruses.

Best regards,
Kongsberg Gruppen
**********************************************************************



-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
