From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] lockd: unlock when client rejects GRANTED_MSG
Date: Sun, 1 Jul 2007 10:58:32 -0400
Message-ID: <20070701145832.GA17334@fieldses.org>
References: <20070629155226.GA25561@janus> <20070701143801.GA22967@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I50tX-0004pR-6y
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 07:59:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I50sm-0001L1-NO
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 07:58:37 -0700
In-Reply-To: <20070701143801.GA22967@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Sun, Jul 01, 2007 at 04:38:01PM +0200, Frank van Maarseveen wrote:
> 
> When lockd grants a blocked lock request after a while then the client
> response on it should not be ignored: When the client rejects GRANTED_MSG
> with GRANTED_RES NLM_LCK_DENIED then lockd on the server must release
> the POSIX lock.

There's not really any way to "remove" a posix lock.  All you can do is
issue an unlock, which isn't quite the same--for example, consider the
case when the granted lock was a read lock downgrading a previously
write-locked region.  Or perhaps it was locking a region only some of
whose bytes where previously locked.

I have some bit-rotting patches that define a new "provisional" lock
type that is like a posix lock except that it isn't combined with other
existing locks--such a lock has the advantage that it really can be
completely undone.  You can then break up the lock-applying process into
two steps:

	1. first apply a "provisional" lock (marked with an FL_BLOCK
	   lock type in my code), then
	2. when whoever originally requested the lock requests it,
	   convert the provisional lock until a real posix lock,
	   combining it with other locks as necessary.

So we could handle your case by delaying step number 2 until we get an
affirmative response to the grant.  I don't think my previous attempt
actually considered that case; I was mainly interested in NFSv4.  The
code's at

	git://linux-nfs.org/~bfields/linux.git	fair-queueing

(see the next-to-latest patch on that branch).

But I don't know how much trouble it's worth going to to get this right;
the NLM protocol is inherently racy.  Is this something you saw in real
life?  What was the client, and why did it refuse the grant?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
