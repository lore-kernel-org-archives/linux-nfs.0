From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Problem with permissions
Date: 18 Apr 2002 09:23:11 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shshem9h3mo.fsf@charged.uio.no>
References: <5.1.0.14.2.20020418115542.058a25a0@pop.cs.curtin.edu.au>
	<15550.27591.650445.471426@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Shirley <dave@cs.curtin.edu.au>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16y6GU-0006GC-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 00:23:34 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15550.27591.650445.471426@notabene.cse.unsw.edu.au>
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

>>>>> " " == Neil Brown <neilb@cse.unsw.edu.au> writes:

     > The server has to allow the client computer to read such a file
     > so that it can then execute it.  However the client computer
     > should restrict client applications to only using "exec" on the
     > file, not "open".

        mmap(/proc/<pid>/mem);

There isn't really a good way to restrict an application to only exec
the file. I believe you will find more reasons why Al & Linus have
refused to implement this if you trawl through the l-k archives.

     > What client OS are you using?  I seem to recall that there was
     > a time when the Linux NFS client didn't use ACCESS requests,
     > but I think that has been fixed (but Trond could say for sure).

ACCESS is unfortunately not yet fully implemented in any of the
existing Linux kernels. I still need to work on a good way to cache
the results.
At the moment we only check in order to try to overturn a false
negative on the permissions. Here we are talking about a false
positive.

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
