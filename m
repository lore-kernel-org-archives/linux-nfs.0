From: Jason Holmes <jholmes@psu.edu>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 14:18:44 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3D914.CB1E73BC@psu.edu>
References: <3FB27670.4C878A84@psu.edu>
			<shssmkttk34.fsf@charged.uio.no>
			<3FB29D43.A618973D@psu.edu>
			<16306.41898.291062.36209@charged.uio.no>
			<3FB2A738.3F2C90B8@psu.edu>
			<16306.49310.195265.145519@charged.uio.no>
			<3FB2DC60.FA7D3E08@psu.edu>
			<16306.59249.857512.354675@charged.uio.no>
			<3FB3A99F.126920E7@amis.com> <16307.50555.813132.978552@charged.uio.no> <3FB3D48D.67E9A28F@amis.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKMzP-0006XJ-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 11:18:47 -0800
Received: from vpn-19-5.aset.psu.edu ([146.186.19.5] helo=funkmachine.cac.psu.edu)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AKMzP-00049e-E0
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 11:18:47 -0800
To: Eric Whiting <ewhiting@amis.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Eric Whiting wrote:
> 
> Trond Myklebust wrote:
> >
> >      > This is not the same test, nor the same results as Jason's, but
> >      > here is some more data from bonnie and dd tests.This shows some
> >      > write performance difference between 2.4 and 2.6 eric
> >
> > How about vs. 2.4.23?
> 
> 2.4.23 looks good -- see below -- these are acceptable numbers for a 100M
> network. I reran the 2.6.0-test6-mm4 benchmarks and it still is much slower than
> the the 2.4.23.
> 
> Question for Jason: -- are you running the 4/4 vm layout in your kernel? My
> 2.6.0-test6-mm4 has the 4/4 vm enabled -- which can have an impact on
> performance. I'll tetest with 2.6.0-test9 without the mm1 and 4/4 vm enabled.

Nope.  I'm just doing normal 4GB highmem.

Thanks,

--
Jason Holmes


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
