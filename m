From: "naveen a" <naveen2005@india.com>
Subject: Help needed in understanding port allocation in NFS
Date: Wed, 16 Feb 2005 18:25:47 +0800
Message-ID: <20050216102547.A248323CFA@ws5-3.us4.outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1MNX-0006kd-Cr
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 02:25:55 -0800
Received: from webmail-outgoing.us4.outblaze.com ([205.158.62.67])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D1MNV-0006Yc-Pi
	for nfs@lists.sourceforge.net; Wed, 16 Feb 2005 02:25:55 -0800
Received: from wfilter.us4.outblaze.com (wfilter.us4.outblaze.com [205.158.62.180])
	by webmail-outgoing.us4.outblaze.com (Postfix) with QMQP id 4FEBF18001A1
	for <nfs@lists.sourceforge.net>; Wed, 16 Feb 2005 10:25:48 +0000 (GMT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Hi,

I wanted some info related to port selection in NFS.

What happens when the port number is not specified in the command line swit=
ch or configuration=20

file for mountd and statd?

In man pages it is mentioned as statd/mountd will select the port from port=
mapper.=20

Can you please let me know how a port is allotted and the code path in sour=
ce.

What is the criteria for allocation of ports by portmapper ?

Please educate me on this.

Thanks
Naveen
--=20
India.com free e-mail - www.india.com.=20
Check out our value-added Premium features, such as an extra 20MB for mail =
storage, POP3, e-mail forwarding, and ads-free mailboxes!

Powered by Outblaze


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
