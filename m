From: "Jake Hammer" <hammer@clarkisland.com>
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Wed, 4 Dec 2002 22:27:09 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <CFEAJJEGMGECBCJFLGDBKEHPCJAA.hammer@clarkisland.com>
References: <3DEEEC53.D24A1933@amis.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "NFS" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cynaptic.com ([128.121.116.181])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JpTl-0002a3-00
	for <nfs@lists.sourceforge.net>; Wed, 04 Dec 2002 22:27:21 -0800
To: <ewhiting@amis.com>
In-Reply-To: <3DEEEC53.D24A1933@amis.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> Sounds like you are not using the 3ware card for anything other than
> just an IDE controller right?

Exactly - I'm using it to give me SCSI JBOD.

> There is a linux-ide-raid mailing list -- with good info. I've seen
> people run raid 5 on the 3ware card and then use SW raid to stripe 2
> 3ware cards. RAID 51 of sorts.

I follow this list - no help as my disks are FAST. I'm using RAID 0+5 truth
be known. Every pair of drives is striped in software. That gives me 7
really fast drives (14 spindles striped in pairs). Then, I S/W Raid 5 those
together. All done with EVMS. So, 1 parity and 6 data basically.

> Also there was a pretty good IDE raid review today:
>
> http://tech-report.com/reviews/2002q4/ideraid/index.x?pg=1

I saw this cool article. My disks are *FAST* on R/W and R+W. My NFS is great
on read, great on write, but just dies on read + write. Hence the conundrum.

Neil or Trond - any clues?

Thanks,

Jake




-------------------------------------------------------
This SF.net email is sponsored by: Microsoft Visual Studio.NET 
comprehensive development tool, built to increase your 
productivity. Try a free online hosted session at:
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr0003en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
