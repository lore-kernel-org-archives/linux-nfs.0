From: trond.myklebust@fys.uio.no
Subject: Re: Problem with nfs data caching?
Date: Wed, 25 Feb 2004 23:10:32 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1514.130.128.48.179.1077747032.squirrel@webmail.uio.no>
References: <403D158B.124C2469@mainframe.ca>
Mime-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw7GK-0000DZ-GF
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 14:12:16 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Aw71b-0005Te-PB
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 13:57:03 -0800
To: "Terry Bates" <tbates@mainframe.ca>
In-Reply-To: <403D158B.124C2469@mainframe.ca>
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

På on , 25/02/2004 klokka 13:37, skreiv Terry Bates:
> We are experiencing a problem which seems to be related to data caching
on our linux nfs clients;
>
> Using Mental Ray, we render picture to an NFS mounted filesystem (I have
tried both SGI and Auspex file servers).  We have an inhouse application
which we use to view the rendered pictures.  If you attempt to view a
picture which has not completely finished rendering, you get a plain
grey window.  Once that situation has happened, you cannot view that
picture from that machine until you umount and mount that filesystem
again.  You can view it from other machines however.

See the thread on the mailing list yesterday concerning shared mmap() and
the limitations of the Linux VM...

Cheers,
  Trond





-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
