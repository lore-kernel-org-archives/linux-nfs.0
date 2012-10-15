Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6963 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab2JORN7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 13:13:59 -0400
Message-ID: <507C4451.5000600@RedHat.com>
Date: Mon, 15 Oct 2012 13:13:53 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chuck Lever <chuck.lever@oracle.com>
CC: NeilBrown <neilb@suse.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: Should "mount -o proto=udp" be usable against an IPv6 only server?
References: <11D4587E-7739-4D31-836D-D63177D13302@oracle.com> <20121008143550.68b4aa45@notabene.brown> <64BBDA5E-E51C-4DD1-9ECB-41322286C57E@oracle.com> <20121009104847.13cceeae@notabene.brown> <61E96B57-9545-4DC5-8AAF-BD704EA802D5@oracle.com>
In-Reply-To: <61E96B57-9545-4DC5-8AAF-BD704EA802D5@oracle.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 09/10/12 11:01, Chuck Lever wrote:
> 
> On Oct 8, 2012, at 7:48 PM, NeilBrown wrote:
> 
>> On Mon, 8 Oct 2012 11:51:29 -0400 Chuck Lever <chuck.lever@oracle.com> wrote:
>>
>>>
>>> On Oct 7, 2012, at 11:35 PM, NeilBrown wrote:
>>>
>>>> On Wed, 3 Oct 2012 21:15:16 -0700 Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>
>>>>> Hi-
>>>>>
>>>>> Unfortunately our corporate e-mail server lost your e-mail from yesterday.  I read it last night and was going to reply this morning, but it was gone from my mailbox.  I'm not sure how to preserve the thread structure at this point.
>>>>>
>>>>> I'm OK with the nfsmount.conf() changes, and the addition of IPv6 syntax to the clientaddr= option.
>>>>>
>>>>>>> The protocol and protocol family the NFS client uses to transmit requests to the NFS server for this mount point.  For example, udp selects UDP over IPv4, while tcp6 selects TCP over IPv6.  If an NFS server has both an IPv4 and an IPv6 address, using a specific netid forces the use of IPv4 or IPv6 networking to communicate with that server.
>>>>>>
>>>>>> I still don't like that last sentence.
>>>>>
>>>>> Can you say why?
>>>>
>>>> Its meaning is not at all clear.  It tells me that some set of circumstances
>>>> will "force the use of IPv4 or IPv6 networking" - given that their isn't
>>>> really any other sort of networking (except maybe RDMA?), I'm not at all
>>>> surprised that it will either use IPv4 or IPv6.  But the sentence doesn't
>>>> tell me how the netid has anything to do with this obvious outcome.
>>>>
>>>> Even if I'm generous and understand that some specific netids will force IPv4
>>>> while other specific netids will force IPv6 (and conveniently forget that
>>>> 'rdma' won't force either), this is true whether the NFS server is
>>>> dual-stack, or has either possible single stack.  So the introductory clause
>>>> it irrelevant to the conclusion.
>>>
>>> Clarifying the last sentence would be less work than rewriting that whole paragraph.
>>>
>>> Incidentally, "rdma" does force IPv4.  NFS/RDMA targets are identified by their IP address and a special port (20049).
>>>
>>>>
>>>>>
>>>>> While that sentence could be made more precise, this is one of the key reasons NFS with netids works the way it does.  Dual-stack NFS servers will be pervasive for some time to come.
>>>>>
>>>>> Other comments:
>>>>>
>>>>> o "rdma6" is not supported, and should not be explicitly listed.
>>>>
>>>> Even though support/nfs/getport.c mentioned it...
>>>> OK, I'll remove that.  I was assuming it might be close given that nfs-utils
>>>> seemed to support it, but apparently not.
>>>
>>> The issue is when the RDMA transport in the kernel will support IPv6.  Since no one is working on adding IPv6 support, it's not likely to happen soon.  The "rmda6" netid support in getport.c is merely for completeness.
>>>
>>>>
>>>>>
>>>>> o "mountproto=rdma[6]" is not supported.
>>>>>
>>>>> o We discourage the use of UDP with NFSv4 (in fact it may no longer be supported).  The NFSv4 proto= language should not list "udp" or "udp6."
>>>>
>>>> It does work ...
>>>> I guess if I change it to "Supported options" rather than "Available options"
>>>> I can bring my self to remove those two...
>>>
>>>> Is this worth an acked-by yet :-)
>>>
>>> I'm not happy about any of the proto= changes, but it's not worth arguing about.  Thanks for the opportunity to comment.  But see below.  You forgot to fix "mountproto=," that really does have to be fixed.
>>>
>>
>> Thanks for your patience.  Sorry I missed the mountproto=rdma changes you
>> mentioned earlier - I've fixed that up now, as well as addressing your other
>> suggestion.
> 
> Acked-by: Chuck Lever <chuck.lever@oracle.com>
Committed..

steved.
> 
>> Thanks,
>> NeilBrown
>>
>> From 0210f5c0cebd884335d2ced5cb3e680d9821e951 Mon Sep 17 00:00:00 2001
>> From: Neil Brown <neilb@suse.de>
>> Date: Tue, 2 Oct 2012 15:21:46 +1000
>> Subject: [PATCH] mount.nfs mapage: clear up confusion between 'proto' and
>> 'transport'
>>
>> The mount option "proto=" actually set the "transport" which in
>> netconfig usage is the pairing of a protocol (e.g. UDP, TCP) with
>> a protocol family (e.g. INET, INET6).
>>
>> This can cause confusion if people naively except "proto=udp" to work
>> equally well on IPv6.
>>
>> So add some text to both nfs(5) and nfsmount.conf(5) to hopefully
>> clarify this.
>>
>> Signed-off-by: NeilBrown <neilb@suse.de>
>>
>> diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
>> index da6d6d3..d04e272 100644
>> --- a/utils/mount/nfs.man
>> +++ b/utils/mount/nfs.man
>> @@ -1,5 +1,5 @@
>> .\"@(#)nfs.5"
>> -.TH NFS 5 "2 November 2007"
>> +.TH NFS 5 "9 October 2012"
>> .SH NAME
>> nfs \- fstab format and options for the
>> .B nfs
>> @@ -472,24 +472,15 @@ Use these options, along with the options in the above subsection,
>> for NFS versions 2 and 3 only.
>> .TP 1.5i
>> .BI proto= netid
>> -The transport protocol name and protocol family the NFS client uses
>> -to transmit requests to the NFS server for this mount point.
>> -If an NFS server has both an IPv4 and an IPv6 address, using a specific
>> -netid will force the use of IPv4 or IPv6 networking to communicate
>> -with that server.
>> -.IP
>> -If support for TI-RPC is built into the
>> -.B mount.nfs
>> -command,
>> -.I netid
>> -is a valid netid listed in
>> -.IR /etc/netconfig .
>> -The value "rdma" may also be specified.
>> -If the
>> -.B mount.nfs
>> -command does not have TI-RPC support, then
>> +The
>> .I netid
>> -is one of "tcp," "udp," or "rdma," and only IPv4 may be used.
>> +determines the transport that is used to communicate with the NFS
>> +server.  Available options are
>> +.BR udp ", " udp6 ", "tcp ", " tcp6 ", and " rdma .
>> +Those which end in
>> +.B 6
>> +use IPv6 addresses and are only available if support for TI-RPC is
>> +built in. Others use IPv4 addresses.
>> .IP
>> Each transport protocol uses different default
>> .B retrans
>> @@ -569,19 +560,18 @@ This option can be used when mounting an NFS server
>> through a firewall that blocks the rpcbind protocol.
>> .TP 1.5i
>> .BI mountproto= netid
>> -The transport protocol name and protocol family the NFS client uses
>> +The transport the NFS client uses
>> to transmit requests to the NFS server's mountd service when performing
>> this mount request, and when later unmounting this mount point.
>> .IP
>> -If support for TI-RPC is built into the
>> +.I netid
>> +may be one of
>> +.BR udp ", and " tcp
>> +which use IPv4 address or, if TI-RPC is built into the
>> .B mount.nfs
>> command,
>> -.I netid
>> -is a valid netid listed in
>> -.IR /etc/netconfig .
>> -Otherwise,
>> -.I netid
>> -is one of "tcp" or "udp," and only IPv4 may be used.
>> +.BR udp6 ", and " tcp6
>> +which use IPv6 addresses.
>> .IP
>> This option can be used when mounting an NFS server
>> through a firewall that blocks a particular transport.
>> @@ -773,21 +763,14 @@ Use these options, along with the options in the first subsection above,
>> for NFS version 4 and newer.
>> .TP 1.5i
>> .BI proto= netid
>> -The transport protocol name and protocol family the NFS client uses
>> -to transmit requests to the NFS server for this mount point.
>> -If an NFS server has both an IPv4 and an IPv6 address, using a specific
>> -netid will force the use of IPv4 or IPv6 networking to communicate
>> -with that server.
>> -.IP
>> -If support for TI-RPC is built into the
>> -.B mount.nfs
>> -command,
>> -.I netid
>> -is a valid netid listed in
>> -.IR /etc/netconfig .
>> -Otherwise,
>> +The
>> .I netid
>> -is one of "tcp" or "udp," and only IPv4 may be used.
>> +determines the transport that is used to communicate with the NFS
>> +server.  Supported options are
>> +.BR tcp ", " tcp6 ", and " rdma .
>> +.B tcp6
>> +use IPv6 addresses and is only available if support for TI-RPC is
>> +built in. Both others use IPv4 addresses.
>> .IP
>> All NFS version 4 servers are required to support TCP,
>> so if this mount option is not specified, the NFS version 4 client
>> @@ -851,6 +834,8 @@ The DATA AND METADATA COHERENCE section discusses
>> the behavior of this option in more detail.
>> .TP 1.5i
>> .BI clientaddr= n.n.n.n
>> +.TP 1.5i
>> +.BI clientaddr= n:n: ... :n
>> Specifies a single IPv4 address (in dotted-quad form),
>> or a non-link-local IPv6 address,
>> that the NFS client advertises to allow servers
>> diff --git a/utils/mount/nfsmount.conf.man b/utils/mount/nfsmount.conf.man
>> index 12a3fe7..2258296 100644
>> --- a/utils/mount/nfsmount.conf.man
>> +++ b/utils/mount/nfsmount.conf.man
>> @@ -1,5 +1,5 @@
>> .\"@(#)nfsmount.conf.5"
>> -.TH NFSMOUNT.CONF 5 "9 Mar 2008"
>> +.TH NFSMOUNT.CONF 5 "9 October 2012"
>> .SH NAME
>> nfsmount.conf - Configuration file for NFS mounts
>> .SH SYNOPSIS
>> @@ -18,6 +18,10 @@ to particular variables using the
>> .BR = 
>> operator, as in 
>> .BR Proto=Tcp .
>> +The variables that can be assigned are exactly the set of NFS specific
>> +mount options listed in
>> +.BR nfs (5).
>> +.PP
>> Sections are broken up into three basic categories:
>> Global options, Server options and Mount Point options.
>> .HP
>> @@ -54,7 +58,7 @@ are defined in the configuration file.
>>     Proto=Tcp
>> .RS
>> .HP
>> -The TCP protocol will be used on every NFS mount.
>> +The TCP/IPv4 protocol will be used on every NFS mount.
>> .HP
>> .RE
>> [ Server \(lqnfsserver.foo.com\(rq ]
>> @@ -62,10 +66,13 @@ The TCP protocol will be used on every NFS mount.
>>     rsize=32k
>> .br
>>     wsize=32k
>> +.br
>> +    proto=udp6
>> .HP
>> .RS
>> -A 33k (32768 bytes) block size will be used as the read and write
>> -size on all mounts to the 'nfsserver.foo.com' server.
>> +A 32k (32768 bytes) block size will be used as the read and write
>> +size on all mounts to the 'nfsserver.foo.com' server.  UDP/IPv6
>> +is the protocol to be used.
>> .HP
>> .RE
>> .BR 
> 
