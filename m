From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [GIT] NFS client updates for 2.6.22...
Date: Fri, 04 May 2007 18:14:33 -0400
Message-ID: <1178316873.6533.24.camel@heimdal.trondhjem.org>
References: <1178117571.5435.10.camel@heimdal.trondhjem.org>
	<1178219691.24217.20.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hk634-0007r5-FT
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 15:14:50 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+JTZHGfu3edZR23Er5UWU2ziIBZt3zpT8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Hk635-0003zJ-LT
	for nfs@lists.sourceforge.net; Fri, 04 May 2007 15:14:49 -0700
In-Reply-To: <1178219691.24217.20.camel@twins>
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

On Thu, 2007-05-03 at 21:14 +0200, Peter Zijlstra wrote:
> On Wed, 2007-05-02 at 07:52 -0700, Trond Myklebust wrote:
> > Hi Linus,
> > 
> > Please pull from the repository at
> > 
> >    git pull git://git.linux-nfs.org/pub/linux/nfs-2.6.git
> 
> I can confirm that this solves my missing IO completions problem; or at
> least, my test has been running for 8h+ and still going strong, whereas
> previous I would be lucky to get 1h.
> 
> Would it be reasonable to include the relevant patches in a
> later .21-stable release?
> 

Well... The read/write fixes turn out to be 7 patches, doing ~ 350
insertions and 420 deletions. I dunno if that is really something the
stable folks will want to take on...

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
