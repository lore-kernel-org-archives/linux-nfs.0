From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 26 Apr 2007 13:00:56 -0400
Message-ID: <20070426170055.GA30402@dantu.rdu.redhat.com>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
	<20070426162300.GA12193@salusa.poochiereds.net>
	<20070426165800.GC4875@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh7LE-00059Q-Ng
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:01:12 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh7LG-0006Tq-6O
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:01:15 -0700
In-Reply-To: <20070426165800.GC4875@fieldses.org>
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

On Thu, Apr 26, 2007 at 12:58:00PM -0400, J. Bruce Fields wrote:
> On Thu, Apr 26, 2007 at 12:23:04PM -0400, Jeff Layton wrote:
> > I've had a look at this, and even took a pretty broad swipe at doing it. The
> > issue here is that a lot of the existing code is not well geared toward having
> > an already-open filehandle that gets passed around. Changing this is going to
> > mean a pretty invasive patch that adds quite a few new functions. I don't feel
> > confident that this method has enough advantages over your earlier patch to
> > make this worthwhile.
> > 
> > Neil, what do you think? Should I continue down this road, or should we just
> > go with what you've already written?
> 
> Wouldn't you get the same benefit just by storing (and comparing) the
> inode number and mtime of etab, instead of just the mtime?
> 
> --b.

Not if the inode number is reused. That can occur on some filesystems if
nothing is holding it open. Then again, if we're opening a new file and
renaming it to the old name, then that might not be an issue here. Let me
play with that idea and see...

-- Jeff



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
