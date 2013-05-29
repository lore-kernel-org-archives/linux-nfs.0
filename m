Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:21599 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932863Ab3E2BOJ convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2013 21:14:09 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: NFS client hangs after server reboot
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <E626E85E-BC60-4FBA-BF02-536508991C65@oracle.com>
Date: Tue, 28 May 2013 21:13:57 -0400
Cc: Bram Vandoren <brambi@gmail.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <BC47EE42-5F58-4555-A49C-4175B75943D8@oracle.com>
References: <1480713067.24683.1369783846612.JavaMail.root@erie.cs.uoguelph.ca> <E626E85E-BC60-4FBA-BF02-536508991C65@oracle.com>
To: Rick Macklem <rmacklem@uoguelph.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On May 28, 2013, at 9:04 PM, Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On May 28, 2013, at 7:30 PM, Rick Macklem <rmacklem@uoguelph.ca> wrote:
> 
>> Bram Vandoren wrote:
>>>>> Hi Rick, Chuck, Bruce,
>>>>> in attachment is a small pcap when a client is in the locked.
>>>>> Hopefully I can reproduce the problem so I can send you a capture
>>>>> during a reboot cycle.
>>>> 
>>>> The pcap file confirms that the state IDs and client ID do not
>>>> appear to match, and do appear on the same TCP connection (in
>>>> different operations). I think the presence of the RENEW operations
>>>> here suggest that the client believes it has not been able to renew
>>>> its lease using stateful operations like READ. IMO this is evidence
>>>> in favor of the theory that the client neglected to recover these
>>>> state IDs for some reason.
>>>> 
>>>> We'll need to see the actual reboot recovery traffic to analyze
>>>> further, and that occurs just after the server reboots. Even better
>>>> would be to see the initial OPEN of the file where the READ
>>>> operations are failing. I recognize this is a non-determinstic
>>>> problem that will be a challenge to capture properly.
>>>> 
>>>> Rather than capturing the trace on the server, you should be able to
>>>> capture it on your clients in order to capture traffic before,
>>>> during, and after the server reboot. To avoid capturing an enormous
>>>> amount of data, both tcpdump and tshark provide options to save the
>>>> captured network data into a small ring of files (see their man
>>>> pages). Once a client mount point has locked, you can stop the
>>>> capture, and hopefully the ring will have everything we need.
>>> 
>>> Hi All,
>>> I managed to capture the packets after a reboot. I send the pcap file
>>> to the people in cc (privacy issue, contact me if someone on the list
>>> wants a copy). This is a summary of what happens after a reboot
>>> (perhaps a missed some relevant information):
>>> 
>>> 38:
>>> - client -> server: client executes 3 writes with a stale clientid (A)
>>> - client -> server: RENEW
>>> 44:
>>> - server -> client: NFS4ERR_STALE_STATEID (in reponse to A)
>>> 45:
>>> - server -> client: NFS4ERR_STALE_CLIENTID
>>> 65:
>>> - client -> server: RENEW
>>> 66
>>> - server -> client: NFS4ERR_STALE_CLIENTID
>>> 67,85,87,93:
>>> SETCLIENTID/SETCLIENTID_CONFIRM sequence (ok)
>>> 78,79:
>>> NFS4STALE_STATEID (reponse to the other 2 writes in A)
>>> 
>>> 98: OPEN with CLAIM_PREVIOUS
>>> 107: response to open: NFS4ERR_NO_GRACE (strange?)
>>> after that the client re-opens the files without CLAIM_PREVIOUS option
>>> and they are all succesful.
>>> 
>>> The client starts using the new stateids except for the files in A.
>>> The server returns a NFS4_STALE_STATEID, the client executes a RENEW
>>> (IMO this should be an OPEN request) and retries the WRITE, the server
>>> returns a NFS4_STALE_STATEID
>>> 
>>> Server: FreeBSD 9.1 with new NFS server implementation
>>> Client: Fedora 17, 3.8.11-100.fc17.x86_64
>>> 
>>> Any clues?
>>> 
>>> Thanks,
>>> Bram
>> I just took a look at the packet capture (I hadn't realized you had
>> posted one when I did the last reply).
>> 
>> I think the problem is a TCP layer one, from looking at the first 8
>> packets captured amd their timestamps. However, my TCP is old and
>> tired, so I'm not sure. From the first 8 packets:
>> Time(sec)
>> 0  - client sends a SYN
>> 0  - server replies [RST, ACK]
>>    Since Reset is in the reply, is this when the server rebooted?
>> 6  - client sends a SYN with same port#s. Wireshark thinks this is
>>    a new connection using same port#s.
>> 6  - FreeBSD replies with [RST, ACK] again, thinking it is a resend
>>    of the first packet and still considers it the old Reset connection.
>> 15 - Repeat of what happened at 6sec.
>> 30,31 - client sends SYN twice, still from the same port#s
>>  - no reply from FreeBSD
>> 4393 - client sends SYN again with same port#s
>> 4393 - server replies with [SYN, ACK] establishing the new TCP
>>    connection on the same port#s, but over an hour later.
> 
> To be clear, this is very early in the capture, just frame 9 and 10.  The Linux client attempts to re-use the previous connection's source port to preserve the server's duplicate reply cache.

And by the way, if the server actually did reboot, it shouldn't have noticed the client's port re-use.  TCP connection state should have been wiped by the system restart.

> But it's not clear why the client is not retrying SYN during the period between frame 8 and frame 9.  The client should retry SYN after just another minute or two, and by that time the server's TCP connection state should allow a connection on that port.
> 
> It's not typical for a client with an active workload to wait 4400 seconds to send a fresh SYN.  Bram, can you shed any light on this?
> 
>> Since this is now over an hour after packet 0, it isn't
>> surprising that Grace is over.
> 
> Fair enough.  However, it does not explain why the client fails to recover the open state for one file.
> 
>> I'd guess that the problem occurs because the client reconnect
>> uses the same client side port# even though the server did a
>> Reset for that port#, but I'm not enough of a TCP guy to know
>> what should be correct TCP behaviour.
>> 
>> If you don't mind the first part of this packet capture being
>> posted (email me to say if it ok to post it), I can post it to
>> freebsd-net@freebsd.org, since there are a bunch of TCP savy
>> types that might be able to help. (If you give the ok for this,
>> please also email me what version of FreeBSD the server is
>> running.)
> 
> Thanks for the extra set of eyes.
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




