From: Olaf Kirch <okir@lst.de>
Subject: Re: Portmap - was Re: Does mountd/statd really need to listen
	on a privileged port??
Date: Fri, 27 Apr 2007 19:07:36 +0200
Message-ID: <200704271907.37089.okir@lst.de>
References: <17958.48121.280256.493824@notabene.brown>
	<200704271707.29862.okir@lst.de>
	<20070427151844.GA23198@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhTvB-00021L-WF
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:07:50 -0700
Received: from verein.lst.de ([213.95.11.210] helo=mail.lst.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhTvD-0001bd-4S
	for nfs@lists.sourceforge.net; Fri, 27 Apr 2007 10:07:52 -0700
In-Reply-To: <20070427151844.GA23198@infradead.org>
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

On Friday 27 April 2007 17:18, Christoph Hellwig wrote:
> I'd be interested in why people want the netconfig stuff.  I can't
> see how it makes any sense out of context on a socket based system.

Well, it's a nice if you have a single handle that ties address family,
socket type, ipproto and a name (aka netid) together. That's all, at
least from my point of view. Representing all that info as strings
in a netconfig object is not all that useful

Olaf
-- 
Olaf Kirch  |  --- o --- Nous sommes du soleil we love when we play
okir@lst.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
