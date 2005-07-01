From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: SuSE 9 sp1 GA : Busy mounts.
Date: Fri, 1 Jul 2005 03:44:15 -0700 (PDT)
Message-ID: <20050701104415.91141.qmail@web51601.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DoJ0R-0001Ne-GO
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 03:44:23 -0700
Received: from web51601.mail.yahoo.com ([206.190.38.206])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1DoJ0P-0008Q5-L6
	for nfs@lists.sourceforge.net; Fri, 01 Jul 2005 03:44:23 -0700
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
      I exported a filesystem.
      Client took lock on a file.
      Then i stopped all nfs daemons
      including lockd .I have also=20
      unexported all filesystem. but
      still filesystems cannot be
      unmounted.It gives "device busy" error
     =20
      vcslinux4:~ # uname -a
      Linux vcslinux4 2.6.5-7.139-smp #1 SMP Fri Jan=20
      14 15:41:33 UTC 2005 i686 i686 i3
      86 GNU/Linux
    =20
      This is rarely reproducible.
      Please let me nkow if this is a known issue.

thanks,
 kiran
     =20
     =20


	=09
__________________________________=20
Do you Yahoo!?=20
Read only the mail you want - Yahoo! Mail SpamGuard.=20
http://promotions.yahoo.com/new_mail=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
