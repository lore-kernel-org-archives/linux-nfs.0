From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: oops in the 2.4.20-NFSALL sunrpc code
Date: Fri, 13 Dec 2002 18:39:08 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15866.6972.723553.421186@charged.uio.no>
References: <15865.65520.122137.890996@charged.uio.no>
	<Pine.LNX.4.44.0212131152280.15305-100000@moisil.badula.org>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18MtmQ-0000Ou-00
	for <nfs@lists.sourceforge.net>; Fri, 13 Dec 2002 09:39:18 -0800
To: Ion Badulescu <ionut@badula.org>
In-Reply-To: <Pine.LNX.4.44.0212131152280.15305-100000@moisil.badula.org>
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

>>>>> " " == Ion Badulescu <ionut@badula.org> writes:

     > Hmm... I can see two places where the NULL could be coming
     > from. One is calling rpc_init_task() with clnt==NULL, which
     > appears to be legal since the function checks clnt for NULL:

That would indeed be very borken behaviour, and would blow up in all
sorts of strange places. Feel free to put a BUG_ON() in there.

     > The other one would be rpc_release_task() if somehow an
     > xprt_timer is fired up, spins for a while on xprt->sock_lock,
     > and in the meantime rpc_release_task() is called and it
     > releases the client:

Should be impossible. See 11 lines further up:

        /* Synchronously delete any running timer */
        rpc_delete_timer(task);

Cheers,
  Trond


-------------------------------------------------------
This sf.net email is sponsored by:
With Great Power, Comes Great Responsibility 
Learn to use your power at OSDN's High Performance Computing Channel
http://hpc.devchannel.org/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
