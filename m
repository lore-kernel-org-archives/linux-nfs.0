From: Justin <listuser@numbnuts.net>
Subject: Re: NFS, Berkley mailboxes, locking, and corruption
Date: Sun, 1 Feb 2004 22:30:02 -0600 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402012224190.23263-100000@poplar.sktc.net>
References: <34505.80.213.3.64.1075671331.squirrel@webmail.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AnVip-0005it-N4
	for nfs@lists.sourceforge.net; Sun, 01 Feb 2004 20:30:07 -0800
Received: from poplar.sktc.net ([64.71.97.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AnVip-0006I9-3U
	for nfs@lists.sourceforge.net; Sun, 01 Feb 2004 20:30:07 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <34505.80.213.3.64.1075671331.squirrel@webmail.uio.no>
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

On Sun, 1 Feb 2004 trond.myklebust@fys.uio.no wrote:

> P=E5 su , 01/02/2004 klokka 04:23, skreiv Justin:
> > At this point and time it looks like NFS is what they planned on usin=
g
> > when they came up with this design.  I know it will "appear" to work.
> > I also know that it will silently lose mail.  Making all involved
> > understand this very important fact is important and possibly
> > difficult.  The mail system currently handles 30-50k pieces of mail a
> > day, not counting spam.   This is busy enough to lose a lot of mail.
> >
> > How badly will NFS and this type of setup lose mail or corrupt mail
> > spools?  We can't afford to risk the integity of our mail system,
> > period.   What other solutions might there be if NFS isn't a viable
> > solution?  How do larger institutions handle grand amounts of mail?
> > SAN?  Many thanks
>=20
> Are you *sure* that you are using POSIX (a.k.a. byte range, a.k.a.
> lockf(), a.k.a. fcntl(), a.k.a "NOT BSD or flock()") style locks?
>=20
> 'cos that's all that's guaranteed to work...

Many thanks for the reply, Trond.  To be honest I'm not really sure what=20
typing of locking mechanisms were in use when I experienced the=20
spool corruptions.  I experienced it twice with one RH 6.2 setup between=20
to x86 boxes.  Procmail, pine, and ipop3d were in use at that time.  I=20
experienced it again with a RH 7.2 and 7.3 combo of x86 boxes, again=20
running Procmail, pine, ipop3d, and Neomail.  I experienced it after that=
=20
with the same boxes but with qpopper instead of ipop3d.  I believe either=
=20
NFSv1 or NFSv2 were used on the 6.2 boxes.  I know NFSv3 over TCP was use=
d=20
on the 7.2 & 7.3 boxes.  Does that give you any ideas what locking=20
mechanisms were in use?  Our new setup will involve Procmail, pine,=20
qpopper, and UW-IMAP.  It might involve Cyrus in the end.

Thanks again
 Justin



-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
