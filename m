From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 13:47:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085507226.3872.132.camel@lade.trondhjem.org>
References: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
	 <20040525123425.GO21886@suse.de>
	 <1085503328.13681.4.camel@tesla.mmt.bellhowell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSg1G-0002RL-9E
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 10:47:18 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BSg1F-0007NR-W3
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 10:47:18 -0700
To: Jeffrey Layton <jtlayton@poochiereds.net>
In-Reply-To: <1085503328.13681.4.camel@tesla.mmt.bellhowell.com>
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

P=E5 ty , 25/05/2004 klokka 12:42, skreiv Jeffrey Layton:

> Perhaps Solaris does some sort of BSD-POSIX lock translation which makes
> flock() work there?

The convention for local filesystems under Linux is that BSD and POSIX
locks are not allowed to see each other. That rules out using the above
trick for NFS.

Cheers,
   Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
