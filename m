From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: NAS server avalanche overload
Date: Thu, 04 Mar 2004 16:47:16 +1100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4046C2E4.C33EAEB5@melbourne.sgi.com>
References: <1078302718.825.67.camel@localhost>
		 <1078351343.821.28.camel@localhost> <20040304000438.GA25910@sgi.com>
		 <1078359638.813.71.camel@localhost> <404688FE.69592A2A@melbourne.sgi.com>
		 <Pine.LNX.4.58.0403041234150.7374@wombat.indigo.net.au> <1078378313.853.3.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian Kent <raven@themaw.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AylnT-0001JI-NM
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 21:53:27 -0800
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=zok.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Aylhl-0003zk-Mv
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 21:47:33 -0800
To: Erik Walthinsen <omega@pdxcolo.net>
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

Erik Walthinsen wrote:
> 
> On Wed, 2004-03-03 at 20:39, Ian Kent wrote:
> > Bumping the number of threads to 32 or 64 or more would be the first
> > thing I would try.
> 
> Only problem is that if the spike occurs anyway, the load will be 33 or
> 65 instead of 17.  I don't know if it's ctxswitching itself to death
> while all these nfsd's are blocking, 

If it's the same as I've seen, an nfsd will be spinning in schedule()
trying to reacquire the BKL.  Changing the number of nfsds is not
going to affect the amount of CPU wasted (i.e. pretty much all of
it) just the number of runnable processes.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
