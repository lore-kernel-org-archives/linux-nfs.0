From: Charles-Edouard Ruault <ce@idtect.com>
Subject: Re: Re: Linux 2.4.25, nfs client hangs when talking to a MacOS nfs server.
Date: Thu, 18 Mar 2004 17:53:13 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <BEC421C0-78FC-11D8-97E9-000A95CFFC9C@idtect.com>
References: <482A3FA0050D21419C269D13989C61130435DD8A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0 (Apple Message framework v613)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Cc: "<csc@cadence.com>" <csc@cadence.com>,
   "<nfs@lists.sourceforge.net>" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B40mR-000558-Lt
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 08:54:03 -0800
Received: from czame.czame.com ([64.33.120.2])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1B40mM-0006LC-1f
	for nfs@lists.sourceforge.net; Thu, 18 Mar 2004 08:53:58 -0800
In-Reply-To: <482A3FA0050D21419C269D13989C61130435DD8A@lavender-fe.eng.netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>,
   "Lever, Charles" <Charles.Lever@netapp.com>
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


On Mar 17, 2004, at 8:56 PM, Lever, Charles wrote:

> charles-
>
>>> [ snip ]
>>>
>>>
>> We'll see if this disappears after we've finished migrating
>> the network
>> to 1Gbps
>>
>>> In these environments you *must* use TCP, since that has congestion
>>> control capabilities baked into the protocol...
>
> what matters here is flow control.  UDP simply doesn't have it.
>
> for gigabit Ethernet, you need flow control at the link level and
> at the transport level.  so once you have gigabit infrastructure,
> be sure you have enabled full gigabit flow control on your servers
> and on your switches.  then you should use TCP and not UDP so you
> have transport layer flow control.
>
Charles and Trond,
thanks for the advices !
I've upgraded the network cards of the linux machines to Gigabit 
ethernet cards and used tcp for my nfs mounts.
The problem disappeard so far so i'm pretty happy !
However i'm very disappointed by the throuhput i'm getting on the Gbps 
network :
When i scp a 473991492 bytes file from one machine to the other, i'm 
getting 14Mbps throughput, which is far less that 1Gpbs theoretical.
Looking at the network card info ( i'm using the sk98lin driver ) i've :
Mar 18 14:49:15 omnirot kernel: eth0: network connection up using port A
Mar 18 14:49:15 omnirot kernel:     speed:           1000
Mar 18 14:49:15 omnirot kernel:     autonegotiation: yes
Mar 18 14:49:15 omnirot kernel:     duplex mode:     full
Mar 18 14:49:15 omnirot kernel:     flowctrl:        symmetric
Mar 18 14:49:15 omnirot kernel:     role:            slave
Mar 18 14:49:15 omnirot kernel:     irq moderation:  disabled
Mar 18 14:49:15 omnirot kernel:     scatter-gather:  enabled

The switch i'm using is a Netgear GS516T

i've tried transferring to/from 2 linux machines connected to this 
switch using the exact same kernel and network cards and also to Mac 
Xserv using a Gbps card . They both yield the same low throuput.
Any hint of what could be causing this ?
Thanks in advance.


Charles-Edouard Ruault
Idtect SA
tel: +33-1-42-81-81-84
fax: +33-1-42-81-82-21
http://www.idtect.com



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
