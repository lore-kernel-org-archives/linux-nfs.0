From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Some interoperability testing
Date: Tue, 08 Feb 2005 09:49:59 -0500
Message-ID: <1107874199.10364.22.camel@lade.trondhjem.org>
References: <200502071839.24804.vincent.roqueta@ext.bull.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyWh1-0000P3-5X
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 06:50:19 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyWgz-000160-KH
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 06:50:19 -0800
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200502071839.24804.vincent.roqueta@ext.bull.net>
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

ty den 08.02.2005 Klokka 10:22 (+0100) skreiv Vincent Roqueta:

> Since all is right with kernel 2.6.9, that looks like a regression...
> Even if that is the true behaviour it may exist a way to stop this process 
> cleanly : since NFS umount is can't be done the client does not reboot, and I 
> need  to turn the power off...

There were no NFS or RPC client changes made between 2.6.9 and 2.6.10,
so it looks like you're going to have to look at networking changes.

Since you are seeing problems with both UDP and TCP, then I would start
by checking whether or not any changes have been made to the network
card driver.

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
