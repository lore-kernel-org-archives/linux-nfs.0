From: "myciel" <myciel@dotcom.pl>
Subject: Re: nfs performance problem
Date: Wed, 6 Nov 2002 12:46:58 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <00b401c2858a$36c4bf80$640a010a@winda>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no> <007901c28505$51e9c240$640a010a@winda> <20021106003237.L23227@vestdata.no> <003201c28572$c04ea260$640a010a@winda> <20021106111628.Q23227@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rtr.pul.pl ([195.116.89.98] helo=poczta.dotcom.pl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189Ojm-0003bt-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 03:52:46 -0800
Received: from winda (office.interia.pl [213.76.176.114])
	by poczta.dotcom.pl (Postfix) with ESMTP id 3F7D916ADF
	for <nfs@lists.sourceforge.net>; Wed,  6 Nov 2002 12:49:57 +0100 (CET)
To: <nfs@lists.sourceforge.net>
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


> On Wed, Nov 06, 2002 at 09:59:01AM +0100, myciel wrote:
> > > > > What filesystem do you use?
> > > >
> > > > reiserfs on top of  lvm (to be able to get snapshots)
> > >
> > > What reiserfs-version? 3.5 or 3.6?
> > > What on-disk format? 3.5 or 3.6?
> >
> > 3.6.25
>
> That's the reiserfs-version.
> The on-disk format must be either "3.5" or "3.6".
> There should be a message at mount-time telling you wich one, or you can
> use "debugreiserfs <device>" to check it.
>

format 3.6 with standard journal

> > > Unnless you're running reiserfs-3.5 my guess is that it is the
> > > IO-performance that is the problem. 3ware 7500 controllers have rather
> > > poor performance on RAID5 - especially for writes.
> >
> > reiserfs 3.6.25, raid 5,
> > ok, I can understand raid 5 is not fast but getting below 2Mbytes/s
> > is really poor :-(
>
> Well, updating a single byte is a very very expensive operation on
> raid5. I agree that 2MB/s is worse than one should expect though, so
> there may be something else going on.
>
> The fact that you say local writes are faster could indicate that the
> problem is not only io-related.
>
> Maybe there is some packet-loss?
I don't see any packet losses - at least as I can see with ping big packets
like 16k or 32k

>That kills performance on nfs.
> Is there anything in the kernel-log on the clients to indicate the
> problem?
>

yesterday evening I switched from udp to tcp,
performace is much better but I get a lot of kernel messages in syslog:

Nov  6 12:40:45 intler kernel: RPC request reserved 272 but used 276
Nov  6 12:40:50 intler kernel: RPC request reserved 240 but used 244
Nov  6 12:40:54 intler kernel: RPC request reserved 244 but used 248

what does above mean?

> >
> > what kind of IDE-RAID would You suggest?
>
> A BigStorage IDE-RAID of course :)
> I'll get back to you off-list about that.

ok

rafal mycielski



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
