From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] knfsd: set the response bitmask for
	NFS4_CREATE_EXCLUSIVE (repost)
Date: Wed, 27 Jun 2007 23:14:16 -0400
Message-ID: <20070628031416.GE20605@fieldses.org>
References: <20070627092903.82f468cd.jlayton@redhat.com>
	<18050.54805.859007.848292@notabene.brown>
	<20070627212805.GA6267@fieldses.org>
	<20070627213047.1ecf1c09.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfsv4@linux-nfs.org,
	nfs@lists.sourceforge.net
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3kSY-0005gC-9A
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:14:18 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3kSa-0001cV-EU
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 20:14:21 -0700
In-Reply-To: <20070627213047.1ecf1c09.jlayton@redhat.com>
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

On Wed, Jun 27, 2007 at 09:30:47PM -0400, Jeff Layton wrote:
> Here's a respun patch that includes an updated comment in nfsd_create_v3.
> Look ok?

Looks fine to me, thanks.  So this tells the client which attributes it
should set in a subsequent setattr?

It's queued up in my tree, so if Neil doesn't take it then I'll pass it
along to him for v2.6.23....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
