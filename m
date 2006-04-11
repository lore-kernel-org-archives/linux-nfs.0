From: Chuck Lever <cel@citi.umich.edu>
Subject: Re: NFS directio
Date: Mon, 10 Apr 2006 20:47:36 -0400
Message-ID: <443AFCA8.8060106@citi.umich.edu>
References: <20060330151544.GA11915@suse.de>	<1143734612.8093.8.camel@lade.trondhjem.org>	<20060331074900.GC32461@suse.de>	<12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu>	<20060331145849.GF18629@suse.de>	<442D4FC2.7060109@citi.umich.edu>	<17465.67.550070.247218@cse.unsw.edu.au>	<44398617.2000208@citi.umich.edu>	<17465.56586.668816.438021@cse.unsw.edu.au>	<443A978A.1010101@citi.umich.edu> <17466.62555.790179.839147@cse.unsw.edu.au>
Reply-To: cel@citi.umich.edu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Olaf Kirch <okir@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FT72n-00018B-4Y
	for nfs@lists.sourceforge.net; Mon, 10 Apr 2006 17:47:45 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FT72l-0007Xp-Lt
	for nfs@lists.sourceforge.net; Mon, 10 Apr 2006 17:47:45 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17466.62555.790179.839147@cse.unsw.edu.au>
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

Neil Brown wrote:
> On Monday April 10, cel@citi.umich.edu wrote:
>> Neil Brown wrote:
>>> I think the case in point was a DVD burner trying to burn an image
>>> that lived on a NFS filesystem.  It tried to direct-read a reasonable
>>> fraction of the whole dvd (100Meg?) and had problems.
>> wow.  first i've heard of this.  was it ever reported to nfs@sf.net?
> 
> No, it was an internal suse thing, and as Olaf said, it was only 32Meg.
> 
>> if you are sure that the problems were directly related to the pagevec 
>> size logic, then i will get this fixed asap in mainline.
> 
> The old 16Meg limit (now gone in mainline, or -mm at least) was the
> problem.  I don't know that kmalloc failure has actually been a
> problem, but when I see a high-order kmalloc, I get all worried.
> 
> So I think it is a "should be fixed sometime", but not necessarily a
> "must be fixed now" issue.

Thanks for clarifying.

This is something I will plan to include in the vectored I/O support for 
NFS O_DIRECT in the next couple of months.

In the meantime, we have some good tests for NFS O_DIRECT and aio+dio 
that involve smaller I/O sizes, but nothing for stretching it with 
larger I/O request sizes.  Until now I had thought we were covering the 
important use cases.  If you have any other tests that will exercise 
O_DIRECT in this way, I'm happy to include them in my development testing.

-- 
corporate:	<cel at netapp dot com>
personal:	<chucklever at bigfoot dot com>


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
