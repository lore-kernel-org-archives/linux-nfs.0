From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: FC3 <-> Solaris 10, NFSv4 interop?
Date: Fri, 25 Feb 2005 13:46:15 -0500
Message-ID: <20050225184615.GD23369@fieldses.org>
References: <1109296629.5897.574.camel@seki.nac.uci.edu> <200502251706.24315.vincent.roqueta@ext.bull.net> <1109355225.5897.580.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4kTf-0006q4-OX
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:46:15 -0800
Received: from dsl093-002-214.det1.dsl.speakeasy.net ([66.93.2.214] helo=pickle.fieldses.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1D4kTc-0007HC-3h
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 10:46:15 -0800
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

On Fri, Feb 25, 2005 at 10:13:45AM -0800, Dan Stromberg wrote:
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

For the Linux side, look through the documentation at

http://www.citi.umich.edu/projects/nfsv4/linux/

and then let us know if you're still having problems.  Corrections to
the documentation are also welcomed.--b.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=3D6595&alloc_id=3D14396&op=3Dclick
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
