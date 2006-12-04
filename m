From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: smart nfs client software
Date: Mon, 04 Dec 2006 17:51:03 -0500
Message-ID: <1165272663.5698.57.camel@lade.trondhjem.org>
References: <Pine.LNX.4.62.0612041456520.26411@harp.ngdc.noaa.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GrMea-0003H3-B0
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 14:51:16 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19EPyA0u4bR0kvUQD5BErkeywu2glPwlEc=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GrMea-0004KD-Fm
	for nfs@lists.sourceforge.net; Mon, 04 Dec 2006 14:51:17 -0800
To: ara.t.howard@noaa.gov
In-Reply-To: <Pine.LNX.4.62.0612041456520.26411@harp.ngdc.noaa.gov>
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

On Mon, 2006-12-04 at 14:58 -0700, ara.t.howard@noaa.gov wrote:
> is there any such beast as an nfs aware 'cp'?
> 
> it seems like some smart software on the client side might be able to illicit
> a sendfile type operation on the server for big reads...

Your 'cp' would have to be aware not only of NFS, but would also need
some sort of special daemon running on the server: the NFS protocol
itself does not support streaming.
I'm not aware of any such beast.

Cheers
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
