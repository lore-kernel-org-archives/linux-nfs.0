From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: open O_EXCL works?
Date: Mon, 14 Mar 2005 10:24:23 -0500
Message-ID: <1110813864.30085.47.camel@lade.trondhjem.org>
References: <20050313141203.1044.BRANDEN@terra.com.br>
	 <1110739478.10684.42.camel@lade.trondhjem.org>
	 <20050314080517.BD8F.BRANDEN@terra.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DArX4-0000hw-Rr
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:31:02 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DArX3-0004Oc-1y
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 07:31:02 -0800
To: Filipe Brandenburger <branden@terra.com.br>
In-Reply-To: <20050314080517.BD8F.BRANDEN@terra.com.br>
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

m=E5 den 14.03.2005 Klokka 08:18 (-0300) skreiv Filipe Brandenburger:

> My question is to know what would happen if:
> a) at the time the "lookup" call is made, the hardlink/symlink/directory
> does not exist yet, so that I can go to the next call;
> b) when I call the main function (link/symlink/mkdir), the
> hardlink/symlink/directory was already created by another process (maybe
> on another host).
>=20
> What I mean is, apparently (to me at least) there's a race condition
> there, that can only be circumvented if mkdir is using the error return
> from the mkdir RPC call besides the result of the lookup. Is that the
> case?
>=20
> What I mean is, if I have processes using mkdir to create a lock
> directory, can I be sure that no two processes will believe they created
> the directory at the same time?

Both symlink and mkdir return errors that close the race. In fact, we
shouldn't have to do that lookup at all (and one of these days, I will
get round to setting up the intent flags for all these cases).

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
