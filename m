From: Eric Whiting <ewhiting@amis.com>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Thu, 13 Nov 2003 12:09:32 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FB3D6EC.E4F1FF17@amis.com>
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
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKMpG-0005RM-00
	for <nfs@lists.sourceforge.net>; Thu, 13 Nov 2003 11:08:18 -0800
Received: from dermis.amis.com ([207.141.5.253])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.24)
	id 1AKMpG-0001xG-8v
	for nfs@lists.sourceforge.net; Thu, 13 Nov 2003 11:08:18 -0800
To: trond.myklebust@fys.uio.no, nfs@lists.sourceforge.net
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
> I'll tetest with 2.6.0-test9 without the mm1 and 4/4 vm enabled.
> 

2.6.0-test9 (without mm1 4/4 vm) is even worse than 2.6.0-test6-mm4.

tcpdump shows very slow writes..


12:07:12.380001 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33858:1480@0+)
12:07:12.380012 172.16.17.176 > 172.16.32.181: udp (frag 33858:1480@1480+)
12:07:12.380014 172.16.17.176 > 172.16.32.181: udp (frag 33858:1284@2960)
12:07:17.979092 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33859:1480@0+)
12:07:17.979102 172.16.17.176 > 172.16.32.181: udp (frag 33859:1480@1480+)
12:07:17.979104 172.16.17.176 > 172.16.32.181: udp (frag 33859:1284@2960)
12:07:18.678981 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33860:1480@0+)
12:07:18.678992 172.16.17.176 > 172.16.32.181: udp (frag 33860:1480@1480+)
12:07:18.678994 172.16.17.176 > 172.16.32.181: udp (frag 33860:1284@2960)
12:07:20.078755 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33861:1480@0+)
12:07:20.078766 172.16.17.176 > 172.16.32.181: udp (frag 33861:1480@1480+)
12:07:20.078768 172.16.17.176 > 172.16.32.181: udp (frag 33861:1284@2960)
12:07:22.879310 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33862:1480@0+)
12:07:22.879321 172.16.17.176 > 172.16.32.181: udp (frag 33862:1480@1480+)
12:07:22.879323 172.16.17.176 > 172.16.32.181: udp (frag 33862:1284@2960)
12:07:28.479388 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33863:1480@0+)
12:07:28.479399 172.16.17.176 > 172.16.32.181: udp (frag 33863:1480@1480+)
12:07:28.479400 172.16.17.176 > 172.16.32.181: udp (frag 33863:1284@2960)
12:07:29.179275 172.16.17.176.1525633085 > 172.16.32.181.2049: 1472 write [|nfs]
(frag 33864:1480@0+)
12:07:29.179286 172.16.17.176 > 172.16.32.181: udp (frag 33864:1480@1480+)


-------------------------------------------------------
This SF.Net email sponsored by: ApacheCon 2003,
16-19 November in Las Vegas. Learn firsthand the latest
developments in Apache, PHP, Perl, XML, Java, MySQL,
WebDAV, and more! http://www.apachecon.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
