From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 08:56:15 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3A99F.126920E7@amis.com>
References: <3FB27670.4C878A84@psu.edu>
		<shssmkttk34.fsf@charged.uio.no>
		<3FB29D43.A618973D@psu.edu>
		<16306.41898.291062.36209@charged.uio.no>
		<3FB2A738.3F2C90B8@psu.edu>
		<16306.49310.195265.145519@charged.uio.no>
		<3FB2DC60.FA7D3E08@psu.edu> <16306.59249.857512.354675@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Holmes <jholmes@psu.edu>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKJoU-0004lA-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 07:55:18 -0800
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AKJoU-0004Su-7I
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 07:55:18 -0800
To: trond.myklebust@fys.uio.no
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
> Any hints on how I can reproduce your results?

Trond, 

This is not the same test, nor the same results as Jason's, but here is some
more data from bonnie and dd tests.This shows some write performance difference
between 2.4 and 2.6
eric

SERVER: 2.4.21

CLIENT: 2.4.19 nfsv3
Bonnie 
Writing with putc()...  done:   9132 kB/s  33.4 %CPU
Rewriting...            done:   8713 kB/s   4.2 %CPU
Writing intelligently...done:   9116 kB/s   4.6 %CPU

$ rm file;time dd if=/dev/zero of=file bs=1 count=10000000
10000000+0 records in
10000000+0 records out

real    0m30.404s
user    0m3.930s
sys     0m26.250s



CLIENT: 2.6.0-test6-mm4
Writing with putc()...  done:    806 kB/s   5.4 %CPU
Rewriting...            done:   3321 kB/s   3.9 %CPU
Writing intelligently...done:   2715 kB/s   2.4 %CPU


$ rm file;time dd if=/dev/zero of=file bs=1 count=10000000
10000000+0 records in
10000000+0 records out

real    1m37.848s
user    0m17.355s
sys     1m8.947s


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
