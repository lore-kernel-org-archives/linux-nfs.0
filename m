From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Mount wsize and sync options
Date: Wed, 19 May 2004 12:11:25 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084983085.4223.8.camel@lade.trondhjem.org>
References: <00de01c43d8d$0676f980$0f01a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQTfI-0004gP-3h
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 09:11:32 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BQTfH-0005QF-Mh
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 09:11:31 -0700
To: Amir Hermelin <amir@montilio.com>
In-Reply-To: <00de01c43d8d$0676f980$0f01a8c0@CARTMAN>
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

P=E5 on , 19/05/2004 klokka 06:35, skreiv Amir Hermelin:
> Hi,
> I run an nfs server (RH9, kernel 2.4.20), and have experienced a behavior
> with the wsize mount option that I have no explanation for. It appears th=
at
> when I use the sync option, the wsize is ignored (in default v3 UDP mount=
)
> and is always 4k.

It is not ignored, it is just capped at PAGE_SIZE. 2k or 1k will
therefore work fine...

Cheers,
  Trond


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
