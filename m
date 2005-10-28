From: Neil Brown <neilb@suse.de>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Fri, 28 Oct 2005 13:34:47 +1000
Message-ID: <17249.40023.950260.948987@cse.unsw.edu.au>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EVL17-0005oT-Np
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 20:34:57 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EVL17-0006hd-Ed
	for nfs@lists.sourceforge.net; Thu, 27 Oct 2005 20:34:57 -0700
To: email builder <emailbuilder88@yahoo.com>
In-Reply-To: message from email builder on Thursday October 27
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

On Thursday October 27, emailbuilder88@yahoo.com wrote:
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

mounting the ext3 partition with 'data=journal' can help NFS service,
especially with the journal on a separate device.

> 
>   We are also quite curious about just running with software raid instead,
> since there seems to be a growing movement that claims there is no reason it
> cannot be as (or more) reliable and fast -- especially compared to the piece
> of $@^!% that we apparently got.  :)

Certainly worth a try.  It may not be as fast as some high-end raid
cards, it is unlikely to be slower than what you have.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
