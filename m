From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 10/14] SUNRPC: Enable support for rpcbind versions
	3 and 4 via CONFIG options
Date: Fri, 19 Jan 2007 00:11:31 +0000
Message-ID: <20070119001131.GC13473@infradead.org>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
	<20070118233045.23310.43704.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: trond.myklybust@fys.uio.no, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7hMK-00080a-K9
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:11:56 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7hML-0005xo-5v
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 16:11:58 -0800
To: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20070118233045.23310.43704.stgit@localhost.localdomain>
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

> +config RPCBIND_VERSION3
> +	bool "Support for rpcbind version 3"
> +	default n

default n is the default behaviour, you don't need to specify it.

> +config RPCBIND_VERSION4
> +	bool "Support for rpcbind version 4"

Do we really need two config options for this?


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
