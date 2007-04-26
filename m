From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect sub-second
	timestamps on etab
Date: Thu, 26 Apr 2007 13:24:44 -0400
Message-ID: <20070426172444.GE4875@fieldses.org>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
	<20070426162300.GA12193@salusa.poochiereds.net>
	<20070426165800.GC4875@fieldses.org>
	<20070426170055.GA30402@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh7i2-0007jb-Mw
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:24:47 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hh7i4-0004ch-3Q
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:24:49 -0700
In-Reply-To: <20070426170055.GA30402@dantu.rdu.redhat.com>
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

On Thu, Apr 26, 2007 at 01:00:56PM -0400, Jeff Layton wrote:
> Not if the inode number is reused. That can occur on some filesystems if
> nothing is holding it open. Then again, if we're opening a new file and
> renaming it to the old name, then that might not be an issue here. Let me
> play with that idea and see...

Hm.  Grepping around: I didn't realize ext2/3/4 seem to have a
GETVERSION ioctl that returns the generation number.  But I don't know
if there's any more filesystem-independent way to do that.

(Is there some better way?  I don't understand why people would work so
hard on change notification without having a simple way to poll for
changes as well--otherwise you lose track of everything the moment the
watcher goes away, and you end up with beagle having to reread your
entire filesystem after every reboot.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
