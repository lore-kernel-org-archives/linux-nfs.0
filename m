From: Tom Talpey <tmtalpey@gmail.com>
Subject: Re: [NFS] nfs-over-tcp still needs udp ports? (SLES 11)
Date: Thu, 07 May 2009 13:08:33 -0400
Message-ID: <4a031594.1c1d640a.6d45.5fed@mx.google.com>
References: <4A02DAA8.6050005@bio.ifi.lmu.de>
	<c2d0b6ec0905070634p6888226cx5b2c8abae51cd1be@mail.gmail.com>
	<4A02FDC3.9090709@bio.ifi.lmu.de>
	<4a02ffdf.1ac1f10a.637d.ffffbc3a@mx.google.com>
	<e7ca40f70905070908p595c1d23gef745a122ae09caa@mail.gmail.com>
	<C8BD2645-6EFC-4669-9074-B57C08B2EF70@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Leonardo Chiquitto <leonardo.lists@gmail.com>,
	Frank Steiner <fsteiner-mail1-G0GEQqhI7DhYiKXMg8wJIg@public.gmane.org>,
	nfs@lists.sourceforge.net
To: Aaron Wiebe <epiphani@gmail.com>,
	Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39678 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbZEGRJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 7 May 2009 13:09:46 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M276N-0007HL-CZ
	for linux-nfs@vger.kernel.org; Fri, 08 May 2009 03:09:43 +1000
In-Reply-To: <C8BD2645-6EFC-4669-9074-B57C08B2EF70@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

At 12:42 PM 5/7/2009, Chuck Lever wrote:
>On May 7, 2009, at 12:08 PM, Aaron Wiebe wrote:
>> On Thu, May 7, 2009 at 11:35 AM, Tom Talpey <tmtalpey@gmail.com>  
>> wrote:
>>>
>>> There is one small caveat to using mountproto=tcp through firewalls:
>>> while the mount will succeed, there are some side protocol exchanges
>>> which may not.
>>>
>>> In particular, if you do NLM file locking, there is a server  
>>> callback (NLM
>>> "granted") which the server may choose to issue via UDP. If this  
>>> callback
>>> is not seen by the client due to firewall blocking, there may be a  
>>> 30-second
>>> pause before a client retry unblocks the caller.
>>>
>>> Also, the NSM (status monitor) exchanges are often performed via UDP.
>>> Again, if you are using NLM and the server reboots, the client may  
>>> not
>>> become aware of this promptly, and lock reclaim will be affected.
>>
>> Sorry for the slight threadjack, but a question along those lines...
>>
>> My understanding is that currently portmap will not bind any UDP NLM
>> listeners unless there are UDP mounts on the machine.
>
>It's not portmap... lockd decides which listeners to start.

Also, there is an important distinction between NLM and NLM *callbacks*.
The NLM client follows the NFS protocol selection in many client kernels,
i.e. if you mount with proto=tcp, you get both NFS and NLM over TCP.

The issue is NLM callbacks, which are used only in specific cases where
clients take blocking locks, which actually need to block due to being already
held by another client. The server replies over NLM (e.g. TCP) with an indication
that a callback will arive later. But when the other lock is released, the callback
comes on a second connection, initiated from the server back to the client and
not on the original NLM channel. To make matters worse, some servers only
ever perform the callback on UDP in order to simplify and reduce the overhead
required.

If this callback doesn't arrive at the client, or arrives in such a way that
it's not recognized (e.g traverses a NAT and therefore changes source IP),
then the client only wakes up on a timer. The long pauses can be a real
problem, and one which only arises occasionally - i.e. very hard to trace down.

Just something to be aware of... it's a day-one defect in the NLM protocol,
actually.

Tom.

>
>>  I know there
>> are servers out there that will always speak NLM over UDP
>> (netapp/ontap being the prominent one), and as a result there can be
>> problems without firewalls.  If servers are out there that will speak
>> NLM over UDP regardless of the mount itself, shouldn't we be binding
>> NLM/UDP regardless of the mount transport?
>>
>> (Or did I miss this change being reverted a while back?)
>
>This change was reverted upstream; see commit 8c3916f4.
>
>--
>Chuck Lever
>chuck[dot]lever[at]oracle[dot]com
>


------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

