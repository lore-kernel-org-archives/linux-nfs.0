From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NSM lock recovery fails too often
Date: Tue, 09 Mar 2004 10:04:32 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1078844671.4067.1.camel@nidelv.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DD1F@lavender-fe.eng.netapp.com>
	 <20040309142200.GC14419@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Charles Lever <Charles.Lever@netapp.com>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B0ivY-000803-Pn
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:13:52 -0800
Received: from dh197.citi.umich.edu
	([141.211.133.197] helo=nidelv.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B0imi-0004s6-6n
	for nfs@lists.sourceforge.net; Tue, 09 Mar 2004 07:04:44 -0800
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040309142200.GC14419@suse.de>
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

P=E5 ty , 09/03/2004 klokka 09:22, skreiv Olaf Kirch:

> I forgot to mention in my previous message that the kernel-statd patch
> requires Andreas Gruenbacher's sunrpc patch that lets you register
> several RPC services on a single socket (originally written for his
> nfsacl implementation)

For 2.6.x, see the rpc_clone_client() function...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
