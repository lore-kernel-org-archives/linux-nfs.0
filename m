From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] implementing BSD style locks on NLM (flocks)
Date: Mon, 14 Mar 2005 10:29:11 -0500
Message-ID: <1110814151.30085.50.camel@lade.trondhjem.org>
References: <20050227192113.GA5778@localhost.localdomain>
	 <1109787034.12460.7.camel@lade.trondhjem.org>
	 <20050303182419.GI6497@hmsendeavour.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DArVc-0000dN-Vu
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:29:32 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DArVb-0004Dc-84
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:29:32 -0800
To: nhorman@redhat.com
In-Reply-To: <20050303182419.GI6497@hmsendeavour.rdu.redhat.com>
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

to den 03.03.2005 Klokka 13:24 (-0500) skreiv nhorman@redhat.com:
> On Wed, Mar 02, 2005 at 10:10:34AM -0800, Trond Myklebust wrote:
> > su den 27.02.2005 Klokka 14:21 (-0500) skreiv nhorman@redhat.com:
> > > Hey all-
> > > 	I was wondering, how much interest there might be in the addition of
> > > support for BSD style locks (flocks) over NLM.  I was thinking that a bit could
> > > be added to differentiate the two namespaces.  Any thoughts appreciated.  
> > 
> > http://client.linux-nfs.org/Linux-2.6.x/2.6.11-rc5/linux-2.6.11-17-flock.dif
> > 
> > Cheers,
> >   Trond
> > 
> > -- 
> > Trond Myklebust <trond.myklebust@fys.uio.no>
> > 
> Do you know when this will get merged with the mainline kernel?
> Thanks!
> Neil

I'm pretty sure, yes. The date for merging was last Thursday. ;-)

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
