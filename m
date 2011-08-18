From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS client virtualization plan
Date: Thu, 18 Aug 2011 11:54:42 -0400
Message-ID: <67028AE2-C41D-4D9E-9AB9-81433AD196A2@oracle.com>
References: <4E4A4DB1.2090105@parallels.com>
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Emelianov <xemul@parallels.com>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:57589 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755542Ab1HRPy6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Aug 2011 11:54:58 -0400
In-Reply-To: <4E4A4DB1.2090105@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Aug 16, 2011, at 7:00 AM, Stanislav Kinsbursky wrote:

> Hello.
> I'm going to virtualize NFS in mainline and here is my plan for NFS client part.
> Any suggestions or criticism are welcome.

What are you going to do about statd?

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
> -- 
> Best regards,
> Stanislav Kinsbursky
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




