Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:59618 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757163Ab1ILOux convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 10:50:53 -0400
Subject: Re: NFS client virtualization plan v2
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4E6E104F.8080903@parallels.com>
Date: Mon, 12 Sep 2011 10:50:43 -0400
Cc: Pavel Emelianov <xemul@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <1055810C-4BE8-4950-8F39-A844834CF666@oracle.com>
References: <4E6E104F.8080903@parallels.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 12, 2011, at 9:59 AM, Stanislav Kinsbursky wrote:

> Hello.
> This is an update for this plan. Added rpc_pipefs and NFS cache virtualization.

You may need a per-net namespace NSM monitor list as well.  That means running a per-namespace statd, each with its own local sm and sm.bak directories, and keeping the in-kernel monitor information sorted by namespace.

The caller_name argument of NLM_LOCK needs to be the namespace's local utsname, and this string should be used as the my_name argument when sending an SM_MON upcall.  I've got a patch or two that make this simpler.

> ==============================================================================
> 
> "NFS client" virtualization plan:
> 
> _RPC layer_:
> 
> 1) Make rpcbind clients (rpcb_local_clnt and rpcb_local4_clnt) to be
> per net namespace.
> 
> 2) Make RPC pipefs to be per net namespace.
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
> 7) Make NFS cache per net namespace.
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
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



