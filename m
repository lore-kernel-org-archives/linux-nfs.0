From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Issue with parallel writes over NFS
Date: Thu, 20 Oct 2005 14:15:36 -0700
Message-ID: <1129842936.9750.15.camel@lade.trondhjem.org>
References: <D821697F08061F4FBB069FA1AAAA92370C4646@hoexmb7.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EShlS-0003QR-D4
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 14:15:54 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EShlQ-0003vX-Uq
	for nfs@lists.sourceforge.net; Thu, 20 Oct 2005 14:15:54 -0700
To: "Weathers, Norman R." <Norman.R.Weathers@conocophillips.com>
In-Reply-To: <D821697F08061F4FBB069FA1AAAA92370C4646@hoexmb7.conoco.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

to den 20.10.2005 klokka 14:25 (-0500) skreiv Weathers, Norman R.:
> The strange thing is that this exact same code, test and actual
> application, run extremely well behaved on
> linux 2.4 kernel based distro's, and it doesn't seem to care if the code
> uses multiples of 4k or some other
> multiple, or something off the wall like 24000 bytes.

Yes. In the interest of better performance for standard buffered I/O,
we've moved towards a model where we page align block writes in the case
where the user is not locking or using direct I/O. This improves the
ability of the client to coagulate pages into r/wsized blocks.

Can you move the application over to using direct I/O? It sounds to me
as if this is pretty much what you want to be using in this environment
anyway. Note that unlike the case of 2.4.x kernels, the NFS direct I/O
implementation in 2.6.x does not have any page or block alignment
requirements.

Cheers,
 Trond



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
