From: pou64 <pou64@ig.com.br>
Subject: on Linux: strange behavior of cliente nfs with soft option
Date: Thu, 27 Jan 2005 12:22:44 -0200
Message-ID: <20050127_142244_030940.pou64@ig.com.br>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="Message-Boundary-by-Mail-Sender-1106835764"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CuAXx-0002Oe-05
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 06:22:57 -0800
Received: from smtp-30.ig.com.br ([200.226.132.30])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CuAXv-0008Jq-2L
	for nfs@lists.sourceforge.net; Thu, 27 Jan 2005 06:22:57 -0800
Received: from 121.131.226.200.in-addr.arpa.ig.com.br (HELO localhost.localdomain) ([200.226.131.121])
          (envelope-sender <pou64@ig.com.br>)
          by email-30.ig.com.br (qmail-ldap-1.03) with SMTP
          for <nfs@lists.sourceforge.net>; 27 Jan 2005 14:22:44 -0000
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

--Message-Boundary-by-Mail-Sender-1106835764
Content-type: text/plain; charset=ISO-8859-1
Content-description: Mail message body
Content-disposition: inline
Content-Transfer-Encoding: quoted-printable

I have the following entry in fstab file=20
nfsserver:/usr/exec /usr/exec_test nfs soft,bg,noac,timeo=3D2,retrans=3D2=
 0 0=20

I need the cliente asnwer a I/O error message in, at most,=20
10 seconds, because i would try by another net.=20
If I take off the ethernet cable and try to acess the filesystem, the=20
first time it answer in 2-5 seconds (OK). But at the second=20
(third, ...) time it answer in 60 seconds.=20

Can someone help me?=20

--Message-Boundary-by-Mail-Sender-1106835764--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
