From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: [autofs] BUG: autofs4 + cd
	/net/<Netapp>/vol/vol[0-3] = port usage problems
Date: Wed, 19 Jan 2005 00:00:16 -0500
Message-ID: <1106110817.12390.12.camel@lade.trondhjem.org>
References: <200501142238.j0EMcbOT002214@jetcar.spd.analog.com>
	 <Pine.LNX.4.61.0501151035230.1597@donald.themaw.net>
	 <16875.53538.836665.652032@segfault.boston.redhat.com>
	 <Pine.LNX.4.58.0501180922310.32570@wombat.indigo.net.au>
	 <16877.6946.710259.562902@segfault.boston.redhat.com>
	 <Pine.LNX.4.58.0501190101000.5388@raven-wl.themaw.net>
	 <41ED482D.8090203@sun.com>
	 <Pine.LNX.4.58.0501190926100.30606@wombat.indigo.net.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Mike Waychison <Michael.Waychison@sun.com>,
	Jeff Moyer <jmoyer@redhat.com>,
	autofs mailing list <autofs@linux.kernel.org>,
	David Meleedy <david.meleedy@analog.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cr7xp-0003qM-Ok
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 21:01:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cr7xn-0007oD-6l
	for nfs@lists.sourceforge.net; Tue, 18 Jan 2005 21:01:05 -0800
To: Ian Kent <raven@themaw.net>
In-Reply-To: <Pine.LNX.4.58.0501190926100.30606@wombat.indigo.net.au>
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

on den 19.01.2005 Klokka 12:21 (+0800) skreiv Ian Kent:

> Trond never finished them. He probably got too much flack about 
> scalability and request slot exhastion and gave up on it.
> 
> He reffered to them in a previous discussion on the same topic and said 
> that if anyone wanted to port them to a current kernel and finish them 
> they were welcome.
> 
> So I did that at the time for vanila kernels (2.4.22 amd 2.6.0) but had no 
> confidence in my work as my understanding of the RPC subsystem is fairly 
> poor and was worse at the time. I asked Trond to check them but he clearly 
> didn't have time.

No, I haven't given up on those changes, but I've postponed merging them
until after Chuck finishes testing his "transport switch". The latter is
the abstraction layer that is expected to take us beyond the single
udp/tcp socket paradigm so that we can add IPv6, infiniband, and
multipathing.
IOW it touches fairly heavily on the code in xprt.c.

btw, we're aiming to have that code ready for testing at Connectathon,
so if any of you are going to be attending, we can perhaps discuss this
subject there?

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
