From: raven@themaw.net
Subject: Re: async vs. sync
Date: Tue, 27 Jul 2004 21:56:38 +0800 (WST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0407272155450.1368@donald.themaw.net>
References: <482A3FA0050D21419C269D13989C61130435E51E@lavender-fe.eng.netapp.com>
 <200407270006.08581.bernd-schubert@web.de> <410643C5.3040004@bruvoll.com>
 <200407271500.38074.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jan Bruvoll <jan@bruvoll.com>,
   NFS mailling list <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BpSSv-0006Dl-Jy
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 06:58:01 -0700
Received: from wombat.indigo.net.au ([202.0.185.19])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1BpSSu-00010X-TS
	for nfs@lists.sourceforge.net; Tue, 27 Jul 2004 06:58:01 -0700
To: Bernd Schubert <bernd-schubert@web.de>
In-Reply-To: <200407271500.38074.bernd-schubert@web.de>
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

On Tue, 27 Jul 2004, Bernd Schubert wrote:

> > >>My set-up has about the same performance data, however my big problem is
> > >>that the server dies when I hook all my clients up... Raw throughput
> > >
> > >Fortunately that doesn't seem to happen in our case.
> >
> > Let me clarify - the server doesn't quite die, however it slows down
> > drastically, having a load of ~7 while 99% CPU idle. The clients clog
> > up, and for instance trying to mount anything just times out. If I
> > unmount the busy share from the clients, everything settles down again.
> 
> We noticed a higher load with sync-mounts, usually we have 0-2, with 2.4. and 
> sync-mounts it went until 3-4. But we also only used sync mounts for less 
> than 24, so changed to async mounts as soon as the people complained.
> 
> [snip]
> 
> >
> > I tried a little more performance number hunting:
> >  - NFS copy and write to same device - 3Mb/s sustained (500Mb file)
> >  - piozone direct write to RAID device - ~34-50Mb/s (depending on file
> > size) - drbd network device - 933Mb/s
> >
> > Nothing really wrong here I'd say - not blazingly quick, but surely
> > nothing to explain why everything just stops when I hook up my 12
> > clients to this set-up?
> 
> Certainly not. We have 45 diskless booting clients.

How many threads is the server running?

Ian



-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
