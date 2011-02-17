Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:35689 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752020Ab1BQMBn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Feb 2011 07:01:43 -0500
Message-ID: <4D5D0E22.3050701@monstr.eu>
Date: Thu, 17 Feb 2011 13:01:38 +0100
From: Michal Simek <monstr@monstr.eu>
Reply-To: monstr@monstr.eu
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
        linux-nfs@vger.kernel.org,
        "ltp-list@lists.sourceforge.net" <ltp-list@lists.sourceforge.net>
Subject: Re: NFS on little-endian platform - Microblaze
References: <4D5BCC74.9010301@monstr.eu>  <4D5BCE43.1090401@monstr.eu>	 <1297862575.6596.0.camel@heimdal.trondhjem.org>	 <4D5BD6E5.8010903@monstr.eu> <1297865074.6596.10.camel@heimdal.trondhjem.org>
In-Reply-To: <1297865074.6596.10.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Trond Myklebust wrote:
> On Wed, 2011-02-16 at 14:53 +0100, Michal Simek wrote: 
>> Trond Myklebust wrote:
>>> On Wed, 2011-02-16 at 14:16 +0100, Michal Simek wrote: 
>>>> Hi again,
>>>>
>>>> I forget to cc linux-nfs mailing list.
>>>>
>>>> Michal
>>>>
>>>> P.S.: Tested on kernels 2.6.38-rc4, 2.6.37 and 2.6.36
>>>>
>>>> Michal Simek wrote:
>>>>> Hi All,
>>>>>
>>>>> I am trying to understand one problem which we have found.
>>>>> The problem is that I can't on Microblaze little-endian platform
>>>>> mount nfs without -o nolock options. (Log below)
>>>>> Selecting tcp or udp has no effect.
>>>>> I am using emaclite driver and there is no problem on big endian 
>>>>> microblaze.
>>>>>
>>>>> ping, telnet, http, ftp, iperf, netperf work well.
>>>>>
>>>>> That's why I have a question if there is any endian specific option for 
>>>>> NFS?
>>>>>
>>>>> Thanks,
>>>>> Michal
>>>>>
>>>>> ~ # mount -t nfs 192.168.0.101:/tftpboot/nfs /mnt
>>>>> svc: failed to register lockdv1 RPC service (errno 13).
>>>>> lockd_up: makesock failed, error=-13
>>>>> svc: failed to register lockdv1 RPC service (errno 13).
>>>>> ~ # mount -t nfs -o nolock 192.168.0.101:/tftpboot/nfs /mnt
>>>>> ~ # mount
>>>>> rootfs on / type rootfs (rw)
>>>>> proc on /proc type proc (rw,relatime)
>>>>> none on /var type ramfs (rw,relatime)
>>>>> none on /sys type sysfs (rw,relatime)
>>>>> none on /etc/config type ramfs (rw,relatime)
>>>>> none on /dev/pts type devpts (rw,relatime,mode=600)
>>>>> 192.168.0.101:/tftpboot/nfs on /mnt type nfs 
>>>>> (rw,relatime,vers=3,rsize=32768,wsize=32768,namlen=255,hard,nolock,proto=udp,port=65535,timeo=7,retrans=3,sec=sys,local_lock=all,addr=192.168.0.101) 
>>>>>
>>>>> ~ #
>>>>> ~ # ps
>>>>> PID   USER     TIME   COMMAND
>>>>>     1 root       0:02 init
>>>>>     2 root       0:00 [kthreadd]
>>>>>     3 root       0:00 [ksoftirqd/0]
>>>>>     4 root       0:00 [kworker/0:0]
>>>>>     5 root       0:00 [kworker/u:0]
>>>>>     6 root       0:00 [khelper]
>>>>>     7 root       0:00 [sync_supers]
>>>>>     8 root       0:00 [bdi-default]
>>>>>     9 root       0:00 [kblockd]
>>>>>    10 root       0:00 [rpciod]
>>>>>    11 root       0:00 [kworker/0:1]
>>>>>    12 root       0:00 [kswapd0]
>>>>>    13 root       0:00 [fsnotify_mark]
>>>>>    14 root       0:00 [aio]
>>>>>    15 root       0:00 [nfsiod]
>>>>>    16 root       0:00 [kworker/u:1]
>>>>>    58 root       0:00 udhcpc -R -n -p /var/run/udhcpc.eth0.pid -i eth0
>>>>>    62 1          0:00 /bin/portmap
>>>>>    64 root       0:00 /bin/inetd /etc/inetd.conf
>>>>>    65 root       0:01 -sh
>>>>>    66 root       0:00 /bin/syslogd -n
>>>>>    67 root       0:00 /bin/flatfsd
>>>>>    68 root       0:00 [kworker/0:2]
>>>>>    91 root       0:00 ps
>>> Where is rpc.statd? Without it, the above behaviour is 100% expected.
>> I see on BE that lockd is used but it is enabled on little endian too but hasn't started.
>>
>> Enabled options:
>> CONFIG_NETWORK_FILESYSTEMS=y
>> CONFIG_NFS_FS=y
>> CONFIG_NFS_V3=y
>> CONFIG_LOCKD=y
>> CONFIG_LOCKD_V4=y
>> CONFIG_NFS_COMMON=y
>> CONFIG_SUNRPC=y
>>
>> On Be lockd is up.
>>     69 root       0:00 /bin/flatfsd
>>     71 root       0:00 [lockd]
>>     73 root       0:00 ps
>>
>> I have to look why.
>> How is it started?
> 
> Either rpc.bind or rpc.portmap and then rpc.statd need to be started
> manually (in that order) before you may mount the NFS partition without
> '-onolock'. The lockd daemon itself will be started by the kernel
> whenever there is a need for it.
> 
> Please check your 'init' boot scripts to find out why they are not being
> started as expected.
> 

It seems to me that the problem is with sunrpc in connection to endian.
I am looking for any package which can test sunrpc on embedded systems.
Can you recommend me any package?

I have found RPC tests in LTP but it is designed for desktops not embedded.

Thanks,
Michal

-- 
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/fdt/
Microblaze U-BOOT custodian
