From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Subject: Re: NFS client virtualization plan
Date: Tue, 16 Aug 2011 16:19:40 +0400
Message-ID: <4E4A605C.6050008@parallels.com>
References: <4E4A4DB1.2090105@parallels.com> <4E4A4FA9.7080600@parallels.com> <4E4A5B8A.5060802@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"trond@netapp.com" <trond@netapp.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42148 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751625Ab1HPMTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 08:19:23 -0400
In-Reply-To: <4E4A5B8A.5060802@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks. Will have a look.

16.08.2011 15:59, Ben Greear =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On 08/16/2011 04:08 AM, Stanislav Kinsbursky wrote:
>> Added maintainer to mail recipients.
>> Trond, please, have a look.
>> Sorry for inconvenience.
>
> I have a set of patches that let NFS clients bind to a specific IP
> address, but I haven't gotten any feedback in the month since
> I posted them.
>
> But, likely you will want to touch similar paths to what I touched.
>
> Here's my patch series:
>
> https://lkml.org/lkml/2011/7/15/382
>
>
> You need some patches to mount.nfs
> for full functionality, in case you want to try it out:
>
> https://github.com/greearb/nfs-utils-ct
>
> Thanks,
> Ben
>
>
>>
>> 16.08.2011 15:00, Stanislav Kinsbursky =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
>>> Hello.
>>> I'm going to virtualize NFS in mainline and here is my plan for NFS=
 client part.
>>> Any suggestions or criticism are welcome.
>>>
>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
>>>
>>> "NFS client" virtualization plan:
>>>
>>> _RPC layer_:
>>>
>>> 1) Make rpcbind clients (rpcb_local_clnt and rpcb_local4_clnt) to b=
e
>>> per net namespace.
>>>
>>> _NFS layer_:
>>>
>>> 1) Net namespace inheritance (current->nsproxy->net have to be used=
 instead
>>> of init_net).
>>> Pointer to net namespace can be stored on nfs_client structure, whi=
ch will
>>> give easy access to proper net namespace during RPC transports crea=
tion.
>>>
>>> 2) Make Lockd kthread able to handle requests from different net na=
mespaces.
>>>
>>> 3) Make NFS callbacks kthreads (nfs4_callback_svc and nfs4.1_callba=
ck_svc) able
>>> to handle requests from different net namespaces.
>>>
>>> 4) Make NFS info lists (nfs_volume_list and nfs_client_list) to be =
per
>>> net namespace in addition to global ones.
>>>
>>> 5) Make NFS proc variables and it's internal content variables to b=
e per
>>> net namespace in addition to global ones.
>>>
>>> 6) Make NFS sysctl variables and it's internal content variables to=
 be per
>>> net namespace in addition to global ones.
>>>
>>>
>>>
>>
>>
>
>


--=20
Best regards,
Stanislav Kinsbursky
