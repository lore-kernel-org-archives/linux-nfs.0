From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Fri, 17 Sep 2004 11:41:17 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16714.16573.467686.621248@cse.unsw.edu.au>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
	<1095304285.8598.51.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andrew Schretter <schrett@math.duke.edu>,
    NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: message from Trond Myklebust on Wednesday September 15
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

On Wednesday September 15, trond.myklebust@fys.uio.no wrote:
> P=E5 on , 15/09/2004 klokka 16:54, skreiv Andrew Schretter:
> > The attached code is a blatant rip from the latest connectathon cod=
e that
> > was stripped down to show exactly where it fails on my 2.6.8.1 NFS =
client.
> > Note that this code works on the local disk and on a 2.4.22 client =
(both to
> > a 2.6.8.1 server and a 2.4.22 server) but fail from a 2.6.8.1 clien=
t to
> > both 2.4.22 and 2.6.8.1 servers.
> >=20
>=20
>=20
> This question keeps recurring on this list. The answer is the same no=
w
> as it was before: Fix the bloody servers!!!!
>=20
>    subtree_check is INCOMPATIBLE with correct rename behaviour, and i=
t
> is simply ridiculous that this is still a default option.

I find it hard to see how it is the server that is at fault.

The effect of "subtree_check" in this case is that the same file (FOO
and TEMP/BAR) has a different file-handle for each name. =20

When the client tries to perform the "rename" request it checks the
two names to see if they exist and what they are.
In the no_subtree_check case it finds that they both have the same
filehandle and so must be the same file, and as the rename request is
defined to be a no-op in that case the client optimises it away.  (This=
 is
based on reading the actual NFS traffic, not the NFS client code).

In the subtree_check case, the two have different filehandles, though
both are clearly files.
In this case, one would think that the client would send the RENAME
request, and the server would then notice that the two files are
actually the same and would do nothing.  This is what appears to
happen from a 2.4 client.

However with 2.6.9-rc1 on the client, something else happens.
Before the rename of BAR to FOO there is a rename
of FOO to .nfs000111a300000002.
It appears to be doing a "silly rename" even though the file is not
open.
Immediately after the rename of BAR to FOO - which ofcourse works as
FOO doesn't exist now, the .nfs000111a300000002 file is removed.

To me, this looks like the client doing the wrong thing - certainly an
unnecessary thing, and in this case an unhelpful thing.

If the file *were* open during the rename, then I can understand the
need for a silly-rename.  However in that case it might be safer to do
a silly-link instead (though I haven't tried to think through all the
implications of this).


Having said all that, I agree that subtree_check should be avoided
where possible.  Maybe we should do what we did with "async" and print
noisy warning messages....

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
