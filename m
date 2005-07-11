From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: [PATCH 2/3]: NFS: use atomic bitops to manipulate flags in nfsi->flags
Date: Mon, 11 Jul 2005 14:53:32 -0700
Message-ID: <482A3FA0050D21419C269D13989C611307CF4CF8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Bill Rugolsky Jr." <brugolsky@telemetry-investments.com>,
	<nfs@lists.sourceforge.net>, "Daniel McNeil" <daniel@osdl.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ds6Dc-0000jQ-4q
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 14:53:40 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1Ds6Db-0001lp-3n
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 14:53:40 -0700
To: "Nick Wilson" <njw@osdl.org>
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

> On Sat, Jul 09, 2005 at 08:33:06AM -0700, Lever, Charles wrote:
> >  Introduce atomic bitops to manipulate the bits in the=20
> nfs_inode structure's
> >  "flags" field.
> >=20
> >  Using bitops means we can use a generic wait_on_bit call=20
> instead of an ad
> >  hoc locking scheme in fs/nfs/inode.c, so we can remove the=20
> "nfs_i_wait"
> >  field from nfs_inode at the same time.
> >=20
> >  The other new flags field will continue to use bitmask and=20
> logic AND and
> >  OR.  This permits several flags to be set at the same time=20
> efficiently.
> >  The following patch adds a spin lock to protect these=20
> flags, and this spin
> >  lock will later cover other fields in the nfs_inode=20
> structure, amortizing
> >  the cost of using this type of serialization.
>=20
> Is there some place to document exactly which fields are=20
> being protected by the spinlock?

right now, of all the fields in nfs_inode, only nfsi->cache_validity is
completely protected via inode->i_lock.  nfsi->flags is now a field of
atomic bits, and does not need serialization.

the problem with documenting something like that is that the
documentation becomes out of date more quickly than you might expect.  i
think once we are done removing the BKL it will be pretty clear how
access to each field is serialized.

> [ ... ]
> >  /*
> >   * Wait for the inode to get unlocked.
> > - * (Used for NFS_INO_LOCKED and NFS_INO_REVALIDATING).
> >   */
> > -static int
> > -nfs_wait_on_inode(struct inode *inode, int flag)
> > +static int nfs_wait_on_inode(struct inode *inode)
> >  {
> >  	struct rpc_clnt	*clnt =3D NFS_CLIENT(inode);
> >  	struct nfs_inode *nfsi =3D NFS_I(inode);
> > -
> > +	sigset_t oldmask;
> >  	int error;
> > -	if (!(NFS_FLAGS(inode) & flag))
> > -		return 0;
> > +
> >  	atomic_inc(&inode->i_count);
> > -	error =3D nfs_wait_event(clnt, nfsi->nfs_i_wait,
> > -				!(NFS_FLAGS(inode) & flag));
> > +	rpc_clnt_sigmask(clnt, &oldmask);
> > +	error =3D wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
> > +					nfs_wait_schedule,=20
> TASK_INTERRUPTIBLE);
>=20
>                                                              =20
>   ^^^^^^^^^^^^^
> Shouldn't this depend on whether the client mounted with intr?

roughly the same logic is used in net/sunrpc/sched.c:__rpc_execute, and
it doesn't observe the intr flag either.  perhaps it is an ommission
there too?


-------------------------------------------------------
This SF.Net email is sponsored by the 'Do More With Dual!' webinar happening
July 14 at 8am PDT/11am EDT. We invite you to explore the latest in dual
core and dual graphics technology at this free one hour event hosted by HP, 
AMD, and NVIDIA.  To register visit http://www.hp.com/go/dualwebinar
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
