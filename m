From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: 11 Jul 2002 13:26:07 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shs8z4i4ib4.fsf@charged.uio.no>
References: <200207091549.15913.trond.myklebust@fys.uio.no>
	<m3lm8ibkp6.fsf@merlin.emma.line.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Sc94-000515-00
	for <nfs@lists.sourceforge.net>; Thu, 11 Jul 2002 04:30:02 -0700
To: Matthias Andree <ma@dt.e-technik.uni-dortmund.de>
In-Reply-To: <m3lm8ibkp6.fsf@merlin.emma.line.org>
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

>>>>> " " == Matthias Andree <ma@dt.e-technik.uni-dortmund.de> writes:

     > What if the NFS stuff is not mounted with sync or explicitly
     > mounted async? Will an nfsd still do synchronous writes to
     > directories?

Of course. It is not possible for the NFS client to switch this
behaviour off, since it is part of the server side specifications in
the protocol.

The only thing that can screw you up is if you use the 'async' option
in /etc/exports on the server.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
PC Mods, Computing goodies, cases & more
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
