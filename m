From: David Dougall <davidd@et.byu.edu>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Wed, 17 Mar 2004 08:56:34 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0403170855400.25099@lewis.et.byu.edu>
References: <482A3FA0050D21419C269D13989C61130435DD6F@lavender-fe.eng.netapp.com>
 <1079456451.3045.40.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-13
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3dPc-0000MM-8Z
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 07:56:56 -0800
Received: from postal1.et.byu.edu ([128.187.122.131])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1B3dPZ-00064H-PB
	for nfs@lists.sourceforge.net; Wed, 17 Mar 2004 07:56:54 -0800
Received: from lewis.et.byu.edu (lewis.et.byu.edu [128.187.112.50])
	by postal1.et.byu.edu (8.12.10/8.12.10) with ESMTP id i2HFuYUg006236
	for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 08:56:34 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <1079456451.3045.40.camel@lade.trondhjem.org>
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

I know in the past we had symptoms like this when we had mismatched
speeds between server and client.  If you can, change all machines to
gigabit or 100Mbit.
--David Dougall


On Tue, 16 Mar 2004, Trond Myklebust wrote:

> P=E5 ty , 16/03/2004 klokka 11:26, skreiv Lever, Charles:
> > i don't think these limits are the problem.  the congestion control
> > and slot table limits should put these processes to sleep, not leave
> > them in D state, right?  same for the per-mountpoint pages in flight
> > limit.
>
> man top
>
>        w: S  --  Process Status
>           The status of the task which can be one of:
>              =FFD=FF =3D uninterruptible sleep
>              =FFR=FF =3D running
>              =FFS=FF =3D sleeping
>              =FFT=FF =3D traced or stopped
>              =FFZ=FF =3D zombie
>
> Cheers,
>  Trond
>
>
> -------------------------------------------------------
> This SF.Net email is sponsored by: IBM Linux Tutorials
> Free Linux tutorial presented by Daniel Robbins, President and CEO of
> GenToo technologies. Learn everything from fundamentals to system
> administration.http://ads.osdn.com/?ad_id=1470&alloc_id638&op=CCk
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>
>


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
