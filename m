From: Oren D <oren01@gmail.com>
Subject: Re: When does NFSv3 client uses FILE_SYNC?
Date: Wed, 10 Nov 2004 18:34:37 +0200
Message-ID: <150dc27e041110083475a838b9@mail.gmail.com>
References: <150dc27e04111008051d64dbd1@mail.gmail.com>
	 <200411101721.40039.vincent.roqueta@ext.bull.net>
Reply-To: Oren D <oren01@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CRvQd-0007l9-RW
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:34:39 -0800
Received: from rproxy.gmail.com ([64.233.170.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CRvQc-0007ST-W4
	for nfs@lists.sourceforge.net; Wed, 10 Nov 2004 08:34:39 -0800
Received: by rproxy.gmail.com with SMTP id y7so13463rne
        for <nfs@lists.sourceforge.net>; Wed, 10 Nov 2004 08:34:37 -0800 (PST)
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>
In-Reply-To: <200411101721.40039.vincent.roqueta@ext.bull.net>
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

> Le mercredi 10 Novembre 2004 17:05, Oren D a =E9crit :
>=20
>=20
> > Hi all,
> >
> > Can someone please list for me the conditions under which an NFSv3
> > client would send FILE_SYNC write requests?
> >
> > I have the filesystem exported on the server with the sync option
> > (which is not supposed to prevent the client from writing with
> > UNSTABLE),
> > and mounted from the client with the default mount options.
> >
> > And still i have a user-space application that generates WRITEs with
> > FILE_SYNC!
> >
> > This is what I know that can make the client write using FILE_SYNC:
> > - mount -o sync
> > - open(...,O_SYNC)
>=20
> What kernel is it?
> For a 2.6.x one, if the export's sync option is set all request will be
> synchronised, (even if the file is opened async... )
>=20
> (I remember some problems with that... )
>=20
>=20
> Vincent
>=20

Kernels are 2.4 (RH9) both client and server.
I read that the sync export option does not prevent the client (in NFS
v3) from working async.
And i see it for a fact when using simple dd or cp commands. It's only
that specific application generating FILE_SYNC writes on the same
mounted filesystem. It has to be something controlled by a userspace
application. I checked with the authors of the application, and they
say their not using O_SYNC, that's why i'm looking for other options.

Regards,
Oren.


-------------------------------------------------------
This SF.Net email is sponsored by:
Sybase ASE Linux Express Edition - download now for FREE
LinuxWorld Reader's Choice Award Winner for best database on Linux.
http://ads.osdn.com/?ad_id=5588&alloc_id=12065&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
