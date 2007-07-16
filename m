From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 00/17] RFC: proposed changes to the NFS mount
	command
Date: Mon, 16 Jul 2007 09:07:23 +0100
Message-ID: <20070716080723.GA19783@infradead.org>
References: <20070716030150.11209.85724.stgit@manray.1015granger.net>
	<18074.61070.150991.554588@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IALcH-0005A8-Hu
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 01:07:37 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IALcK-0005OQ-0J
	for nfs@lists.sourceforge.net; Mon, 16 Jul 2007 01:07:41 -0700
In-Reply-To: <18074.61070.150991.554588@notabene.brown>
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

On Mon, Jul 16, 2007 at 02:05:34PM +1000, Neil Brown wrote:
> I've wondered why that was happening... Can't we just make a version
> x+1 with a big string buffer so new options get put there is regular
> string format and old options stay the way they are?
> 
> But I guess that - long term - it is better to be just like other
> filesystems.

Having anything but a plain string means the filesystem is a complete
oddball.  And with the planned removal of smbfs nfs would be the only
oddball left.

> > option that will disable building nfsmount.c and nfs4mount.c, and
> > enable building a version of these files that will introduce support
> > for passing mount options as a string (that work is yet to be done).
> 
> Does this mean that you cannot compile nfs-utils to support both old
> and new kernels?  Is that really a good plan?
> What is the over-all migration strategy?

Making the different argument passing variants exclusive sounds like
a bad idea indeed.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
