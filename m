From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: [PATCH 2/3]: NFS: use atomic bitops to manipulate flags
	in nfsi->flags
Date: Mon, 11 Jul 2005 18:39:06 -0400
Message-ID: <1121121546.16899.1.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C611307CF4CF8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Nick Wilson <njw@osdl.org>,
	"Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
	nfs@lists.sourceforge.net, Daniel McNeil <daniel@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds6vu-0002Zc-Kp
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 15:39:26 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds6vt-0002jA-9V
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 15:39:26 -0700
To: "Lever, Charles" <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C611307CF4CF8@lavender-fe.eng.netapp.com>
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

m=C3=A5 den 11.07.2005 Klokka 14:53 (-0700) skreiv Lever, Charles:
> > > +
> > >  	atomic_inc(&inode->i_count);
> > > -	error =3D nfs_wait_event(clnt, nfsi->nfs_i_wait,
> > > -				!(NFS_FLAGS(inode) & flag));
> > > +	rpc_clnt_sigmask(clnt, &oldmask);
> > > +	error =3D wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
> > > +					nfs_wait_schedule,=20
> > TASK_INTERRUPTIBLE);
> >=20
> >                                                              =20
> >   ^^^^^^^^^^^^^
> > Shouldn't this depend on whether the client mounted with intr?
>=20
> roughly the same logic is used in net/sunrpc/sched.c:__rpc_execute, and
> it doesn't observe the intr flag either.  perhaps it is an ommission
> there too?

rpc_clnt_sigmask() should offer sufficient protection.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
