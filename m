From: "Chris Croswhite" <csc@cadence.com>
Subject: Issues with nfs solaris server
Date: Wed, 18 Jun 2003 18:23:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <EE335453C5C57840823404C684F9F617012D6849@exmbx01sj.Cadence.COM>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailgate.cadence.com ([158.140.2.1])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19So9P-0003PO-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 18:23:43 -0700
Received: from exmbx01sj.global.cadence.com (exmbx01sj.Cadence.COM [158.140.128.146])
	by mailgate.Cadence.COM (8.9.3/8.9.3) with ESMTP id SAA27713
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 18:23:41 -0700 (PDT)
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

Guys,

We are seeing issues with solaris nfs servers.  Every once in a while, =
mount points die and are not recoverable (except to reboot).  nfsutils =
1.0.3 kernel 2.4.19.  I had heard someone mention that it might be a =
spinlock within the kernel.

Does anyone have any information/

TIA!


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
