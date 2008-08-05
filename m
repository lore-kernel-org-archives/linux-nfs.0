From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs-utils and unfsd
Date: Tue, 5 Aug 2008 14:30:22 -0400
Message-ID: <BFA7510D-B3C2-48FB-8C17-80008A362B6D@oracle.com>
References: <959E2970-49E6-425C-A10D-2D486913CD3F@oracle.com> <48989831.2030808@RedHat.com>
Mime-Version: 1.0 (Apple Message framework v928.1)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Neil Brown <neilb@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:21031 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753345AbYHESbv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2008 14:31:51 -0400
In-Reply-To: <48989831.2030808-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Aug 5, 2008, at 2:13 PM, Steve Dickson wrote:
> Chuck Lever wrote:
>> There is a generic RPC server helper in nfs-utils called rpc_init().
>> This API will need to be modified to support IPv6 in statd and  
>> mountd,
>> at least.
>>
>> However, there is a comment inside support/nfs/rpcmisc.c, where
>> rpc_init() resides, that suggests that this interface is also used by
>> unfsd.
>>
>> Is it OK for me to modify nfs-utils' copy of this function, or is  
>> there
>> any kind of ABI restriction between unfsd and nfs-utils?
> I don't see any problem... Is there even a supported/maintained  
> version
> of unfsd out there today? I did a quick google search and didn't find
> anything but man pages...

I found this ancient web page:

http://rpm.pbone.net/index.php3/stat/4/idpl/6572509/com/unfs3-0.9.20-1.el3.pp.i386.rpm.html

which suggests there is no binary dependency between unfsd and nfs- 
utils.

I ask because we have had some unfsd questions on the list in the past  
year, so I assumed it was something that was still supported by some  
distributions.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
