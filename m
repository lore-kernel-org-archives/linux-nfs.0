From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: several messages
Date: Tue, 03 Oct 2006 12:40:42 -0400
Message-ID: <1159893642.5592.12.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<451A618B.5080901@agami.com>
	<Pine.LNX.4.64.0610020939450.5072@madrid.max-t.internal>
	<20061002223056.GN4695059@melbourne.sgi.com>
	<Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Chinner <dgc@sgi.com>, nfs@lists.sourceforge.net,
	Shailendra Tripathi <stripathi@agami.com>, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GUnKV-0003zt-C6
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 09:41:15 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GUnKT-0006dR-Tt
	for nfs@lists.sourceforge.net; Tue, 03 Oct 2006 09:41:16 -0700
To: Stephane Doyon <sdoyon@max-t.com>
In-Reply-To: <Pine.LNX.4.64.0610030917060.31738@madrid.max-t.internal>
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

On Tue, 2006-10-03 at 09:39 -0400, Stephane Doyon wrote:
> Sorry for insisting, but it seems to me there's still a problem in need of 
> fixing: when writing a 5GB file over NFS to an XFS file system and hitting 
> ENOSPC, it takes on the order of 22hours before my application gets an 
> error, whereas it would normally take about 2minutes if the file system 
> did not become full.
> 
> Perhaps I was being a bit too "constructive" and drowned my point in 
> explanations and proposed workarounds... You are telling me that neither 
> NFS nor XFS is doing anything wrong, and I can understand your points of 
> view, but surely that behavior isn't considered acceptable?

Sure it is. You are allowing the kernel to cache 5GB, and that means you
only get the error message when close() completes.

If you want faster error reporting, there are modes like O_SYNC,
O_DIRECT, that will attempt to flush the data more quickly. In addition,
you can force flushing using fsync(). Finally, you can tweak the VM into
flushing more often using /proc/sys/vm.

Cheers,
 Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
