From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: time after which statd gives up
Date: Tue, 5 Jul 2005 04:50:35 -0700 (PDT)
Message-ID: <20050705115035.78035.qmail@web51608.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dplwq-000114-1m
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 04:50:44 -0700
Received: from web51608.mail.yahoo.com ([206.190.38.213])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1Dplwn-00024i-Hx
	for nfs@lists.sourceforge.net; Tue, 05 Jul 2005 04:50:43 -0700
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

Hi ,=20
      On RHEL4 U1 i have observed that statd
      sends notification only till the=20
      max(if cannot notify) time 30 seconds.
      Then statd gives
      up and no files are there in sm.bak.

      Is this the expected behavior ?
      Should statd try notifying indefinitely ?
      If this is the behavior , what is use of sm.bak
      dir ?

thanks,
 kiran
     =20
=20

    =20
    =20


	=09
__________________________________=20
Yahoo! Mail=20
Stay connected, organized, and protected. Take the tour:=20
http://tour.mail.yahoo.com/mailtour.html=20



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
