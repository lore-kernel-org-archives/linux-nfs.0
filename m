From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [Fwd: Re: NFS problems across reboot]
Date: Mon, 8 Apr 2002 12:44:07 +1000 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15537.1015.272089.720395@notabene.cse.unsw.edu.au>
References: <3CB0E93C.5D08BA1A@tricord.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uP5i-0006DC-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 19:41:10 -0700
Received: From notabene ([129.94.211.194] == dulcimer.orchestra.cse.unsw.EDU.AU)
	(for <ABorchers@tricord.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Mon, 8 Apr 2002 12:40:59 +1000
To: Al Borchers <ABorchers@tricord.com>
In-Reply-To: message from Al Borchers on Sunday April 7
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

On Sunday April 7, ABorchers@tricord.com wrote:
> Neil --
> 
> > From: Neil Brown <neilb@cse.unsw.edu.au>
> > My guess is that "exportfs -a" is being run *After* rpc.nfsd.
> > It must must run *before* for correct operation.
> 
> I did not know this.  Can you explain why?

If a NFS request arrives after nfsd is started, and before exportfs is
run, the server will return "ESTALE".  The client will think that it's
filehandle is stale and will fail all future accesses.  Even if it
only failed this one access, it would still be a problem.

So you could not start the nfsd until all exported filesystems have
been mounted and exported.

This will not always manifest as a real problem: it depends on how
hard the clients are hitting the server and how small the window is
between starting nfsd and exporting the filesystems, but it certainly
can be a problem.


> 
> Our situation -- We run a proprietary file system that holds
> the exported directories, but it does not start up until _after_
> nfs is started.  On a reboot, we run "exportfs -a" again after
> our file system is up, so the clients that held mounts before the
> reboot don't get stale file handle errors.  (The first run of
> exportfs, before rpc.nfsd, did not find the exported directories
> since the file system they are on was not up yet.)
> 
> Will this be a problem?  Should we delay starting nfs until _after_
> our file system is up?

It would be best if you did.

NeilBrown

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
