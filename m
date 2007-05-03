From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect
	sub-second	timestamps on etab
Date: Thu, 3 May 2007 10:55:37 +1000
Message-ID: <17977.13065.307535.484372@notabene.brown>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
	<20070426120536.GB24800@dantu.rdu.redhat.com>
	<20070426162300.GA12193@salusa.poochiereds.net>
	<20070426165800.GC4875@fieldses.org>
	<20070426170055.GA30402@dantu.rdu.redhat.com>
	<20070426172444.GE4875@fieldses.org>
	<20070426182901.GA31081@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HjPcA-0003SF-87
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 17:56:10 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HjPcA-0006Cg-M7
	for nfs@lists.sourceforge.net; Wed, 02 May 2007 17:56:13 -0700
In-Reply-To: message from Jeff Layton on Thursday April 26
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

On Thursday April 26, jlayton@redhat.com wrote:
> 
> This patch seems to fix the problem as well. mountd holds the etab open, but
> doesn't actually do any I/O on that fd. This makes sure that the inode number
> of the new etab file won't be the same as the current version that mountd is
> aware of. I also added a comment to xtab_write to warn people who might
> consider changing how the files are written.
> 
> We might also consider adding back in some of the mtime logic to try and
> catch programs that edit the file in place, but I'm not sure if that's
> worthwhile.

I agree.

> 
> Neil, what do you think?

I was about to say "fine", but then saw the problem.
Because of the way get_exportlist uses the return value, that value
needs to unique over all time (or close to it).  So returning the
inode number won't work (as we have seen that ext3 cycles between
two).

A simple event counter could be returned though, which would give
something unique to get_exportlist.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
