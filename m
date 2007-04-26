From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 26 Apr 2007 13:33:19 -0400
Message-ID: <20070426173316.GB12193@salusa.poochiereds.net>
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
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh7qJ-0000Fr-OW
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:33:21 -0700
Received: from ms-smtp-02.southeast.rr.com ([24.25.9.101])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hh7qM-0007Sm-0k
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 10:33:22 -0700
Received: from mail.poochiereds.net (cpe-071-070-159-068.nc.res.rr.com
	[71.70.159.68])
	by ms-smtp-02.southeast.rr.com (8.13.6/8.13.6) with ESMTP id
	l3QHXJkP017442
	for <nfs@lists.sourceforge.net>; Thu, 26 Apr 2007 13:33:19 -0400 (EDT)
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
> On Thu, Apr 26, 2007 at 12:58:00PM -0400, J. Bruce Fields wrote:
> > On Thu, Apr 26, 2007 at 12:23:04PM -0400, Jeff Layton wrote:
> > > I've had a look at this, and even took a pretty broad swipe at doing it. The
> > > issue here is that a lot of the existing code is not well geared toward having
> > > an already-open filehandle that gets passed around. Changing this is going to
> > > mean a pretty invasive patch that adds quite a few new functions. I don't feel
> > > confident that this method has enough advantages over your earlier patch to
> > > make this worthwhile.
> > > 
> > > Neil, what do you think? Should I continue down this road, or should we just
> > > go with what you've already written?
> > 
> > Wouldn't you get the same benefit just by storing (and comparing) the
> > inode number and mtime of etab, instead of just the mtime?
> > 
> > --b.
> 
> Not if the inode number is reused. That can occur on some filesystems if
> nothing is holding it open. Then again, if we're opening a new file and
> renaming it to the old name, then that might not be an issue here. Let me
> play with that idea and see...
> 
> -- Jeff
> 

Yep, that won't fix the problem on my test rig (excuse the ugly reproducer
line and output):

# exportfs -ua ; pkill rpc.mountd ; sleep 1 ; exportfs -rv ; stat /var/lib/nfs/etab && rpc.mountd -d all && exportfs -uva ; stat /var/lib/nfs/etab && exportfs -iv -o no_root_squash,rw 127.0.0.1:/foo ; stat /var/lib/nfs/etab && exportfs -v && showmount -e 127.0.0.1
exporting *:/export
  File: `/var/lib/nfs/etab'
  Size: 165             Blocks: 16         IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 2091908     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-04-26 13:11:17.000000000 -0400
Modify: 2007-04-26 13:11:17.000000000 -0400
Change: 2007-04-26 13:11:17.000000000 -0400
  File: `/var/lib/nfs/etab'
  Size: 0               Blocks: 8          IO Block: 4096   regular empty file
Device: fd00h/64768d    Inode: 2091920     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-04-26 13:11:17.000000000 -0400
Modify: 2007-04-26 13:11:17.000000000 -0400
Change: 2007-04-26 13:11:17.000000000 -0400
exporting 127.0.0.1:/foo
  File: `/var/lib/nfs/etab'
  Size: 162             Blocks: 16         IO Block: 4096   regular file
Device: fd00h/64768d    Inode: 2091908     Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-04-26 13:11:17.000000000 -0400
Modify: 2007-04-26 13:11:17.000000000 -0400
Change: 2007-04-26 13:11:17.000000000 -0400
/foo            127.0.0.1(rw,wdelay,no_root_squash,no_subtree_check)
Export list for 127.0.0.1:
/foo 127.0.0.1

This was testing with Neil's latest patch, which does seem to fix the
issue.  Anyway, on this test with /var/lib/nfs on ext3, the exportfs -uva
changed the inode number, but the next exportfs command immediately changed
it back. So if Neil's patch wasn't present, then I don't think mountd would
have picked up the changes. I'm not sure that tracking the inode number alone
will give us any real benefit.

My earlier patch was focused on keeping the etab held open by mountd and doing
all I/O to that file via the held-open fd. Maybe that's overkill, and we should
keep most of the existing logic (where we open and close the file) and simply
have an 'extra' fd to keep inode numbers unique. I'll give that a try and see
if it's more reasonable...

-- Jeff


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
