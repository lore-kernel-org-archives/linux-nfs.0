From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: Kernel panic :  Redhat 4 GA nfs client
Date: Tue, 14 Jun 2005 23:10:52 -0700 (PDT)
Message-ID: <20050615061052.83674.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiR76-0001No-CR
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 23:11:00 -0700
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1DiR74-0007iw-Si
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 23:11:00 -0700
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
    I get following error messages on nfs client=20
    side when RHEL4 U1 nfs server talks to nfs=20
    client RHEL4 GA.This is reproducible (though=20
    not easily.Exact situation not known)
   =20
    nfs ""server"" machine  =20
    #uname -a
    Linux vcslinux118.vxindia.veritas.com 2.6.9-
   6.37.ELsmp #1 SMP Tue Mar 29 15:46:31 EST 2005=20
   x86_64 x86_64 x86_64 GNU/Linux

   nfs_mon_unmon : rpc failed , status =3D -13
   lockd : cannot monitor  10.212.98.131
   lockd : failed to monitor 10.212.98.131

    kernel panic -- not syncing
    Attempting to free lock with active block list

thanks,
 kiran




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
