From: Yusuf Goolamabbas <yusufg@outblaze.com>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Tue, 1 Jun 2004 08:16:58 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040601001658.GA7373@outblaze.com>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi> <1085695748.23934.94.camel@lade.trondhjem.org> <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi> <20040528135515.GG5657@suse.de> <Pine.LNX.4.58.0405282058300.14886@penti.sit.fi> <1085771968.3882.17.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Harald Hannelius <harald+nfs@arcada.fi>,
	Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUwxm-00079A-1n
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 17:17:06 -0700
Received: from corpmail.outblaze.com ([203.86.166.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUwxl-0000NN-4R
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 17:17:05 -0700
Received: from localhost.localdomain (localhost.localdomain [127.0.0.1])
	by corpmail.outblaze.com (Postfix) with ESMTP id A8A4337AD5
	for <nfs@lists.sourceforge.net>; Tue,  1 Jun 2004 00:16:59 +0000 (GMT)
Received: from yusufg.portal2.com (210-177-227-130.outblaze.com [210.177.227.130])
	by corpmail.outblaze.com (Postfix) with SMTP id E193D16DD91
	for <nfs@lists.sourceforge.net>; Tue,  1 Jun 2004 00:16:58 +0000 (GMT)
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085771968.3882.17.camel@lade.trondhjem.org>
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

> > I guess (as a total don't-know) that nfsd reads and writes files in a
> > different way than local processes do. I read somewhere something about
> > read-ahead but that was in 2.6.0-pre-something..
> 
> Hmm... The current readahead code does a load of crap in order to
> determine whether or not the user is doing linear or random I/O. It may
> be that the nfsd server with all its multi-threading and out-of-sequence
> I/O is triggering the random I/O readahead code (which of course aims to
> limit readahead).

Any thoughts on this patch posted to lkml 

http://marc.theaimsgroup.com/?l=linux-kernel&m=108603045809565&w=2

Regards, /yg


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
