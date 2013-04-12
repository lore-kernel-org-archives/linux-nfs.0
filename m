Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:44384 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753031Ab3DLPOW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Apr 2013 11:14:22 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 6.3 \(1503\))
Subject: Re: NFS client hangs after server reboot
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CACQjR_CcKwHU8sMrmQ5YfgV5dbuiMLRRqBkDRQEVq2yjGEuzmg@mail.gmail.com>
Date: Fri, 12 Apr 2013 11:14:10 -0400
Cc: Rick Macklem <rmacklem@uoguelph.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <DC99B54B-3C48-49A6-B8C4-1410CA707734@oracle.com>
References: <452C72A5-F773-4E16-88F4-B1100C505C41@oracle.com> <60201423.761959.1365722152352.JavaMail.root@erie.cs.uoguelph.ca> <CACQjR_Arj61HJ-QrKfccg=r38555U-43uwhqtwzrN3nd1uUO-Q@mail.gmail.com> <CACQjR_CcKwHU8sMrmQ5YfgV5dbuiMLRRqBkDRQEVq2yjGEuzmg@mail.gmail.com>
To: Bram Vandoren <brambi@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bram-

I'm going to leave linux-nfs on the cc: line while we debug this.  If there is a privacy issue, you can send raw pcap files directly to us.  The mail archive does not save attachments, IIRC.


On Apr 12, 2013, at 5:26 AM, Bram Vandoren <brambi@gmail.com> wrote:

> Hi Rick, Chuck, Bruce,
> in attachment is a small pcap when a client is in the locked.
> Hopefully I can reproduce the problem so I can send you a capture
> during a reboot cycle.

The pcap file confirms that the state IDs and client ID do not appear to match, and do appear on the same TCP connection (in different operations).  I think the presence of the RENEW operations here suggest that the client believes it has not been able to renew its lease using stateful operations like READ.  IMO this is evidence in favor of the theory that the client neglected to recover these state IDs for some reason.

We'll need to see the actual reboot recovery traffic to analyze further, and that occurs just after the server reboots.  Even better would be to see the initial OPEN of the file where the READ operations are failing.  I recognize this is a non-determinstic problem that will be a challenge to capture properly.

Rather than capturing the trace on the server, you should be able to capture it on your clients in order to capture traffic before, during, and after the server reboot.  To avoid capturing an enormous amount of data, both tcpdump and tshark provide options to save the captured network data into a small ring of files (see their man pages).  Once a client mount point has locked, you can stop the capture, and hopefully the ring will have everything we need.



> 
> Thanks,
> Bram.
> 
> On Fri, Apr 12, 2013 at 11:19 AM, Bram Vandoren <brambi@gmail.com> wrote:
>>> Just to clarify/correct what I posted yesterday...
>>> The boot instance is the first 4 bytes of the clientid and the first
>>> 4 bytes of the stateid.other. (Basically, for the FreeBSD server, a
>>> stateid.other is just the clientid + 4 additional bytes that identify
>>> which stateid related to the clientid that it is.)
>>> 
>>> Those first 4 bytes should be the same for all clientids/stateid.others
>>> issued during a server boot cycle. Any clientid/stateid.other with a
>>> different first 4 bytes will get the NFS4ERR_STALE_CLIENTID/STATEID
>>> reply.
>> 
>> Thanks for the clarification. I tried to reproduce the problem using a
>> test setup but so far I didn't succeed. It's clearly not a problem
>> that happens all the time. Also not all the clients lock up in the
>> production system. Only a fraction of them (~ 1 in 10).
>> 
>> I checked the packets again. The Stateid in a read operation is:
>> 9a:b6:5d:51:bc:07:00:00:24:23:00:00
>> The client id:
>> af:c1:63:51:8b:01:00:00
>> 
>> It seems we ended up with a stale stateid but with a valid client id.
>> 
>> I am going to do some more tests with mutiple clients to try to
>> reproduce the problem. If that doesn't succeed I try to get the data
>> from the production server when we have to reboot it next time (but
>> this can take a while).
>> 
>> Thanks,
>> Bram

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




