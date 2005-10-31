From: Dan Stromberg <strombrg@dcs.nac.uci.edu>
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Mon, 31 Oct 2005 11:27:05 -0800
Message-ID: <1130786827.31211.49.camel@seki.nac.uci.edu>
References: <20051028032149.14201.qmail@web51905.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, strombrg@dcs.nac.uci.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWfOx-0004oI-CD
	for nfs@lists.sourceforge.net; Mon, 31 Oct 2005 11:33:03 -0800
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EWfOu-0003ef-PP
	for nfs@lists.sourceforge.net; Mon, 31 Oct 2005 11:33:03 -0800
Received: from dcs.nac.uci.edu ([128.200.34.32])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1EWfOq-0005tD-1S
	for nfs@lists.sourceforge.net; Mon, 31 Oct 2005 11:32:56 -0800
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


Most, if not all, of my notes pertaining to large storage are here:

http://dcs.nac.uci.edu/~strombrg/tech-tidbits-by-category.html#Large%20Storage

I think commodity hardware is generally a good way to go when you can,
but we also had bad experiences with some 3Ware RAID cards, though in
our case, it wasn't clear if the problem was best attributed to the
Maxtor disks, the 3Ware RAID cards, the Promicrosystems PC's, or the GFS
and Lustre we tried overtop of this hardware.

We eventually replaced all this with a Sun 3511 with a Sun V440 out
front of it as a NAS head, with a QFS filesystem to piece together the
slices (no SVM or other extra tack-them-together layer required, since
QFS does that -and- the filesystem).  It's served out via a Solaris NFS
server to a handful of AIX NFS clients, and it works well.  But that's
because we needed 15T of storage - had we required only 2T, we would've
had many more choices.

You -can- get good performance out of commodity stuff.  As a simple
thought-experiment, consider what would happen if you had a huge number
of small disks accessed via distinct 100BaseT links, with your data
being striped across them all.  Because of the huge amount of striping,
your aggregate throughput should be quite good despite the 100BaseT.

I believe Hitachi bought the Deskstar line of disks from IBM, shortly
after IBM had to replace tons of Deskstars being they were dying left
and right.  The problems may or may not have been thoroughly worked out
since then.

Sometimes under linux and other OS's, a single process that's pound a
storage resource can pretty well mess up the performance for the other
processes requiring access to that resource.  Sometimes deprioritising
that I/O hungry process can help the other processes on the system A
LOT:

http://dcs.nac.uci.edu/~strombrg/Keeping-backups-from-pounding-a-system-as-hard.html

HTH!

On Thu, 2005-10-27 at 20:21 -0700, email builder wrote:
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
> 
>   But instead of sticking it out with that hardware, we are thinking about a
> couple possibilities, but a look around Google just found too many "shopping"
> sites, and not enough real information and comparisons.  We are wanting
> advice for proven performers: RAID controller cards and drives.  We had been
> hoping not to have to pay the hefty costs that SCSI incurrs, but at this
> point we are considering the possibility, so advice on both sides of the
> fence is sought.
> 
>   We are also quite curious about just running with software raid instead,
> since there seems to be a growing movement that claims there is no reason it
> cannot be as (or more) reliable and fast -- especially compared to the piece
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
> 



-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.
Get Certified Today * Register for a JBoss Training Course
Free Certification Exam for All Training Attendees Through End of 2005
Visit http://www.jboss.com/services/certification for more information
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
