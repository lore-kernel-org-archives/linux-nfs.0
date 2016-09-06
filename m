Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:28122 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933499AbcIFQiY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Sep 2016 12:38:24 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: 4.6, 4.7 slow ifs export with more than one client.
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru>
Date: Tue, 6 Sep 2016 12:38:14 -0400
Cc: Jeff Layton <jlayton@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <6FDE27B8-D2AB-400F-ACD6-E30FA62A844B@oracle.com>
References: <6C329B27-111A-4B16-84F4-7357940EBC01@linuxhacker.ru> <1473172215.13234.8.camel@redhat.com> <A7375479-E5A6-47FE-915E-8E2B6E5CF012@linuxhacker.ru> <1473175124.13234.16.camel@redhat.com> <05AA5CE8-143C-4CB7-AFF0-36BE495AA328@linuxhacker.ru>
To: Oleg Drokin <green@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Sep 6, 2016, at 11:47 AM, Oleg Drokin <green@linuxhacker.ru> wrote:
> 
> 
> On Sep 6, 2016, at 11:18 AM, Jeff Layton wrote:
> 
>> On Tue, 2016-09-06 at 10:58 -0400, Oleg Drokin wrote:
>>> On Sep 6, 2016, at 10:30 AM, Jeff Layton wrote:
>>> 
>>>> 
>>>> On Mon, 2016-09-05 at 00:55 -0400, Oleg Drokin wrote:
>>>>> 
>>>>> Hello!
>>>>> 
>>>>>   I have a somewhat mysterious problem with my nfs test rig that I suspect is something
>>>>>   stupid I am missing, but I cannot figure it out and would appreciate any help.
>>>>> 
>>>>>   NFS server is Fedora23 with 4.6.7-200.fc23.x86_64 as the kernel.
>>>>>   Clients are a bunch of 4.8-rc5 nodes, nfsroot.
>>>>>   If I only start one of them, all is fine, if I start all 9 or 10, then suddenly all
>>>>>   operations ground to a half (nfs-wise). NFS server side there's very little load.
>>>>> 
>>>>>   I hit this (or something similar) back in June, when testing 4.6-rcs (and the server
>>>>>   was running 4.4.something I believe), and back then after some mucking around
>>>>>   I set:
>>>>> net.core.rmem_default=268435456
>>>>> net.core.wmem_default=268435456
>>>>> net.core.rmem_max=268435456
>>>>> net.core.wmem_max=268435456
>>>>> 
>>>>>   and while no idea why, that helped, so I stopped looking into it completely.
>>>>> 
>>>>>   Now fast forward to now, I am back at the same problem and the workaround above
>>>>>   does not help anymore.
>>>>> 
>>>>>   I also have a bunch of "NFSD: client 192.168.10.191 testing state ID with incorrect client ID"
>>>>>   in my logs (also had in June. Tried to disable nfs 4.2 and 4.1 and that did not
>>>>>   help).
>>>>> 
>>>>>   So anyway I discovered the nfsdcltrack and such and I noticed that whenever
>>>>>   the kernel calls it, it's always with the same hexid of
>>>>>   4c696e7578204e465376342e32206c6f63616c686f7374
>>>>> 
>>>>>   NAturally if I try to list the content of the sqlite file, I get:
>>>>> sqlite> select * from clients;
>>>>> Linux NFSv4.2 localhost|1473049735|1
>>>>> sqlite> select * from clients;
>>>>> Linux NFSv4.2 localhost|1473049736|1
>>>>> sqlite> select * from clients;
>>>>> Linux NFSv4.2 localhost|1473049737|1
>>>>> sqlite> select * from clients;
>>>>> Linux NFSv4.2 localhost|1473049751|1
>>>>> sqlite> select * from clients;
>>>>> Linux NFSv4.2 localhost|1473049752|1
>>>>> sqlite> 
>>>>> 
>>>> 
>>>> Well, not exactly. It sounds like the clients are all using the same
>>>> long-form clientid string. The server sees that and tosses out any
>>>> state that was previously established by the earlier client, because it
>>>> assumes that the client rebooted.
>>>> 
>>>> The easiest way to work around this is to use the nfs4_unique_id nfs.ko
>>>> module parm on the clients to give them each a unique string id. That
>>>> should prevent the collisions.
>>> 
>>> Hm, but it did work ok in the past.
>>> What determines the unique id now by default?
>>> The clients do start with a different ip address for one, so that
>>> seems to make that a much more good proxy for unique id
>>> (or local ip/server ip as is in case of centos7) than whatever local
>>> hostname is at any random point in time during boot
>>> (where it might not be set yet apparently).
>>> 
>> 
>> The v4.1+ clientid is (by default) determined entirely from the
>> hostname.
>> 
>> IP addresses are a poor choice given that they can easily change for
>> clients that have them dynamically assigned. That's the main reason
>> that v4.0 behaves differently here. The big problems there really come
>> into play with NFSv4 migration. See this RFC draft for the gory
>> details:
>> 
>>    https://tools.ietf.org/html/draft-ietf-nfsv4-migration-issues-10
> 
> Duh, so "ip addresses are unreliable, let's use something even less
> reliable". hostname is also dynamic in a bunch of cases, btw.
> Worst of all, there are very many valid cases where nfs might be mounted
> before hostname is set (or do you regard that as a bug in the environment
> and I should just file a ticket in Fedora bugzilla?)

That's a bug IMO. How can network activity be done before the host is
properly configured? If the host has an IP address, it can perform
a reverse-lookup and find out the matching hostname and use that.

At any rate, if NFS needs the hostname set before performing a mount,
that dependency should be added to the O/S's start-up logic.


> Looking over the draft, the two cases are:
> what if client reboots, how do we reclaim state ASAP and
> what if there is server migration, but same client.
> 
> The second case is trivial as long as the client id stays constant no matter
> what server you connect to and might be any number of constant identifiers,
> be it random, or not.
> 
> On the other hand the rebooted client is more interesting. Of course there's
> also a lease expiration (that's what we do in Lustre too, if the client dies,
> it'll be expired eventually, but also if we talk to it and it does not reply,
> we kick it out as well, and this has a much shorter timeout, so not as disruptive).
> 
> Cannot some more unique identifier be used by default?

There is no good way to do this. We picked a way that works in many
convenient cases, and provided a mechanism for setting a unique ID
in the cases where the default behavior does not work. That's the
best that can be done.

Ideally, we would want O/S installation to generate a random value
(say, a UUID) and store that persistently on the client to use as
its client ID. A diskless client does not have persistent storage,
however.


> Say "mac address of the primary interface, whatever that happens to be",
> in that case as long as your client remains on the same physical box
> (and the network card has not changed), you should be fine.

That has all the same caveats as using hostname or IP address. Given that
Linux is notoriously bad about the "ordering" of hardware devices after
a reboot, it's difficult to claim that this would be more reliable than
using a hostname.


> I guess there are other ways.
> Ideally, kernel would offer an API (might be there is already, but I cannot find it)
> that could be queried for a unique id like that (with inputs from mac addresses,
> various serial numbers identifiable and such).

The IESG had some trouble with that; namely that (if I recall correctly)
it makes it possible for an attacker to see that serial number on the
wire, tracking that host and its MACs and PRNG.

We carefully considered all of this when authoring that document. And,
implementations of NFSv4 are free to use whatever they like in that
client ID. The text in that document is a suggestion, not a normative
requirement.

--
Chuck Lever



