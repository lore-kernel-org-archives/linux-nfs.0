From: Ian Kent <raven@themaw.net>
Subject: Re: NAS server avalanche overload
Date: Thu, 4 Mar 2004 12:39:32 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0403041234150.7374@wombat.indigo.net.au>
References: <1078302718.825.67.camel@localhost>   <1078351343.821.28.camel@localhost>
  <20040304000438.GA25910@sgi.com> <1078359638.813.71.camel@localhost>
 <404688FE.69592A2A@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Erik Walthinsen <omega@pdxcolo.net>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AykgM-0004pZ-MI
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 20:42:02 -0800
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1Aykaf-0006rY-W8
	for nfs@lists.sourceforge.net; Wed, 03 Mar 2004 20:36:10 -0800
To: Greg Banks <gnb@melbourne.sgi.com>
In-Reply-To: <404688FE.69592A2A@melbourne.sgi.com>
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

On Thu, 4 Mar 2004, Greg Banks wrote:

> 
> > Alternately, would reducing the
> > number of nfsd's help?  
> 
> No, that will either have no effect or reduce the throughput when things
> are going well.
> 
> > Since there are only 2 heavy and 2-3 light
> > physical clients, is 16 overkill?
> 
> Probably not.

Never seen a situation were less nfs threads was useful but I haven't 
worked much with Linux as a server.

> 
> You need more than 1 nfsd per client, because (assuming you don't have
> the sync *mount* option on the clients) the clients will be issuing
> multiple (up to 16 for 2.4.x) rpc calls in parallel each.  The number
> that is useful is limited (at least on my machines) by the nfsd's doing
> time consuming memcpy()s with the BKL; absent this even more nfsds
> would be useful.

Bumping the number of threads to 32 or 64 or more would be the first 
thing I would try.

Ian



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
