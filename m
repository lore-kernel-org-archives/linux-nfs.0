From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Long sleep with i_mutex in xfs_flush_device(),
	affects	NFS service
Date: Tue, 26 Sep 2006 16:29:56 -0400
Message-ID: <1159302596.5492.57.camel@lade.trondhjem.org>
References: <Pine.LNX.4.64.0609191533240.25914@madrid.max-t.internal>
	<1159297579.5492.21.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0609261531430.10642@madrid.max-t.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, xfs@oss.sgi.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSJZI-0006WG-M8
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 13:30:17 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSJZH-0003kK-0b
	for nfs@lists.sourceforge.net; Tue, 26 Sep 2006 13:30:17 -0700
To: Stephane Doyon <sdoyon@max-t.com>
In-Reply-To: <Pine.LNX.4.64.0609261531430.10642@madrid.max-t.internal>
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

On Tue, 2006-09-26 at 16:05 -0400, Stephane Doyon wrote:
> I suppose it's not technically wrong to try to flush all the pages of the 
> file, but if the server file system is full then it will be at its worse. 
> Also if you happened to be on a slower link and have a big cache to flush, 
> you're waiting around for very little gain.

That all assumes that nobody fixes the problem on the server. If
somebody notices, and actually removes an unused file, then you may be
happy that the kernel preserved the last 80% of the apache log file that
was being written out.

ENOSPC is a transient error: that is why the current behaviour exists.

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
