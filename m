From: Olaf Kirch <okir@suse.de>
Subject: Re: NFS directio
Date: Tue, 11 Apr 2006 11:15:54 +0200
Message-ID: <20060411091554.GF30315@suse.de>
References: <1143734612.8093.8.camel@lade.trondhjem.org> <20060331074900.GC32461@suse.de> <12E368A4-2262-4EBF-8769-581DB3500A36@citi.umich.edu> <20060331145849.GF18629@suse.de> <442D4FC2.7060109@citi.umich.edu> <17465.67.550070.247218@cse.unsw.edu.au> <44398617.2000208@citi.umich.edu> <17465.56586.668816.438021@cse.unsw.edu.au> <443A978A.1010101@citi.umich.edu> <17466.62555.790179.839147@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cel@citi.umich.edu, Trond Myklebust <trond.myklebust@fys.uio.no>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FTEyi-00050G-Uv
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 02:16:04 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FTEyh-0007qh-DH
	for nfs@lists.sourceforge.net; Tue, 11 Apr 2006 02:16:04 -0700
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

On Tue, Apr 11, 2006 at 10:12:11AM +1000, Neil Brown wrote:
> > wow.  first i've heard of this.  was it ever reported to nfs@sf.net?
> 
> No, it was an internal suse thing

No, it's from http://fy.chalmers.se/~appro/linux/DVD+RW/
The tool is growisofs, and has a builtin dd replacement
that wants to do this.

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
