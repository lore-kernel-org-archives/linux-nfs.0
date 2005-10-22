From: Jun Zhang <nugulus@yahoo.com>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sat, 22 Oct 2005 08:52:10 -0700 (PDT)
Message-ID: <20051022155210.76957.qmail@web52402.mail.yahoo.com>
References: <435A456D.8080601@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETLfN-0004dv-3K
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 08:52:17 -0700
Received: from web52402.mail.yahoo.com ([206.190.48.165])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ETLfM-00028C-Tn
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 08:52:17 -0700
To: Steve Dickson <steved@redhat.com>
In-Reply-To: <435A456D.8080601@redhat.com>
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

Steve,
   The problem is that I don't what is trying to be
mounted, from what server. All automount map listed
directories are also accessible. As of this writing,
three 'df -k' processes are still running, and refuse
to be killed.
   I've never used ethereal, and it seems not
available on this redhat 7.1. I'll download and try
that.

Jun Zhang

--- Steve Dickson <steved@redhat.com> wrote:

> Jun Zhang wrote:
>=20
> > =20
> > Many a time when I type df -k, the prompt will not
> come back. Went to=20
> > another session, I found the df process is not
> killable. I then=20
> > checked each piece in /etc/fstab, each piece is
> fine (mounted and=20
> > accessible).
> > Can somebosy give a clue?
>=20
> Is autofs in the picture? which kernel and nfs-utils
> versions are you=20
> running also
> who is the server? Is there any errors being logged
> on either the client=20
> or server?
> Finally, a ethereal trace (i.e. tethereal -w
> /tmp/data.cap host=20
> <server>) at the
> time of the hang might also help...
>=20
> steved.
>=20
>=20



	=09
__________________________________=20
Yahoo! FareChase: Search multiple travel sites in one click.
http://farechase.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
