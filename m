From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: Mount wsize and sync options
Date: Wed, 19 May 2004 15:41:51 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1084995711.4223.99.camel@lade.trondhjem.org>
References: <013201c43dde$ca448a20$0f01a8c0@CARTMAN>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQWws-0008Es-8v
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 12:41:54 -0700
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BQWwr-0007wr-MQ
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 12:41:53 -0700
To: Amir Hermelin <amir@montilio.com>
In-Reply-To: <013201c43dde$ca448a20$0f01a8c0@CARTMAN>
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

P=E5 on , 19/05/2004 klokka 16:20, skreiv Amir Hermelin:
> Yes, It does accept 1 or 2k.  What's the reason for limiting synced write=
s
> to page size?

It is because the VFS only writes one page at a time.

Now you could cluster those pages into one large RPC request (and this
is how O_SYNC normally works), but it turns out that some applications
do actually depend on the pages being synced to disk in the particular
order that they were written. The clustering technique unfortunately has
races that can ruin those ordering guarantees.

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
