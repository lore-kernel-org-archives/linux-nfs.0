From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 10/14] SUNRPC: Enable support for rpcbind	versions
	3 and 4 via CONFIG options
Date: Fri, 19 Jan 2007 17:10:34 -0500
Message-ID: <1169244634.6262.20.camel@lade.trondhjem.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233045.23310.43704.stgit@localhost.localdomain>
	<20070119001131.GC13473@infradead.org>  <45B1405D.2000804@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H81wz-0000Lp-Ni
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:11:09 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18Hzk0jcePskUc6d9r28nEZDByXaqXvJZw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H81wu-0000dZ-6K
	for nfs@lists.sourceforge.net; Fri, 19 Jan 2007 14:11:05 -0800
To: chuck.lever@oracle.com
In-Reply-To: <45B1405D.2000804@oracle.com>
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

On Fri, 2007-01-19 at 17:04 -0500, Chuck Lever wrote:
> Christoph Hellwig wrote:
> >> +config RPCBIND_VERSION4
> >> +	bool "Support for rpcbind version 4"
> > 
> > Do we really need two config options for this?
> 
> I can easily combine these into a single option, but actually, do we 
> need any config option at all?  Trond, why not leave versions 3 and 4 
> enabled all the time?

Fine by me.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
