From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: 2.6.8.1 kernel NFS client connectathon failure
Date: Fri, 17 Sep 2004 11:54:05 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16714.17341.832452.765979@cse.unsw.edu.au>
References: <200409152054.i8FKsTNV002355@roma.math.duke.edu>
	<1095304285.8598.51.camel@lade.trondhjem.org>
	<16714.16573.467686.621248@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
    Andrew Schretter <schrett@math.duke.edu>,
    NFS@lists.sourceforge.net
In-Reply-To: message from Neil Brown on Friday September 17
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

On Friday September 17, neilb@cse.unsw.edu.au wrote:
> However with 2.6.9-rc1 on the client, something else happens.
> Before the rename of BAR to FOO there is a rename
> of FOO to .nfs000111a300000002.
> It appears to be doing a "silly rename" even though the file is not
> open.
> Immediately after the rename of BAR to FOO - which ofcourse works as
> FOO doesn't exist now, the .nfs000111a300000002 file is removed.
> 
> To me, this looks like the client doing the wrong thing - certainly an
> unnecessary thing, and in this case an unhelpful thing.

I just realised why it is definitely *Wrong*.
"rename" is meant to guarantee that the target name always exists.
Thus implementing
   rename BAR FOO
as
   rename FOO .nfsxxx
   rename BAR FOO
is clearly wrong as there is a moment when FOO doesn't exist.
   link FOO .nfsxxx
   rename BAR FOO
would be OK.

NeilBrown


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM.
Deadline: Sept. 24. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
