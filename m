From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Can someone explain me what this error means?
Date: Thu, 17 Mar 2005 11:08:50 -0500
Message-ID: <1111075730.13215.19.camel@lade.trondhjem.org>
References: <4239A9A3.5000109@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBxYb-0004ci-UG
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:09:09 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBxYa-0004Ze-2G
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:09:09 -0800
To: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
In-Reply-To: <4239A9A3.5000109@framestore-cfc.com>
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

to den 17.03.2005 Klokka 16:00 (+0000) skreiv Johan van den Dorpe:
> Mar 16 12:25:55 nyserv1 kernel: rpc-srv/tcp: nfsd: sent only 5160 bytes 
> of 8324 - shutting down socket
> 
> We get this just before the machine becomes inaccessable from the network.

Is this an error from the kernel nfs daemon? If so, which kernel are you
running, 'cos there is no such error message in Linux-2.6.11.

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
