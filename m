From: email builder <emailbuilder88@yahoo.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 15:09:38 -0700 (PDT)
Message-ID: <20051028220938.76022.qmail@web51901.mail.yahoo.com>
References: <4361E6BD.2060701@stams.strath.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVcPz-0002DC-1S
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 15:09:47 -0700
Received: from web51901.mail.yahoo.com ([206.190.48.64])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EVcPx-0005Jq-JK
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 15:09:46 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <4361E6BD.2060701@stams.strath.ac.uk>
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

> We noticed similar issues which we never tracked down, even after help=20
> from this list.  There is a huge bug report at Redhat entitled:
>=20
> "Extremely high iowait with 3Ware array and moderate disk activity"
>=20
> https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=3D121434
>=20
> which may be of some help, but it never quite gets to the bottom
> of things.  3ware cards/drivers seem to the common factor in most if

Yes, we've combed this thread, much to our shagrin, none of the tips work=
ed
for us.  I suppose I should have said that one of our other possibilities=
 is
to go with FreeBSD to see if this issue is the source of the problem.  Wh=
at
can you say after reading this thread that's been open for WELL over a ye=
ar?=20
RedHat loses a lot of points on this one.

> not all of the "me too's", but of course everyone with a 3ware problem=20
> would find this bug report...




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
