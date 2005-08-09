From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "Server not responding" after periods of client
	inactivity
Date: Tue, 09 Aug 2005 16:59:20 -0400
Message-ID: <1123621160.8245.200.camel@lade.trondhjem.org>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox>
	 <1122732943.8248.13.camel@lade.trondhjem.org> <20050730143216.GA2339@fox>
	 <1122735345.8248.28.camel@lade.trondhjem.org>
	 <20050809190634.GA5779@fox.upc.no>
	 <1123614892.8245.166.camel@lade.trondhjem.org>
	 <20050809203219.GA6740@fox.upc.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E2cKd-0006Jd-I8
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 15:12:23 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E2cEp-00042Z-Ak
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 15:06:23 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1E2bCF-0004nZ-IM
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 13:59:40 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1E2bC8-0006wt-9K
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 22:59:32 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050809203219.GA6740@fox.upc.no>
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

ty den 09.08.2005 Klokka 22:32 (+0200) skreiv Haakon Riiser:
> Done.  Unfortunately, I couldn't find a call trace for mountd,
> I only got this:
> 
> rpc.mountd    R running  1880  2814      1               18906 (NOTLB)

Makes sense. That means that rpc.mountd is hanging in userland. That
would also explain why you can't immediately ptrace it.

It is worrying, though. rpc.mountd should almost always be in the
kernel, waiting in select().

Did you compile this version of rpc.mountd yourself? If not, is there
anything special/weird in your /etc/exports file that might cause the
rpc.mountd parser to be screwing up?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
