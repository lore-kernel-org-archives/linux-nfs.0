Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:35277 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752025Ab1HPMAQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Aug 2011 08:00:16 -0400
Message-ID: <4E4A5B8A.5060802@candelatech.com>
Date: Tue, 16 Aug 2011 04:59:06 -0700
From: Ben Greear <greearb@candelatech.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, trond@netapp.com,
        Pavel Emelianov <xemul@parallels.com>
Subject: Re: NFS client virtualization plan
References: <4E4A4DB1.2090105@parallels.com> <4E4A4FA9.7080600@parallels.com>
In-Reply-To: <4E4A4FA9.7080600@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 08/16/2011 04:08 AM, Stanislav Kinsbursky wrote:
> Added maintainer to mail recipients.
> Trond, please, have a look.
> Sorry for inconvenience.

I have a set of patches that let NFS clients bind to a specific IP
address, but I haven't gotten any feedback in the month since
I posted them.

But, likely you will want to touch similar paths to what I touched.

Here's my patch series:

https://lkml.org/lkml/2011/7/15/382


You need some patches to mount.nfs
for full functionality, in case you want to try it out:

https://github.com/greearb/nfs-utils-ct

Thanks,
Ben


>
> 16.08.2011 15:00, Stanislav Kinsbursky пишет:
>> Hello.
>> I'm going to virtualize NFS in mainline and here is my plan for NFS client part.
>> Any suggestions or criticism are welcome.
>>
>> ==============================================================================
>>
>> "NFS client" virtualization plan:
>>
>> _RPC layer_:
>>
>> 1) Make rpcbind clients (rpcb_local_clnt and rpcb_local4_clnt) to be
>> per net namespace.
>>
>> _NFS layer_:
>>
>> 1) Net namespace inheritance (current->nsproxy->net have to be used instead
>> of init_net).
>> Pointer to net namespace can be stored on nfs_client structure, which will
>> give easy access to proper net namespace during RPC transports creation.
>>
>> 2) Make Lockd kthread able to handle requests from different net namespaces.
>>
>> 3) Make NFS callbacks kthreads (nfs4_callback_svc and nfs4.1_callback_svc) able
>> to handle requests from different net namespaces.
>>
>> 4) Make NFS info lists (nfs_volume_list and nfs_client_list) to be per
>> net namespace in addition to global ones.
>>
>> 5) Make NFS proc variables and it's internal content variables to be per
>> net namespace in addition to global ones.
>>
>> 6) Make NFS sysctl variables and it's internal content variables to be per
>> net namespace in addition to global ones.
>>
>>
>>
>
>


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
