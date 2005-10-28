From: email builder <emailbuilder88@yahoo.com>
Subject: OT: RAID perf doldrums: advice/recommendations?
Date: Thu, 27 Oct 2005 20:21:49 -0700 (PDT)
Message-ID: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVKoW-0005Dy-2j
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 20:21:56 -0700
Received: from web51905.mail.yahoo.com ([206.190.48.68])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1EVKoV-0003ch-MB
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 20:21:56 -0700
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

Hello,

  Recently we turned on a RAID-backed NFS server that fell flat on its fa=
ce
as soon as it started to see even moderate activity (particularly IMAP
traffic from Courier-IMAP).  Through help on the Courier mailing list, th=
e
problem appears to be very poor throughput to our hard drives (although
systems is not my strong point, so I hope there is not something else I'v=
e
overlooked).

  Our choice to go with consumer-grade hardware seems to have bit us hard=
.=20
We are using the oft-maligned 3Ware 85xx series RAID5 controller and thre=
e
Hitachi Deskstar 7k250 (250GB) SATA drives.  The NFS serves up the mailst=
ore
for a system that does about 60 mail messages/min, plus IMAP against the
mailstore (which is what brings the hurt), and some moderately (much more
than Joe Bob's homepage, but not Slashdot) trafficed web content.  We wer=
e
able to buy some time by moving our (ext3) journal off of the same device=
,
fiddle with a couple NFS settings (nodiratime,noatime), but it is still
woefully slow.

  Are we completely wrong to give up on this hardware?  If anyone is
interested in giving advice in that realm, I am happy to provide more sta=
ts
(like the fact that the machine sits at near 100% iowait all day long).

  But instead of sticking it out with that hardware, we are thinking abou=
t a
couple possibilities, but a look around Google just found too many "shopp=
ing"
sites, and not enough real information and comparisons.  We are wanting
advice for proven performers: RAID controller cards and drives.  We had b=
een
hoping not to have to pay the hefty costs that SCSI incurrs, but at this
point we are considering the possibility, so advice on both sides of the
fence is sought.

  We are also quite curious about just running with software raid instead=
,
since there seems to be a growing movement that claims there is no reason=
 it
cannot be as (or more) reliable and fast -- especially compared to the pi=
ece
of $@^!% that we apparently got.  :)

Thoguhts and links highly appreciated!




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
