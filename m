From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs and iptables
Date: Tue, 08 Feb 2005 09:41:01 -0500
Message-ID: <1107873661.10364.13.camel@lade.trondhjem.org>
References: <Pine.LNX.4.60.0502072228370.22564@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CyWYR-00006R-OP
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 06:41:27 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CyWYP-00031w-AZ
	for nfs@lists.sourceforge.net; Tue, 08 Feb 2005 06:41:27 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0502072228370.22564@harp.ngdc.noaa.gov>
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

m=E5 den 07.02.2005 Klokka 22:44 (-0700) skreiv Ara.T.Howard:

> in summary: we allow *any* incoming connection to our server(s) from clie=
nts
> on the backdoor (nfs on backdoor only); do we need anything special on an=
y of
> the clients or is all communication initiated from the client?
>=20

As I told you before. Lock recovery assumes that rpc.statd on the server
can contact the clients after a server reboot. If you don't allow that,
then it is quite possible for the client not to notice that the server
has rebooted until after the grace period has expired.

IOW: lock recovery may indeed "work" without this, but you are leaving
yourself open to races that may crash your application and/or cause data
corruption.

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
