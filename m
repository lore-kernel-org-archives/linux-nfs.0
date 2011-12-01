Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yx0-f174.google.com ([209.85.213.174]:47327 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356Ab1LAQ7z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2011 11:59:55 -0500
Received: by yenl6 with SMTP id l6so1875424yen.19
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2011 08:59:54 -0800 (PST)
Message-ID: <4ED7B287.4010802@gmail.com>
Date: Thu, 01 Dec 2011 10:59:51 -0600
From: Bruce Dubbs <bruce.dubbs@gmail.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: nfs server issues
References: <4ED6BCEA.9050000@gmail.com> <4ED77E8E.2040304@RedHat.com>
In-Reply-To: <4ED77E8E.2040304@RedHat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steve Dickson wrote:
> 
> On 11/30/2011 06:31 PM, Bruce Dubbs wrote:

>> I am trying to document the installation of nfs for Linux From
 >> Scratch. The client works, but the server does not and I'm looking
 >> for some help. If this is the wrong place to ask for help, please
 >> redirect me.

>> For now, I am only trying to get nfs version 3 to work.
>>
>> # mount -t nfs -o nfsvers=3 lfs6:/home/bdubbs /mnt/test
>>    [ mounts OK ]
>> # mount -t nfs -o nfsvers=3 localhost:/usr/src /mnt/tmp
>> # mount.nfs: requested NFS version or transport protocol is not supported

> The reason you getting the mounting error to localhost is because there are 
> no NFS services registered with rpcbind. Note the lack of nfs entires in
> your rpcinfo -p output. For the above mount to work you would need at least 
> the following entry:

>   100003    3   tcp   2049  nfs

> Figure out why that is not happening and you find the problem...

Yes, I thought that might be the problem.  The hard part is figuring out 
why.  I am running 'rpc.nfsd -p 2049 8' and I would think that would do 
it, but it's not registering with rpcbind.  The actual nfsd daemon is 
running in the kernel.

I looked at the nfsd.c source and nfsdfs is mounted in /proc correctly.
The threads seem to be started properly in nfssvc_threads() and there 
are no error messages either on the terminal or in syslog.

I'm just not familiar enough with the code to see where nfs is supposed 
to register with rpcbind.  That's where I'm trying to get help.  I 
suspect I've done something wrong with the build or configuration, but I 
don't see where.  Is the kernel nfsd process supposed to register when 
it starts?

One other thing.  When I try to mount the share from a remote (older) 
system, the error message is sightly different: "RPC Error: Program not 
registered", but I think that means the same thing as above.

   -- Bruce
