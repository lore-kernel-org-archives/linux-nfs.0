From: Kresimir Kukulj <madmax@iskon.hr>
Subject: Re: Re: NFS Problems (kernel locks up)
Date: Thu, 20 Mar 2003 20:31:41 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030320193141.GA22420@max.zg.iskon.hr>
References: <5CA6F03EF05E0046AC5594562398B916A32893@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iskon.hr ([213.191.128.4])
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18w5ls-0006Ph-00
	for <nfs@lists.sourceforge.net>; Thu, 20 Mar 2003 11:32:12 -0800
To: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
In-Reply-To: <5CA6F03EF05E0046AC5594562398B916A32893@POEXMB3.conoco.net>
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

Quoting Heflin, Roger A. (Roger.A.Heflin@conocophillips.com):
> 	I would suggest running a machine stress test on the machine.
> 
> 	I did had a situation where a large NFS load would quickly take
> 	down a machine, and finally determined that the actual hardware
> 	was bad, and when put under stress would crash, I swapped
> 	out the hardware (case+mb+memory+cpu) with another (I used
> 	all of the same hd's) and the machine quite crashing even under
> 	the same kind of load.   The original machine lasted 5-10 minutes
> 	under heavy NFS load, would last days under light NFS loads.
> 
> 	We have had good luck with 2.4.19 and 2.4.21pre[34] as nfs 
> 	servers.
> 
> 	The only thing to watch out for on the number of files is that
> 	there are issues on unix (unix in general) with lots of files
> 	in a single directory, quite a number of things get slow with
> 	lots of files in a single dir.  
> 
> 	You might try one of the cpu burn in type programs and see if
> 	that also makes it fail, and maybe a disk benchmark and see if 
> 	that makes it fail.
> 
> 	If either of those make it fail, it is a hardware problem of some
> 	sort.
> 
> 	I have a large number of NFS servers and we get a few odd crashes
> 	that generally are traced back to hardware issues.

Thanks for a reply.

I have tested local RAID array with bonnie, IOzone, postmark and home-made
tools to benchmark file system performance. I tested local fs more that 10
times, and NFS (1 client load) with the same tools using various
combinations of NFSv2, NFSv3, sync, async.
Not a single crash.

I reverted problematic server to 2.4.21-pre5 with NFSv3,udp,sync and it
survived the nightly backup. We'll see how long will it take before it
crashes again. I don't think this is hardware related. Crashes are not
random. Kernel version and protocol version determine when it will crash.

-- 
Kresimir Kukulj                      madmax@iskon.hr
+--------------------------------------------------+
Old PC's never die. They just become Unix terminals.


-------------------------------------------------------
This SF.net email is sponsored by: Tablet PC.  
Does your code think in ink? You could win a Tablet PC. 
Get a free Tablet PC hat just for playing. What are you waiting for? 
http://ads.sourceforge.net/cgi-bin/redirect.pl?micr5043en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
