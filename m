Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:25671 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab2DXO2o convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Apr 2012 10:28:44 -0400
Subject: Re: NFSv4 high availability setups
Mime-Version: 1.0 (Apple Message framework v1257)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20120424100117.67d3d842@tlielax.poochiereds.net>
Date: Tue, 24 Apr 2012 10:28:00 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, jiri.horky@cesnet.cz
Message-Id: <80759DD6-7733-468F-AAA5-F927DF1091BA@oracle.com>
References: <20120405103124.GV4752@ics.muni.cz> <20120405073901.63d1c749@tlielax.poochiereds.net> <20120410125552.GC5074@ics.muni.cz> <20120410091321.1be1a87e@tlielax.poochiereds.net> <20120417143448.GU32132@ics.muni.cz> <20120417111411.334c3d2b@corrin.poochiereds.net> <20120424100117.67d3d842@tlielax.poochiereds.net>
To: Jeff Layton <jlayton@redhat.com>, Lukas Hejtmanek <xhejtman@ics.muni.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Apr 24, 2012, at 10:01 AM, Jeff Layton wrote:

> On Tue, 17 Apr 2012 11:14:11 -0400
> Jeff Layton <jlayton@redhat.com> wrote:
> 
>> On Tue, 17 Apr 2012 16:34:48 +0200
>> Lukas Hejtmanek <xhejtman@ics.muni.cz> wrote:
>> 
>>> Hi,
>>> 
>>> On Tue, Apr 10, 2012 at 09:13:21AM -0400, Jeff Layton wrote:
>>>> Nope. It'll all work just great...until it doesn't. I don't have any
>>>> specific failure scenarios, but most of the problems will be issues
>>>> with state recovery when a server node is restarted.
>>>> 
>>>> That may manifest in different ways -- problems reclaiming locks for
>>>> instance, or even silent data corruption depending on the application.
>>> 
>>> would it work if I relax active-active scenario to just active-passive in the
>>> following way:
>>> 
>>> Server A actively exports  /export/A
>>> Server B actively exports  /export/B
>>> 
>>> Server B is passive backup for Server A
>>> Server A is passive backup for Server B
>>> 
>>> would it work to migrate the failed Server B to Server A so that Server A will
>>> server both /export/A and /export/B?
>>> 
>>> There will be a problem with v4recovery dir. Would it be possible just to
>>> merge v4recovery from Server B to Server A (nfs export would be stopped while
>>> merging v4recovery).
>>> 
>>> It seems that cp -r B/v4recovery/* A/v4recovery/ would do all the things. Am
>>> I right?
>>> 
>>> Do I need to copy recovery state if I delay migration of the failed Server B to
>>> Server A for 91 secs? I.e., longer than lease expiry time.. Or do I still need
>>> a record for the client in v4recovery dir in such a case?
>>> 
>> 
>> That'll still be dangerous. Suppose (for instance) that a client1 lost
>> communication with server B for a period of time and then it expired
>> the lease and handed out a lock to client2 that it was holding
>> previously. client2 modifies the file and drops the lock. At the same
>> time, client1 has uninterrupted communication with serverA, and holds
>> state on it.
>> 
>> Eventually, you fail over server B and merge the directories. client1
>> attempts to renew its lease, but gets back an error and starts
>> reclaiming things. Now, server B would have denied reclaim of that lock
>> -- its lease had expired, but in this case it's allowed because you
>> merged the directory and it client1 held state on serverA. client1
>> reclaims the lock and thinks that it's held the lock the entire time --
>> data corruption and other hilarity ensues...
>> 
> 
> Now that I've had some time to think about this, you may actually be OK
> to just merge those directories when you fail over. The caveat is that
> you need to know for certain that the clients are using non-uniform
> clientid strings when they talk to the server.

The nfs_client_id4 string is supposed to be entirely opaque to servers.  A server can only compare these for equality.  It's simply not valid for a server to "make certain the client is using non-uniform clientid strings."

In fact, NFSv4.1 clients are supposed to use only UCS client strings, so any server implementation that depends on non-UCS is going to be broken for NFSv4.1.  IMO a server implementation should never depend on clients using non-UCS v. UCS.

> When a client makes a SETCLIENTID call to the server, it sends an opaque
> identifier string to the server. Traditionally (and I think per a
> SHOULD in the RFC) Linux clients have varied that string based on the IP
> address of the server. That's called the non-UCS (uniform client string)
> based model.

We've demonstrated that RFC 3530's recommendation to use IP addresses in a client's ID string is mistaken.  The problem this was designed to solve (that servers would mistakenly purge leases if a client identifies itself the same way on multiple server IP addresses) cannot occur, thanks to the SETCLIENTID boot verifier.

Aside from that, the intent of RFC 3530 is that a client should have a single lease on each server.  If either a server or client is multi-homed, using IP addresses in the client ID strings means a client can have more than one lease on a server.  That makes transparent state migration challenging, but it's also a scaling issue because it means servers and clients have to manage much more state information.

> There is some debate on this practice though, as it makes it difficult
> to identify clients for recovery purposes in migration scenarios (Dave
> Novak has a paper on this). In order to facilitate that, we're
> considering moving to a UCS based model in the linux client.

Noveck's migration draft is being accepted as a working group draft, so one could say the debate is officially drawing to consensus.

> The upshot here is that if you do it that way, then a client that holds
> state on both server addresses will look like two different clients even
> after the service floats to the backup server. In that case, you'd have
> no problems with reclaim (in principle, of course!).

A better approach to clustering is to virtualize each NFS service.  The network addresses and filesystem hierarchy (and possibly NFSv4 state as well) on each virtual server move between physical hosts, but are never merged with each other.  Then there is no possibility of confusion.

> The catch here is that if any clients have a UCS based model for
> generating client strings (where the client string is invariant vs. the
> server's IP address), then you'll be subject to the scenario above.
> 
> Still, merging those directories is enough of an uncharted territory
> that I'd advise against it even if it would theoretically work.

Just don't depend on the contents of the client strings.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




