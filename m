From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Smooth out NFS client writeback
Date: Tue, 07 Jun 2005 00:12:23 -0400
Message-ID: <1118117543.13667.28.camel@lade.trondhjem.org>
References: <20050602121624.41192.qmail@web30705.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DfVSC-0001Jk-Cc
	for nfs@lists.sourceforge.net; Mon, 06 Jun 2005 21:12:40 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DfVSB-0007Rh-Ie
	for nfs@lists.sourceforge.net; Mon, 06 Jun 2005 21:12:40 -0700
To: Shantanu Goel <sgoel01@yahoo.com>
In-Reply-To: <20050602121624.41192.qmail@web30705.mail.mud.yahoo.com>
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

to den 02.06.2005 Klokka 05:16 (-0700) skreiv Shantanu Goel:

> The low memory situation is avoided because of the
> congestion check I added in writepage().  If the inode
> is congested, it redirty's the page and returns.  It
> also issues a commit request if there are at least
> NFS_WRITE_CLUSTER pages.

This sounds very much like what we were doing in the early 2.6 series
when we were returning WRITEPAGE_ACTIVATE in order to achieve the same
effect. We ended up reverting those patches after learning that
systematically redirtying pages in low-memory situations may lead to
some _very_ nasty deadlocks.
The above have "works" for ramdisks because they have hard limits on the
amount of physical memory they can use in the form of the ramdisk size.
NFS OTOH really shouldn't do it, since it has no such limits, and can
basically end up eating all of physical memory.

Have you BTW tested the performance of the other changes without this
part of the patch? I assume the numbers you presented last week were for
the combined changes.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.  How far can you shotput
a projector? How fast can you ride your desk chair down the office luge track?
If you want to score the big prize, get to know the little guy.  
Play to win an NEC 61" plasma display: http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
