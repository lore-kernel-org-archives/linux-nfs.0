From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Fri, 28 May 2004 15:19:28 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1085771968.3882.17.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
	 <1085695748.23934.94.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
	 <20040528135515.GG5657@suse.de>
	 <Pine.LNX.4.58.0405282058300.14886@penti.sit.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTmtG-0007LV-6H
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 12:19:38 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BTmtF-0007su-TG
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 12:19:37 -0700
To: Harald Hannelius <harald+nfs@arcada.fi>
In-Reply-To: <Pine.LNX.4.58.0405282058300.14886@penti.sit.fi>
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

P=E5 fr , 28/05/2004 klokka 14:03, skreiv Harald Hannelius:

> I guess (as a total don't-know) that nfsd reads and writes files in a
> different way than local processes do. I read somewhere something about
> read-ahead but that was in 2.6.0-pre-something..

Hmm... The current readahead code does a load of crap in order to
determine whether or not the user is doing linear or random I/O. It may
be that the nfsd server with all its multi-threading and out-of-sequence
I/O is triggering the random I/O readahead code (which of course aims to
limit readahead).

Cheers
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
