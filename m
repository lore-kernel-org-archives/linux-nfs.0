From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 13/15] SUNRPC: RPC buffer size estimates are too
	large
Date: Wed, 24 Jan 2007 16:01:31 -0500
Message-ID: <20070124210131.GD6587@fieldses.org>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
	<20070124192020.31133.78494.stgit@localhost.localdomain>
	<20070124204724.GB6587@fieldses.org> <45B7C69D.1090709@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9pFX-000374-7C
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:01:47 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9pFY-0005DZ-Iy
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 13:01:45 -0800
In-Reply-To: <45B7C69D.1090709@oracle.com>
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

On Wed, Jan 24, 2007 at 03:50:37PM -0500, Chuck Lever wrote:
> I've been running Connectathon and fsx-odirect with hundreds of 
> thousands of ops on a kernel that has all the slab debugging options 
> enabled.  I haven't hit a problem yet.

That's not going to exercise all the possible buffer calculations--it
probably doesn't perform any ACL operations, for example.

I wonder if it would be possible to generate those buffer sizes directly
from the .x files or something?

> And besides, the RPC buffers are all a fixed size (2kiB), and much 
> larger than required already.  The slack is "built in" to the buffer size.

OK.  Do we know of any calls or replies that are close to that limit?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
