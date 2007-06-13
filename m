From: Christoph Hellwig <hch@infradead.org>
Subject: Re: New NFS-RDMA Patchset
Date: Wed, 13 Jun 2007 04:40:56 +0100
Message-ID: <20070613034056.GA17058@infradead.org>
References: <1181662022.6343.14.camel@trinity.ogc.int>
	<1181705928.6616.16.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HyJjB-0001MH-JE
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 20:41:01 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HyJjE-0004TO-K1
	for nfs@lists.sourceforge.net; Tue, 12 Jun 2007 20:41:04 -0700
In-Reply-To: <1181705928.6616.16.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Jun 12, 2007 at 11:38:48PM -0400, Trond Myklebust wrote:
> On Tue, 2007-06-12 at 10:27 -0500, Tom Tucker wrote:
> > I have a new patchset that addresses almost all of the comments from the
> > last review. The patchset includes the transport switch and the rdma
> > transport driver. The patchset is rather large and has 33 patches. I'd
> > like some guidance as to whether I tar it up or just send them out.
> > 
> > Thanks,
> > Tom
> 
> If you are worried about the number of patches then there are 3 possible
> solutions:
> 
>      1. Provide a link to a website which lists the patches in an easily
>         reviewable format.
>      2. Put them up in a git tree, and send us a pointer
>      3. Just send us a pointer to the gitweb site for the git tree you
>         set up in 2. above :-)

Gitweb is extremly painfull to review, the only thing even worse is
a git tree without gitweb :)

the only reasonable formats for a big pile of patches to review are
a tarball of patches or a patchseries sent to a mailinglist.

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
