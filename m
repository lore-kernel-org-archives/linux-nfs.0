From: Olaf Kirch <okir@suse.de>
Subject: Re: NSM lock recovery fails too often
Date: Tue, 9 Mar 2004 16:59:28 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040309155927.GL14419@suse.de>
References: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com> <20040309142200.GC14419@suse.de> <1078844671.4067.1.camel@nidelv.trondhjem.org> <20040309151054.GF14419@suse.de> <1078847262.4067.7.camel@nidelv.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Charles Lever <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0jme-0006Rw-Oi
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 08:08:44 -0800
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B0jFn-0006ad-U8
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:34:48 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1078847262.4067.7.camel@nidelv.trondhjem.org>
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

On Tue, Mar 09, 2004 at 10:47:42AM -0500, Trond Myklebust wrote:
> P=E5 ty , 09/03/2004 klokka 10:10, skreiv Olaf Kirch:
> > What I was referring to was the ability to have several RPC programs =
on a
> > single svc_sock server side; e.g. NFS and NFSACL, or NLM and NSM. Pre=
tty
> > much the way svc_register from the good ole sunrpc code works.
>=20
> Oh, sorry...
>=20
> Hmm... Any reason why you couldn't put them all on port 2049 with this
> patch? Would that be less efficient than having two sets of threads?

No, you could put all of them on the same port. The problem is that
you want lockd and nfsd to be two different processes, so you can
shut down nfsd without disrupting lockd.

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
