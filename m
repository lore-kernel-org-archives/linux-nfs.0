From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: making the 'addr=' mount option an address hint
Date: Mon, 18 Jul 2005 11:36:01 -0400
Message-ID: <1121700961.8780.13.camel@lade.trondhjem.org>
References: <1121614708.6713.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DuXfl-00088B-0D
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 08:36:49 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1DuXfi-0004uN-G2
	for nfs@lists.sourceforge.net; Mon, 18 Jul 2005 08:36:49 -0700
To: Jeff Layton <jtlayton@poochiereds.net>
In-Reply-To: <1121614708.6713.41.camel@localhost.localdomain>
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

su den 17.07.2005 Klokka 11:38 (-0400) skreiv Jeff Layton:
> So, what I'd like to do is roll a patch for mount to change the behavior
> of the 'addr=' option. Instead of ignoring it, we'd treat it as an
> address hint. If one of the addresses returned by gethostbyname()
> matches this address, then we'd mount using that address. Otherwise, the
> existing behavior would prevail (use the first address in the list).
> 
> I'm writing this to solicit some feedback before I dive in and start
> working on it. Does this sound like a reasonable idea? Is there
> something I'm not considering that would prevent this from working?

There's nothing preventing it from working, but what is stopping you
from developing a fully automatic version?

If you see that the server has multiple addresses, you can, for
instance, try timing an RPC ping (null rpc call) to the NFS server. In
the version of "mount" that RedHat is using (which I still haven't
pushed to the utils-linux maintainer) we're already doing a ping in
order to test for service availability. It would be trivial to time
those pings.

Note that there are various problems that you need to consider.

There is the trivial fact that our NFS client doesn't yet work over any
other network than IPv4.
Less obvious, is the fact that the NFS server may not be willing to
grant you access on certain networks (if it is only exporting the disk
to an internal LAN for instance).

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
