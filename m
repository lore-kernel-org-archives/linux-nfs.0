Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from imail.uvensys.de ([37.208.110.138]:37850 "EHLO
        imail01.uvensys.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726120AbeH1Q2m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Aug 2018 12:28:42 -0400
Received: from [192.168.2.103] (p57B6D170.dip0.t-ipconnect.de [87.182.209.112])
        by imail01.uvensys.de (Postfix) with ESMTPSA id E7269AC6A0
        for <linux-nfs@vger.kernel.org>; Tue, 28 Aug 2018 14:37:10 +0200 (CEST)
From: Volker Lieder <v.lieder@uvensys.de>
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: Question about nfs in infiniband environment
Date: Tue, 28 Aug 2018 14:37:09 +0200
References: <0D862469-B678-4827-B75D-69557734D34F@uvensys.de>
To: linux-nfs@vger.kernel.org
In-Reply-To: <0D862469-B678-4827-B75D-69557734D34F@uvensys.de>
Message-Id: <93486E63-F27E-4F45-9C43-ECEA66A46183@uvensys.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

a short update from our site.

We resized CPU and RAM on the nfs server and the performance is good right now and the error messages are gone.

Is there a guide what hardware requirements a fast nfs server has?

Or an information, how many nfs prozesses are needed for x nfs clients?

Best regards,
Volker

> Am 28.08.2018 um 09:45 schrieb Volker Lieder <v.lieder@uvensys.de>:
> 
> Hi list,
> 
> we have a setup with round about 15 centos 7.5 server.
> 
> All are connected via infiniband 56Gbit and installed with new mellanox driver.
> One server (4 Core, 8 threads, 16GB) is nfs server for a disk shelf with round about 500TB data.
> 
> The server exports 4-6 mounts to each client.
> 
> Since we added 3 further nodes to the setup, we recieve following messages:
> 
> On nfs-server:
> [Tue Aug 28 07:29:33 2018] rpc-srv/tcp: nfsd: sent only 224000 when sending 1048684 bytes - shutting down socket
> [Tue Aug 28 07:30:13 2018] rpc-srv/tcp: nfsd: sent only 209004 when sending 1048684 bytes - shutting down socket
> [Tue Aug 28 07:30:14 2018] rpc-srv/tcp: nfsd: sent only 204908 when sending 630392 bytes - shutting down socket
> [Tue Aug 28 07:32:31 2018] rpc-srv/tcp: nfsd: got error -11 when sending 524396 bytes - shutting down socket
> [Tue Aug 28 07:32:33 2018] rpc-srv/tcp: nfsd: got error -11 when sending 308 bytes - shutting down socket
> [Tue Aug 28 07:32:35 2018] rpc-srv/tcp: nfsd: got error -11 when sending 172 bytes - shutting down socket
> [Tue Aug 28 07:32:53 2018] rpc-srv/tcp: nfsd: got error -11 when sending 164 bytes - shutting down socket
> [Tue Aug 28 07:38:52 2018] rpc-srv/tcp: nfsd: sent only 749452 when sending 1048684 bytes - shutting down socket
> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 244 bytes - shutting down socket
> [Tue Aug 28 07:39:29 2018] rpc-srv/tcp: nfsd: got error -11 when sending 1048684 bytes - shutting down socket
> 
> on nfs-clients:
> [229903.273435] nfs: server 172.16.55.221 not responding, still trying
> [229903.523455] nfs: server 172.16.55.221 OK
> [229939.080276] nfs: server 172.16.55.221 OK
> [236527.473064] perf: interrupt took too long (6226 > 6217), lowering kernel.perf_event_max_sample_rate to 32000
> [248874.777322] RPC: Could not send backchannel reply error: -105
> [249484.823793] RPC: Could not send backchannel reply error: -105
> [250382.497448] RPC: Could not send backchannel reply error: -105
> [250671.054112] RPC: Could not send backchannel reply error: -105
> [251284.622707] RPC: Could not send backchannel reply error: -105
> 
> Also file requests or "df -h" ended sometimes in a stale nfs status whcih will be good after a minute.
> 
> I googled all messages and tried different things without success.
> We are now going on to upgrade cpu power on nfs server. 
> 
> Do you also have any hints or points i can look for?
> 
> Best regards,
> Volker
