From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: client write ordering
Date: Wed, 27 Sep 2006 13:23:24 -0400
Message-ID: <1159377804.5883.15.camel@lade.trondhjem.org>
References: <3A8D2969972400448F9C908CFE890D9503A34783@exchange1.DataDomain.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GSd8E-0008U9-M2
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 10:23:38 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GSd8D-0004M4-0A
	for nfs@lists.sourceforge.net; Wed, 27 Sep 2006 10:23:39 -0700
To: Bob Fozard <Bob.Fozard@datadomain.com>
In-Reply-To: <3A8D2969972400448F9C908CFE890D9503A34783@exchange1.DataDomain.com>
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

On Wed, 2006-09-27 at 09:26 -0700, Bob Fozard wrote:
> Using the NFSv3 client on Redhat's 2.6.15 x86, I've noticed that when
> writing large sequential files, it will sometimes send write RPC's to
> the server with very large gaps (> 1GB) in the file offset (i.e. my nice
> sequential writes are being occasionally randomized in a big way).
> While the ordering of write RPC's on the wire have often been noticed to
> be shuffled somewhat in earlier (e.g. 2.4) kernels, they were typically
> within a few MB's of each other at most.  The large gaps in
> sequentiality we're seeing with 2.6 are pretty undesirable to our server
> (and I dare say they're undesirable in general) and I'm searching for
> some insight as to how I might be able to bring back the 2.4 behavior,
> or whether this may be fixed in newer code.   BTW, we've noticed this
> with earlier FC4 versions also (e.g. 2.6.11), but has not been
> reproduced when running the x86_64 versions of the same kernels.  It
> should be noted that the x86 client has 3GB RAM, the x86_64 box has 4GB.
> Any suggestions are gratefully appreciated.

The NFSv3 and newer protocols allow server-side caching. A well-written
server shouldn't start flushing the data to disk unless the client tells
it to, or until memory pressure forces it to do so. Write ordering and
elevator algorithms are therefore not expected to have much of an effect
on performance. Are you seeing one?

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
