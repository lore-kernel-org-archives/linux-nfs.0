From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: list of patches between 2.6.9 and 2.6.11-rc4
Date: Mon, 21 Feb 2005 19:05:38 -0500
Message-ID: <1109030738.22895.59.camel@lade.trondhjem.org>
References: <200502212335.25502.bernd-schubert@web.de>
	 <1109030592.22895.57.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3NYj-0002rg-Ou
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:05:49 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D3NYi-0004Rh-1n
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:05:49 -0800
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <1109030592.22895.57.camel@lade.trondhjem.org>
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

m=E5 den 21.02.2005 Klokka 19:03 (-0500) skreiv Trond Myklebust:

> You should really always be mounting using "nolock" when you are running
> against unfs3. Is that what you have normally been using?

Duh... Sorry, you've already answered that question in your mail....

Do you have a "strace" output of what ypbind is seeing?

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
