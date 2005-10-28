From: email builder <emailbuilder88@yahoo.com>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 14:58:07 -0700 (PDT)
Message-ID: <20051028215807.77283.qmail@web51915.mail.yahoo.com>
References: <17249.40023.950260.948987@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVcEp-0001VH-7h
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 14:58:15 -0700
Received: from web51915.mail.yahoo.com ([206.190.48.78])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EVcEo-0002cw-2u
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 14:58:15 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <17249.40023.950260.948987@cse.unsw.edu.au>
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

> were
> > able to buy some time by moving our (ext3) journal off of the same
> device,
> > fiddle with a couple NFS settings (nodiratime,noatime), but it is sti=
ll
> > woefully slow.
>=20
> mounting the ext3 partition with 'data=3Djournal' can help NFS service,
> especially with the journal on a separate device.

OK, we must have missed this one in the noise.  I just added it to the mo=
unt
where all the NFS server's exports are (ext3 defaults,data=3Djournal).  E=
ven
rebooted, but don't see evidence that it took (cat /proc/mounts just show=
s
ext3 rw but nothing about the journaling mode, should it?).  Where can I
verify what mode it is in?

The other thing that came as a strong recommendation to us was to put
"no_acl" on all of our NFS exports, but on our Fedora system (with up to =
date
nfs-utils), "no_acl" is treated as an unrecognized keyword.  Is there any
support for no_acl under redhat at all???


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
