From: Johan van den Dorpe <johan.vandendorpe@framestore-cfc.com>
Subject: Re: rpc.mountd stops functioning
Date: Thu, 25 Nov 2004 12:45:31 +0000
Message-ID: <41A5D3EB.1000004@framestore-cfc.com>
References: <411217BE.8070209@framestore-cfc.com> <41122039.9040907@framestore-cfc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CXJ0y-0007kn-1S
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 04:46:24 -0800
Received: from gw.fs-cfc.co.uk ([193.203.83.22])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.41)
	id 1CXJ0w-0001l8-Op
	for nfs@lists.sourceforge.net; Thu, 25 Nov 2004 04:46:23 -0800
Received: from localhost (localhost [127.0.0.1])
	by mail.admin.local (Postfix) with ESMTP id EDD1DA075F8
	for <nfs@lists.sourceforge.net>; Thu, 25 Nov 2004 12:45:33 +0000 (GMT)
Received: from [172.18.10.33] (sys33.prod.local [172.18.10.33])
	by mail.admin.local (Postfix) with ESMTP id 8AEB2B07A92
	for <nfs@lists.sourceforge.net>; Thu, 25 Nov 2004 12:45:31 +0000 (GMT)
To: nfs@lists.sourceforge.net
In-Reply-To: <41122039.9040907@framestore-cfc.com>
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

I think I've got this sussed. After reading this thread:

http://sourceforge.net/mailarchive/message.php?msg_id=9891180
http://sourceforge.net/mailarchive/message.php?msg_id=9901077

I thought it might be worth testing the vanilla nfs-utils package from 
kernel.org rather than the redhat supplied versions.

Now, I've had this setup running for 28 days without any issues on one 
of our servers that has been a real problem in the past.

I'm going to try this solution on a wider scale to try and confirm this 
further, but for now I consider this the fix.

My advice to anyone running a vanilla kernel is to run the vanilla 
nfs-utils package and not a redhat nfs-utils package.

Johan van den Dorpe wrote:
> I clicked send a bit fast. Other info:
> 
> Running RHEL 3 with 2.4.25 vanilla kernel. nfs-utils-1.0.5
> 
> Experienced the problem in the past with Red Hat 7.3 with same 2.4.25 
> kernel and 2.4.20 kernel + XFS patches + Trond's all patch for 2.4.20. 
> Tried nfs-utils 0.3.3 and 1.0.6
> 
> Johan van den Dorpe wrote:
> 
>> Hello,
>>
>> For a long time we've been experiencing problems with rpc.mountd 
>> stopping functioning.
>>
>> I'm finding it hard to pinpoint the precise circumstances where we 
>> encounter a problem, but here is what we have observed:
>>
>> - A mount request, or a showmount -e, to the server will hang
>>
>> - The server will print a log message authenticating the mount request
>>
>> - The server doesn't print log messages that it has authenticated 
>> unmount requests.
>>
>> - Killing rpc.mountd and then restarting it fixes the problem (I've 
>> not tried a HUP)
>>
>> - There is a correlation between the number of mounts being handled 
>> (i.e. the number of entries in rmtab) and the frequency of the problem.
>>
>> - The problem only occurs on servers that are mounted by a significant 
>> number of hosts (500-700).
>>
>> - The more exports on the server, the more frequently the problem occurs.
>>
>> - It should be noted that clients are mounting subdirectories of a 
>> single exported filesystem, so number of rmtab entries > number of 
>> xtab entries.
>>
>> - Clearing the rmtab and restarting nfs (service nfs restart) seems to 
>> provide the longest time between failures.
>>
> 
> 


-- 
Johan van den Dorpe


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
