From: "Amir Hermelin" <amir@montilio.com>
Subject: RE: Mount wsize and sync options
Date: Wed, 19 May 2004 22:20:55 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <013201c43dde$ca448a20$0f01a8c0@CARTMAN>
References: <1084983085.4223.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQWcv-0004Ri-OV
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 12:21:17 -0700
Received: from zion.barak.net.il ([212.150.48.100])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BQWcv-0004yi-94
	for nfs@lists.sourceforge.net; Wed, 19 May 2004 12:21:17 -0700
To: "'Trond Myklebust'" <trond.myklebust@fys.uio.no>
In-Reply-To: <1084983085.4223.8.camel@lade.trondhjem.org>
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

Yes, It does accept 1 or 2k.  What's the reason for limiting synced =
writes
to page size?

-----Original Message-----
From: Trond Myklebust [mailto:trondmy@trondhjem.org] On Behalf Of Trond
Myklebust
Sent: Wednesday, May 19, 2004 6:11 PM
To: Amir Hermelin
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Mount wsize and sync options


P=E5 on , 19/05/2004 klokka 06:35, skreiv Amir Hermelin:
> Hi,
> I run an nfs server (RH9, kernel 2.4.20), and have experienced a=20
> behavior with the wsize mount option that I have no explanation for.=20
> It appears that when I use the sync option, the wsize is ignored (in=20
> default v3 UDP mount) and is always 4k.

It is not ignored, it is just capped at PAGE_SIZE. 2k or 1k will =
therefore
work fine...

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
