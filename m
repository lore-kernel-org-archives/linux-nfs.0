From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: trouble with file locking
Date: Thu, 20 Nov 2003 02:36:47 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16316.28431.109436.403040@charged.uio.no>
References: <20031112105043.020c1548.erik@thiele-hydraulik.de>
	<Pine.LNX.4.58.0311191259400.846@lewis.et.byu.edu>
	<shsd6bohzxw.fsf@charged.uio.no>
	<20031120070531.7886de98.erik@thiele-hydraulik.de>
	<16316.23490.266052.855506@charged.uio.no>
	<20031120074957.6f1a95d5.erik@thiele-hydraulik.de>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no,
    davidd@et.byu.edu,
    nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AMjNh-0008H7-00
	for <nfs@lists.sourceforge.net>; Wed, 19 Nov 2003 23:37:37 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AMjN3-0007qU-9O
	for nfs@lists.sourceforge.net; Wed, 19 Nov 2003 23:36:57 -0800
To: Erik Thiele <erik@thiele-hydraulik.de>
In-Reply-To: <20031120074957.6f1a95d5.erik@thiele-hydraulik.de>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Erik Thiele <erik@thiele-hydraulik.de> writes:

     > from my original mail:


I know... I was responding to the suggestion that you use flock()
instead. That is a bad idea.

     > from my original mail:

     > i am exporting to old hp-ux machines a subdirectory of / like
     > this: /Archiv xxx.unix.yyy-intern(rw,no_root_squash)

     > i also export my homedirectory to my linux woody debian
     > machines like this: /home/erik
     > str.blafoo-intern(rw,no_root_squash)


     > .. so the question is, can different exports interfere with
     > each other with locking???

If the server is a linux box, then yes. I have a patch from Patrice
Dumas that fixes a bug w.r.t. 2 clients waiting on a lock. The current
code allows those waits to interfere with one another.
See

   http://www.fys.uio.no/~trondmy/src/Linux-2.4.x/2.4.23-rc1/linux-2.4.23-04-fix_lockd3.dif

     > can one lock files on a readonly export? (then this would be a
     > security problem, because if i mount an anonymous readonly
     > export with hp-ux, the other exports will fail to lock.


     > again, what i don't understand is that a restart of the statd
     > daemon fixes the problem forever.

That signals to the server that the client has rebooted (or vice
versa) and tells it to clear all locks (start lock recovery).

Cheers,
  Trond


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
