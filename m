Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imail.uvensys.de ([37.208.110.138]:38354 "EHLO
        imail01.uvensys.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727026AbeH1TXc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2018 15:23:32 -0400
Received: from [192.168.2.103] (p57B6D170.dip0.t-ipconnect.de [87.182.209.112])
        by imail01.uvensys.de (Postfix) with ESMTPSA id 5D24EAC6A0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2018 17:31:18 +0200 (CEST)
From: Volker Lieder <v.lieder@uvensys.de>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: Question about nfs in infiniband environment
Date: Tue, 28 Aug 2018 17:31:17 +0200
References: <0D862469-B678-4827-B75D-69557734D34F@uvensys.de>
 <93486E63-F27E-4F45-9C43-ECEA66A46183@uvensys.de>
 <D480748B-967F-421C-8749-914CBD38C995@gmail.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
In-Reply-To: <D480748B-967F-421C-8749-914CBD38C995@gmail.com>
Message-Id: <79933889-D7B8-4E8D-989F-297FD411644E@uvensys.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Chuck,

> Am 28.08.2018 um 17:26 schrieb Chuck Lever <chucklever@gmail.com>:
> 
> Hi Volker-
> 
> 
>> On Aug 28, 2018, at 8:37 AM, Volker Lieder <v.lieder@uvensys.de> wrote:
>> 
>> Hi,
>> 
>> a short update from our site.
>> 
>> We resized CPU and RAM on the nfs server and the performance is good right now and the error messages are gone.
>> 
>> Is there a guide what hardware requirements a fast nfs server has?
>> 
>> Or an information, how many nfs prozesses are needed for x nfs clients?
> 
> The nfsd thread count depends on number of clients _and_ their workload.
> There isn't a hard and fast rule.
> 
> The default thread count is probably too low for your workload. You can
> edit /etc/sysconfig/nfs and find "RPCNFSDCOUNT". Increase it to, say,
> 64, and restart your NFS server.

I tried this, but then the load on the "small" server was to high to serve further requests, so that was the idea to grow this up.

> 
> With InfiniBand you also have the option of using NFS/RDMA. Mount with
> "proto=rdma,port=20049" to try it.

Yes, thats true, but in the mellanox driver set they disabled nfsordma in Version 3.4.
It should work with centos driver, but we didnt tested it right now in newer setups.

One more question, since other problems seem to be solved:

What about this message?

[Tue Aug 28 15:10:44 2018] NFSD: client 172.16.YY.XXX testing state ID with incorrect client ID


> 
> 
>> Best regards,
>> Volker
>> 
>>> Am 28.08.2018 um 09:45 schrieb Volker Lieder <v.lieder@uvensys.de>:
>>> 
>>> Hi list,
>>> 
>>> we have a setup with round about 15 centos 7.5 server.
>>> 
>>> All are connected via infiniband 56Gbit and installed with new mellanox driver.
>>> One server (4 Core, 8 threads, 16GB) is nfs server for a disk shelf with round about 500TB data.
>>> 
>>> The server exports 4-6 mounts to each client.
>>> 
>>> Since we added 3 further nodes to the setup, we recieve following messages:
>>> 
>>> On nfs-server:
>>> [Tue Aug 28 07:29:33 2018] rpc-srv/tcp: nfsd: sent only 224000 when sending 1048684 bytes - shutting down socket
>>> [Tue Aug 28 07:30:13 2018] rpc-srv/tcp: nfsd: sent only 209004 when sending 1048684 bytes - shutting down socket
>>> [Tue Aug 28 07:30:14 2018] rpc-srv/tcp: nfsd: sent only 204908 when sending 630392 bytes - shutting down socket
>>> [Tue Aug 28 07:32:31 2018] rpc-srv/tcp: nfsd: got error -11 when sending 524396 bytes - shutting down socket
>>> [Tue Aug 28 07:32:33 2018] rpc-srv/tcp: nfsd: got error -11 when sending 308 bytes - shutting down socket
>>> [Tue Aug 28 07:32:35 2018] rpc-srv/tcp: nfsd: got error -11 when sending 172 bytes - shutting down socket
>>> [Tue Aug 28 07:32:53 2018] rpc-srv/tcp: nfsd: got error -11 when sending 164 bytes - shutting down socket
>>> [Tue Aug 28 07:38:52 2018] rpc-srv/tcp: nfsd: sent only 749452 when sending 1048684 bytes - shutting down socket
>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 244 bytes - shutting down socket
>>> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 1048684 bytes - shutting down socket
>>> 
>>> on nfs-clients:
>>> [229903.273435] nfs: server 172.16.55.221 not responding, still trying
>>> [229903.523455] nfs: server 172.16.55.221 OK
>>> [229939.080276] nfs: server 172.16.55.221 OK
>>> [236527.473064] perf: interrupt took too long (6226 > 6217), lowering kernel.perf_event_max_sample_rate to 32000
>>> [248874.777322] RPC: Could not send backchannel reply error: -105
>>> [249484.823793] RPC: Could not send backchannel reply error: -105
>>> [250382.497448] RPC: Could not send backchannel reply error: -105
>>> [250671.054112] RPC: Could not send backchannel reply error: -105
>>> [251284.622707] RPC: Could not send backchannel reply error: -105
>>> 
>>> Also file requests or "df -h" ended sometimes in a stale nfs status whcih will be good after a minute.
>>> 
>>> I googled all messages and tried different things without success.
>>> We are now going on to upgrade cpu power on nfs server. 
>>> 
>>> Do you also have any hints or points i can look for?
>>> 
>>> Best regards,
>>> Volker
>> 
> 
> --
> Chuck Lever
> chucklever@gmail.com
