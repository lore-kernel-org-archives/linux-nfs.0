From: Olaf Kirch <okir@lst.de>
Subject: Re: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Mon, 30 Apr 2007 08:08:11 +0200
Message-ID: <200704300808.12914.okir@lst.de>
References: <17973.19011.690165.95878@notabene.brown>
	<1177899233.6400.58.camel@heimdal.trondhjem.org>
	<17973.26166.844328.279844@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiP3k-0001u3-MF
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 23:08:28 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiP3l-0002cm-QV
	for nfs@lists.sourceforge.net; Sun, 29 Apr 2007 23:08:31 -0700
In-Reply-To: <17973.26166.844328.279844@notabene.brown>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Monday 30 April 2007 05:44, Neil Brown wrote:
>  - you cannot hold both an fcntl lock and a flock for the same file at
>    the same time (thus NFS breaks local file semantics again) or

It would be nice if we could at least return EDEADLOCK
and do a printk("%s tried to take flock+posix lock\n", current->comm);
I think in general the current behavior isn't that bad, and I wouldn't
expect many apps to be affected. In general, MUAs will usually
implement either flock or fcntl locks, but not both at the same time.
Except for procmail, which has always been a bit... special.

>  - we return to the unfortunate but well-understood situation that
>    flock locks don't work over NFS.

I don't think we want that.

>  - massive rewrite of the lockd code so that the client doesn't depend
>    on the server for local arbitration, and the client needs to
>    potentially send lots of subrange unlocks for a single unlock
>    call.

Don't go there. You basically need to copy fs/locks.c and butcher it
badly. On a per-file and per-owner basis, you need to maintain a
list of ranges and their lock status. They would be overlapping
(shared locks), and the semantics on unlock would be a mess
because of the different inheritance rules for posix vs flock locks.

> What would you think of an "noflock" option to allow people to choose
> the old practice of not supporting flock???

I'd suggest, fix procmail and be done with it :-)

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
