From: "myciel" <myciel@dotcom.pl>
Subject: Re: nfs performance problem
Date: Wed, 6 Nov 2002 09:59:01 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <003201c28572$c04ea260$640a010a@winda>
References: <005b01c284f5$ae1d6090$640a010a@winda> <20021105201758.I23227@vestdata.no> <007901c28505$51e9c240$640a010a@winda> <20021106003237.L23227@vestdata.no>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rtr.pul.pl ([195.116.89.98] helo=poczta.dotcom.pl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 189M71-0001Rg-00
	for <nfs@lists.sourceforge.net>; Wed, 06 Nov 2002 01:04:36 -0800
Received: from winda (office.interia.pl [213.76.176.114])
	by poczta.dotcom.pl (Postfix) with ESMTP id B882C16E16
	for <nfs@lists.sourceforge.net>; Wed,  6 Nov 2002 10:02:00 +0100 (CET)
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
Sent: Wednesday, November 06, 2002 12:32 AM
Subject: Re: [NFS] nfs performance problem


> On Tue, Nov 05, 2002 at 08:55:41PM +0100, poczta.dotcom.pl wrote:
> > > How is local performance?
> >
> > local read/writes are ok
> >
> > > What filesystem do you use?
> >
> > reiserfs on top of  lvm (to be able to get snapshots)
>
> What reiserfs-version? 3.5 or 3.6?
> What on-disk format? 3.5 or 3.6?

3.6.25

>
> > > What's the output from "iostat -x -d -k 60 3"?
> > >
> > below is output from 'iostat -d 60 3'  (- my iostat does not take '-k=
'
> > option,
> > and '-d' gives me empty output) - mayby this is enough?
>
> And not -x either?
now I have 4.0.6,
iostat -x -k 60 3  - outputs only column titles every 60 seconds  but lin=
e
where numbers should be is blank,
the same I have on other machine (fresh gentoo linux)
> iostat fr=E5 sysstat-4.0.3-2 (from RedHat) includes a "-x" option for
> extended output. Most importantly, it will tell how much of the time
> each device is busy.

anyway local writes are ok
>
> It's unclear from your posts if this is a io-related problem or not.
> Unnless you're running reiserfs-3.5 my guess is that it is the
> IO-performance that is the problem. 3ware 7500 controllers have rather
> poor performance on RAID5 - especially for writes.

reiserfs 3.6.25, raid 5,
ok, I can understand raid 5 is not fast but getting below 2Mbytes/s
is really poor :-(
>
> If that's correct, then switching to a different RAID-level or replacin=
g
> the 3ware-controller should solve the problem. SCSI- or FC- RAIDS are
> easily 10 or 20 times faster than the 3ware RAID for some types of
> operations, and if you want something cheaper there is also different
> types of IDE-RAIDs.
>

what kind of IDE-RAID would You suggest?


thanks

rafal mycielski



-------------------------------------------------------
This sf.net email is sponsored by: See the NEW Palm 
Tungsten T handheld. Power & Color in a compact size!
http://ads.sourceforge.net/cgi-bin/redirect.pl?palm0001en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
