Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:27083 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751720Ab1HPLHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 07:07:50 -0400
Message-ID: <4E4A4FA9.7080600@parallels.com>
Date: Tue, 16 Aug 2011 15:08:25 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>, trond@netapp.com,
        Pavel Emelianov <xemul@parallels.com>
Subject: Re: NFS client virtualization plan
References: <4E4A4DB1.2090105@parallels.com>
In-Reply-To: <4E4A4DB1.2090105@parallels.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Added maintainer to mail recipients.
Trond, please, have a look.
Sorry for inconvenience.

16.08.2011 15:00, Stanislav Kinsbursky пишет:
> Hello.
> I'm going to virtualize NFS in mainline and here is my plan for NFS client part.
> Any suggestions or criticism are welcome.
>
> ==============================================================================
>
> "NFS client" virtualization plan:
>
> _RPC layer_:
>
> 1) Make rpcbind clients (rpcb_local_clnt and rpcb_local4_clnt) to be
> per net namespace.
>
> _NFS layer_:
>
> 1) Net namespace inheritance (current->nsproxy->net have to be used instead
> of init_net).
> Pointer to net namespace can be stored on nfs_client structure, which will
> give easy access to proper net namespace during RPC transports creation.
>
> 2) Make Lockd kthread able to handle requests from different net namespaces.
>
> 3) Make NFS callbacks kthreads (nfs4_callback_svc and nfs4.1_callback_svc) able
> to handle requests from different net namespaces.
>
> 4) Make NFS info lists (nfs_volume_list and nfs_client_list) to be per
> net namespace in addition to global ones.
>
> 5) Make NFS proc variables and it's internal content variables to be per
> net namespace in addition to global ones.
>
> 6) Make NFS sysctl variables and it's internal content variables to be per
> net namespace in addition to global ones.
>
>
>


-- 
Best regards,
Stanislav Kinsbursky
