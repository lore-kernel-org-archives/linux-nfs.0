From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFS problems across reboot
Date: Mon, 8 Apr 2002 12:50:20 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15537.1388.991719.856639@notabene.cse.unsw.edu.au>
References: <3CACA93C.5010304@blue-labs.org>
	<3CAD6A78.4205CD61@moving-picture.com>
	<3CAFCE8C.5030300@blue-labs.org>
	<15535.55222.401084.736426@notabene.cse.unsw.edu.au>
	<20020407063953.GA30304@physics.cornell.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uPBp-0008GS-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 19:47:30 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <freedman@physics.cornell.edu>)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Mon, 8 Apr 2002 12:47:20 +1000
To: Daniel Freedman <freedman@physics.cornell.edu>
In-Reply-To: message from Daniel Freedman on Sunday April 7
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Sunday April 7, freedman@physics.cornell.edu wrote:
> 
> Hi,
> 
> I just checked the default NFS server init script from Debian stable (2.2)
> as found in '/etc/init.d/nfs-kernel-server'.  It appears to violate the
> above order, by starting exportfs *after* rpc.nfsd.  Am I missing something,
> please?

You are right.  2.2 has it wrong.  3.0 has it right.
I don't know the Debian policy on how serious a bug has to be to get
it fixed in "stable".  This isn't a *very* serious bug, but is
certainly can cause some problems.

> 
> Could this explain why I've seen the same behaviour as described in an
> earlier post in this thread: in other words, when the NFS server cleanly
> reboots, all clients with open file handles develop difficulty with NFS
> access (sorry I can't remember exact error, it hasn't happened in months);
> come to think of it, though, I don't have this problem with my Debian woody
> NFS server, which has the correct 'exportfs'/'rpc.nfsd' order in the
> init-scripts.

Yes.  This would explain exactly that behaviour.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
