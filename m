From: Martin Wegner <mailing-lists@mroot.net>
Subject: Re: nfssvc: Address already in use
Date: Tue, 12 Sep 2006 14:49:27 +0200
Message-ID: <4506ACD7.9050105@mroot.net>
References: <450605F4.1060806@mroot.net>
	<1158059348.8386.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GN7hh-0006Lz-Ce
	for nfs@lists.sourceforge.net; Tue, 12 Sep 2006 05:49:29 -0700
Received: from daemo09.udag.de ([62.146.33.133] helo=mail.udag.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GN7hg-0002P6-PU
	for nfs@lists.sourceforge.net; Tue, 12 Sep 2006 05:49:30 -0700
Received: from [192.168.1.23] (p5485A584.dip0.t-ipconnect.de [84.133.165.132])
	by mail.udag.de (Postfix) with ESMTP id 6026F7FAA
	for <nfs@lists.sourceforge.net>; Tue, 12 Sep 2006 14:49:27 +0200 (CEST)
To: nfs <nfs@lists.sourceforge.net>
In-Reply-To: <1158059348.8386.19.camel@lade.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hello.

Trond Myklebust wrote:
> [...]
> Have you tried looking with 'netstat -p' if some daemon has already
> grabbed port 2049? If you have set fixed ports for lockd, you might also
> want to check that those ports are free.

Thanks for this clue, it pushed me into the right direction. I found out
that the DHCP server component of my dnsmasq used port 2048. Sure, this
is not 2049, but somehow, when I had shut down dnsmasq and then started
nfsd, everything worked. Also after reboot now, everything's fine, so
the problem is solved for me.

Thanks again,
martin

-- 
Get my public GPG key from pgp.mit.edu or wwwkeys.pgp.net
Key ID: 0x44085D12
--
Homepage: http://mroot.net/
Powered by Gentoo Linux (http://gentoo.org/)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
