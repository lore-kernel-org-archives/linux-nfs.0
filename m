Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-o-1.desy.de ([131.169.56.154]:54143 "EHLO smtp-o-1.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069AbcEJP53 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2016 11:57:29 -0400
Received: from smtp-map-1.desy.de (smtp-map-1.desy.de [131.169.56.66])
	by smtp-o-1.desy.de (DESY-O-1) with ESMTP id 9B2122800BC
	for <linux-nfs@vger.kernel.org>; Tue, 10 May 2016 17:57:21 +0200 (CEST)
Received: from ZITSWEEP1.win.desy.de (zitsweep1.win.desy.de [131.169.97.95])
	by smtp-map-1.desy.de (DESY_MAP_1) with ESMTP id 8F4A413EA1
	for <linux-nfs@vger.kernel.org>; Tue, 10 May 2016 17:57:21 +0200 (MEST)
Received: from smtp-intra-3.desy.de (lb-40-26.desy.de) by ZITSWEEP1.win.desy.de
 (Clearswift SMTPRS 5.5.0) with ESMTP id <Tc1a839b20583a9615f6168@ZITSWEEP1.win.desy.de> for <linux-nfs@vger.kernel.org>;
 Tue, 10 May 2016 17:57:21 +0200
Date: Tue, 10 May 2016 17:57:21 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: linux-nfs list <linux-nfs@vger.kernel.org>
Cc: yves kemp <yves.kemp@desy.de>
Message-ID: <919864487.12463321.1462895841271.JavaMail.zimbra@desy.de>
Subject: pnfs client running out TCP port numbers
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Dear NFS gurus,

we observe very interesting problem with pNFS client.
We have ~600 DSes in our installation + MDS + some
regular NFSv3 and v4 mounts. After some time we get on
the client nodes that they can't create new mounts:

May 10 16:00:25 bXXX0 automount[5351]: attempting to mount entry /nfs/aaa/bbb
May 10 16:00:26 bXXX0 automount[5351]: >> mount.nfs: mount system call failed
May 10 16:00:26 bXXX0 automount[5351]: >> mount.nfs: mount system call failed

Turned out that problem is in RPC layer. There are no free source ports anymore:

May 10 17:05:04 bXXX0 kernel: RPC: 35575 call_connect xprt ffff880209f0b000 is not connected
May 10 17:05:04 bXXX0 kernel: RPC: 35575 xprt_connect xprt ffff880209f0b000 is not connected
May 10 17:05:04 bXXX0 kernel: RPC: 35575 sleep_on(queue "xprt_pending" time 14685414165)
May 10 17:05:04 bXXX0 kernel: RPC: 35575 added to queue ffff880209f0b258 "xprt_pending"
May 10 17:05:04 bXXX0 kernel: RPC: 35575 setting alarm for 60000 ms
May 10 17:05:04 bXXX0 kernel: RPC:       xs_connect scheduled xprt ffff880209f0b000
May 10 17:05:04 bXXX0 kernel: RPC: 35575 sync task going to sleep
May 10 17:05:04 bXXX0 kernel: RPC:       xs_bind 0.0.0.0:1023: failed (-98)
May 10 17:05:04 bXXX0 kernel: RPC: 35575 __rpc_wake_up_task (now 14685414165)
May 10 17:05:04 bXXX0 kernel: RPC: 35575 disabling timer
May 10 17:05:04 bXXX0 kernel: RPC: 35575 removed from queue ffff880209f0b258 "xprt_pending"
May 10 17:05:04 bXXX0 kernel: RPC:       __rpc_wake_up_task done
May 10 17:05:04 bXXX0 kernel: RPC: 35575 sync task resuming
May 10 17:05:04 bXXX0 kernel: RPC: 35575 xprt_connect_status: error 98 connecting to server 1xx.xx4.xx8.xx3
May 10 17:05:04 bXXX0 kernel: RPC:       wake_up_first(ffff880209f0b190 "xprt_sending")
May 10 17:05:04 bXXX0 kernel: RPC: 35575 call_connect_status (status -5)
May 10 17:05:04 bXXX0 kernel: RPC: 35575 return 0, status -5


This is limited by min_resvport and max_resvport, which are, by default, 665 and 1023, accordingly.
This gives us only 358 connections. If a client accesses many DSes, then we have a problem.

Questions:

  - Why pNFS client must use privileged port number, when talks to DS?

  - Why pNFS client uses port number only for one connection as for ip connection
    it a src_addr+src_port - dst_addr+dst_port must be unique and source port number
    can be reused for other connections as well.

  - Should we just bump max_resvport to solve it (which in did have helped)?


Thanks in advance,
   Tigran.
