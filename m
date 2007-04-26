From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfs-utils: make auth_reload respect	sub-second
	timestamps on etab
Date: Thu, 26 Apr 2007 08:35:11 -0400
Message-ID: <20070426123511.GA453@fieldses.org>
References: <20070425173918.GB6696@salusa.poochiereds.net>
	<20070425180932.GC6696@salusa.poochiereds.net>
	<20070425201354.GD6696@salusa.poochiereds.net>
	<462FC850.7040600@oracle.com>
	<17968.12554.934818.359167@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Jeff Layton <jlayton@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hh3Bq-0006oU-VO
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 05:35:15 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hh3Bs-0006Hg-B9
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 05:35:17 -0700
In-Reply-To: <17968.12554.934818.359167@notabene.brown>
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

On Thu, Apr 26, 2007 at 02:56:42PM +1000, Neil Brown wrote:
> Actually, mountd could open etab and hold it open. auth_reload could
> stat "/var/lib/nfs/etab" and if it is a different file, then the
> content is presumably different, while if it is the same file, we can
> be certain the content is unchanged.
> 
> Further, we would be certain only to read each version once - zero
> risk of re-parsing data when there is no change.
> 
> That might be an even better option .... anyone want to code it up??
> 
> Or is it wrong to depend on current exportfs behaviour?

Would it be worth continuing to check the mtime as well, at least for a
transitional period?  (And if we see the file modified without being
replaced, we could emit a warning asking the user to notify us how that
happened.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
