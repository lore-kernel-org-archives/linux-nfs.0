From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: nfs root directory security
Date: Wed, 18 Jun 2003 10:34:20 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <31B1521BD986E84E9D43651F8DF99BDC0134B417@POEXMB1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "Neil Brown" <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman1.ppco.com ([138.32.33.10])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Sf4m-0007CY-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 08:42:20 -0700
To: "Scott Leerssen" <scott@leerssen.com>,
   "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
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



And Scott, you have the DHCP table, write a simple script
to take the info from the DHCP table and generate a proper
exports file based on that info.=20

You aren't doing two separate sets of the same information
separately?   We usually have a original set of files with info
in them (be that our own format, or the DHCP entries, or something
else), and then have scripts to generate the system files,
that would be used from that info, such as the DHCP and exports
entries, so the correct information is only in one place and=20
all others are derivitavies of that original source, this also reduces
mistakes where you are manually adjusting the several sources
and fail to keep everything consistant.

				Roger


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
