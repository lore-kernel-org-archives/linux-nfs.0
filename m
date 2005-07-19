From: Ian Kent <raven@themaw.net>
Subject: Re: making the 'addr=' mount option an address hint
Date: Tue, 19 Jul 2005 20:03:46 +0800 (WST)
Message-ID: <Pine.LNX.4.63.0507191953300.2061@donald.themaw.net>
References: <1121614708.6713.41.camel@localhost.localdomain>
 <1121700961.8780.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Layton <jtlayton@poochiereds.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Duqwe-0000Oh-Qs
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 05:11:32 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44)
	id 1Duqwc-0002bm-TS
	for nfs@lists.sourceforge.net; Tue, 19 Jul 2005 05:11:32 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1121700961.8780.13.camel@lade.trondhjem.org>
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

On Mon, 18 Jul 2005, Trond Myklebust wrote:

> su den 17.07.2005 Klokka 11:38 (-0400) skreiv Jeff Layton:
> > So, what I'd like to do is roll a patch for mount to change the behavior
> > of the 'addr=' option. Instead of ignoring it, we'd treat it as an
> > address hint. If one of the addresses returned by gethostbyname()
> > matches this address, then we'd mount using that address. Otherwise, the
> > existing behavior would prevail (use the first address in the list).
> > 
> > I'm writing this to solicit some feedback before I dive in and start
> > working on it. Does this sound like a reasonable idea? Is there
> > something I'm not considering that would prevent this from working?
> 
> There's nothing preventing it from working, but what is stopping you
> from developing a fully automatic version?
> 
> If you see that the server has multiple addresses, you can, for
> instance, try timing an RPC ping (null rpc call) to the NFS server. In
> the version of "mount" that RedHat is using (which I still haven't
> pushed to the utils-linux maintainer) we're already doing a ping in
> order to test for service availability. It would be trivial to time
> those pings.

That patch is present on Aurora (FC2 base , where I've been testing autofs 
development. It effectively prevents mounting of any more than about 80 
mounts before you have to wait for the sockets to close.

Don't get me wrong I'm also guilty of probing in autofs.

Unfortunately, it really interferes with the ability to mount a healthy 
number of filesystems quickly.

Perhaps we should consider you old patch to multiplex RPC TCP connections 
before pushing ahead with more probing in the utilities. I also plead 
guilty to not any work on this. I wish I had more time.

Ian



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
