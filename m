From: Jun Zhang <nugulus@yahoo.com>
Subject: Re: How to find what to make "df -jk" hang (redhat)
Date: Sun, 23 Oct 2005 17:27:16 -0700 (PDT)
Message-ID: <20051024002717.14233.qmail@web52402.mail.yahoo.com>
References: <Pine.LNX.4.63.0510231205130.19701@donald.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Steve Dickson <steved@redhat.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ETqBV-00077g-Ln
	for nfs@lists.sourceforge.net; Sun, 23 Oct 2005 17:27:29 -0700
Received: from web52402.mail.yahoo.com ([206.190.48.165])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1ETqBU-0001Kj-5G
	for nfs@lists.sourceforge.net; Sun, 23 Oct 2005 17:27:29 -0700
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.63.0510231205130.19701@donald.themaw.net>
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

automount version 3.1.7
linux kernel version 2.4.2-2

The content of /etc/auto.master,
/home   /etc/auto.home  -nobrowse,intr
/vol    /etc/auto.vol   -nobrowse,intr
/data   /etc/auto.data -nobrowse,intr
/biostat        /etc/auto.biostat -nobrowse,intr
/usr/local/tps  /etc/auto.tps -nobrowse,intr
/apps   /etc/auto.apps -nobrowse,intr

I tried to access each one of them, at least for one
key, no problem. I'll try to get some log and post it
next time.

Jun Zhang

--- Ian Kent <raven@themaw.net> wrote:

> On Sat, 22 Oct 2005, Jun Zhang wrote:
>=20
> > Steve,
> >    The problem is that I don't what is trying to
> be
> > mounted, from what server. All automount map
> listed
> > directories are also accessible. As of this
> writing,
> > three 'df -k' processes are still running, and
> refuse
> > to be killed.
>=20
> So you are using autofs.
>=20
> That's a different story altogether.
> If autofs is hanging on trying to mount something
> you should see the mount=20
> command it has issued in a ps listing. You might be
> able to see the=20
> mountpoint directory there.
>=20
> Care to tell the version of autofs?
> The kernel version?
> What are your maps?
>=20
> Maybe get a debug log of autofs by using the -d
> option added to your=20
> master map entries? Don't forget to ensure that
> syslog priority debug is=20
> being logged. Use man syslog.conf to check this.
>=20
> You probably should be asking this on the autofs
> list.
> http://linux.kernel.org/mailman/listinfo/autofs
>=20
> Ian
>=20
>=20
>=20
>
-------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.
> Get Certified Today * Register for a JBoss Training
> Course
> Free Certification Exam for All Training Attendees
> Through End of 2005
> Visit http://www.jboss.com/services/certification
> for more information
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
