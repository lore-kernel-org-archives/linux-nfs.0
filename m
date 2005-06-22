From: Hugh Caley <Hugh_Caley@affymetrix.com>
Subject: Re: How many nfsd's can I run?
Date: Wed, 22 Jun 2005 12:12:25 -0700
Message-ID: <42B9B819.5030900@affymetrix.com>
References: <42B8C69C.6010302@affymetrix.com> <17080.52358.24058.797844@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DlAeY-0006Aa-Gs
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 12:12:50 -0700
Received: from firewall.neomorphic.com ([205.217.46.68] helo=roma.ev.affymetrix.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DlAeY-00082t-3t
	for nfs@lists.sourceforge.net; Wed, 22 Jun 2005 12:12:50 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <17080.52358.24058.797844@cse.unsw.edu.au>
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

Thanks for the advice.  So, if I run "nfsd 256", it will increase the 
currently running 125 daemons to 256?

Filesystem is reiser, and the disk device is a Nexsan Atabeast. 

Hugh

Neil Brown wrote:

>On Tuesday June 21, Hugh_Caley@affymetrix.com wrote:
>  
>
>>Often when a cluster run (100+ nodes) is started my NFS server will get 
>>very slow; users with their home directories on the server will lock up 
>>for short periods, and the load average crawls higher.
>>
>>The output of cat /proc/net/rpc/nfsd:
>>
>>th 125 264502 142948.997 38666.037 22620.179 16494.577 10072.689 
>>5700.113 2623.322 1094.785 474.752 1900.536
>>
>>This would seem to mean that my nfsd threads are runnning at 100% for 
>>much of the time, meaning I need more nfsd's, correct?  But is there a 
>>limit to the amount of nfsd's I should run?  I had had it as high as 150 
>>at one time, but it seemed to me this made the server less stable.  
>>There may have been other reasons for this, however.
>>
>>Anyway I have since doubled the ram on the server (to 8 gig).  Machine 
>>is a dual Xeon 2.6 Ghz machine running Fedora Core 2, kernel version 
>>2.6.10-1.771_FC2smp, gigabit ethernet.  Can I run more nfsd's, or should 
>>I be looking for other problems?
>>    
>>
>
>There should be very little cost in pushing the number of nfsd
>substantially higher, but there might not be much gain.
>
>So definitely run more nfsd - say 256 (you can just run "nfsd 256" and
>it will increase the number of threads to that number).
>But also look into how the filesystem and storage is performing.
>
>What filesys and what storage are you using?
>
>NeilBrown
>  
>


-- 
Hugh Caley | Unix Systems Administrator | CIS
AFFYMETRIX, INC. | 6550 Vallejo St. Ste 100 | Emeryville, CA 94608
Tel: 510-428-8537 | Hugh_Caley@affymetrix.com



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
