From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Debian Bug#235886: nfs-kernel-server inducing load of
	8-9 with no good reason for Linux 2.6 clients
Date: Thu, 18 Mar 2004 19:08:40 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079654920.6089.7.camel@lade.trondhjem.org>
References: <20040318210943.GK3605@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B47ZJ-0001pn-MR
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 16:08:57 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B47ZJ-0002HH-6a
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 16:08:57 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040318210943.GK3605@perlsupport.com>
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

P=E5 to , 18/03/2004 klokka 16:09, skreiv Chip Salzenberg:
> Neil (or someone), what should I tell this user?
>=20

I typically see the "ip reassembly time exceeded" in situations where
the machine is dropping fragments due to missed interrupts.

What's probably happening here is that because the 2.6 clients can cache
huge amounts of writes before everything needs to be written out at
close() time, the server is being overwhelmed...

Cheers
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
