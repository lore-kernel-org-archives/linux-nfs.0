From: Tom McNeal <trmcneal@attbi.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for
 directories on NFS mounts
Date: Thu, 11 Jul 2002 13:05:18 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3D2DE4FE.35B1ABA7@attbi.com>
References: <E17SjDh-00067R-00@usw-sf-list2.sourceforge.net> <200207111414.03258.rdieter@math.unl.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Sk8U-0000Ez-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 13:01:58 -0700
To: Rex Dieter <rdieter@math.unl.edu>,
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

Rex Dieter wrote:
> 
> Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> 
> > >>>>> " " == Matthias Andree <ma@dt.e-technik.uni-dortmund.de> writes:
> >      > What if the NFS stuff is not mounted with sync or explicitly
> >      > mounted async? Will an nfsd still do synchronous writes to
> >      > directories?
> 
> > Of course. It is not possible for the NFS client to switch this
> > behaviour off, since it is part of the server side specifications in
> > the protocol.
> > The only thing that can screw you up is if you use the 'async' option
> > in /etc/exports on the server.
> 
> How is specifying 'async' in /etc/exports on the NFS server different than a
> NFS client explicitly mounting async?
> 
> -- Rex


The /etc/exports async option allows the server to tell the client
that it has indeed written data/metadata to the disk, regardless
of what has actually happened.

So, the client sync/async affects *when* the client writes to the
server, and the server sync/async affects *how* (OK, and *when*) the 
server replies to the client.  

Regards -

Tom

--
------------------------------------------------------------
Tom McNeal       trmcneal@attbi.com     (650)906-0761 (cell) 
------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
