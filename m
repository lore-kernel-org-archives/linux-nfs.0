From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS problems, UMON, missing directories, wrong permissions
Date: 06 May 2003 13:48:56 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsr87c70t3.fsf@charged.uio.no>
References: <200305061042.02405.c.pollmeier@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D0wS-0003qa-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 04:49:04 -0700
To: Cajus Pollmeier <c.pollmeier@gmx.net>
In-Reply-To: <200305061042.02405.c.pollmeier@gmx.net>
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

>>>>> " " == Cajus Pollmeier <c.pollmeier@gmx.net> writes:

     > * Randomly missing directories / shredded permissions
     >   Either users don't see shared directories contents or have no
     >   permissions to access them. In fact they have, "id" shows up
     >   with the correct group membership and "ls -la" shows the
     >   directory group writable. After logging out and in again,
     >   everything's fine.

Please note that NFS doesn't support more than 16 groups. If the
permissions depend on the 17th group as listed by 'id', then it
probably won't work.

However that may not be the cause of your problem:

     >   May 6 07:12:59 terminalserver kernel: nsm:
     >   xdr_encode_mon(0a010002, -1249509120, 67108864, 268435456)

That's interesting. Looks like a pretty nasty stack corruption to
me. Are you running an Nvidia-tainted kernel by any chance?

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
