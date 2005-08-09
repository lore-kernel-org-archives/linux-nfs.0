From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: "Server not responding" after periods of client
	inactivity
Date: Tue, 09 Aug 2005 15:14:52 -0400
Message-ID: <1123614892.8245.166.camel@lade.trondhjem.org>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox>
	 <1122732943.8248.13.camel@lade.trondhjem.org> <20050730143216.GA2339@fox>
	 <1122735345.8248.28.camel@lade.trondhjem.org>
	 <20050809190634.GA5779@fox.upc.no>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E2ZZA-0000d4-BN
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:15:12 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E2ZZ8-0002h5-Sg
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 12:15:12 -0700
Received: from mail-mx2.uio.no ([129.240.10.30])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1E2ZZ3-0005dQ-8x
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 21:15:05 +0200
To: Haakon Riiser <haakon.riiser@fys.uio.no>
In-Reply-To: <20050809190634.GA5779@fox.upc.no>
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

ty den 09.08.2005 Klokka 21:06 (+0200) skreiv Haakon Riiser:
> OK, I've been trying for some time to reproduce the bug while
> stracing mountd on the server, but it seems impossible to do it.
> If I do
> 
>   strace -p $(pidof rpc.mountd)
> 
> the bug never occurs.  If I try to start strace immediately after
> the hang begins, strace doesn't attach until the hang is over.
> That is, it takes approximately 15 seconds (the entire duration of
> the hang) before the
> 
>   Process <PID> attached - interrupt to quit
> 
> message is displayed and anything else is printed by strace.  Does
> this tell you anything?

Just means that the mountd process is stuck in a syscall. Have you tried
getting a thread dump when it happens?

echo "t" > /proc/sysrq-trigger

on the server then scour through the 'dmesg' output until you find out
where mountd is hiding.

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
