From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Thu, 16 Sep 2004 23:14:34 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1095390874.10216.191.camel@lade.trondhjem.org>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
	 <1095304285.8598.51.camel@lade.trondhjem.org>
	 <16714.16573.467686.621248@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Andrew Schretter <schrett@math.duke.edu>, NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Neil Brown <neilb@cse.unsw.edu.au>, Alexander Viro <viro@parcelfarce.linux.theplanet.co.uk>
In-Reply-To: <16714.16573.467686.621248@cse.unsw.edu.au>
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

P=E5 to , 16/09/2004 klokka 21:41, skreiv Neil Brown:

> I find it hard to see how it is the server that is at fault.
>=20
> The effect of "subtree_check" in this case is that the same file (FOO
> and TEMP/BAR) has a different file-handle for each name. =20
>=20
> When the client tries to perform the "rename" request it checks the
> two names to see if they exist and what they are.
> In the no_subtree_check case it finds that they both have the same
> filehandle and so must be the same file, and as the rename request is
> defined to be a no-op in that case the client optimises it away.  (This i=
s
> based on reading the actual NFS traffic, not the NFS client code).
>=20
> In the subtree_check case, the two have different filehandles, though
> both are clearly files.
> In this case, one would think that the client would send the RENAME
> request, and the server would then notice that the two files are
> actually the same and would do nothing.  This is what appears to
> happen from a 2.4 client.


> However with 2.6.9-rc1 on the client, something else happens.
> Before the rename of BAR to FOO there is a rename
> of FOO to .nfs000111a300000002.
> It appears to be doing a "silly rename" even though the file is not
> open.
> Immediately after the rename of BAR to FOO - which ofcourse works as
> FOO doesn't exist now, the .nfs000111a300000002 file is removed.
>=20
> To me, this looks like the client doing the wrong thing - certainly an
> unnecessary thing, and in this case an unhelpful thing.

Yes. There does appear to be a bug in the vfs_rename_other() code. Al,
can you explain WTF we're doing an extra dget()/dput() on the target
dentry there? It appears to be totally arbitrary, and induces a totally
unnecessary sillyrename on all renames where an target file that is not
in use exists.

That said, the sillyrename issue is precisely WHY the client needs to be
able to do the check, and not the server. If the file *IS* open, we do
not want to be sillyrenaming it in a situation which should otherwise be
a no-op.

> If the file *were* open during the rename, then I can understand the
> need for a silly-rename.  However in that case it might be safer to do
> a silly-link instead (though I haven't tried to think through all the
> implications of this).
>=20
>=20
> Having said all that, I agree that subtree_check should be avoided
> where possible.  Maybe we should do what we did with "async" and print
> noisy warning messages....

At the very least, we should change the default.

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
