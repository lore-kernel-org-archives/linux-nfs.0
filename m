From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: statd for NFSv4 does not create file
Date: Thu, 14 Jul 2005 05:55:36 -0700 (PDT)
Message-ID: <20050714125536.788.qmail@web51609.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: steved@redhat.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dt3Fr-0006Q1-Ui
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 05:55:55 -0700
Received: from web51609.mail.yahoo.com ([206.190.38.214])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.44)
	id 1Dt3Fq-0001ZV-OO
	for nfs@lists.sourceforge.net; Thu, 14 Jul 2005 05:55:56 -0700
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
        I have observed the following.
        RHEL4 GA and U1=20
        client accesses filesystem exported
        by server using nfsv4 .

        It takes lock  on a file.
        Other clients on "different" systems
        get NFSERR_DENIED and they retry to acquire
        lock.

        When first client release lock , other client
        gets the lock.
        But when i see in /var/lib/nfs/statd/sm=20
        directory , i cannot see any file with
        name =3D server's name.
      =20
        Has anybody observed this.

thanks,
 kiran

=20
       =20


	=09
__________________________________=20
Yahoo! Mail=20
Stay connected, organized, and protected. Take the tour:=20
http://tour.mail.yahoo.com/mailtour.html=20



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happen=
ing
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by H=
P,=20
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
