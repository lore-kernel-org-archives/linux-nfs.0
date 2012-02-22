Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:63373 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754613Ab2BVKRr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 Feb 2012 05:17:47 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 41E6917013C
	for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 18:17:46 +0800 (CST)
Received: from mailserver.fnst.cn.fujitsu.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id q1MAHjAI001726
	for <linux-nfs@vger.kernel.org>; Wed, 22 Feb 2012 18:17:45 +0800
Message-ID: <4F44C071.8010104@cn.fujitsu.com>
Date: Wed, 22 Feb 2012 18:16:17 +0800
From: Fu Liankun <fuliankun@cn.fujitsu.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: spnfs write performance issue
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When copy a big file(about 500MB) to nfs server using pnfs, it cost
obvious longer time as compared with NFSv3 or NFSv4 protocol.

PNFS cost about 300-550s
NFSv3 cost about 49s
NFSv4 cost about 49s

My test environment as following:

MDS: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.100, ipaddr2:192.168.1.100
DS1: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.101, ipaddr2:192.168.1.101
DS2: 3.1.0-rc8-pnfs   ipaddr1: 192.168.0.102, ipaddr2:192.168.1.102
client: RHEL6.2GA(2.6.32-220.el6.i686)    ipaddr1: 192.168.0.19,
ipaddr2:192.168.1.19

192.168.1.100 <-------- NFS4.1 connection --------->192.168.1.101
192.168.0.100 <-------- NFS4.1 connection --------->192.168.0.102
192.168.0.19  <-------- NFS4.1 connection --------->192.168.0.100

Dunring the write process, the client output the message:
FS-Cache: Loaded
FS-Cache: Netfs 'nfs' registered for caching
nfs4filelayout_init: NFSv4 File Layout Driver Registering...
nfs: server 192.168.1.101 not responding, timed out

The message "nfs: server 192.168.1.101 not responding, timed out" was
output during the COMMIT request.

Who can tell me the reason why pnfs cost so long time.



