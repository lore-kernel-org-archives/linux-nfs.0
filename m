From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: RE: linus 2.4.20 nfs performance problem
Date: Tue, 16 Mar 2004 12:00:51 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1079456451.3045.40.camel@lade.trondhjem.org>
References: <482A3FA0050D21419C269D13989C61130435DD6F@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-13
Cc: Brasseur =?ISO-8859-1?Q?Val=E9ry?= <Valery.Brasseur@atosorigin.com>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3Hw2-0001cs-G4
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 09:00:58 -0800
Received: from dh132.citi.umich.edu
	([141.211.133.132] helo=lade.trondhjem.org ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1B3Hw1-0000Fi-Rx
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 09:00:57 -0800
To: Charles Lever <Charles.Lever@netapp.com>
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD6F@lavender-fe.eng.netapp.com>
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

P=E5 ty , 16/03/2004 klokka 11:26, skreiv Lever, Charles:
> i don't think these limits are the problem.  the congestion control
> and slot table limits should put these processes to sleep, not leave
> them in D state, right?  same for the per-mountpoint pages in flight
> limit.

man top

       w: S  --  Process Status
          The status of the task which can be one of:
             =FFD=FF =3D uninterruptible sleep
             =FFR=FF =3D running
             =FFS=FF =3D sleeping
             =FFT=FF =3D traced or stopped
             =FFZ=FF =3D zombie
                                                                           =
    =20
Cheers,
 Trond


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
