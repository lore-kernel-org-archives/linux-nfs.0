From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsprog support
Date: Thu, 15 Apr 2004 12:39:37 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1082057977.7141.31.camel@lade.trondhjem.org>
References: <200404151750.53209.bernd-schubert@web.de>
	 <20040415175143.GA25858@suse.de> <200404152040.06227.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFafy-0003By-45
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 08:27:14 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BFafx-00051b-Pf
	for nfs@lists.sourceforge.net; Mon, 19 Apr 2004 08:27:13 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200404152040.06227.bernd-schubert@web.de>
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

P=E5 to , 15/04/2004 klokka 11:39, skreiv Bernd Schubert:

> nfsprog=3Dn	Use  an  alternate  RPC  program number to contact the 	=09
> 			NFS daemon on the remote host.
> 			This option is useful for hosts that can run multiple NFS servers.  Th=
e =09
> 			default value  is 100003 which is the standard RPC NFS daemon program=20
> 			number.

So, just out of curiosity... Why would anyone prefer to do this rather
than just having the NFS servers run on different ports, and then using
the 'port=3D' option?

AFAICS, the only difference there is that you get somewhat dubious extra
support in the form of a separate portmapper entry for each NFS daemon.
However given that you still have to feed the NFS client the special
"nfsprog" number, is there really any benefit to doing this over just
fixing a set of alternate port numbers that your "mount" can probe?

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
