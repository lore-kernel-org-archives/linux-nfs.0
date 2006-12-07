From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [GIT] Please pull the NFS client update for 2.6.19
Date: Wed, 06 Dec 2006 20:34:21 -0500
Message-ID: <1165455261.5744.71.camel@lade.trondhjem.org>
References: <1165424156.5744.10.camel@lade.trondhjem.org>
	<Pine.LNX.4.64.0612061713270.3542@woody.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gs89g-0002Sl-Il
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 17:34:32 -0800
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18yDeL3cG0MaBRSLpE0hrO4fOuom/dsqnw=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gs89g-0004e8-IL
	for nfs@lists.sourceforge.net; Wed, 06 Dec 2006 17:34:34 -0800
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0612061713270.3542@woody.osdl.org>
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

On Wed, 2006-12-06 at 17:16 -0800, Linus Torvalds wrote:
> 
> On Wed, 6 Dec 2006, Trond Myklebust wrote:
> > 
> >    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git
> > 
> > This will update the following files through the appended changesets.
> 
> Well, right now it conflicts with the workqueue cleanups. Can you fix up 
> the conflicts and push again? Quite frankly, I could try, but since I 
> don't even run NFS, I _really_ don't think you want me to do so.

OK. I'll fix it up and resend.

Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
