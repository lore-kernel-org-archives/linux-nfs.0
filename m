From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC] implementing BSD style locks on NLM (flocks)
Date: Wed, 02 Mar 2005 10:10:34 -0800
Message-ID: <1109787034.12460.7.camel@lade.trondhjem.org>
References: <20050227192113.GA5778@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6YJB-0007Kr-P3
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 10:10:53 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D6YJB-00006b-01
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 10:10:53 -0800
To: nhorman@redhat.com
In-Reply-To: <20050227192113.GA5778@localhost.localdomain>
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

su den 27.02.2005 Klokka 14:21 (-0500) skreiv nhorman@redhat.com:
> Hey all-
> 	I was wondering, how much interest there might be in the addition of
> support for BSD style locks (flocks) over NLM.  I was thinking that a bit could
> be added to differentiate the two namespaces.  Any thoughts appreciated.  

http://client.linux-nfs.org/Linux-2.6.x/2.6.11-rc5/linux-2.6.11-17-flock.dif

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
