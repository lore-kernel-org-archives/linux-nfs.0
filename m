Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:65138 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751077Ab3ADF53 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Jan 2013 00:57:29 -0500
Message-ID: <50E670C8.6050400@cn.fujitsu.com>
Date: Fri, 04 Jan 2013 14:03:52 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: =?UTF-8?B?UGF3ZcWCIFNpa29yYQ==?= <pawel.sikora@agmk.net>
CC: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        baggins@pld-linux.org, Trond.Myklebust@netapp.com
Subject: Re: mount.nfs: cannot allocate memory.
References: <2891788.0SBnrhN2VX@pawels> <50E598B9.4000109@RedHat.com> <14289664.zy0he5HnEB@localhost>
In-Reply-To: <14289664.zy0he5HnEB@localhost>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paweł Sikora 写道:
> On Thursday 03 of January 2013 09:42:01 Steve Dickson wrote:
>> On 03/01/13 04:27, Paweł Sikora wrote:
>>> Hi,
>>>
>>> with the latest nfs-1.2.7/kernel-3.7.1 tools i've noticed an error during autofs mounting.
>>> reduced testcase shows that mount.nfs with 'vers=4' has a problem:
>>>
>>> [root@chufu ~]# mount.nfs -v -o vers=4 192.168.2.100:/home/atest/farm-local /mnt
>>> mount.nfs: timeout set for Thu Jan  3 10:22:00 2013
>>> mount.nfs: trying text-based options 'vers=4,addr=192.168.2.100,clientaddr=192.168.2.103'
>>> mount.nfs: mount(2): Cannot allocate memory
>>> mount.nfs: Cannot allocate memory
>>>
>>> while the vers=3 works fine:
>>>
>>> [root@chufu ~]# mount.nfs -v -o vers=3 192.168.2.100:/home/atest/farm-local /mnt
>>> mount.nfs: timeout set for Thu Jan  3 10:22:04 2013
>>> mount.nfs: trying text-based options 'vers=3,addr=192.168.2.100'
>>> mount.nfs: prog 100003, trying vers=3, prot=6
>>> mount.nfs: trying 192.168.2.100 prog 100003 vers 3 prot TCP port 2049
>>> mount.nfs: prog 100005, trying vers=3, prot=17
>>> mount.nfs: trying 192.168.2.100 prog 100005 vers 3 prot UDP port 42412
>>>
>>> no obvious errors in logs on nfs server/client side :(
>>> i can provide more info if you need to diagnose this issue.
>> Please set the kernel debugging with 'rpcdebug -m nfs -s mount' then post the out put found in /var/log/messages.
>>
> 
> rpcdebug can't find the /proc/sys/sunrpc/nfs_debug file in my system. how can i enable it?
> 
Hi, I found that the upstream kernel didn't create /proc/sys/sunrpc/nfs_debug default,
if you want to debug rpc,you should set CONFIG_SUNRPC_DEBUG = y.

#cat .config
.............................
CONFIG_SUNRPC_BACKCHANNEL=y
CONFIG_SUNRPC_XPRT_RDMA=m
CONFIG_RPCSEC_GSS_KRB5=m
CONFIG_SUNRPC_DEBUG=y <-----CONFIG_SUNRPC_DEBUG = y
CONFIG_CEPH_FS=m
CONFIG_CIFS=m

.......................

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 




