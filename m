From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: NFS retry on disconnection
Date: 14 May 2002 11:31:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsoffjf53d.fsf@charged.uio.no>
References: <Pine.LNX.4.44.0205141035150.22074-100000@sofie.lambo.student.liu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177Yen-0008VZ-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 02:31:46 -0700
To: Peter Astrand <astrand@lysator.liu.se>
In-Reply-To: <Pine.LNX.4.44.0205141035150.22074-100000@sofie.lambo.student.liu.se>
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

>>>>> " " == Peter Astrand <astrand@lysator.liu.se> writes:

     > Does this mean that the man page nfs(5) is incorrect? It says:

     > "intr

     > If an NFS file operation has a major timeout and it is hard
     > mounted, then allow signals to interupt the file operation and
     > cause it to return EINTR to the calling program."

That looks to be incorrect, yes.

    >> function 'lock_page()'.  That unfortunately means that it
    >> cannot interrupt, since 'lock_page()' does not do interruptible
    >> sleeps.

     > I see. And this is not possible to change?

Not without great effort, and it would demand considerable auditing to
determine exactly where interruptible sleeps make sense.

A better alternative might be to use asynchronous I/O (as in the POSIX
'aio' library functions). There are patches floating around for that
sort of thing.

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
