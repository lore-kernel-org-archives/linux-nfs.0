Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-3.desy.de ([131.169.56.156]:39908 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932378AbcFBT3M convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Jun 2016 15:29:12 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 196FC2809C8
	for <linux-nfs@vger.kernel.org>; Thu,  2 Jun 2016 21:29:10 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id F22E41417
	for <linux-nfs@vger.kernel.org>; Thu,  2 Jun 2016 21:29:09 +0200 (MEST)
Date: Thu, 2 Jun 2016 21:29:09 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>, yves kemp <yves.kemp@desy.de>,
        Chuck Lever <chuck.lever@oracle.com>
Message-ID: <1891481671.15806841.1464895749568.JavaMail.zimbra@desy.de>
In-Reply-To: <FED0B49D-4E2B-4787-B359-8FCC7B4245AB@primarydata.com>
References: <919864487.12463321.1462895841271.JavaMail.zimbra@desy.de> <FED0B49D-4E2B-4787-B359-8FCC7B4245AB@primarydata.com>
Subject: Re: pnfs client running out TCP port numbers
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Hi Trond,

today, during linux-nfs phone-conf Chuck has suggested to use **noresvport**
mount option. It works for client <=> MDS connection, but was ignored for
client <=> DS connection:

[root@dcache-lab-wn002 ~]# netstat -tnC
Active Internet connections (w/o servers)
Proto Recv-Q Send-Q Local Address               Foreign Address             State      
tcp        0      0 131.169.161.126:860         131.169.191.142:32049       ESTABLISHED 
tcp        0      0 131.169.161.126:49451       131.169.191.144:2049        ESTABLISHED 
tcp        0    200 131.169.161.126:887         131.169.191.141:32049       ESTABLISHED 
[root@dcache-lab-wn002 ~]# 

Looks like it's a trivial change to fix that. I will send a patch after testing.

Tigran.

----- Original Message -----
> From: "Trond Myklebust" <trondmy@primarydata.com>
> To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>, "linux-nfs list" <linux-nfs@vger.kernel.org>
> Cc: "yves kemp" <yves.kemp@desy.de>
> Sent: Tuesday, May 10, 2016 6:21:14 PM
> Subject: Re: pnfs client running out TCP port numbers

> On 5/10/16, 11:57, "linux-nfs-owner@vger.kernel.org on behalf of Mkrtchyan,
> Tigran" <linux-nfs-owner@vger.kernel.org on behalf of tigran.mkrtchyan@desy.de>
> wrote:
> 
>>
>>Dear NFS gurus,
>>
>>we observe very interesting problem with pNFS client.
>>We have ~600 DSes in our installation + MDS + some
>>regular NFSv3 and v4 mounts. After some time we get on
>>the client nodes that they can't create new mounts:
>>
>>May 10 16:00:25 bXXX0 automount[5351]: attempting to mount entry /nfs/aaa/bbb
>>May 10 16:00:26 bXXX0 automount[5351]: >> mount.nfs: mount system call failed
>>May 10 16:00:26 bXXX0 automount[5351]: >> mount.nfs: mount system call failed
>>
>>Turned out that problem is in RPC layer. There are no free source ports anymore:
>>
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 call_connect xprt ffff880209f0b000 is
>>not connected
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 xprt_connect xprt ffff880209f0b000 is
>>not connected
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 sleep_on(queue "xprt_pending" time
>>14685414165)
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 added to queue ffff880209f0b258
>>"xprt_pending"
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 setting alarm for 60000 ms
>>May 10 17:05:04 bXXX0 kernel: RPC:       xs_connect scheduled xprt
>>ffff880209f0b000
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 sync task going to sleep
>>May 10 17:05:04 bXXX0 kernel: RPC:       xs_bind 0.0.0.0:1023: failed (-98)
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 __rpc_wake_up_task (now 14685414165)
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 disabling timer
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 removed from queue ffff880209f0b258
>>"xprt_pending"
>>May 10 17:05:04 bXXX0 kernel: RPC:       __rpc_wake_up_task done
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 sync task resuming
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 xprt_connect_status: error 98
>>connecting to server 1xx.xx4.xx8.xx3
>>May 10 17:05:04 bXXX0 kernel: RPC:       wake_up_first(ffff880209f0b190
>>"xprt_sending")
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 call_connect_status (status -5)
>>May 10 17:05:04 bXXX0 kernel: RPC: 35575 return 0, status -5
>>
>>
>>This is limited by min_resvport and max_resvport, which are, by default, 665 and
>>1023, accordingly.
>>This gives us only 358 connections. If a client accesses many DSes, then we have
>>a problem.
>>
>>Questions:
>>
>>  - Why pNFS client must use privileged port number, when talks to DS?
> 
> That's a default requirement on most NFSv3 servers, particularly when using
> AUTH_SYS.
> 
>>
>>  - Why pNFS client uses port number only for one connection as for ip connection
>>    it a src_addr+src_port - dst_addr+dst_port must be unique and source port number
>>    can be reused for other connections as well.
> 
> As you say above, in order to reuse the port, the connection end points need to
> be unique. That can sometimes be tricky if the server is acting both as an MDS
> and a DS.
> 
>>
>>  - Should we just bump max_resvport to solve it (which in did have helped)?
> 
> You could. We could also look into handling the AUTH_TOOWEAK RPC level error by
> turning on privileged ports. That might allow us to default to not using
> privileged ports.
> 
> 
> 
> N�����r��y���b�X��ǧv�^�)޺{.n�+����{���"��^n�r���z���h����&���G���h�(�階�ݢj"���m�����z�ޖ���f���h���~�m�
