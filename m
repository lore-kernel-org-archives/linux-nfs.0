From: "Cooke, Alan" <acooke@hp.com>
Subject: RE: RedHat 7.3 crashed NetApp?
Date: Fri, 17 May 2002 08:14:37 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <C0B72BFE4E6CFF4C97FDB17BED66E84A085DB7@cceexc15.americas.cpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ztxmail04.ztx.compaq.com ([161.114.1.208])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 178hZM-0000Pq-00
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 06:14:52 -0700
Received: from cceexg11.americas.cpqcorp.net (cceexg11.americas.cpqcorp.net [16.110.250.125])
	by ztxmail04.ztx.compaq.com (Postfix) with ESMTP id BE3B11C56
	for <nfs@lists.sourceforge.net>; Fri, 17 May 2002 08:14:39 -0500 (CDT)
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

While running the 2.4.18-4smp kernel (RedHat), and testing NFS3, our =
NetApp filer running OnTap 6.1.1R2 experienced massive incoming traffic =
from the Linux client in question. The Linux client required rebooting. =
We have been able to repeat this behavior, and are suspicious of the =
network driver on the Linux client which is using the eth0 driver. A

Sound familiar?

Alan Cooke
Hewlett-Packard Company
ISS/EDA
Office: 281-518-9775
Fax    : 281-518-8015
Email  : acooke@hp.com

"If everything seems under control, you're just not going fast enough."
-- Mario Andretti








-----Original Message-----
From: H . J . Lu [mailto:hjl@lucon.org]
Sent: Thursday, May 16, 2002 5:39 PM
To: nfs@lists.sourceforge.net
Subject: [NFS] RedHat 7.3 crashed NetApp?


Has anyone seen

http://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D65069


H.J.

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We =
supply
the hardware. You get the recognition. Email Us: =
bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
