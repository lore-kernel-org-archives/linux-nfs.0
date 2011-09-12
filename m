Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:5624 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755276Ab1ILPEL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Sep 2011 11:04:11 -0400
Message-ID: <4E6E1F5E.1010508@parallels.com>
Date: Mon, 12 Sep 2011 19:03:58 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: Chuck Lever <chuck.lever@oracle.com>
CC: Pavel Emelianov <xemul@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFS client virtualization plan v2
References: <4E6E104F.8080903@parallels.com> <1055810C-4BE8-4950-8F39-A844834CF666@oracle.com>
In-Reply-To: <1055810C-4BE8-4950-8F39-A844834CF666@oracle.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

12.09.2011 18:50, Chuck Lever пишет:
>
> On Sep 12, 2011, at 9:59 AM, Stanislav Kinsbursky wrote:
>
>> Hello.
>> This is an update for this plan. Added rpc_pipefs and NFS cache virtualization.
>
> You may need a per-net namespace NSM monitor list as well.  That means running a per-namespace statd, each with its own local sm and sm.bak directories, and keeping the in-kernel monitor information sorted by namespace.
>
> The caller_name argument of NLM_LOCK needs to be the namespace's local utsname, and this string should be used as the my_name argument when sending an SM_MON upcall.  I've got a patch or two that make this simpler.
>

Great. Thanks for advise, Chuck.
Right now this part of the code is not clear enough for me and I'm mainly 
concentrated on rpcbind and pipefs.
Hope for your assistance later when I'll get to the point (if any problems occur).

>> ==============================================================================
>>
>> "NFS client" virtualization plan:
>>
>> _RPC layer_:
>>
>> 1) Make rpcbind clients (rpcb_local_clnt and rpcb_local4_clnt) to be
>> per net namespace.
>>
>> 2) Make RPC pipefs to be per net namespace.
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
>> 7) Make NFS cache per net namespace.
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
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
>
>
>


-- 
Best regards,
Stanislav Kinsbursky
