From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: nfs root directory security
Date: Wed, 18 Jun 2003 10:27:01 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <31B1521BD986E84E9D43651F8DF99BDC0134B416@POEXMB1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Cc: "Neil Brown" <neilb@cse.unsw.edu.au>, <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mailman2.ppco.com ([138.32.33.140])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Seyd-0005Kc-00
	for <nfs@lists.sourceforge.net>; Wed, 18 Jun 2003 08:35:59 -0700
To: "Scott Leerssen" <scott@leerssen.com>,
   "Bogdan Costescu" <bogdan.costescu@iwr.uni-heidelberg.de>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Scott,

If you really want to be scared, try=20
"showmount -a servername"
This will tell the server to list the clients and what filesystems they =
have
mounted.  And unguessable becomes a non-issue, and anyone can grab =
anyone
elses data since they know exactly what partition to mount.


		Roger

> -----Original Message-----
> From:	Scott Leerssen [SMTP:scott@leerssen.com]
> Sent:	Wednesday, June 18, 2003 9:28 AM
> To:	Bogdan Costescu
> Cc:	Neil Brown; nfs@lists.sourceforge.net
> Subject:	Re: [NFS] nfs root directory security
>=20
> I agree with everything you say here, and in a controlled and fairly
> unchanging environment with clients you trust, exporting to specific
> clients is a perfectly acceptable solution.  All I'm suggesting is
> adding an extra "layer of the onion" by restricting the ability to =
mount
> read-restricted directories.  It gives us the ability to create
> mountable filesystems for each server in a path that can not be
> traversed by mounting higher level directories.
>=20
> Imagine if the B and C paths of /A/B/C/root are cryptographically
> generated names, and that C is different for every mount point, B is
> different for every "repository", and A is simply an anchor in the =
root
> of my NAS.  I can export my clients root filesystems as:
>=20
>    /A 192.168.100.0/255.255.255.0(rw,no_root_squash,...)
>=20
> If B and C are unmountable and unguessable (without a lot of failed =
and
> obvious nfs mount attempts), I don't have to worry about anyone but =
the
> intended client mounting its root filesystem (assuming the network is
> safe from sniffing DHCP and mount requests).  Plus, I don't have to =
have
> an entry for every single client.  I could, and that would buy me an
> added bit of assurance, but I don't need one so it's much easier to
> maintain hundreds of mount points.
>=20
> Of course, there's a lot more to securing an NFS environment such as
> this, particularly when you can't trust the clients to behave.  This
> tweak just eases the burden of managing exports for hundreds (or
> thousands) of clients on as many NAS as you can imagine.  The burden =
is
> shifted to managing unreadable pathnames in the management software...
> (sigh).
>=20
> That's about all I have to add on this... feel free to use the patch =
or,
> if you haven't already, delete it from your inbox.
>=20
> --=20
> Scott Leerssen <scott@leerssen.com>
>=20
>=20
>=20
> -------------------------------------------------------
> This SF.Net email is sponsored by: INetU
> Attention Web Developers & Consultants: Become An INetU Hosting =
Partner.
> Refer Dedicated Servers. We Manage Them. You Get 10% Monthly =
Commission!
> INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
