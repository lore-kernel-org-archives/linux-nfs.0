From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: statd -o change
Date: Fri, 04 Mar 2005 11:48:02 -0800
Message-ID: <1109965682.10173.29.camel@lade.trondhjem.org>
References: <20050227192113.GA5778@localhost.localdomain>
	 <1109787034.12460.7.camel@lade.trondhjem.org>
	 <20050304153436.GA32203@gam3.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nhorman@redhat.com, nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D7Imk-0006SY-55
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 11:48:30 -0800
Received: from pat2.uio.no
	([129.240.130.19] helo=pat.uio.no ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D7Img-0007lu-Js
	for nfs@lists.sourceforge.net; Fri, 04 Mar 2005 11:48:30 -0800
To: "G. Allen Morris III" <gam3@gam3.net>
In-Reply-To: <20050304153436.GA32203@gam3.net>
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

fr den 04.03.2005 Klokka 10:34 (-0500) skreiv G. Allen Morris III:
> Trond,
> 
> I would think that statd should fail if the requested outgoing port (-o)
> can't be bound to. The main reason to bind to a particular outgoing port
> is because of a firewall.  If a random port is used statd will not make
> it through the firewall, but the log file will have to be checked to
> find out why statd is not working (falling back on randomly chosen port).
> 
> Not starting statd seems to be the failure mode if the rpc.statd port
> (-p) can't be bound to.

I'm not against doing this, but it would be a change w.r.t. existing
behaviour, so it warrants some discussion first.

Anyone have an opinion on this?

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
