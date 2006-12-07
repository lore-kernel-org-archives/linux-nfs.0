From: Christoph Hellwig <hch@infradead.org>
Subject: Re: asynchronous locks for cluster exports
Date: Thu, 7 Dec 2006 16:51:08 +0000
Message-ID: <20061207165108.GA21009@infradead.org>
References: <11653832602203-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	Marc Eshel <eshel@almaden.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsMSt-000140-BB
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 08:51:19 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsMSt-0003vd-G6
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 08:51:20 -0800
To: "J. Bruce Fields" <bfields@fieldses.org>
In-Reply-To: <11653832602203-git-send-email-bfields@fieldses.org>
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

On Wed, Dec 06, 2006 at 12:34:10AM -0500, J. Bruce Fields wrote:
> We'd like an asynchronous posix locking interface so that we can provide NFS
> 	- We added a new ->lock() export operation, figuring this was a feature
> 	  that only lockd and nfsd care about for now, and that we'd rather not
> 	  muck about with common locking code.  But the export operation is
> 	  pretty much identical to the file ->lock() operation; would it make
> 	  more sense to use that?

This definitly needs to be merged back into the ->lock file operation

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
