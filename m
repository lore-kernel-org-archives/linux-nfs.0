From: Christoph Hellwig <hch@infradead.org>
Subject: Re: cel's patches for 2.6.18 kernels
Date: Wed, 20 Sep 2006 21:20:10 +0100
Message-ID: <20060920202010.GA22954@infradead.org>
References: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GQ8Z7-0001yC-5P
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 13:21:05 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GQ8Z6-0004OA-NP
	for nfs@lists.sourceforge.net; Wed, 20 Sep 2006 13:21:06 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30609201128r9188a17i51b779c6e1b569fc@mail.gmail.com>
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

On Wed, Sep 20, 2006 at 02:28:10PM -0400, Chuck Lever wrote:
> This e-mail announces the release of cel's patch set for Linux 2.6.18
> kernels.  The patchset contains several important features, including:
> 
> 1.  The finishing patches for the RPC client transport switch
> 
> 2.  Support for rpcbind protocol versions 2 and 3
> 
> 3.  Some support for IPv6 in the RPC and NFS clients
> 
> 4.  Elimination of the BKL in the RPC and NFS clients
> 
> 5.  Elimination of the RPC slot table

What's the merge plan for those patches?  The transport switch and ipv6
code is eagerly anticipated by many people.


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
