From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: flock and lockf over NFS and the 'pid' in lockd requests.
Date: Mon, 30 Apr 2007 09:17:40 -0400
Message-ID: <1177939060.6392.16.camel@heimdal.trondhjem.org>
References: <17973.19011.690165.95878@notabene.brown>
	<1177899233.6400.58.camel@heimdal.trondhjem.org>
	<17973.26166.844328.279844@notabene.brown>
	<200704300808.12914.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HiVlB-0003eQ-TK
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 06:17:50 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18CrnLY+B9kvxWzPc+8B8zqAvm9cGTzdUY=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HiVlD-0002Sp-Kg
	for nfs@lists.sourceforge.net; Mon, 30 Apr 2007 06:17:48 -0700
In-Reply-To: <200704300808.12914.okir@lst.de>
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

On Mon, 2007-04-30 at 08:08 +0200, Olaf Kirch wrote:
> On Monday 30 April 2007 05:44, Neil Brown wrote:
> >  - you cannot hold both an fcntl lock and a flock for the same file at
> >    the same time (thus NFS breaks local file semantics again) or
> 
> It would be nice if we could at least return EDEADLOCK
> and do a printk("%s tried to take flock+posix lock\n", current->comm);
> I think in general the current behavior isn't that bad, and I wouldn't
> expect many apps to be affected. In general, MUAs will usually
> implement either flock or fcntl locks, but not both at the same time.
> Except for procmail, which has always been a bit... special.

EDEADLK isn't really a valid flock() error, but I wouldn't object to
returning ENOLCK if someone tries to take both a flock and a posix lock.

> >  - massive rewrite of the lockd code so that the client doesn't depend
> >    on the server for local arbitration, and the client needs to
> >    potentially send lots of subrange unlocks for a single unlock
> >    call.
> 
> Don't go there. You basically need to copy fs/locks.c and butcher it
> badly. On a per-file and per-owner basis, you need to maintain a
> list of ranges and their lock status. They would be overlapping
> (shared locks), and the semantics on unlock would be a mess
> because of the different inheritance rules for posix vs flock locks.

Yeah. You also lose the ability to do things like lockf(fd, F_ULOCK, 0)
in order to atomically release all locks on the file. That has
consequences for fair queueing of blocking locks, etc...

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
