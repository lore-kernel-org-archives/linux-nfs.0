From: Ragnar =?iso-8859-15?Q?Kj=F8rstad?= <nfs@ragnark.vestdata.no>
Subject: Re: rpc.statd -n
Date: Wed, 2 Feb 2005 21:47:44 +0100
Message-ID: <20050202204744.GB14848@vestdata.no>
References: <Pine.LNX.4.60.0502021127170.8434@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CwRPs-0000GQ-LM
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 12:48:00 -0800
Received: from [217.149.127.10] (helo=stine.vestdata.no ident=0)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CwRPp-0003b2-1w
	for nfs@lists.sourceforge.net; Wed, 02 Feb 2005 12:47:59 -0800
To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
In-Reply-To: <Pine.LNX.4.60.0502021127170.8434@harp.ngdc.noaa.gov>
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

On Wed, Feb 02, 2005 at 11:41:52AM -0700, Ara.T.Howard wrote:
> i have a question regarding rpc.statd and it's reporting of hostname.  =
in=20
> the
> case of a multi-homed client, say one running nfs on the
>=20
>   client.b.domain
>=20
> interface.  rpc.statd must be forced to report itself as 'client.b.doma=
in'
> lest lockd recovery fail when it reports client.domain.  this is all we=
ll=20
> and
> good - but what if you have nfs running on more than one interface, lik=
e the
> case of home dirs on front-door and file-server on back-door?  now what=
 can
> you do?  if you specify the hostname for rpc.statd you'll break lock=20
> recovery
> on one or the other filesystem right?

Search the archives for "STATD - SM_NOTIFY have wrong ID_NAME on
multihost servers".


--=20
Ragnar Kj=F8rstad
Software Engineer
Scali - http://www.scali.com
High Performance Clustering


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
