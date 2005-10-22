From: Jun Zhang <nugulus@yahoo.com>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sat, 22 Oct 2005 08:45:28 -0700 (PDT)
Message-ID: <20051022154528.24385.qmail@web52411.mail.yahoo.com>
References: <Pine.LNX.4.63.0510221218370.2552@donald.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETLYt-0004IW-IY
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 08:45:35 -0700
Received: from web52411.mail.yahoo.com ([206.190.48.174])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ETLYs-0007P1-77
	for nfs@lists.sourceforge.net; Sat, 22 Oct 2005 08:45:35 -0700
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.63.0510221218370.2552@donald.themaw.net>
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

Ian,
   What do I look for? Those two file have quite the
same contents. Ain't what listed there are mounted
items?

Jun Zhang

--- Ian Kent <raven@themaw.net> wrote:

> On Fri, 21 Oct 2005, Jun Zhang wrote:
>=20
> > =20
> > Many a time when I type df -k, the prompt will not
> come back. Went to another session, I found the df
> process is not killable. I then checked each piece
> in /etc/fstab, each piece is fine (mounted and
> accessible).
> > Can somebosy give a clue?
>=20
> Not fstab.
>=20
> Try working out what is blocked by looking at
> /etc/mtab or /proc/mounts.
>=20
> Ian
>=20
>=20
>=20
>
-------------------------------------------------------
> This SF.Net email is sponsored by:
> Power Architecture Resource Center: Free content,
> downloads, discussions,
> and more.
> http://solutions.newsforge.com/ibmarch.tmpl
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20



=09
	=09
__________________________________=20
Yahoo! Mail - PC Magazine Editors' Choice 2005=20
http://mail.yahoo.com


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
