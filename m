From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: ReasmFails increases / NFS performance on Linux Cluster
Date: Mon, 16 Aug 2004 08:54:01 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0408160851520.24272@chaos.egr.duke.edu>
References: <E1BwYLA-0004on-C0@sc8-sf-list2.sourceforge.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bwh01-0001lC-UU
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 05:54:05 -0700
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1Bwh01-0004mV-Q5
	for nfs@lists.sourceforge.net; Mon, 16 Aug 2004 05:54:06 -0700
To: nfs@lists.sourceforge.net, Patrice Seyed <apseyed@bu.edu>
In-Reply-To: <E1BwYLA-0004on-C0@sc8-sf-list2.sourceforge.net>
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

> 
> Message: 1
> From: "Patrice Seyed" <apseyed@bu.edu>
> To: <nfs@lists.sourceforge.net>
> Cc: "'Patrice Seyed'" <apseyed@bu.edu>
> Subject: RE: [NFS] ReasmFails increases / NFS performance on Linux Cluster
> Date: Sun, 15 Aug 2004 17:52:13 -0400
> 
> Like I said I'm now running 64 nfs daemons, and the th line looks like =
> this
> now:
> 
> th 64 2380739 168.120 128.860 68.350 261.730 184.990 121.680 145.930 =
> 122.090
> 178.390 1749.090

You don't have enough threads.  That 2nd number (after the number of 
threads) should be as close to zero as possible -- that's the number of 
times all threads have been busy when a request came in.  IIRC, you have 
plenty of memory on the server -- crank up the number of threads and you 
should see some difference.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
