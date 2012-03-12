Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:49376 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756749Ab2CLUuC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 16:50:02 -0400
Subject: Re: NFS4 over VPN hangs when connecting > 2 clients
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120312204238.GA8991@fieldses.org>
Date: Mon, 12 Mar 2012 16:49:29 -0400
Cc: Nikolaus Rath <Nikolaus@rath.org>, linux-nfs@vger.kernel.org
Message-Id: <7C4C12AF-5820-4BF3-8262-3BF5C201DA8C@oracle.com>
References: <878vj7x6mj.fsf@vostro.rath.org> <87pqchn64e.fsf@inspiron.ap.columbia.edu> <20120312193115.GA7203@fieldses.org> <4F5E5241.7070008@rath.org> <20120312201505.GC7203@fieldses.org> <4F5E5CF2.50309@rath.org> <20120312204238.GA8991@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 12, 2012, at 4:42 PM, J. Bruce Fields wrote:

> On Mon, Mar 12, 2012 at 04:30:42PM -0400, Nikolaus Rath wrote:
>> On 03/12/2012 04:15 PM, J. Bruce Fields wrote:
>>> On Mon, Mar 12, 2012 at 03:45:05PM -0400, Nikolaus Rath wrote:
>>>> On 03/12/2012 03:31 PM, J. Bruce Fields wrote:
>>>>> On Mon, Mar 12, 2012 at 12:20:17PM -0400, Nikolaus Rath wrote:
>>>>>> Nikolaus Rath <Nikolaus-BTH8mxji4b0@public.gmane.org> writes:
>>>>>>> The problem is that as soon as more than three clients are accessing the
>>>>>>> NFS shares, any operations on the NFS mountpoints by the clients hang.
>>>>>>> At the same time, CPU usage of the VPN processes becomes very high. If I
>>>>>>> run the VPN in debug mode, all I can see is that it is busy forwarding
>>>>>>> lots of packets. I also ran a packet sniffer which showed me that 90% of
>>>>>>> the packets were NFS related, but I am not familiar enough with NFS to
>>>>>>> be able to tell anything from the packets themselves. I can provide an
>>>>>>> example of the dump if that helps.
>>>>>> 
>>>>>> I have put a screenshot of the dump on
>>>>>> http://www.rath.org/res/wireshark.png (the full dump is 18 MB, and I'm
>>>>>> not sure which parts are important).
>>>>> 
>>>>> Looks like they're doing SETCLIENTID, SETCLIENTID_CONFIRM, OPEN,
>>>>> OPEN_CONFIRM repeatedly.
>>>>> 
>>>>>> Any suggestions how I could further debug this?
>>>>> 
>>>>> Could the clients be stepping on each others' state if they all think
>>>>> they have the same IP address (because of something to do with the VPN
>>>>> networking?)
>>>> 
>>>> That sounds like promising path of investigation. What determines the IP
>>>> of a client as far as NFS is concerned?
>>> 
>>> I don't remember where it gets the ip it uses to construct clientid's
>>> from....  But there is a mount option (clientaddr=) that will let you
>>> change what it uses.  So it *might* be worth checking whether using a
>>> clientaddr= option on each client (giving it a different ipaddr on each
>>> client) would change the behavior.
>> 
>> I'll try that.
>> 
>> Since there seems to be some problem with client identity: all the
>> clients are generated using the same disk image. This image also
>> includes some stuff in /var/lib/nfs. I already tried emptying this on
>> every client and did not help, but maybe there is another directory with
>> state data that could cause problems?
> 
> The state in there is used by the v2/v3 client, and by the server with
> v4 as well, but not by the v4 client, so I wouldn't expect that to be an
> issue.
> 
>>>>> It'd be interesting to know the fields of the setclientid call, and the
>>>>> errors that the server is responding with to these calls.  If you look
>>>>> at the packet details you'll probably see the same thing happening
>>>>> over and over again.
>>>>> 
>>>>> Filtering to look at traffic between server and one client at a time
>>>>> might help to see the pattern.
>>>> 
>>>> Hmm. I'm looking at the fields, but I just have no idea what any of
>>>> those mean. Would you possibly be willing to take a look? I uploaded a
>>>> pcap dump of a few packets to http://www.rath.org/res/sample.pcap.
>>> 
>>> Looking at the packet details, under the client id field, the clients
>>> are all using:
>>> 
>>> 	"0.0.0.0/192.168.1.2 tcp UNIX 0"
>> 
>> Hmm. 192.168.1.2 is the server's address on the VPN. Is that supposed to
>> be there?
> 
> Yes,and the first ip is usually the ip of the client, which does suggest
> the client is guessing it's ip wrong; so the "clientaddr=" option will
> likely help.

I thought 0.0.0.0 was a legal callback address, and means "don't send me CB requests".

But if all the clients are using the same nfs_client_id4 string, then no, the server can't distinguish between them, and they will tromp on each other's state.

The question is why can't the clients tell what their own IP address is?  mount.nfs is supposed to figure that out automatically.  Could be a bug in mount.nfs.

> Hm, perhaps the server should be rejecting these SETCLIENTID's with
> INUSE.  It used to do that, and the client would likely recover from
> that more easily.

INUSE means the client is using multiple authentication flavors when performing RENEW or SETCLIENTID.  I can't think of a reason the server should reject these; it's not supposed to look at the contents of the nfs_client_id4 string.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




