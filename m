From: trmcneal@attbi.com
Subject: RE: NFS read ok, write ok, simultaneous R+W=TERRIBLE
Date: Thu, 05 Dec 2002 10:32:40 +0000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E18JtJJ-00010L-00@sc8-sf-list1.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rwcrmhc51.attbi.com ([204.127.198.38])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18JtJJ-00010L-00
	for <nfs@lists.sourceforge.net>; Thu, 05 Dec 2002 02:32:49 -0800
To: nfs@lists.sourceforge.net
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

I haven't had a chance to look at it carefully, but this sounds
like unnecessary reads to update cached data prior to writes.
We had an issue with this on HP-UX a few years back.

Regards -

Tom

--
-----------------------------------
Tom McNeal            (650)906-0761
-----------------------------------
> > Sounds like you are not using the 3ware card for anything other than
> > just an IDE controller right?
> 
> Exactly - I'm using it to give me SCSI JBOD.
> 
> > There is a linux-ide-raid mailing list -- with good info. I've seen
> > people run raid 5 on the 3ware card and then use SW raid to stripe 2
> > 3ware cards. RAID 51 of sorts.
> 
> I follow this list - no help as my disks are FAST. I'm using RAID 0+5 truth
> be known. Every pair of drives is striped in software. That gives me 7
> really fast drives (14 spindles striped in pairs). Then, I S/W Raid 5 those
> together. All done with EVMS. So, 1 parity and 6 data basically.
> 
> > Also there was a pretty good IDE raid review today:
> >
> > http://tech-report.com/reviews/2002q4/ideraid/index.x?pg=1
> 
> I saw this cool article. My disks are *FAST* on R/W and R+W. My NFS is great
> on read, great on write, but just dies on read + write. Hence the conundrum.
> 
> Neil or Trond - any clues?
> 
> Thanks,
> 
> Jake
> 
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
