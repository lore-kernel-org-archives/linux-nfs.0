From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: Re: jumbo frames and performance
Date: Mon, 17 Jun 2002 14:13:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D0E5106.6392471@attbi.com>
References: <E17K1pY-00014i-00@usw-sf-list2.sourceforge.net> <3D0E3491.10309@rockefeller.edu> <3D0E3D05.3010108@rockefeller.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc53.attbi.com ([204.127.198.39])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17K3lv-0001nz-00
	for <nfs@lists.sourceforge.net>; Mon, 17 Jun 2002 14:10:47 -0700
To: Raphael Clifford <cliffor@rockefeller.edu>,
 	NFS maillist <nfs@lists.sourceforge.net>
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

> as far as i know, jumbo frames are supported only on gigabit.

Yup, you're right.  Duh.

> >>> Also, since you're using 0.3.3 utils, I assume you are using sync
> >>> exports; otherwise there are costs at the server which are hidden
> >>> from the benchmark data.
> >
> > if you use "sync" the server behaves like all other NFS servers
> > and pushes data to disk when the client asks it to.  if you
> > use "async" the server ignores the client, and pushes data to
> > disk when it feels like it.
> >
> > so, if you benchmark with "async" you get artificially good
> > write results because the server responds "OK" to write requests
> > before it has really written them to disk.  "async" is not
> > an option you would ever use in a production environment,
> > naturally.
> >
> 
> Right, performance from the client perspective is explained in the faq
> (actually its not really presented from any particular perspective, but
> its closest to the client perspective) but I thought the point being
> made above was that the server suffers from a large overhead too.  So
> there are two perspectives. The first is that async is faster for the
> client and corrupts your data and the second is whether or not it
> reduces the load for the server.  This is not explained explicitly in
> the HOWTO.


What I meant by "costs at the server which are hidden from the 
benchmark data" was the cost of getting the data to the disk,
and the fact that this is hidden from the measurements you
are taking at the client, when the server uses the 0.3.3 async
default.  The actual load on the server may be somewhat different
in sync and async, due to the fact that the write to the disk
might be bundled with other writes when doing it asynchronously,
but I'm not really sure how significant that would be.

Tom


--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------

----------------------------------------------------------------------------------------------------
                                     Sponsor's Message
----------------------------------------------------------------------------------------------------
                      Bringing you mounds of caffeinated joy
                         >>>     http://thinkgeek.com/sf    <<<

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
