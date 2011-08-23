Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from hub024-nj-5.exch024.serverdata.net ([206.225.165.120]:41179
	"EHLO HUB024-nj-5.exch024.serverdata.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754646Ab1HWJWP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2011 05:22:15 -0400
Message-ID: <4E537105.8020106@gluster.com>
Date: Tue, 23 Aug 2011 14:51:09 +0530
From: Shehjar Tikoo <shehjart@gluster.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Steve Dickson <SteveD@redhat.com>, <linux-nfs@vger.kernel.org>
Subject: Re: Expected response from server not supporting v4
References: <4E4A23E2.3020103@gluster.com> <4E4A67AE.8040305@RedHat.com> <4E4B6134.7000903@gluster.com> <4B79A89A-6511-4447-976A-924670409438@oracle.com> <4E4E0171.6010104@gluster.com> <77A4C7C5-9578-433E-B37A-B61180834963@oracle.com>
In-Reply-To: <77A4C7C5-9578-433E-B37A-B61180834963@oracle.com>
Content-Type: text/plain; charset="us-ascii"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Chuck Lever wrote:
> On Aug 19, 2011, at 2:23 AM, Shehjar Tikoo wrote:
> 
>> Chuck Lever wrote:
>>> On Aug 17, 2011, at 2:35 AM, Shehjar Tikoo wrote:
>>>> Steve Dickson wrote:
>>>>> On 08/16/2011 04:01 AM, Shehjar Tikoo wrote:
>>>>>> Hi All
>>>>>>
>>>>>> The following thread discusses the behaviour when the client does not support v4:
>>>>>> http://thread.gmane.org/gmane.linux.nfs/36928/
>>>>>>
>>>>>> OTOH, when the server does not support v4, for eg. Gluster NFS server, where we support only v3, I believe v4 client will attempt to connect directly to port 2049 and receive connection failure errors on TCP. Does the current nfs client handle the situation where this results in a timeout for mount? We're hearing  a report of a timeout occurring on the RHEL6 client because the server does not have v4 support. Could someone please shed some light on how this behaviour is handled at present? Thanks
>>>>> Here is the current logic as to what will cause a fall back:
>>>>>   switch (errno) {
>>>>>   case EPROTONOSUPPORT:
>>>>>       /* A clear indication that the server or our
>>>>>        * client does not support NFS version 4. */
>>>>>       goto fall_back;
>>>>>   case ENOENT:
>>>>>       /* Legacy Linux servers don't export an NFS
>>>>>        * version 4 pseudoroot. */
>>>>>       goto fall_back;
>>>>>   case EPERM:
>>>>>       /* Linux servers prior to 2.6.25 may return
>>>>>        * EPERM when NFS version 4 is not supported. */
>>>>>       goto fall_back;
>>>>>   default:
>>>>>       return result;
>>>>>   }
>>>>> fall_back:
>>>>>   return nfs_try_mount_v3v2(mi);
>>>>> So in the case of the Gluster server, you are dropping into the
>>>>> default case which is causing the time out.
>>>>> In the above patch set, Mi patches the mount code to fall back on EINVAL which is the current return value from the kernel, when v4 is not configured. I'm not totally against doing something like this, but this is very touchy  code since it could have negative effects on other legacy servers.
>>>>> So I'm thinking Mi's kernel patch that cause the kernel
>>>>> to return EPROTONOSUPPORT, which is the correct return
>>>>> value, is probably the better way to go... 
>>>> Thanks Steve. My understanding is that Mi's patch is to handle the case where the client does not support v4. Do you think the same patch will also handle a server that does not support v4 and hence prevents a client from connecting to 2049?
>>> It's a best practice for clients to connect to 2049 immediately, rather than querying the server's portmapper, to discover and potentially connect to a server's NFSv4 service.
>>> A full-frame network trace of a mount attempt that times out would tell us if there is something pathological going on.
>> Thanks Chuck. Heres the wireshark screenshot of the network trace. As you can see, the SYN from client(10.1.12.45) to the server machine(192.168.1.117) receives a RST. At the client, it manifests as;
>>
>> [root@centos6-1 ~]# mount 192.168.1.117:/posix /mnt
>> mount.nfs: Connection timed out
>>
>> Thats it. The client is Linux centos6-1 2.6.32-71.el6.x86_64
>>
>> Does this point to a bug or is it expected? I was under the impression that the version 3 becomes the failback in case v4 is not available on the server.
> 
> I assume this connection attempt comes from the kernel's NFS client.  The RST should cause the mount(2) system call to return immediately with an error code, but it's very likely this edge case was never tested.

Thanks Chuck.

Thats correct. The Linux NFS kernel client and server is Gluster NFS server.
> 
> I suppose you could try a newer kernel (2.6.39 or 3.0) to see if it behaves any better.

Same behavior with 2.6.38. Should a bug be filed?

Thanks
-Shehjar

> 

