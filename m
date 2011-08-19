Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:20305 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab1HSJqa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Aug 2011 05:46:30 -0400
Message-ID: <4E4E30E8.2080704@parallels.com>
Date: Fri, 19 Aug 2011 13:46:16 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Pavel Emelianov <xemul@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS client virtualization plan
References: <4E4A4DB1.2090105@parallels.com> <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com>
In-Reply-To: <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

18.08.2011 19:54, Chuck Lever пишет:
>
> On Aug 16, 2011, at 7:00 AM, Stanislav Kinsbursky wrote:
>
>> Hello.
>> I'm going to virtualize NFS in mainline and here is my plan for NFS client part.
>> Any suggestions or criticism are welcome.
>
> What are you going to do about statd?
>

Do you mean user-space statd?
If so, what are the problems with it do you see?

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
>> --
>> Best regards,
>> Stanislav Kinsbursky
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Best regards,
Stanislav Kinsbursky
