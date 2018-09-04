Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.aixigo.de ([5.145.142.10]:17236 "EHLO mail.aixigo.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725992AbeIDLzP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 4 Sep 2018 07:55:15 -0400
Subject: Re: nfs4_reclaim_open_state: Lock reclaim failed!
To: Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org
References: <03f45066-5cc4-b99a-edc4-69dc34592101@aixigo.de>
 <b4c125d6-be59-6953-bfa7-8ada6f8daa01@aixigo.de>
 <30d4e07de5d976756857db77ddb17582897ae2bf.camel@kernel.org>
 <a5a072db-8624-3f52-867e-c7a612df811f@aixigo.de>
 <4aa0284e9f2d4b7994aa976926fd1a84493ee228.camel@kernel.org>
From: Harald Dunkel <harald.dunkel@aixigo.de>
Message-ID: <cf2e08fb-7130-d40f-fa93-bf805c87b770@aixigo.de>
Date: Tue, 4 Sep 2018 09:31:22 +0200
MIME-Version: 1.0
In-Reply-To: <4aa0284e9f2d4b7994aa976926fd1a84493ee228.camel@kernel.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Jeff,

On 9/3/18 11:32 AM, Jeff Layton wrote:
> 
> Yes, typically a server reboot will cause the client to reclaim its
> state. If the server isn't restarting then you probably have a situation
> where the client and server have gotten out of sync in some fashion, the
> client is realizing it and attempting to reclaim its state.
> 
> One thing that could (potentially) cause this is a nfs4_unique_id
> collision. You might want to survey your clients and ensure that there
> aren't any.
> 

/sys/module/nfs/parameters/nfs4_unique_id tells me that the default
is an empty string. Thats hard to believe. I had expected the default
is derived from the mac address of eth0 or something like this. ???

All explicitly defined nfs4_unique_id are unique, I checked (on the
Linux hosts). il06 (the NFS client here) and 4 other ancient servers
*were* running with the default "unique" id. My fault.

>> Would you recommend to stick with NFS 4(.0) or NFS 3, avoiding the
>> new code in NFS 4.{1,2}? Which NFS version in 4.9 or another LTS
>> kernel suits best for production use?
>>
> 
> v4.1+ are fine (in general) for production, but there are always bugs.
> 

How do NFS version numbers on client and Linux server affect each
other? AIX 7.1 (just as an example) supports just "nfs" and "nfs4",
not "nfs4.1" or "nfs4.2". Will the AIX clients benefit from the bug
fixes included in Linux' nfs 4.1+?


Regards
Harri
