From: Olaf Kirch <okir@suse.de>
Subject: Re: NSM lock recovery fails too often
Date: Tue, 9 Mar 2004 16:10:54 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309151054.GF14419@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com> <20040309142200.GC14419@suse.de> <1078844671.4067.1.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Charles Lever <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0j1Z-0001M0-6q
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:20:05 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0isi-00067q-Nd
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:10:56 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1078844671.4067.1.camel@nidelv.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, Mar 09, 2004 at 10:04:32AM -0500, Trond Myklebust wrote:
> P=E5 ty , 09/03/2004 klokka 09:22, skreiv Olaf Kirch:
>=20
> > I forgot to mention in my previous message that the kernel-statd patc=
h
> > requires Andreas Gruenbacher's sunrpc patch that lets you register
> > several RPC services on a single socket (originally written for his
> > nfsacl implementation)
>=20
> For 2.6.x, see the rpc_clone_client() function...

That's something different; rpc_clone_client is client side.

What I was referring to was the ability to have several RPC programs on a
single svc_sock server side; e.g. NFS and NFSACL, or NLM and NSM. Pretty
much the way svc_register from the good ole sunrpc code works.

Olaf
--=20
Olaf Kirch     |  Stop wasting entropy - start using predictable
okir@suse.de   |  tempfile names today!
---------------+=20


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
