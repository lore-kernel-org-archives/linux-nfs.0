From: Philippe Troin <phil@fifi.org>
Subject: Re: Killed process on NFS client can result in lost lock on server
Date: 30 Sep 2003 15:35:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <87n0cl29cp.fsf@ceramic.fifi.org>
References: <87r81y11og.fsf@ceramic.fifi.org> <shspthi0zk4.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A4T5e-0006l1-00
	for <nfs@lists.sourceforge.net>; Tue, 30 Sep 2003 15:35:30 -0700
Received: from tantale.fifi.org ([216.27.190.146] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A4T5c-0003S5-8V
	for nfs@lists.sourceforge.net; Tue, 30 Sep 2003 15:35:28 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shspthi0zk4.fsf@charged.uio.no>
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

Trond Myklebust <trond.myklebust@fys.uio.no> writes:

> >>>>> " " == Philippe Troin <phil@fifi.org> writes:
> 
>      > While trying to make this test program, I've noticed that the
>      > problem only occurs while I/O is done on the locked file. Note
>      > the write() in a while loop in the test program. I could not
>      > get the bad behavior to show up if no I/O is going on.
> 
> Yep. It's the same problem as in nlmclnt_proc(): we have to clean up
> all locks come rain or shine when the process exits.

Thanks for the patch Trond, I'll give it a shot later today.

Is this patch in a -pre kernel yet or in 2.6.x or is it a new bug?

Phil.


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
