From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfs mount problem on vxfs
Date: Wed, 10 Jan 2007 11:47:25 -0500
Message-ID: <1168447645.13083.2.camel@lade.trondhjem.org>
References: <56800.63.119.254.10.1168372296.squirrel@mail.sonysnowie.com>
	<20070110124704.GA3350@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H4gcp-0006F7-Cy
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 08:48:31 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18P/3K+9vvW00jH7ZXz9AHkNrflQCC79y0=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H4gco-0007oX-Rw
	for nfs@lists.sourceforge.net; Wed, 10 Jan 2007 08:48:33 -0800
To: Christoph Hellwig <hch@infradead.org>, Neil Brown <neilb@suse.de>
In-Reply-To: <20070110124704.GA3350@infradead.org>
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

On Wed, 2007-01-10 at 12:47 +0000, Christoph Hellwig wrote:

> I haven't added support for nfs exporting to the vxfs driver.  To be honest
> it's quite old and didn't resource (time and actual  vxfs native systems)
> to test it again.

That brings up a point. Given that vxfs doesn't even define s_export_op,
why is he seeing a hang rather than an error?

It sounds to me as if he should be getting an EINVAL error on the call
to 'exportfs' on the server, as well as an immediate EACCES error when
he tries to mount it from the client.

Neil?

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
