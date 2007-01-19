From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/14] NFS: fix print format for tk_pid
Date: Fri, 19 Jan 2007 00:03:19 +0000
Message-ID: <20070119000319.GA13473@infradead.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118232925.23310.31437.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hEO-0006XP-8k
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:03:44 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hEO-0004HS-Q1
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:03:46 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20070118232925.23310.31437.stgit@localhost.localdomain>
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

On Thu, Jan 18, 2007 at 06:29:27PM -0500, Chuck Lever wrote:
> The tk_pid field is an unsigned short.  The proper print format specifier for
> that type is %5u, not %4d.
> 
> Also clean up some miscellaneous print formatting nits.

Once you cleanup all these printks please make sure to add line breaks
after at most 80 characters.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
