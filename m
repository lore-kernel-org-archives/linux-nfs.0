From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 15:03:49 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085511829.9224.20.camel@lade.trondhjem.org>
References: <1085487829.6666.32.camel@tesla.mmt.bellhowell.com>
	 <20040525123425.GO21886@suse.de>
	 <1085503328.13681.4.camel@tesla.mmt.bellhowell.com>
	 <1085507226.3872.132.camel@lade.trondhjem.org>
	 <1085511385.11596.21.camel@tesuji.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BShDS-0001Lt-Ig
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:03:58 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BShDS-0007Al-6W
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 12:03:58 -0700
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1085511385.11596.21.camel@tesuji.nac.uci.edu>
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

P=E5 ty , 25/05/2004 klokka 14:56, skreiv Dan Stromberg:

> Actually, wouldn't you be OK if you had a flock that was just a wrapper
> around fcntl?

No! flock locks behave very differently from POSIX locks after a fork().

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
