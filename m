From: Shehjar Tikoo <shehjart-+FkPdpiNhgJBDgjK7y7TUQ@public.gmane.org>
Subject: Re: Linux client mount fails with Gluster NFSv3 server
Date: Tue, 01 Sep 2009 18:43:02 +0530
Message-ID: <4A9D1DDE.1060000@gluster.com>
References: <4A9BD90B.4090804@gluster.com>	 <1251738771.5144.21.camel@heimdal.trondhjem.org>	 <4A9CC186.10504@gluster.com> <1251807998.18608.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from saturn.datasyncintra.net ([208.88.241.29]:53133 "EHLO
	saturn.datasyncintra.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754620AbZIANI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 09:08:59 -0400
In-Reply-To: <1251807998.18608.1.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-09-01 at 12:09 +0530, Shehjar Tikoo wrote:
>> Trond Myklebust wrote:
>>> On Mon, 2009-08-31 at 19:37 +0530, Shehjar Tikoo wrote:
>>>> Hi All
>>>>
>>>> I am writing a NFSv3 server as part of the Gluster clustered FS.
>>>> To start with, I've implemented the Mountv3 protocol and am just
>>>> starting out with NFSv3. In NFSv3, the first thing I've implemented
>>>> is the FSINFO and GETATTR calls to support mounting with NFS client.
>>>>
>>>> The problem I am facing is this. The Linux NFS client fails to mount
>>>> the remote export even though it is successfully receiving the file
>>>> handle from the MNT request and the result of the FSINFO call. This
>>>> is shown in the attached pcap file, which would be best viewed through
>>>> wireshark with "rpc" as the display filter.
>>>>
>>>> The command line output is shown below:
>>>>
>>>> root@indus:statcache# mount 127.0.0.1:/pos1 /mnt -o noacl,nolock
>>>> mount.nfs: mounting 127.0.0.1:/pos1 failed, reason given by server:
>>>>    No such file or directory
>>>>
>>>> This happens even though, we're told the following by showmount.
>>>> root@indus:statcache# showmount -e
>>>> Export list for indus:
>>>> /pos1 (everyone)
>>>> /pos2 (everyone)
>>>> /pos3 (everyone)
>>>> /pos4 (everyone)
>>>> root@indus:statcache#
>>>>
>>>> ..where /pos1, /pos2, etc are exports from the locally running Gluster
>>>> NFS server.
>>>>
>>>> As you'll notice in the trace, there is no NFSv3 request after
>>>> the FSINFO, so I've a feeling it could be that some field in the
>>>> FSINFO reply is not what the Linux NFS client is expecting. Could that
>>>> be the reason for the mount failure?
>>>>
>>>> What else should I be looking into to investigate this further?
>>>>
>>>> The client is a 2.6.18-5 kernel supplied with Debian on an AMD64 box.
>>>> nfs-utils is version 1.1.4.
>>>>
>>>> Many thanks,
>>>> -Shehjar
>>> Wireshark fails to decode your server's reply too. I'd start looking
>>> there...
>>>
>> Bruce, Trond,
>>
>> I am able to view the packets just fine using wireshark Version 1.0.6.
>> It is possible that the default options for you for TCP and RPC are
>> not same as the ones below.
>> Could you please try viewing the dump with the following options set 
>> in the wireshark Protocol preferences pane.
>>
>> Press <Ctrl> + <Shift> + p to bring up the protocol preferences
>> window.
>>
>> First, expand the "Protocol" section header in the window that pops
>> up. Then look for "TCP" section. In the TCP section, please check the 
>> following option:
>>
>> "Allow subdissector to reassemble TCP streams"
>>
>> Then, search for the "RPC" section under "Protocols". For RPC, please
>> check the following option:
>>
>> "Reassemble RPC over TCP message spanning multiple TCP segments"
>>
>> This should make the RPC records visible properly.
> 
> I always run with those options enabled, and they were able to
> reconstruct most of the RPC records correctly, but not the reply to the
> FSINFO call.
> Furthermore, when I looked at the binary contents, it seemed to me that
> the post-op attributes contained some fishy information, such as
> nlink==0. That alone would cause the NFS client to give up.
> 

Got it! That was the problem. I missed setting the nlink field
in FSINFO. Mount works fine now.

Thanks a ton.
-Shehjar

> Trond
> 

