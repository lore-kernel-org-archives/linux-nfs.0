From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: "Server not responding" after periods of client inactivity
Date: Tue, 9 Aug 2005 21:22:24 +0200
Message-ID: <20050809192224.GA6006@fox.upc.no>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox> <1122732943.8248.13.camel@lade.trondhjem.org> <20050730143216.GA2339@fox> <1122735345.8248.28.camel@lade.trondhjem.org> <20050809190634.GA5779@fox.upc.no> <1123614892.8245.166.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E2ZgL-00012n-N7
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:22:37 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E2ZgK-0004jM-V2
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:22:37 -0700
Received: from mail-mx4.uio.no ([129.240.10.45])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1E2ZgG-0006Hq-9B
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 21:22:32 +0200
Received: from cm-80.111.122.093.chello.no ([80.111.122.93] helo=fox.venod.com)
	by mail-mx4.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1E2ZgD-00069k-Po
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 21:22:29 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1123614892.8245.166.camel@lade.trondhjem.org>
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

Trond,

> Have you tried getting a thread dump when it happens?
> echo "t" > /proc/sysrq-trigger
> on the server then scour through the 'dmesg' output until you find out
> where mountd is hiding.

Haven't tried that yet, but I'll get right on it.  (That is, in an
hour or two, since that's about how long I have to wait before the
bug occurs. :-)

-- 
 Haakon


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
