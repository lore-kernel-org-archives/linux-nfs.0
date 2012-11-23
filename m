Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:23859 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1750841Ab2KWFRI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 23 Nov 2012 00:17:08 -0500
Message-ID: <50AF0850.6060901@cn.fujitsu.com>
Date: Fri, 23 Nov 2012 13:23:28 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: "bfields@fieldses.org" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        =?UTF-8?B?6IyD5pyd5oy6?= <fanchaoting@cn.fujitsu.com>
Subject: Re: nfs cache bug (when server delete the file ,nfs client can read
 file also)
References: <50AEF92B.4080900@cn.fujitsu.com> <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F07@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA9092F7F07@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Myklebust, Trond 写道:
> On Fri, 2012-11-23 at 12:18 +0800, fanchaoting wrote:
>> Hi,everyone. I found a big bug abount nfs cache.
>>
>> when server delete the file ,nfs client can read file also.
>>
>> the following is the reproduce.
>>
>> ip: 192.168.0.19  nfs-client
>> ip: 192.168.0.20  nfs-client
>> ip: 192.168.0.21  nfs-server
>>
>> ############################################################################
>>
>> /usr/bin/ssh -n 192.168.0.21 service nfs start
>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/rpc.idmapd
>> /usr/bin/ssh -n 192.168.0.19 /usr/sbin/rpc.idmapd
>> /usr/bin/ssh -n 192.168.0.20 /usr/sbin/rpc.idmapd
>> /usr/bin/ssh -n 192.168.0.21 "rm -rf /nfsroot; mkdir -p /nfsroot"
>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -au
>> /usr/bin/ssh -n 192.168.0.21 /usr/sbin/exportfs -i -o insecure,no_root_squash,rw,fsid=0 *:/nfsroot
>> /usr/bin/ssh -n 192.168.0.19 test -d /nfsroot || (rm -rf /nfsroot; mkdir -p /nfsroot)
>> /usr/bin/ssh -n 192.168.0.20 test -d /nfsroot || (rm -rf /nfsroot; mkdir -p /nfsroot)
>>
>> /usr/bin/ssh -n 192.168.0.19 umount /nfsroot
>> /usr/bin/ssh -n 192.168.0.20 umount /nfsroot
>> cmd="echo \"hello world\" > /nfsroot/tmpfile"
>> /usr/bin/ssh -n 192.168.0.21 $cmd
>> /usr/bin/ssh -n 192.168.0.21 mkdir /nfsroot/tmpdir
>> /usr/bin/ssh -n 192.168.0.21 touch /nfsroot/tmpdir/tmpdfile
>> /usr/bin/ssh -n 192.168.0.19 mount -t nfs4 192.168.0.21:/ /nfsroot
>> /usr/bin/ssh -n 192.168.0.20 mount -t nfs4 192.168.0.21:/ /nfsroot
>> /usr/bin/ssh -n 192.168.0.21 cat  /nfsroot/tmpfile
>> /usr/bin/ssh -n 192.168.0.21 ls -l /nfsroot/tmpdir
>> /usr/bin/ssh -n 192.168.0.19 cat  /nfsroot/tmpfile
>> /usr/bin/ssh -n 192.168.0.19 ls -l  /nfsroot/tmpdir
>> /usr/bin/ssh -n 192.168.0.20 cat  /nfsroot/tmpfile
>> /usr/bin/ssh -n 192.168.0.20 ls -l  /nfsroot/tmpdir
>> /usr/bin/ssh -n 192.168.0.19 cat /nfsroot/tmpfile > /dev/null
>> /usr/bin/ssh -n 192.168.0.20 cat /nfsroot/tmpfile > /dev/null
>> /usr/bin/ssh -n 192.168.0.21 rm -rf /nfsroot/tmpfile
>> echo -e "sleep 60~~~~~~~~\n"
>> sleep 60
>>
>> #############################################################################
>>
>> last: In 192.168.0.19 I do:
>>
>> #cat /nfsroot/tmpfile           <--the nfs server delete the file,but nfs client can read the file
>>  hello world
>>
>>
>> I think  when the nfs server delete the file ,
>> the  server should notice the nfs client,
>> but the upstream kernel does't this.
> 
> So is this a problem with the client or the server? In other words, if
> you use a different server/client combination, do you see a different
> result?
> 

I think that the server has the problem .when the server deletes the file ,
it should notice the client immediately.

> Which kernels are you using in your tests for the client and server?
> 

I found the problem in kernel  3.7.0-rc6


