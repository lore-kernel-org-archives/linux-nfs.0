From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS directio
Date: Mon, 10 Apr 2006 12:55:03 +0200
Message-ID: <20060410105503.GF21979@suse.de>
References: <20060330151544.GA11915@suse.de> <1143734612.8093.8.camel@lade.trondhjem.org> <20060331074900.GC32461@suse.de> <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu> <20060331145849.GF18629@suse.de> <442D4FC2.7060109@citi.umich.edu> <17465.67.550070.247218@cse.unsw.edu.au> <44398617.2000208@citi.umich.edu> <17465.56586.668816.438021@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cel@citi.umich.edu, Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FSu35-0007Io-SL
	for nfs@lists.sourceforge.net; Mon, 10 Apr 2006 03:55:11 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FSu31-0008Pi-Nn
	for nfs@lists.sourceforge.net; Mon, 10 Apr 2006 03:55:12 -0700
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17465.56586.668816.438021@cse.unsw.edu.au>
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

On Mon, Apr 10, 2006 at 02:20:26PM +1000, Neil Brown wrote:
> I think the case in point was a DVD burner trying to burn an image
> that lived on a NFS filesystem.  It tried to direct-read a reasonable
> fraction of the whole dvd (100Meg?) and had problems.

Actually they use chunks of 32Meg, but otherwise accurate.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
