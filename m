From: jpmg@eng.cam.ac.uk
Subject: purpose of knfsd reply cache
Date: Fri, 5 Apr 2002 13:45:28 GMT
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200204051345.19407@tulip.eng.cam.ac.uk>
Received: from spanner.eng.cam.ac.uk ([129.169.8.9])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16tU29-0002EY-00
	for <nfs@lists.sourceforge.net>; Fri, 05 Apr 2002 05:45:41 -0800
Received: from tigger.eng.cam.ac.uk
          (via root@tigger.eng.cam.ac.uk [129.169.80.71])
          by spanner.eng.cam.ac.uk with ESMTP id OAA03275
          for <nfs@lists.sourceforge.net>; Fri, 5 Apr 2002 14:45:31 +0100 (BST)
Received: from tulip.eng.cam.ac.uk
          (via mailuser@tulip [129.169.81.11])
          by tigger.eng.cam.ac.uk with ESMTP id NAA24484
          for <nfs@lists.sourceforge.net>; Fri, 5 Apr 2002 13:45:29 GMT
Received: (via jpmg@localhost)
          by tulip.eng.cam.ac.uk id NAA19407
          for nfs@lists.sourceforge.net; Fri, 5 Apr 2002 13:45:28 GMT
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

I'm trying to pin down a data corruption corruption bug in knfsd .  As
a side effect, I've been looking at the reply cache, and getting puzzled.

Any answers to any of the following very much appreciated!

a) am I correct in thinking that the comment in both nfs3proc.c and
   nfsproc.c 
   * Only the results of non-idempotent operations are cached.
   should actually read
   * Only the results of idempotent operations are cached.

   [ ie, only operations that are idempotent (acts as if used only once
   even if used many times) can safely be "faked" on subsequent calls
   by using the cached reply data ]

b) given the set of operations for which reply caching is allowed, is
   it not the case that the only likely cause of a reply cache hit is
   when a client sends a request, the server handles the request, the
   reply is lost, so the client repeats the request?

c) on my server, "nfsstat -o rc" suggests that around 0.0005% of replies
   that could have been cached were hits.  Is my server unusual?  Does
   nfsstat correctly report this statistic?  If the answers to those
   are "no" and "yes", then is the reply cache worth bothering with?  

-patrick.

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
