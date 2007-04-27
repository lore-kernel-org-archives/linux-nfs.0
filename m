From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 16:18:44 +0100
Message-ID: <20070427151844.GA23198@infradead.org>
References: <17958.48121.280256.493824@notabene.brown>
	<17968.18279.424773.589417@notabene.brown>
	<200704261059.50688.okir@lst.de> <200704271707.29862.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhSDf-0007bz-5u
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:18:48 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HhSDe-0000Nz-Cv
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 08:18:49 -0700
In-Reply-To: <200704271707.29862.okir@lst.de>
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

On Fri, Apr 27, 2007 at 05:07:28PM +0200, Olaf Kirch wrote:
> (In fact, the only bits I copied from the TIRPC code base were header
> files, but that's just because I like to tinker; I guess some things
> such as the netconfig stuff might as well be used verbatim, at the
> expense of making some code more complicated.)

I'd be interested in why people want the netconfig stuff.  I can't
see how it makes any sense out of context on a socket based system.


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
