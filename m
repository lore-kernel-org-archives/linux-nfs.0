From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS retry on disconnection
Date: 14 May 2002 10:16:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shssn4vf8jo.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0205140833140.20950-100000@sofie.lambo.student.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177XUa-0003QF-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 01:17:08 -0700
To: Peter =?iso-8859-1?q?=C5strand?= <astrand@lysator.liu.se>
In-Reply-To: <Pine.LNX.4.44.0205140833140.20950-100000@sofie.lambo.student.liu.se>
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

>>>>> " " == astrand  <Peter> writes:


     > One thing that keeps annoying me is that "intr" only allows
     > interrupting the file operation when a major timeout happens. I

Nope. Major, minor, it all goes through the same code and both can be
interrupted. What can happen, though, is that one process could
actually be waiting on another process.

If, say, they are both waiting to read data from the same page, then
only one process actually does the RPC call. The VFS/MM layers will
put the other process to sleep in the global function 'lock_page()'.
That unfortunately means that it cannot interrupt, since 'lock_page()'
does not do interruptible sleeps.

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
