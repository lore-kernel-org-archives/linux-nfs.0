From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 11:59:25 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3D48D.67E9A28F@amis.com>
References: <3FB27670.4C878A84@psu.edu>
		<shssmkttk34.fsf@charged.uio.no>
		<3FB29D43.A618973D@psu.edu>
		<16306.41898.291062.36209@charged.uio.no>
		<3FB2A738.3F2C90B8@psu.edu>
		<16306.49310.195265.145519@charged.uio.no>
		<3FB2DC60.FA7D3E08@psu.edu>
		<16306.59249.857512.354675@charged.uio.no>
		<3FB3A99F.126920E7@amis.com> <16307.50555.813132.978552@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKMfW-0003oJ-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 10:58:15 -0800
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AKMfW-00089B-FB
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 10:58:14 -0800
To: trond.myklebust@fys.uio.no, Jason Holmes <jholmes@psu.edu>
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

Trond Myklebust wrote:
> 
>      > This is not the same test, nor the same results as Jason's, but
>      > here is some more data from bonnie and dd tests.This shows some
>      > write performance difference between 2.4 and 2.6 eric
> 
> How about vs. 2.4.23?

2.4.23 looks good -- see below -- these are acceptable numbers for a 100M
network. I reran the 2.6.0-test6-mm4 benchmarks and it still is much slower than
the the 2.4.23.

Question for Jason: -- are you running the 4/4 vm layout in your kernel? My
2.6.0-test6-mm4 has the 4/4 vm enabled -- which can have an impact on
performance. I'll tetest with 2.6.0-test9 without the mm1 and 4/4 vm enabled.

eric


Linux host 2.4.23-rc1 #2 SMP Thu Nov 13 11:30:02 MST 2003 i686 athlon i386
GNU/Linux
/test> bonnie -s 100
Writing with putc()...  done:   9228 kB/s  52.0 %CPU
Rewriting...            done:   9435 kB/s   6.0 %CPU
Writing intelligently...done:   9235 kB/s   4.0 %CPU

/test> rm file;time dd if=/dev/zero of=file bs=1 count=10000000
10000000+0 records in
10000000+0 records out

real    0m20.086s
user    0m3.120s
sys     0m16.740s


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
