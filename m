From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Fri, 17 Sep 2004 12:34:40 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095438880.7426.17.camel@lade.trondhjem.org>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
	 <1095304285.8598.51.camel@lade.trondhjem.org>
	 <16714.16573.467686.621248@cse.unsw.edu.au>
	 <1095390874.10216.191.camel@lade.trondhjem.org>
	 <20040917035515.GR23987@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, Andrew Schretter <schrett@math.duke.edu>, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Alexander Viro <viro@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040917035515.GR23987@parcelfarce.linux.theplanet.co.uk>
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

P=E5 to , 16/09/2004 klokka 23:55, skreiv
viro@parcelfarce.linux.theplanet.co.uk:
> On Thu, Sep 16, 2004 at 11:14:34PM -0400, Trond Myklebust wrote:
> > Yes. There does appear to be a bug in the vfs_rename_other() code. Al,
> > can you explain WTF we're doing an extra dget()/dput() on the target
> > dentry there? It appears to be totally arbitrary, and induces a totally
> > unnecessary sillyrename on all renames where an target file that is not
> > in use exists.
>=20
> We need to make sure that victim inode won't disappear on us.  Note that
> we are holding ->i_sem on it.

So dget() will block d_delete(), but is that really necessary? Is there
any reason why we couldn't just limit ourselves to doing an
igrab()/iput() instead?

Also, what is the target->i_sem protecting us against there?

> FWIW, I would love to take sillyrename logics to fs/namei.c.  First of
> all, that would make life _much_ simpler wrt keeping the locking logics
> in one place.  And NFS is not the only filesystem that doesn't handle
> opened-but-unliked stuff - NCPFS et.al. simply break on it and IIRC
> HFS+ tries to do a homegrown version and fails.
>=20
> Would something like
> 	sillyrename_target =3D dir->i_op->sillyrename(dir, victim);
> creating a suitable negative dentry encapsulate all NFS-specific
> logics in there?  ISTR that it would be enough, but I haven't looked
> at the details since 2.3.late...

Yes, that would clearly suffice as far as NFS is concerned. I've no idea
about what semantics the other filesystems want.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
