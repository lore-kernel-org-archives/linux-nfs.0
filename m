From: Al Borchers <ABorchers@tricord.com>
Subject: [Fwd: Re: NFS problems across reboot]
Date: Sun, 07 Apr 2002 19:50:04 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3CB0E93C.5D08BA1A@tricord.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from mx01.tricord.com ([64.240.27.4] helo=ns1.tricord.com)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16uNOO-0002GQ-00
	for <nfs@lists.sourceforge.net>; Sun, 07 Apr 2002 17:52:21 -0700
To: nfs@lists.sourceforge.net
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

Neil --

> From: Neil Brown <neilb@cse.unsw.edu.au>
> My guess is that "exportfs -a" is being run *After* rpc.nfsd.
> It must must run *before* for correct operation.

I did not know this.  Can you explain why?

Our situation -- We run a proprietary file system that holds
the exported directories, but it does not start up until _after_
nfs is started.  On a reboot, we run "exportfs -a" again after
our file system is up, so the clients that held mounts before the
reboot don't get stale file handle errors.  (The first run of
exportfs, before rpc.nfsd, did not find the exported directories
since the file system they are on was not up yet.)

Will this be a problem?  Should we delay starting nfs until _after_
our file system is up?

We are still having some problems with stale file handles on reboot,
even after the second exportfs, but it only happens occasionally.
Sometimes it goes away after a minute or two, sometimes not.

We are running 2.4.17 on both clients and servers.

Thanks for any info on this, 
-- Al

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
