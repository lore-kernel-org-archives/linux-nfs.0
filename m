From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS problems, UMON, missing directories, wrong permissions
Date: 06 May 2003 14:35:06 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsisso6yo5.fsf@charged.uio.no>
References: <200305061042.02405.c.pollmeier@gmx.net>
	<shsr87c70t3.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cajus Pollmeier <c.pollmeier@gmx.net>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D1f8-0006In-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 05:35:14 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsr87c70t3.fsf@charged.uio.no>
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


     >>   May 6 07:12:59 terminalserver kernel: nsm:
     >>   xdr_encode_mon(0a010002, -1249509120, 67108864, 268435456)

     > That's interesting. Looks like a pretty nasty stack corruption
     > to me. Are you running an Nvidia-tainted kernel by any chance?

Duh. Forget that... For some reason or another xdr_encode_mon() has
been set up to print its arguments using network-order (and in
decimal). That's almost worth a bugfix in itself...

OK. The bug appears to be in userland then, since the UNMON request is
correct, and the /var/lib/nfs/sm does contain the 10.0.0.2 address.

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
