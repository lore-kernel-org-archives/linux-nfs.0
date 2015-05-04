Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:38442 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627AbbEDTRS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 15:17:18 -0400
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id t44JHI76025407
	(version=TLSv1 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 19:17:18 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userv0022.oracle.com (8.13.8/8.13.8) with ESMTP id t44JHIG4011628
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 19:17:18 GMT
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
	by userv0122.oracle.com (8.13.8/8.13.8) with ESMTP id t44JHHPv031339
	for <linux-nfs@vger.kernel.org>; Mon, 4 May 2015 19:17:18 GMT
From: Chuck Lever <chuck.lever@oracle.com>
Content-Type: text/plain; charset=windows-1252
Subject: RFC: combine xprtrdma and svcrdma
Message-Id: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
Date: Mon, 4 May 2015 15:17:25 -0400
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I’ve been experimenting with adding bi-directional RPC/RDMA support
on both the client and server side. The problem is that both modules
need to be loaded before the backchannel transports are registered
and can be used by the upper layers.

If I add a couple of request_module() call sites I get this:

> WARNING: Module /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/xprtrdma.ko ignored, due to loop
> WARNING: Loop detected: /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/svcrdma.ko needs xprtrdma.ko which needs svcrdma.ko again!
> WARNING: Module /lib/modules/4.1.0-rc2-00011-g1460752/kernel/net/sunrpc/xprtrdma/svcrdma.ko ignored, due to loop
> Installing kernel boot image ...
> Constructing initramdisk ...
> ERROR: modinfo: could not find module svcrdma


This isn’t a problem for TCP because both client and server side
TCP socket support are built into the sunrpc.ko module. The client and
server RDMA transport support are in separate modules.

A straightforward way to address this would be to combine xprtrdma.ko
with svcrdma.ko. Any thoughts on this approach?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



