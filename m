From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 09:52:13 +0100
Message-ID: <4361E6BD.2060701@stams.strath.ac.uk>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVPz5-0000cH-E3
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 01:53:11 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1EVPz4-0004Z1-6T
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 01:53:11 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:39414)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1EVPy9-0003oY-RC
	for <nfs@lists.sourceforge.net>; Fri, 28 Oct 2005 08:52:13 +0000
To: email builder <emailbuilder88@yahoo.com>
In-Reply-To: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
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

email builder wrote:
> Hello,
> 
>   Recently we turned on a RAID-backed NFS server that fell flat on its face
> as soon as it started to see even moderate activity (particularly IMAP
> traffic from Courier-IMAP).  Through help on the Courier mailing list, the
> problem appears to be very poor throughput to our hard drives (although
> systems is not my strong point, so I hope there is not something else I've
> overlooked).
> 
>   Our choice to go with consumer-grade hardware seems to have bit us hard. 
> We are using the oft-maligned 3Ware 85xx series RAID5 controller and three
> Hitachi Deskstar 7k250 (250GB) SATA drives.  The NFS serves up the mailstore
> for a system that does about 60 mail messages/min, plus IMAP against the
> mailstore (which is what brings the hurt), and some moderately (much more
> than Joe Bob's homepage, but not Slashdot) trafficed web content.  We were
> able to buy some time by moving our (ext3) journal off of the same device,
> fiddle with a couple NFS settings (nodiratime,noatime), but it is still
> woefully slow.
> 
>   Are we completely wrong to give up on this hardware?  If anyone is
> interested in giving advice in that realm, I am happy to provide more stats
> (like the fact that the machine sits at near 100% iowait all day long).


Hi

We noticed similar issues which we never tracked down, even after help 
from this list.  There is a huge bug report at Redhat entitled:

"Extremely high iowait with 3Ware array and moderate disk activity"

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=121434

which may be of some help, but it never quite gets to the bottom
of things.  3ware cards/drivers seem to the common factor in most if
not all of the "me too's", but of course everyone with a 3ware problem 
would find this bug report...

Cheers

Ian
-- 
Ian Thurlbeck                http://www.stams.strath.ac.uk/
Statistics and Modelling Science, University of Strathclyde
Livingstone Tower, 26 Richmond Street, Glasgow, UK,  G1 1XH
Tel: +44 (0)141 548 3667           Fax: +44 (0)141 552 2079


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
