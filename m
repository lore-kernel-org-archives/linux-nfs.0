From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Kernel NFS nfs_update_inode Oops in 2.6.20.11
Date: Wed, 27 Jun 2007 22:22:35 -0400
Message-ID: <20070628022235.GC20605@fieldses.org>
References: <20070623153345.GA22117@ligo.caltech.edu>
	<1182615064.5859.2.camel@heimdal.trondhjem.org>
	<20070623215131.GC27551@ligo.caltech.edu>
	<20070627230453.GA14474@ligo.caltech.edu>
	<1182986558.5311.70.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Stuart Anderson <anderson@ligo.caltech.edu>, MalteSch@gmx.de,
	nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3jed-0000d9-Cx
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:22:43 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I3jef-00034m-H9
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 19:22:46 -0700
In-Reply-To: <1182986558.5311.70.camel@heimdal.trondhjem.org>
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

On Wed, Jun 27, 2007 at 07:22:38PM -0400, Trond Myklebust wrote:
> On Wed, 2007-06-27 at 16:04 -0700, Stuart Anderson wrote:
> > This has patch has now been stable for 5 days on two different machines.
> > 
> > Any thoughts about the "bad sequence-id error"?
> 
> I seem to remember that a couple of sources of state corruption were
> found in the server in and around the 2.6.20 series. Do I remember
> correctly, Bruce?

I don't remember any (and don't see any relevant patches in a quick skim
of 'git log fs/nfsd').

Which isn't to say we couldn't have some problem there....

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
