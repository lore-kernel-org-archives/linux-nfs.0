Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ebox.rath.org ([173.255.235.238]:50099 "EHLO ebox.rath.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752920Ab2CLUan (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Mar 2012 16:30:43 -0400
Message-ID: <4F5E5CF2.50309@rath.org>
Date: Mon, 12 Mar 2012 16:30:42 -0400
From: Nikolaus Rath <Nikolaus@rath.org>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org>
In-Reply-To: <20120312201505.GC7203@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/12/2012 04:15 PM, J. Bruce Fields wrote:
> On Mon, Mar 12, 2012 at 03:45:05PM -0400, Nikolaus Rath wrote:
>> On 03/12/2012 03:31 PM, J. Bruce Fields wrote:
>>> On Mon, Mar 12, 2012 at 12:20:17PM -0400, Nikolaus Rath wrote:
>>>> Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> writes:
>>>>> The problem is that as soon as more than three clients are accessing the
>>>>> NFS shares, any operations on the NFS mountpoints by the clients hang.
>>>>> At the same time, CPU usage of the VPN processes becomes very high. If I
>>>>> run the VPN in debug mode, all I can see is that it is busy forwarding
>>>>> lots of packets. I also ran a packet sniffer which showed me that 90% of
>>>>> the packets were NFS related, but I am not familiar enough with NFS to
>>>>> be able to tell anything from the packets themselves. I can provide an
>>>>> example of the dump if that helps.
>>>>
>>>> I have put a screenshot of the dump on
>>>> http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
>>>> not sure which parts are important).
>>>
>>> Looks like they're doing SETCLIENTID, SETCLIENTID_CONFIRM, OPEN,
>>> OPEN_CONFIRM repeatedly.
>>>
>>>> Any suggestions how I could further debug this?
>>>
>>> Could the clients be stepping on each others' state if they all think
>>> they have the same IP address (because of something to do with the VPN
>>> networking?)
>>
>> That sounds like promising path of investigation. What determines the IP
>> of a client as far as NFS is concerned?
> 
> I don't remember where it gets the ip it uses to construct clientid's
> from....  But there is a mount option (clientaddr=) that will let you
> change what it uses.  So it *might* be worth checking whether using a
> clientaddr= option on each client (giving it a different ipaddr on each
> client) would change the behavior.

I'll try that.

Since there seems to be some problem with client identity: all the
clients are generated using the same disk image. This image also
includes some stuff in /var/lib/nfs. I already tried emptying this on
every client and did not help, but maybe there is another directory with
state data that could cause problems?

>>> It'd be interesting to know the fields of the setclientid call, and the
>>> errors that the server is responding with to these calls.  If you look
>>> at the packet details you'll probably see the same thing happening
>>> over and over again.
>>>
>>> Filtering to look at traffic between server and one client at a time
>>> might help to see the pattern.
>>
>> Hmm. I'm looking at the fields, but I just have no idea what any of
>> those mean. Would you possibly be willing to take a look? I uploaded a
>> pcap dump of a few packets to http://www.rath.org/res/sample.pcap.
> 
> Looking at the packet details, under the client id field, the clients
> are all using:
> 
> 	"0.0.0.0/192.168.1.2 tcp UNIX 0"

Hmm. 192.168.1.2 is the server's address on the VPN. Is that supposed to
be there?


Thanks for your help!

   -Nikolaus

-- 
 »Time flies like an arrow, fruit flies like a Banana.«

  PGP fingerprint: 5B93 61F8 4EA2 E279 ABF6  02CF A9AD B7F8 AE4E 425C
