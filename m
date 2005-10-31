From: mhaverkamp@kcp.com
Subject: Re: OT: RAID perf doldrums: advice/recommendations?
Date: Mon, 31 Oct 2005 09:12:27 -0600
Message-ID: <OF4F03C35B.15525291-ON862570AB.0052D3A1-862570AB.005389DD@kcp.com>
References: <20051028222238.92185.qmail@web51914.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EWbL7-0000MZ-31
	for nfs@lists.sourceforge.net; Mon, 31 Oct 2005 07:12:49 -0800
Received: from mailhost2.os.kcp.com ([198.124.201.32])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EWbKz-0001ta-Te
	for nfs@lists.sourceforge.net; Mon, 31 Oct 2005 07:12:48 -0800
In-Reply-To: <20051028222238.92185.qmail@web51914.mail.yahoo.com>
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

nfs-admin@lists.sourceforge.net wrote on 10/28/2005 05:22:38 PM:

> 
> > If you stay with RAID5, get something with a battery backed write 
cache. 
> > That will make a huge difference in RAID5 performance.
> 
> Really?  I was under the impression that this was just a safety 
precaution or
> similar... it is called a "backup" after all.  :)  How exactly does it
> increase performance? 

Without one, writes must be flushed to disk before the RAID controller can 
report them as complete.  This includes even trivial things like updating 
file access times.  With one, writes only need to get into the 
controller's write cache before they are reported as complete.  This 
allows the controller to schedule the actual write to disk at an optimal 
time.

A good way to show this is to untar a tar file full of small files (e.g. 
kernel source).  On RAID5 without write cache, this takes at least 10 
times longer than even a single ATA disk.

> 
> (And, yes, I have seen this mentioned in many places, so this would be a
> criteria for our next purchase. :) )
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
