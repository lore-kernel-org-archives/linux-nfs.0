From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 17:13:46 -0500
Message-ID: <1110838426.24466.17.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
	 <1110835899.19295.42.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0503141434390.4702@harp.ngdc.noaa.gov>
	 <1110836857.24466.4.camel@lade.trondhjem.org>
	 <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxoy-0003vY-Py
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:13:56 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxoy-0006zP-39
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 14:13:56 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0503141456140.4702@harp.ngdc.noaa.gov>
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

m=E5 den 14.03.2005 Klokka 14:59 (-0700) skreiv Ara.T.Howard:
> On Mon, 14 Mar 2005, Trond Myklebust wrote:
>=20
> > That was why I asked. If you update the binaries by copying into them (=
not
> > renaming + creating new file), then strange things will happen: you wil=
l not
> > see ESTALE, but you will usually see cache corruption.
>=20
> hmmm.  i HAVE compiled these binaries and copied them up - but last week.
> coud that make the cache so sick that it would not recover?

On Linux-2.4.x, mmap() will prevent the NFS client from clearing the
cache in a timely fashion, and so pages that should have been thrown out
of cache may become "frozen in" to the cache.

In Linux-2.6.x, that problem should hopefully have been fixed due to a
combination of updates to the memory management layer + NFS client
fixes.

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
