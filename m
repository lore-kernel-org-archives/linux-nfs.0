From: "poczta.dotcom.pl" <myciel@dotcom.pl>
Subject: Re: nfs performance problem
Date: Tue, 5 Nov 2002 20:55:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <007901c28505$51e9c240$640a010a@winda>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rtr.pul.pl ([195.116.89.98] helo=poczta.dotcom.pl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1899sx-00017k-00
	for <nfs@lists.sourceforge.net>; Tue, 05 Nov 2002 12:01:16 -0800
Received: from winda (office.interia.pl [213.76.176.114])
	by poczta.dotcom.pl (Postfix) with ESMTP id 0B9A916E16
	for <nfs@lists.sourceforge.net>; Tue,  5 Nov 2002 20:58:44 +0100 (CET)
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


----- Original Message -----
From: "Ragnar Kj=F8rstad" <nfs@ragnark.vestdata.no>
To: "poczta.dotcom.pl" <myciel@dotcom.pl>
Cc: <nfs@lists.sourceforge.net>
Sent: Tuesday, November 05, 2002 8:17 PM
Subject: Re: [NFS] nfs performance problem


> On Tue, Nov 05, 2002 at 07:03:43PM +0100, poczta.dotcom.pl wrote:
> > Hi All
> >
> > I have really slow working nfs.
> > Server is build on:
> > - dual pentium Xeon 2GHz,
> > - 2 3ware 7500 controllers,
> > - raid 5 on 7 160GB discs on controler 1
> > - raid 5 on 6 160GB disks on cotroller 2
> >
> > Serwer is used for ~500k maildirs,
> > all clients (~20) are freebsd boxes, when nfs transfer is around 1MB/=
s
for writing and 1.5MB/s for reading
> > listing user directories even with very few file stakes up to 15
seconds.
> >
> > I tried nfs-ALL patch, but it didn' t help.
>
> How is local performance?

local read/writes are ok

> What filesystem do you use?

reiserfs on top of  lvm (to be able to get snapshots)

> What's the output from "iostat -x -d -k 60 3"?
>
below is output from 'iostat -d 60 3'  (- my iostat does not take '-k'
option,
and '-d' gives me empty output) - mayby this is enough?

Linux 2.4.19 (hostname)        11/05/02

Device:        tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev8-0       16.16       205.52        82.84    3481842    1403528
dev8-1      160.58      1266.39      1346.12   21455002   22805744

Device:        tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev8-0        9.23       134.93        16.13       8096        968
dev8-1      150.92       753.20      1715.87      45192     102952

Device:        tps   Blk_read/s   Blk_wrtn/s   Blk_read   Blk_wrtn
dev8-0       10.02       135.07        26.53       8104       1592
dev8-1      152.78       763.33      1767.20      45800     106032


rafal



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
