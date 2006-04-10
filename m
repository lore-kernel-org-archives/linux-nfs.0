From: Neil Brown <neilb@suse.de>
Subject: Re: NFS directio
Date: Mon, 10 Apr 2006 14:20:26 +1000
Message-ID: <17465.56586.668816.438021@cse.unsw.edu.au>
References: <20060330151544.GA11915@suse.de>
	<1143734612.8093.8.camel@lade.trondhjem.org>
	<20060331074900.GC32461@suse.de>
	<12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>
	<20060331145849.GF18629@suse.de>
	<442D4FC2.7060109@citi.umich.edu>
	<17465.67.550070.247218@cse.unsw.edu.au>
	<44398617.2000208@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Olaf Kirch <okir@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FSntY-00006Y-Qy
	for nfs@lists.sourceforge.net; Sun, 09 Apr 2006 21:20:56 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FSntX-0000jF-Eg
	for nfs@lists.sourceforge.net; Sun, 09 Apr 2006 21:20:56 -0700
To: cel@citi.umich.edu
In-Reply-To: message from Chuck Lever on Sunday April 9
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

On Sunday April 9, cel@citi.umich.edu wrote:
> 
> howdy neil-

G'Day :-)

> 
> usually I/O is broken up into smaller chunks by the time it gets down to 
> this level, so it's never been much of an issue.  it's pretty 
> challenging to generate a test case for extremely large I/O sizes (for 
> example, the size of the entire process address space).

I don't think direct_io requests get broken up at all...

I think the case in point was a DVD burner trying to burn an image
that lived on a NFS filesystem.  It tried to direct-read a reasonable
fraction of the whole dvd (100Meg?) and had problems.

> 
> and until now, there really hasn't been much call for doing NFS O_DIRECT 
> with very large requests.  it's been a matter of meeting the 
> requirements of database I/O, which is generally 4KB to 16KB for data 
> files, and about a megabyte for log writes.
> 
> at this point we don't really have a test case and a use case that 
> reliably breaks this, so it hasn't been a priority to address this.
> 
> the structure of this code was adapted (ie stolen) from other parts of 
> the kernel that also employ get_user_pages.  you can probably take a 
> look at other places that employ get_user_pages(), and see how they've 
> since tackled the issue.

Looking at fs/direct-io.c, it called get_user_pages is blocks of
at-most 64 pages.  I suspect a similar thing would be possible for
nfs.  I might have a look one day....

Thanks,
NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
