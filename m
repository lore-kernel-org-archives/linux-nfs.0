From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Fri, 17 Sep 2004 21:23:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095470605.6944.82.camel@lade.trondhjem.org>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
	 <1095304285.8598.51.camel@lade.trondhjem.org>
	 <16714.16573.467686.621248@cse.unsw.edu.au>
	 <1095390874.10216.191.camel@lade.trondhjem.org>
	 <20040917035515.GR23987@parcelfarce.linux.theplanet.co.uk>
	 <1095438880.7426.17.camel@lade.trondhjem.org>
	 <20040918001817.GX23987@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, Andrew Schretter <schrett@math.duke.edu>, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Alexander Viro <viro@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <20040918001817.GX23987@parcelfarce.linux.theplanet.co.uk>
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

P=E5 fr , 17/09/2004 klokka 20:18, skreiv
viro@parcelfarce.linux.theplanet.co.uk:
> >=20
> > Also, what is the target->i_sem protecting us against there?
>=20
> target->i_sem protects us against a lot of fun stuff - e.g. attempts to
> create a link to victim in the middle of removal, etc.

Ah, OK... We've been unhashing the dentry since day 1 in order to
achieve the same thing. That has the added advantage that it prevents
someone from coming along and actually opening the target: that's an
extra requirement in those cases where you have sillyrename semantics.


> FWIW, could we change the check in nfs_rename() and don't do that d_delet=
e()
> there?  The only potential trouble I can see is if target is itself
> sillyrenamed and we probably want to prevent that anyway...  Comments?

Do you have to unconditionally unhash new_dentry then?
=20
> Care to give a braindump on your async unlink logics?  The problem with
> doing that for local filesystems is that we need to protect the parent
> directory here...

It's fairly simple:

If the dentry->d_flags is marked with the sillyrename flag, then our
->d_delete() is rigged to cause dput() to kill the dentry.

The ->d_iput() method (i.e. dentry_iput()) is then responsible for
actually triggering the RPC call.

We do not actually try to lock down the directory while the unlink is on
the wire. That means we implicitly assume that nobody in their right
mind will look up or try to open a sillydeleted file and expect strict
POSIX behaviour.
The only thing that cares about the lookup behaviour of sillyrenamed
files is nfs_silly_rename() itself, and it is really only concerned
about avoiding naming collisions (and note that sillyrename is always
done while holding the dir->i_sem).

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
