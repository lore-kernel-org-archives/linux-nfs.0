From: Neil Brown <neilb@suse.de>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Mon, 2 Apr 2007 09:35:29 +1000
Message-ID: <17936.16833.295258.406430@notabene.brown>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
	<20070401121641.GB26681@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HY9aD-00087s-Dy
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 16:35:37 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HY9aE-0001nl-BR
	for nfs@lists.sourceforge.net; Sun, 01 Apr 2007 16:35:39 -0700
In-Reply-To: message from Frank van Maarseveen on Sunday April 1
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

On Sunday April 1, frankvm@frankvm.com wrote:
> On Thu, Mar 29, 2007 at 07:31:25PM +1000, Neil Brown wrote:
> > 
> > Hmm... good question.
> > 
> > I think:
> > 
> >   - idmapd and gssd should be started before any nfs mount
> >   - idmapd and svcgssd should be started before nfsd
> >   - mountd should start before nfsd.
> 
> At first that seems the logically correct order but suppose a client
> succeeds in mounting something but issues NFS requests before nfsd got
> started on the server?

That shouldn't matter.  The NFS server will not respond so the client
will retry.
Ofcourse if you have a soft mount it could get messy, but then soft
mounts are always messy.

> 
> where's the exportfs?

Good point.  exportfs should be run before mountd is started, and
after nfsd filesystem is mounted.

NeilBrown


> 
> Consider a "sleep 30" at every point in the startup sequence and think
> about what would go wrong. Also consider a dead-again server at every
> point in the startup sequence.
> 
> -- 
> Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
