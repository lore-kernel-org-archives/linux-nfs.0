From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Can someone explain me what this error means?
Date: Thu, 17 Mar 2005 17:59:02 -0500
Message-ID: <1111100343.11736.12.camel@lade.trondhjem.org>
References: <4239A9A3.5000109@framestore-cfc.com>
	 <1111075730.13215.19.camel@lade.trondhjem.org>
	 <200503171737.19660.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DC3xV-0007wX-U7
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 14:59:17 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DC3xT-0004b0-QM
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 14:59:17 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200503171737.19660.vincent.roqueta@ext.bull.net>
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

to den 17.03.2005 Klokka 17:37 (+0100) skreiv Vincent Roqueta:

> The kernel is the 2.4.20, using the e1000 driver... That looks like the bug I 
> had with UDP fragmentation? I used the same driver!

Possibly, but there are a bunch of patches that went into 2.4.21 that
look like they might be relevant:

v2.4.22-pre1:
  o kNFSd: TCP nfsd connection hangs when partial record header is
received
  o kNFSd: Make sure an early close on a nfs/tcp connection is handled
properly

I would first try to reproduce on a newer kernel.

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
