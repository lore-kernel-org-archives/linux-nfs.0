From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: SM_UNMON again -> kernel
Date: 14 Jul 2003 10:47:52 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <shsu19pijev.fsf@charged.uio.no>
References: <20030711061615.GA1924@quasar.nro.au.com>
	<shsr84x768e.fsf@charged.uio.no>
	<20030713042557.GA12903@quasar.nro.au.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19bz0G-0002ly-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 01:48:12 -0700
To: Lawrence Ong <lawrence.ong@netregistry.com.au>
In-Reply-To: <20030713042557.GA12903@quasar.nro.au.com>
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

>>>>> " " == Lawrence Ong <lawrence.ong@netregistry.com.au> writes:

     > Anyhow, it shows that the kernel is still continually sending
     > out unmonitor packets to statd at regular intervals.  What the?
     > Why is this happening?

What's wrong with that: I presume you *are* releasing locks every now
and then?

There's no point in monitoring a server on which you're not holding
any locks.

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
