From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 11:07:46 -0800
Message-ID: <20050225190746.GG423992@jurassic.eng.sun.com>
References: <1109296629.5897.574.camel@seki.nac.uci.edu> <200502251706.24315.vincent.roqueta@ext.bull.net> <1109355225.5897.580.camel@seki.nac.uci.edu>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4koc-0007l6-O5
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 11:07:54 -0800
Received: from nwkea-mail-2.sun.com ([192.18.42.14])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1D4koa-0001GQ-Cx
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 11:07:54 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1109355225.5897.580.camel@seki.nac.uci.edu>
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

On Fri, Dan Stromberg wrote:
> On Fri, 2005-02-25 at 17:06 +0100, Vincent Roqueta wrote:
> > Le vendredi 25 F=E9vrier 2005 02:57, Dan Stromberg a =E9crit :
> > > Has anyone got NFSv4 working from an FC3 NFS server to a Solaris 10=
 NFS
> > > client?
> > >
> > > foobar-root /) mount seki.nac.uci.edu:/sdb1 /mnt
> > > nfs mount: mount: /mnt: Not owner
> > > foobar-root /) mount -o vers=3D3 seki.nac.uci.edu:/sdb1 /mnt
> > > foobar-root /)
> >=20
> > Yes. interop works fine.
>=20
> Cool!
>=20
> Unfortunately though, I don't know the first thing about setting up
> NFSv4.  I gather on the Solaris side, an NFSv4 domain is needed, and
> Solaris has a "take a guess at a good NFSv4 domain name" option.
>=20
> So:
>=20
> 1) How do I define the NFSv4 domain on FC3?
>=20
> 2) Is there a "take a guess" option on FC3?
>=20
> 3) Is there anything else I need to set up to get NFSv4 working?
>=20
> I perhaps should point out that the systems in question are using NIS,
> not kerberos.

The Solaris client will choose the DNS domain (if DNS is being used for
host resolution).  It will use the NIS domain if DNS is not being=20
used.  These can be overridden by setting the NFSMAPID_DOMAIN value
in /etc/default/nfs on Solaris.

The Soalris client will also use a DNS TXT RR record to obtain
the NFSv4 domain but at this point Solaris is the only platform
that does this (that I know of).

Spencer


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
