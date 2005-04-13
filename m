From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: O_NONBLOCK for regular files
Date: Wed, 13 Apr 2005 10:45:53 +1000
Message-ID: <1113353153.1956.481.camel@hole.melbourne.sgi.com>
References: <405C0DC0.3E61994@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DLW2H-0001uY-W6
	for nfs@lists.sourceforge.net; Tue, 12 Apr 2005 17:47:17 -0700
Received: from omx2-ext.sgi.com ([192.48.171.19] helo=omx2.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DLW2G-00077P-BO
	for nfs@lists.sourceforge.net; Tue, 12 Apr 2005 17:47:17 -0700
To: Linux Filesystem Development List <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <405C0DC0.3E61994@melbourne.sgi.com>
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

G'day,

On Sat, 2004-03-20 at 20:24, Greg Banks wrote:
> Jamie Lokier wrote:
> > Christoph Hellwig wrote:
> > > It's used to [...] return EAGAIN to the nfs server so it doesn't block all
> > > nfsd threads on possible long-enduring HSM operations.
> > 
> > How does nfsd get notified when the operation is possible? 
> 
> It doesn't; the nfsd sends an RPC reply containing the NFSERR_JUKEBOX
> error to the NFS client, which sleeps and retries the operation after a
> few seconds.  If the operation is not yet possible the cycle repeats.

http://marc.theaimsgroup.com/?l=linux-fsdevel&m=107959907311576&w=2

This thread was started by Christoph Hellwig 13 months ago to discuss
the possibility of using O_NONBLOCK in nfsd to make the combination
of NFS and Hierarchical Storage Managers play nicely together.  The
thread petered out with no firm conclusion but no major objections
either.

There's now a patch to actually do it, see

http://marc.theaimsgroup.com/?l=linux-nfs&m=111087383132762&w=2

Does anyone want to give a firm yea or nea to this approach?  I'd
really like to get this patch moving in the pipeline.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.




-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
