From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] implementing BSD style locks on NLM (flocks)
Date: Wed, 02 Mar 2005 10:55:08 -0800
Message-ID: <1109789708.13286.5.camel@lade.trondhjem.org>
References: <20050227192113.GA5778@localhost.localdomain>
	 <1109787034.12460.7.camel@lade.trondhjem.org>
	 <20050302184441.GA8609@suse.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nhorman@redhat.com, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6Z0I-0001ax-Fb
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 10:55:26 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D6Z0H-0000mO-4x
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 10:55:26 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050302184441.GA8609@suse.de>
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

on den 02.03.2005 Klokka 19:44 (+0100) skreiv Olaf Kirch:
> On Wed, Mar 02, 2005 at 10:10:34AM -0800, Trond Myklebust wrote:
> > http://client.linux-nfs.org/Linux-2.6.x/2.6.11-rc5/linux-2.6.11-17-flock.dif
> 
> +	/* We're simulating flock() locks using posix locks on the server */
> +	fl->fl_owner = (fl_owner_t)filp;
> +	fl->fl_start = 0;
> +	fl->fl_end = OFFSET_MAX;
> 
> Will this work as expected? Right now, the code sets fl_pid to the thread
> group ID (tgid) - but every forked process gets a new tgid, unless you
> use CLONE_THREAD, right? So the standard BSD behavior of opening a file
> in process A, calling flock, forking and doing the final close in process
> B will leave a stale lock, because the unlock call with have a different
> pid value.

Ah, but we don't actually send the fl->fl_pid on the wire anywhere. That
causes problems even with standard POSIX locks when people do wierd
things with the CLONE_ flags.
Instead we only use the fl_owner field to emulate a "pid".

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
