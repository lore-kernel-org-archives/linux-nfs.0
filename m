From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Multiple rpciod threads
Date: 14 Apr 2002 19:06:59 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shspu12tdjg.fsf@charged.uio.no>
References: <01C1E3DB.F0A8C5A0.halop@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16wnT5-00022T-00
	for <nfs@lists.sourceforge.net>; Sun, 14 Apr 2002 10:07:11 -0700
To: "halop@gmx.de" <halop@gmx.de>
In-Reply-To: <01C1E3DB.F0A8C5A0.halop@gmx.de>
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

>>>>> " " == halop  <halop@gmx.de> writes:

     > Hi, can someone tell me how to setup multiple rpciod threads?

     > I'm trying to boost my NFS througput on a multiproc SMP system
     > with 2 GigE NICs.

Not supported. There is little need for more than 1 rpciod thread, since

  - it is only used for asynchronous RPC requests in order to perform
    the completion.

  - unlike *BSD nfsiod threads rpciod is non-blocking. Once one RPC
    request has been processed up to the point where it needs to sleep
    pending I/O, rpciod goes on to handle the next one in the queue.

  - copying from the socket is handled directly by the networking
    layer bottom halves (for RPC over TCP this is not yet merged in
    to the official kernels, but UDP has done this for some time).

Cheers,
  Trond

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
