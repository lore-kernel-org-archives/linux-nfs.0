From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [kNFSD] [PATCH] fixed '-p port' arg to rpc.nfsd plus
	more.
Date: Mon, 21 Mar 2005 10:18:21 -0500
Message-ID: <1111418301.11588.8.camel@lade.trondhjem.org>
References: <423EDD43.8000209@RedHat.com>
	 <20050321145632.GB20587@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Steve Dickson <SteveD@redhat.com>,
	Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DDOgG-00057t-OC
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:19:00 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DDOgE-00038c-9l
	for nfs@lists.sourceforge.net; Mon, 21 Mar 2005 07:19:00 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <20050321145632.GB20587@fieldses.org>
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

m=E5 den 21.03.2005 Klokka 09:56 (-0500) skreiv J. Bruce Fields:
> On Mon, Mar 21, 2005 at 09:42:11AM -0500, Steve Dickson wrote:
> >     -N  or  --no-nfs-version vers
> >         This option can be used to request that rpc.nfsd does not  offe=
r
> >         certain  versions of NFS. The current version of rpc.nfsd can
> >         support both NFS version 2,3 and the newer version 4.
>=20
> We definitely need something like this, thanks!  Though I would have
> thought something like "--min-version" and "--max-version" would be more
> natural.  (What do other OS's do?)

--min-version and --max-version are indeed more in line with the RPC
model: the PROG_MISMATCH error offers a single range of supported
versions, and was never designed to say that you are offering NFSv2 and
v4, but not NFSv3.

That said, we have already added the -N option to rpc.mountd, so if we
fix rpc.nfsd, then we should also fix rpc.mountd.

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
