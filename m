From: "M. Todd Smith" <todd@sohovfx.com>
Subject: Re: NFS tuning - high performance throughput.
Date: Tue, 14 Jun 2005 16:38:25 -0400
Message-ID: <42AF4041.8030504@sohovfx.com>
References: <482A3FA0050D21419C269D13989C611308539C89@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DiIB6-0006Qk-Gq
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:38:32 -0700
Received: from smtp1.beanfield.com ([66.207.192.6] helo=smtp1.beanfield.net)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DiIB5-0006qO-UH
	for nfs@lists.sourceforge.net; Tue, 14 Jun 2005 13:38:32 -0700
Received: from [192.168.1.26] ([66.207.206.227])
	by smtp1.beanfield.net (8.13.4/8.12.11) with ESMTP id j5EKcGma002439
	for <nfs@lists.sourceforge.net>; Tue, 14 Jun 2005 16:38:17 -0400 (EDT)
	(envelope-from todd@sohovfx.com)
To: nfs@lists.sourceforge.net
In-Reply-To: <482A3FA0050D21419C269D13989C611308539C89@lavender-fe.eng.netapp.com>
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

Charles,

I've tried mounting both TCP and UDP and with rwsizes varying from 8k to 
32k, 32k rwsizes are giving us the best performance thus far.

Indeed I did skip a level with the ping times didn't I, 200 microseconds 
it is.

Cheers
Todd


Lever, Charles wrote:

>first place i would look is mount options on the client.  are you
>mounting with NFS over TCP, or NFS over UDP?
>
>(btw, your ping time should be 200 microseconds, not 200 nanoseconds).
>
>  
>
>>-----Original Message-----
>>From: M. Todd Smith [mailto:todd@sohovfx.com] 
>>Sent: Tuesday, June 14, 2005 4:18 PM
>>To: nfs@lists.sourceforge.net
>>Subject: [NFS] NFS tuning - high performance throughput.
>>
>>
>>Hello all,
>>
>>I've been attempting to get a better hold over our NFS performance as 
>>our network grows and grows.
>>
>>We've recently upgraded our NFS server machine to a dual 3.2ghz Xeon 
>>running Fedora Core 3 (kernel 2.6.11-1.14_FC3smp) w/ 4Gb RAM. 
>> Coupled 
>>with this machine we have a 2 Broadcom NetExtreme 2 Port PCI-X NIC on 
>>its own PCI-X bus (133Mhz).  Attached to this machine is our fibre 
>>channel SAN, using Seagate fibre-channel drives and an LSI 
>>dual channel 
>>2gigabit fibre adapter on its own PCI-X bus.  Local RW is 
>>~135Mbytes/sec.
>> 
>>The 4 ports are trunked together using bonding (balanced round robin 
>>mode), and trunked together on our Extreme Networks Summit 
>>400i switch.  
>>All the test machines are attached to this switch, making everything 
>>within one hop and ping times of less than a 200 nanoseconds.
>>
>>Current test machine is running Suse 9.2 and has an Intel 100/1000 XT 
>>server adapter (e1000 driver) on a shared but not high 
>>traffic PCI bus.  
>>Other test machines include some Dell PowerEdge 1850's with onboard 
>>Intel NICs, and some Apple G4, G5 and Xserves.
>>
>>I have read most of the tuning guides I can find on the net and 
>>attempted just about everything I can get my hands on (I have 
>>not tried 
>>jumbo frames yet, still waiting for some downtime to attempt 
>>that).  My 
>>problem is that no matter how I tune the machines I can get at max 
>>45Mb/ps throughput on NFS.  This was the same throughput we 
>>were getting 
>>with our old server with PCI cards, moreover this throughput 
>>is roughly 
>>the same for every machine on our network.  Theoretically we 
>>should be 
>>able to get much higher values.
>>
>>Any idea as to why this is?  I can provide config files and such if 
>>needed, but I'm really at a loss as to where to start.
>>
>>Cheers
>>Todd
>>
>>-- 
>>Systems Administrator
>>----------------------------------
>>Soho VFX - Visual Effects Studio
>>99 Atlantic Avenue, Suite 303
>>Toronto, Ontario, M6K 3J8
>>(416) 516-7863 
>>http://www.sohovfx.com
>>----------------------------------
>>
>>
>> 
>>
>>
>>
>>-------------------------------------------------------
>>SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
>>from IBM. Find simple to follow Roadmaps, straightforward articles,
>>informative Webcasts and more! Get everything you need to get up to
>>speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
>>_______________________________________________
>>NFS maillist  -  NFS@lists.sourceforge.net
>>https://lists.sourceforge.net/lists/listinfo/nfs
>>
>>    
>>
>
>
>  
>


-- 
Systems Administrator
----------------------------------
Soho VFX - Visual Effects Studio
99 Atlantic Avenue, Suite 303
Toronto, Ontario, M6K 3J8
(416) 516-7863 
http://www.sohovfx.com
----------------------------------


 



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
