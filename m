From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [PATCH] lockd: unlock when client rejects GRANTED_MSG
Date: Wed, 4 Jul 2007 00:24:19 +0200
Message-ID: <20070703222419.GD16497@janus>
References: <20070629155226.GA25561@janus> <20070701143801.GA22967@janus>
	<20070701145832.GA17334@fieldses.org>
	<20070701151154.GA23704@janus>
	<20070703205302.GV14074@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I5qnB-0004JQ-Bz
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 15:24:17 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I5qnE-0006v1-Da
	for nfs@lists.sourceforge.net; Tue, 03 Jul 2007 15:24:20 -0700
In-Reply-To: <20070703205302.GV14074@fieldses.org>
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

On Tue, Jul 03, 2007 at 04:53:02PM -0400, J. Bruce Fields wrote:
> On Sun, Jul 01, 2007 at 05:11:54PM +0200, Frank van Maarseveen wrote:
> > On Sun, Jul 01, 2007 at 10:58:32AM -0400, J. Bruce Fields wrote:
> > > On Sun, Jul 01, 2007 at 04:38:01PM +0200, Frank van Maarseveen wrote:
> > > > 
> > > > When lockd grants a blocked lock request after a while then the client
> > > > response on it should not be ignored: When the client rejects GRANTED_MSG
> > > > with GRANTED_RES NLM_LCK_DENIED then lockd on the server must release
> > > > the POSIX lock.
> > > 
> > > There's not really any way to "remove" a posix lock.  All you can do is
> > > issue an unlock, which isn't quite the same--for example, consider the
> > > case when the granted lock was a read lock downgrading a previously
> > > write-locked region.  Or perhaps it was locking a region only some of
> > > whose bytes where previously locked.
> > > 
> > > I have some bit-rotting patches that define a new "provisional" lock
> > > type that is like a posix lock except that it isn't combined with other
> > > existing locks--such a lock has the advantage that it really can be
> > > completely undone.  You can then break up the lock-applying process into
> > > two steps:
> > > 
> > > 	1. first apply a "provisional" lock (marked with an FL_BLOCK
> > > 	   lock type in my code), then
> > > 	2. when whoever originally requested the lock requests it,
> > > 	   convert the provisional lock until a real posix lock,
> > > 	   combining it with other locks as necessary.
> > > 
> > > So we could handle your case by delaying step number 2 until we get an
> > > affirmative response to the grant.
> > 
> > The affirmative response will never happen
> 
> The point of that scheme is that we can also handle a negative response,
> since the provisional lock is (unlike a regular posix lock) something
> that can be cancelled.
> 
> But I don't know how useful that really is in this case.

I think your patch is addressing something different. It _might_ fix
the nlm_grant_reply() bug as a side effect but that's already done by
the small patch I posted earlier so... I think it is best to consider
these issues separately.

But I'm still unsure about who's picking up NLM patches and if server
or client side matters.


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
