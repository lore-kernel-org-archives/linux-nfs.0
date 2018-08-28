Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp2130.oracle.com ([156.151.31.86]:58174 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726383AbeH1TdD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2018 15:33:03 -0400
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: Question about nfs in infiniband environment
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <79933889-D7B8-4E8D-989F-297FD411644E@uvensys.de>
Date: Tue, 28 Aug 2018 11:40:32 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <989D72C4-553B-46CD-AE3F-4EB5BDEDB2BE@oracle.com>
References: <0D862469-B678-4827-B75D-69557734D34F@uvensys.de>
 <93486E63-F27E-4F45-9C43-ECEA66A46183@uvensys.de>
 <D480748B-967F-421C-8749-914CBD38C995@gmail.com>
 <79933889-D7B8-4E8D-989F-297FD411644E@uvensys.de>
To: Volker Lieder <v.lieder@uvensys.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Aug 28, 2018, at 11:31 AM, Volker Lieder <v.lieder@uvensys.de> =
wrote:
>=20
> Hi Chuck,
>=20
>> Am 28.08.2018 um 17:26 schrieb Chuck Lever <chucklever@gmail.com>:
>>=20
>> Hi Volker-
>>=20
>>=20
>>> On Aug 28, 2018, at 8:37 AM, Volker Lieder <v.lieder@uvensys.de> =
wrote:
>>>=20
>>> Hi,
>>>=20
>>> a short update from our site.
>>>=20
>>> We resized CPU and RAM on the nfs server and the performance is good =
right now and the error messages are gone.
>>>=20
>>> Is there a guide what hardware requirements a fast nfs server has?
>>>=20
>>> Or an information, how many nfs prozesses are needed for x nfs =
clients?
>>=20
>> The nfsd thread count depends on number of clients _and_ their =
workload.
>> There isn't a hard and fast rule.
>>=20
>> The default thread count is probably too low for your workload. You =
can
>> edit /etc/sysconfig/nfs and find "RPCNFSDCOUNT". Increase it to, say,
>> 64, and restart your NFS server.
>=20
> I tried this, but then the load on the "small" server was to high to =
serve further requests, so that was the idea to grow this up.

That rather suggests the disks are slow. A deeper performance
analysis might help.


>> With InfiniBand you also have the option of using NFS/RDMA. Mount =
with
>> "proto=3Drdma,port=3D20049" to try it.
>=20
> Yes, thats true, but in the mellanox driver set they disabled nfsordma =
in Version 3.4.

Not quite sure what you mean by "mellanox driver". Do you
mean MOFED? My impression of the stock CentOS 7.5 code is
that it is close to upstream, and you shouldn't need to
replace it except in some very special circumstances (high
end database, eg).


> It should work with centos driver, but we didnt tested it right now in =
newer setups.
>=20
> One more question, since other problems seem to be solved:
>=20
> What about this message?
>=20
> [Tue Aug 28 15:10:44 2018] NFSD: client 172.16.YY.XXX testing state ID =
with incorrect client ID

Looks like an NFS bug. Someone else on the list should be able
to comment.


>>> Best regards,
>>> Volker
>>>=20
>>>> Am 28.08.2018 um 09:45 schrieb Volker Lieder <v.lieder@uvensys.de>:
>>>>=20
>>>> Hi list,
>>>>=20
>>>> we have a setup with round about 15 centos 7.5 server.
>>>>=20
>>>> All are connected via infiniband 56Gbit and installed with new =
mellanox driver.
>>>> One server (4 Core, 8 threads, 16GB) is nfs server for a disk shelf =
with round about 500TB data.
>>>>=20
>>>> The server exports 4-6 mounts to each client.
>>>>=20
>>>> Since we added 3 further nodes to the setup, we recieve following =
messages:
>>>>=20
>>>> On nfs-server:
>>>> [Tue Aug 28 07:29:33 2018] rpc-srv/tcp: nfsd: sent only 224000 when =
sending 1048684 bytes - shutting down socket
>>>> [Tue Aug 28 07:30:13 2018] rpc-srv/tcp: nfsd: sent only 209004 when =
sending 1048684 bytes - shutting down socket
>>>> [Tue Aug 28 07:30:14 2018] rpc-srv/tcp: nfsd: sent only 204908 when =
sending 630392 bytes - shutting down socket
>>>> [Tue Aug 28 07:32:31 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 524396 bytes - shutting down socket
>>>> [Tue Aug 28 07:32:33 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 308 bytes - shutting down socket
>>>> [Tue Aug 28 07:32:35 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 172 bytes - shutting down socket
>>>> [Tue Aug 28 07:32:53 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 164 bytes - shutting down socket
>>>> [Tue Aug 28 07:38:52 2018] rpc-srv/tcp: nfsd: sent only 749452 when =
sending 1048684 bytes - shutting down socket
>>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 244 bytes - shutting down socket
>>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when =
sending 1048684 bytes - shutting down socket
>>>>=20
>>>> on nfs-clients:
>>>> [229903.273435] nfs: server 172.16.55.221 not responding, still =
trying
>>>> [229903.523455] nfs: server 172.16.55.221 OK
>>>> [229939.080276] nfs: server 172.16.55.221 OK
>>>> [236527.473064] perf: interrupt took too long (6226 > 6217), =
lowering kernel.perf_event_max_sample_rate to 32000
>>>> [248874.777322] RPC: Could not send backchannel reply error: -105
>>>> [249484.823793] RPC: Could not send backchannel reply error: -105
>>>> [250382.497448] RPC: Could not send backchannel reply error: -105
>>>> [250671.054112] RPC: Could not send backchannel reply error: -105
>>>> [251284.622707] RPC: Could not send backchannel reply error: -105
>>>>=20
>>>> Also file requests or "df -h" ended sometimes in a stale nfs status =
whcih will be good after a minute.
>>>>=20
>>>> I googled all messages and tried different things without success.
>>>> We are now going on to upgrade cpu power on nfs server.=20
>>>>=20
>>>> Do you also have any hints or points i can look for?
>>>>=20
>>>> Best regards,
>>>> Volker
>>>=20
>>=20
>> --
>> Chuck Lever
>> chucklever@gmail.com

--
Chuck Lever
