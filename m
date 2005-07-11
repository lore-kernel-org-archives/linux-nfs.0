From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH fs/locks 3 of 3] Fix race conditions with file
	lock vs close
Date: Mon, 11 Jul 2005 09:18:12 -0400
Message-ID: <1121087893.13326.25.camel@lade.trondhjem.org>
References: <20050711103254.GI27163@suse.de> <42D266C5.4010203@redhat.com>
	 <20050711125419.GS27163@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	akpm@osdl.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DryB6-0001oz-Vh
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:18:32 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.44)
	id 1DryB5-0005va-G3
	for nfs@lists.sourceforge.net; Mon, 11 Jul 2005 06:18:32 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20050711125419.GS27163@suse.de>
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

m=C3=A5 den 11.07.2005 Klokka 14:54 (+0200) skreiv Olaf Kirch:

> I just wonder how the following can work - your patch seems to drop
> local book-keeping of locks completely, unless I misread it:
>=20
>=20
> > +	if (filp->f_op && filp->f_op->lock !=3D NULL)
> >  		error =3D filp->f_op->lock(filp, cmd, file_lock);
> > +	else {
> > +		for (;;) {
> > +			error =3D __posix_lock_file(inode, file_lock);
> > +			if ((error !=3D -EAGAIN) || (cmd =3D=3D F_SETLK))
> > +				break;
> > +			error =3D wait_event_interruptible(file_lock->fl_wait,
> > +					!file_lock->fl_next);
> > +			if (!error)
> > +				continue;
> > +=09
> > +			locks_delete_block(file_lock);
> >  			break;
> > +		}
> > +	}
>=20
> This means if the application establishes an NFS lock, this will not
> be reflected locally - and as a consequence, when the application just
> exits, the lock will never be released.

In recent kernels, a filesystem that overrides the ->lock() method
should provide its own lock bookkeeping. Usually that means calling
posix_lock_file but it doesn't have to.

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
