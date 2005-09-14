From: Peter Staubach <staubach@redhat.com>
Subject: Re: Sporadic timeout problems during streaming to nfs server
Date: Wed, 14 Sep 2005 17:17:29 -0400
Message-ID: <43289369.9080906@redhat.com>
References: <044B81DE141D7443BCE91E8F44B3C1E288E43F@exsvl02.hq.netapp.com> <ef6372aa4d.stefan@wuerthner.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFejB-0006dO-Vr
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 14:23:37 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFejA-00073j-JN
	for nfs@lists.sourceforge.net; Wed, 14 Sep 2005 14:23:37 -0700
To: Stefan Wuerthner <trash.wuerthner@gmx.de>
In-Reply-To: <ef6372aa4d.stefan@wuerthner.dyndns.org>
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

Stefan Wuerthner wrote:

>In message <044B81DE141D7443BCE91E8F44B3C1E288E43F@exsvl02.hq.netapp.com> you wrote:
>
>  
>
>>>In message 
>>><044B81DE141D7443BCE91E8F44B3C1E288E43C@exsvl02.hq.netapp.com>
>>> you wrote:
>>>
>>>      
>>>
>>>>don't use the "soft" option -- use "hard" instead.  "soft" 
>>>>        
>>>>
>>>with "udp" is
>>>      
>>>
>>>>a sure recipe for data corruption and the very symptoms you describe
>>>>below. 
>>>>
>>>>        
>>>>
>>>I already tried "hard", but without success:
>>>
>>>The serial log tells me:
>>>
>>>[Fri Sep  9 11:50:20 2005]
>>>nfs: server 192.168.24.50 not responding, still trying
>>>[Fri Sep  9 12:58:53 2005]
>>>PANIC: not enough space in ringbuffer, available 42887, needed 93225
>>>
>>>
>>>E.g. the client cannot reach the server and therefore the 
>>>client ringbuffer
>>>overflows. This results in a total lockup of the client...
>>>      
>>>
>>a ring buffer overflow is a NIC driver problem.  the NFS timeout issues
>>suggest a network problem (either the link or the NICs or...).  i would
>>start looking closely at your client-side network (driver version,
>>hardware, cabling, switch, etc).
>>
>>in the long run you want to use NFS over TCP rather than UDP (and don't
>>use "soft").
>>
>>    
>>
>
>Client side is more or less fixed because it's not a computer but a
>consumer device running busybox. Ethernet controller is partially
>formed by the CPU (slow PPC)...
>
>The ring buffer is afaik not part of the NIC, but has been added
>some time ago to buffer peak bitrates in the TS stream. Hardware 
>should be o.k. (Cat5e+ cabling, Allied Telesyn switches).
>
>The difficult points are:
>
>1. Real-time application: video streaming (MPEG2 stream)
>2. Receiver NIC is limited to 10MBit half-duplex
>3. video streams can peak to 8-10MBit...
>
>So:
>
>1. NFS over TCP is too slow
>2. - "hard" is no option, because it stops writing the stream finally
>   - "soft" allows the server to restart the recording after several seconds
>     but there is a small interruption in the final recording
>
>The interesting questions are:
>
>Why does streaming work for e.g. 30min or 65min and then fail with
>'timeout'?
>
>How can I get more information on the server side what happened exactly at
>this point of time. I could not find any logs related to serverside NFS.
>

10Mb/s is really slow, for today's standards.  Almost anything ought to
be able to drive the network at full speed, even with TCP.

Can you try this without the ring buffer?

I would suggest using ethereal or tcpdump on the server to watch the
traffic and see if anything appears unusual when the situation occurs.

       ps


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
