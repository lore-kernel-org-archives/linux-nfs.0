From: "Roger Heflin" <rheflin@atipa.com>
Subject: RE: How many nfsd's can I run?
Date: Wed, 22 Jun 2005 08:07:12 -0500
Message-ID: <EXCHG2003pYC98Bi89Q000001f9@EXCHG2003.microtech-ks.com>
References: <42B8C69C.6010302@affymetrix.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dl4uy-0002Sn-Mx
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 06:05:24 -0700
Received: from host27-37.discord.birch.net ([65.16.27.37] helo=EXCHG2003.microtech-ks.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dl4uw-0000hf-6W
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 06:05:24 -0700
To: "'Hugh Caley'" <Hugh_Caley@affymetrix.com>,
	<nfs@lists.sourceforge.net>
In-Reply-To: <42B8C69C.6010302@affymetrix.com>
Sender: nfs-admin@lists.sourceforge.net
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


My experience is that above 16 or so I have not seen a gain
in the actual performance delivered to the network.

There also appears (on RHEL3 2.4 kernel) to be some sort
of kernel resource that gets overused by having too
many nfsds and causes other issues, this would not a 
conclusive test, but appears to be a problem, we took
the nfsds back down from 256 to 64 because of this 
perceived problem, and because it did not change any
of the performance issues that we had.

                        Roger
				Atipa Technologies

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] On Behalf Of Hugh Caley
> Sent: Tuesday, June 21, 2005 9:02 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] How many nfsd's can I run?
> 
> Often when a cluster run (100+ nodes) is started my NFS 
> server will get very slow; users with their home directories 
> on the server will lock up for short periods, and the load 
> average crawls higher.
> 
> The output of cat /proc/net/rpc/nfsd:
> 
> th 125 264502 142948.997 38666.037 22620.179 16494.577 10072.689
> 5700.113 2623.322 1094.785 474.752 1900.536
> 
> This would seem to mean that my nfsd threads are runnning at 
> 100% for much of the time, meaning I need more nfsd's, 
> correct?  But is there a limit to the amount of nfsd's I 
> should run?  I had had it as high as 150 at one time, but it 
> seemed to me this made the server less stable.  
> There may have been other reasons for this, however.
> 
> Anyway I have since doubled the ram on the server (to 8 gig). 
>  Machine is a dual Xeon 2.6 Ghz machine running Fedora Core 
> 2, kernel version 2.6.10-1.771_FC2smp, gigabit ethernet.  Can 
> I run more nfsd's, or should I be looking for other problems?
> 
> Hugh
> 
> --
> Hugh Caley | Unix Systems Administrator | CIS AFFYMETRIX, 
> INC. | 6550 Vallejo St. Ste 100 | Emeryville, CA 94608
> Tel: 510-428-8537 | Hugh_Caley@affymetrix.com
> 
> 
> 
> -------------------------------------------------------
> SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
> from IBM. Find simple to follow Roadmaps, straightforward articles,
> informative Webcasts and more! Get everything you need to get up to
> speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
> 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
