From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: binaries becoming corrupt on nfs
Date: Mon, 14 Mar 2005 16:31:39 -0500
Message-ID: <1110835899.19295.42.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DAxAJ-0001lZ-6T
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:31:55 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DAxAH-00030J-KM
	for nfs@lists.sourceforge.net; Mon, 14 Mar 2005 13:31:55 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0503141414590.4702@harp.ngdc.noaa.gov>
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

m=E5 den 14.03.2005 Klokka 14:25 (-0700) skreiv Ara.T.Howard:
> we are seeing some really bizarre strange behaviour on our nfs systems.
> essentially a system will hum along nicely, running binaries from our nfs
> server without issue.  for no apparent reason these binaries suddenly bec=
ome
> corrupt on the client side and stop working.  running md5sum on the affec=
ted
> binary on a 'good' host and a 'bad' one shows them to, in fact, be differ=
ent.
>=20
> doing and unmount and remount fixes the issue.  obviously so does a reboo=
t.
> both are temporary fixes though - eventually a node will start getting co=
rrupt
> binaries - or perhaps not.

Do you perhaps have some cronjob or something that is updating the
binaries on the server?

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
