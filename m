From: Ian Kent <raven@themaw.net>
Subject: Re: NAS server avalanche overload
Date: Thu, 4 Mar 2004 22:38:08 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0403042233420.4704@raven.themaw.net>
References: <1078302718.825.67.camel@localhost>  <1078351343.821.28.camel@localhost>
 <20040304000438.GA25910@sgi.com>  <1078359638.813.71.camel@localhost>
 <404688FE.69592A2A@melbourne.sgi.com>  <Pine.LNX.4.58.0403041234150.7374@wombat.indigo.net.au>
 <1078378313.853.3.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ayu3d-00081r-8X
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 06:42:41 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Aytdy-0005dn-M5
	for nfs@lists.sourceforge.net; Thu, 04 Mar 2004 06:16:10 -0800
To: Erik Walthinsen <omega@pdxcolo.net>
In-Reply-To: <1078378313.853.3.camel@localhost>
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

On Wed, 3 Mar 2004, Erik Walthinsen wrote:

> On Wed, 2004-03-03 at 20:39, Ian Kent wrote:
> > Bumping the number of threads to 32 or 64 or more would be the first 
> > thing I would try.
> 
> Only problem is that if the spike occurs anyway, the load will be 33 or
> 65 instead of 17.  I don't know if it's ctxswitching itself to death
> while all these nfsd's are blocking, but if so, doubling or quadrupling
> the number of blocked processes will just make the spike worse.

I'm assuming there is not a problem with the NFS implementation of course.
Never the less you generally need many more than 16 threads for a busy 
NFS server.

> 
> Also, I've learned to be extremely careful about messing with nfsd while
> clients are connected.  I've had cases where just running exportfs

I wouldn't change this on the fly either. I'm suggesting this type 
of change be made when during scheduled downtime.

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
