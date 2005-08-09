From: Haakon Riiser <haakon.riiser@fys.uio.no>
Subject: Re: "Server not responding" after periods of client inactivity
Date: Wed, 10 Aug 2005 00:24:03 +0200
Message-ID: <20050809222403.GA9444@fox.upc.no>
References: <20050714212514.GA23867@fox> <20050730131031.GA1668@fox> <1122732943.8248.13.camel@lade.trondhjem.org> <20050730143216.GA2339@fox> <1122735345.8248.28.camel@lade.trondhjem.org> <20050809190634.GA5779@fox.upc.no> <1123614892.8245.166.camel@lade.trondhjem.org> <20050809203219.GA6740@fox.upc.no> <1123621160.8245.200.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E2cWA-00073k-Ja
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 15:24:18 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E2cWA-0001jH-3P
	for nfs@lists.sourceforge.net; Tue, 09 Aug 2005 15:24:18 -0700
Received: from mail-mx3.uio.no ([129.240.10.44])
	by pat.uio.no with esmtp (Exim 4.43)
	id 1E2cW3-0006mW-Jm
	for nfs@lists.sourceforge.net; Wed, 10 Aug 2005 00:24:11 +0200
Received: from cm-80.111.122.093.chello.no ([80.111.122.93] helo=fox.venod.com)
	by mail-mx3.uio.no with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.43)
	id 1E2cW0-0001Gn-Q2
	for nfs@lists.sourceforge.net; Wed, 10 Aug 2005 00:24:08 +0200
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1123621160.8245.200.camel@lade.trondhjem.org>
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

>> rpc.mountd    R running  1880  2814      1               18906 (NOTLB)
> 
> Makes sense. That means that rpc.mountd is hanging in userland. That
> would also explain why you can't immediately ptrace it.

But shouldn't strace immediately attach, even if mountd is
busy-waiting in userspace?  E.g., if I create a program that loops
forever, such as

  for (;;) { }

I can still attach immediately, although nothing is printed since
there are no system calls (I've verified this).  How can a program
running in userspace delay strace's initial attachment?

> It is worrying, though. rpc.mountd should almost always be in the
> kernel, waiting in select().
> 
> Did you compile this version of rpc.mountd yourself? If not, is there
> anything special/weird in your /etc/exports file that might cause the
> rpc.mountd parser to be screwing up?

No and no.  I'm using Fedora Core 3's rpc.mountd (nfs-utils-1.0.6-52),
and this is my /etc/exports:

/pub    10.0.0.4(rw,async,no_root_squash,no_subtree_check)
/raid   10.0.0.4(rw,async,no_subtree_check)
/pub    10.0.0.21(rw,async,no_root_squash,no_subtree_check)
/raid   10.0.0.21(rw,async,no_subtree_check)

Shouldn't have any problems with this, right?

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
