From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: FW: Unable to mount nfs directories RHEL 4.8
Date: Wed, 09 Jun 2010 18:33:14 -0400
Message-ID: <4C1016AA.2030702@oracle.com>
References: <620E93B2E5CC3B46BD811165E3335B8708C2A04E@0461-its-exmb02.us.saic.com> <4C0FBED0.9030809@oracle.com> <620E93B2E5CC3B46BD811165E3335B8708CB9D3B@0461-its-exmb02.us.saic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: linux-nfs@vger.kernel.org
To: "Murata, Dennis" <DENNIS.MURATA-jTGLxe6cr0Q@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38731 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753905Ab0FIWel (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 18:34:41 -0400
In-Reply-To: <620E93B2E5CC3B46BD811165E3335B8708CB9D3B-9/h0XwadXgnyjpQT3Si/rsM9+qvyE0V4QQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/ 9/10 02:47 PM, Murata, Dennis wrote:
>
>
>> -----Original Message-----
>> From: Chuck Lever [mailto:chuck.lever@oracle.com]
>> Sent: Wednesday, June 09, 2010 11:18 AM
>> To: Murata, Dennis
>> Cc: linux-nfs@vger.kernel.org
>> Subject: Re: FW: Unable to mount nfs directories RHEL 4.8
>>
>> On 06/ 8/10 08:05 PM, Murata, Dennis wrote:
>>> Didn't see the original message, sorry if this is a duplicate
>>>
>>> -----Original Message-----
>>> From: Murata, Dennis
>>> Sent: Tuesday, June 08, 2010 3:26 PM
>>> To: linux-nfs-owner@vger.kernel.org
>>> Subject: Unable to mount nfs directories RHEL 4.8
>>>
>>> We are using a modified RHEL 4.8 build accessing Netapp filers for
>>> data directories.  The build has nfs-utils-1.0.6-93.EL4,
>>> nfs-utils-lib-1.0.6-10.el4, kernel-largesmp-2.6.9-89.EL all x86_64.
>>> After a period of use, on a very questionable network using
>> tcp as the
>>> nfs transport, workstation will start getting error messages in
>>> /var/log/messages|dmesg and are not able to mount/access the data
>>> directories.  A reboot is necessary to allow the mounts.  The time
>>> period varies and seems to depend on the usage, but in general will
>>> start within a week of moderate use.  The error messages are:
>>>
>>> lockd: cannot monitor 192.168.10.133
>>> lockd: failed to monitor 192.168.10.133
>>> nsm_mon_unmon: rpc failed, status=-96
>>> lockd: cannot monitor 192.168.10.133
>>> lockd: failed to monitor 192.168.10.133
>>> nsm_mon_unmon: rpc failed, status=-96
>>> lockd: cannot monitor 192.168.10.133
>>> lockd: failed to monitor 192.168.10.133

These are all from the kernel, specifically lockd.  They are reported 
when lockd can't perform the upcall (via loopback) to rpc.statd to 
monitor 192.168.10.133.

status -96 means the server (both portmap and rpc.statd are on the local 
host in this case) doesn't support the requested program version (either 
rpcbind v2 or statd v1).

You might get more information by enabling RPC debugging messages on 
clients in this state.

# sudo rpcdebug -m rpc -s all

This will cause a lot of traffic in the syslog, so only do it once the 
host is wedged, but still trying to do work.  We want to capture 
debugging output during at least one iteration of the messages above.

There are Red Hat NFS engineers on this list who can help you if you can 
reproduce this with stock RHEL 4.8.

>>> These errors are repeated as access to the filer (ip
>> address has been
>>> changed) is tried.  A ps on the workstation shows rpc.statd still
>>> running, service nfslock status reports rpc.statd running.
>>
>> Is portmap running, and is the statd service registered?  Is
>> lockd registered for both UDP and TCP?
> Portmap is running.  Not sure how to check if lockd is registered but
> the output from rpcinfo -p
> [root@host1 ~]# rpcinfo -p
>     program vers proto   port
>      100000    2   tcp    111  portmapper
>      100000    2   udp    111  portmapper
>      100007    2   udp    880  ypbind
>      100007    1   udp    880  ypbind
>      100007    2   tcp    883  ypbind
>      100007    1   tcp    883  ypbind
>      100011    1   udp    948  rquotad
>      100011    2   udp    948  rquotad
>      100011    1   tcp    963  rquotad
>      100011    2   tcp    963  rquotad
>      100003    2   udp   2049  nfs
>      100003    3   udp   2049  nfs
>      100003    4   udp   2049  nfs
>      100003    2   tcp   2049  nfs
>      100003    3   tcp   2049  nfs
>      100003    4   tcp   2049  nfs
>      100021    1   udp  34574  nlockmgr
>      100021    3   udp  34574  nlockmgr
>      100021    4   udp  34574  nlockmgr
>      100021    1   tcp  32786  nlockmgr
>      100021    3   tcp  32786  nlockmgr
>      100021    4   tcp  32786  nlockmgr
>      100005    1   udp    962  mountd
>      100005    1   tcp    974  mountd
>      100005    2   udp    962  mountd
>      100005    2   tcp    974  mountd
>      100005    3   udp    962  mountd
>      100005    3   tcp    974  mountd
>      100024    1   udp    744  status
>      100024    1   tcp    750  status
> [root@host1 ~]#

