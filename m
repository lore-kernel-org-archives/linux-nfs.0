From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsd, rmtab, failover, and stale filehandles
Date: Fri, 7 May 2004 14:25:43 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040507182543.GA27341@fieldses.org>
References: <20040506185603.GM23287@polop.usc.edu> <20040506191351.GP23287@polop.usc.edu> <20040506215311.GA26968@polop.usc.edu> <20040506222455.GP18964@fieldses.org> <20040506230055.GC26968@polop.usc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BMA2f-00085i-14
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 11:25:49 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BMA2e-0005js-Hi
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 11:25:48 -0700
Received: from bfields by pumpkin.fieldses.org with local (Exim 4.32)
	id 1BMA2a-00077r-65
	for nfs@lists.sourceforge.net; Fri, 07 May 2004 14:25:44 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <20040506230055.GC26968@polop.usc.edu>
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

On Thu, May 06, 2004 at 04:00:55PM -0700, Garrick Staples wrote:
> No effect.  All I did was kill mountd, run the patched mountd, and try to 'ls'
> on the client.

I think that's not enough....

> Watching an strace of mountd, it doesn't seem that mountd is ever contacted.
> The client reports stale filehandle pretty much immediately, and mountd doesn't
> do anything.

The upcall was made earlier, and the kernel has cached it (even if it's
a negative result).  So, just to make sure, could you try:

killall rpc.mountd
exportfs -f	#flush the kernel's caches
rpc.mountd	#(the patched version)

and then try again?

Of course, I may be barking up completely the wrong tree here, but I
think that bug in mountd could explain the problem you're seeing....--b.


-------------------------------------------------------
This SF.Net email is sponsored by Sleepycat Software
Learn developer strategies Cisco, Motorola, Ericsson & Lucent use to deliver
higher performing products faster, at low TCO.
http://www.sleepycat.com/telcomwpreg.php?From=osdnemail3
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
