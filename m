From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: open O_EXCL works?
Date: Sun, 13 Mar 2005 13:44:38 -0500
Message-ID: <1110739478.10684.42.camel@lade.trondhjem.org>
References: <20050313141203.1044.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAY5F-0007EP-5Z
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 10:45:01 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAY5D-0006IQ-Ic
	for nfs@lists.sourceforge.net; Sun, 13 Mar 2005 10:45:01 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050313141203.1044.BRANDEN@terra.com.br>
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

su den 13.03.2005 Klokka 14:23 (-0300) skreiv Filipe Brandenburger:
> Hello,
> 
> I'm trying to find out if open(O_CREAT|O_EXCL) works or not in NFS. I
> read the RFC1813, and it says NFSv3 must implement it on the server, but
> even so I don't know if the client is doing it reliably or not.
> 
> My server is a Netapp FAS940, my client is Linux RH7.3 with kernel 2.4.9-e.38smp
> (the kernel is from RHAS2.1). I'm mounting the NFS with vers=3, the line
> that is output in the "mount" command for this filesystem is:
> 

2.4.x kernels do not implement O_EXCL opens in NFS due to VFS
limitations. In 2.6.x we fixed the VFS limitations by adding "intents"
and so those kernels implement O_EXCL correctly for both NFSv3 and
NFSv4.

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
