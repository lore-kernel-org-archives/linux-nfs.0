From: mhaverkamp@kcp.com
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 09:25:19 -0500
Message-ID: <OFD83698F6.DC37B847-ON862570A8.004CF42A-862570A8.004F38EC@kcp.com>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVVAq-00068D-At
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:25:40 -0700
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EVVAp-0002RE-1M
	for nfs@lists.sourceforge.net; Fri, 28 Oct 2005 07:25:40 -0700
In-Reply-To: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
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

If you stay with RAID5, get something with a battery backed write cache. 
That will make a huge difference in RAID5 performance.

Michael Haverkamp

nfs-admin@lists.sourceforge.net wrote on 10/27/2005 10:21:49 PM:

> Hello,
> 
>   Recently we turned on a RAID-backed NFS server that fell flat on its 
face
> as soon as it started to see even moderate activity (particularly IMAP
> traffic from Courier-IMAP).  Through help on the Courier mailing list, 
the
> problem appears to be very poor throughput to our hard drives (although
> systems is not my strong point, so I hope there is not something else 
I've
> overlooked).
> 
>   Our choice to go with consumer-grade hardware seems to have bit us 
hard. 
> We are using the oft-maligned 3Ware 85xx series RAID5 controller and 
three
> Hitachi Deskstar 7k250 (250GB) SATA drives.  The NFS serves up the 
mailstore
> for a system that does about 60 mail messages/min, plus IMAP against the
> mailstore (which is what brings the hurt), and some moderately (much 
more
> than Joe Bob's homepage, but not Slashdot) trafficed web content.  We 
were
> able to buy some time by moving our (ext3) journal off of the same 
device,
> fiddle with a couple NFS settings (nodiratime,noatime), but it is still
> woefully slow.
> 
>   Are we completely wrong to give up on this hardware?  If anyone is
> interested in giving advice in that realm, I am happy to provide more 
stats
> (like the fact that the machine sits at near 100% iowait all day long).
> 
>   But instead of sticking it out with that hardware, we are thinking 
about a
> couple possibilities, but a look around Google just found too many 
"shopping"
> sites, and not enough real information and comparisons.  We are wanting
> advice for proven performers: RAID controller cards and drives.  We had 
been
> hoping not to have to pay the hefty costs that SCSI incurrs, but at this
> point we are considering the possibility, so advice on both sides of the
> fence is sought.
> 
>   We are also quite curious about just running with software raid 
instead,
> since there seems to be a growing movement that claims there is no 
reason it
> cannot be as (or more) reliable and fast -- especially compared to the 
piece
> of $@^!% that we apparently got.  :)
> 
> Thoguhts and links highly appreciated!
> 
> 
> 
> 
> 
> 
> __________________________________ 
> Yahoo! Mail - PC Magazine Editors' Choice 2005 
> http://mail.yahoo.com
> 
> 
> -------------------------------------------------------
> This SF.Net email is sponsored by the JBoss Inc.
> Get Certified Today * Register for a JBoss Training Course
> Free Certification Exam for All Training Attendees Through End of 2005
> Visit http://www.jboss.com/services/certification for more information
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
