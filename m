From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Debian Bug#203077: Locks not released on NFS client reboot
Date: Fri, 14 Jan 2005 11:19:58 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501141113230.11608@harp.ngdc.noaa.gov>
References: <Pine.OSF.4.56.0307271137050.10355@grover.WPI.EDU>
 <20030727163124.GC19877@perlsupport.com>  <16164.29864.268358.781865@gargle.gargle.HOWL>
  <Pine.LNX.4.60.0501131844130.6332@harp.ngdc.noaa.gov>
 <16871.11926.507904.373575@cse.unsw.edu.au> <1105724840.13393.36.camel@localhost.localdomain>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Chip Salzenberg <chip@pobox.com>, nfs@lists.sourceforge.net,
	thomas.r.carey@noaa.gov, Mark O Sleeper <Mark.O.Sleeper@noaa.gov>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpW3S-0003me-RR
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 10:20:14 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpW3Q-0000ns-8G
	for nfs@lists.sourceforge.net; Fri, 14 Jan 2005 10:20:14 -0800
To: Dan Stromberg <strombrg@dcs.nac.uci.edu>
In-Reply-To: <1105724840.13393.36.camel@localhost.localdomain>
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

On Fri, 14 Jan 2005, Dan Stromberg wrote:

> On Fri, 2005-01-14 at 13:29 +1100, Neil Brown wrote:
>> On Thursday January 13, Ara.T.Howard@noaa.gov wrote:
>>>
>>> i am seeing problems here on my system (which has rebooted and now has stale
>>> locks on server)
>>>
>> ..
>>>    server:
>>>
>>>      mussel:~ > rpcinfo -u bligh status
>>>      rpcinfo: RPC: Port mapper failure - RPC: Unable to receive
>>>      program 100024 is not available
>> ...
>>>
>>>    client:
>>>
>>>      bligh:~ > rpcinfo -p
>>>         program vers proto   port
>>>          100000    2   tcp    111  portmapper
>>>          100000    2   udp    111  portmapper
>>>          100024    1   udp  32768  status
>>>          100024    1   tcp  32768  status
>> ...
>>
>>
>> So bligh, the client, is running statd (the "status" service), but
>> mussel can not talk to it.  This is a problem.
>>
>> It would appear that some for of firewall is blocking access to
>> bligh's statd from mussel, or that  bligh's statd is ignoring requests
>> from mussel.  I don't know which.
>>
>> NeilBrown
>
> I'm actually seeing a lot of problems on *ix systems were a service is
> registered, but then the corresponding daemon doesn't actually service
> requests.
>
> My rpc-health script allowed me to identify a lot of such problems
> fairly quickly:
>
> http://dcs.nac.uci.edu/~strombrg/rpc-health.html
>
> ...so I guess the upshot is "It isn't necessarily a firewall problem".

nice!

it is showing (mussel=server, bligh=client) :

   mussel:

     ~ > ./rpc-health bligh
     rpcinfo: can't contact portmapper: RPC: Remote system error - No route to
     host

   bligh:

     ~ > ./rpc-health mussel
     Program portmapper/100000, Proto tcp, Version 2 is OK
     Program portmapper/100000, Proto udp, Version 2 is OK
     Program status/100024, Proto udp, Version 1 is OK
     Program status/100024, Proto tcp, Version 1 is BAD <========
     Program rquotad/100011, Proto udp, Version 1 is OK
     Program rquotad/100011, Proto udp, Version 2 is OK
     Program rquotad/100011, Proto tcp, Version 1 is BAD <========
     Program rquotad/100011, Proto tcp, Version 2 is BAD <========
     Program nfs/100003, Proto udp, Version 2 is OK
     Program nfs/100003, Proto udp, Version 3 is OK
     Program nfs/100003, Proto tcp, Version 2 is OK
     Program nfs/100003, Proto tcp, Version 3 is OK
     Program nlockmgr/100021, Proto udp, Version 1 is OK
     Program nlockmgr/100021, Proto udp, Version 3 is OK
     Program nlockmgr/100021, Proto udp, Version 4 is OK
     Program nlockmgr/100021, Proto tcp, Version 1 is BAD <========
     Program nlockmgr/100021, Proto tcp, Version 3 is BAD <========
     Program nlockmgr/100021, Proto tcp, Version 4 is BAD <========
     Program mountd/100005, Proto udp, Version 1 is OK
     Program mountd/100005, Proto tcp, Version 1 is BAD <========
     Program mountd/100005, Proto udp, Version 2 is OK
     Program mountd/100005, Proto tcp, Version 2 is BAD <========
     Program mountd/100005, Proto udp, Version 3 is OK
     Program mountd/100005, Proto tcp, Version 3 is BAD <========

so apparently our system is severly misconfigured!  i'm guess all the BAD's
for tcp are o.k. but that the 'no route to host' is not a good thing.  sound
accurate?

btw. here is a small patch:

[ahoward@mussel ahoward]$ diff -u rpc-health.org rpc-health
--- rpc-health.org      2005-01-06 17:48:53.000000000 -0700
+++ rpc-health  2005-01-14 11:11:20.000000000 -0700
@@ -1,7 +1,9 @@
-#!/dcs/bin/bash2
+#!/usr/bin/env bash

  #set -x

+PATH=$PATH:/usr/sbin:sbin # for rpcinfo
+
  function usage
  {
         echo Usage "$0" hostname 1>&2


kind regards.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
