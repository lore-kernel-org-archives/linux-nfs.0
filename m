Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:42880 "EHLO
	mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbcBEVlZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Feb 2016 16:41:25 -0500
Date: Fri, 5 Feb 2016 16:41:22 -0500 (EST)
From: Matt Benjamin <mbenjamin@redhat.com>
To: andros@netapp.com
Cc: trond myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Message-ID: <602004174.33270134.1454708482500.JavaMail.zimbra@redhat.com>
In-Reply-To: <1454706518-4641-1-git-send-email-andros@netapp.com>
References: <1454706518-4641-1-git-send-email-andros@netapp.com>
Subject: Re: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1 Session
 Trunking
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks like a good thing.

Matt

----- Original Message -----
> From: andros@netapp.com
> To: "trond myklebust" <trond.myklebust@primarydata.com>
> Cc: linux-nfs@vger.kernel.org, "Andy Adamson" <andros@netapp.com>
> Sent: Friday, February 5, 2016 4:08:32 PM
> Subject: [PATCH RFC Version 1 0/6] Request for Comment: NFS4.1 Session Trunking
> 
> From: Andy Adamson <andros@netapp.com>
> 
> This early patch set implements NFSv4.1 session trunking utilizing Tronds
> multipath feature.  This works against an upstream linux server with
> two NICs as the EXCHANGE_ID info is the same for both NICs.
> 
> Unmodified code will create a new nfs_client structure for the mount as
> nfs_match_client fails due to the different full server address.
> Tunking is detected by comparing the eir_server_owner.major/minor/scope
> and the eir_server_impl_id to an existing mount. When trunking is detected,
> the 2nd mount point uses the existing  (not new) nfs_client for the new
> mount point.
> 
> When trunking is detected, this patch set adds an rpc_xprt for the new server
> address to the exisiting mount, calls BIND_CONN_TO_SESSION, and destroys
> the new clientid (no second mount).
> 
> We then get round robin use of the two NICs off one mount point all
> using a single session.
> 
> 
> Is using mount a good way to setup NFSv4.1 session trunking?
> 
> The first two patches fix issues with the multipath code.
> 
> SUNRPC: allow rpc_xprt_switch_add_xprt to add xprts on the same net
>     This patch adds a flag to allow multipathing within the origial net.
>     I don't understand why this was not allowed, so I expect a different
>     solution for this issue.
> 
> 
> Comments please.
> 
> Thanks
> 
> -->Andy
> 
> Andy Adamson (6):
>   SUNRPC fix rpc_clnt_add_xprt setup return
>   SUNRPC fix rpc_clnt_xprt_iter_init infinite loop
>   SUNRPC: allow rpc_xprt_switch_add_xprt to add xprts on the same net
>   NFS session trunking support: add trunk xprt to nfs4.1 mount
>   NFS add callback_ops to nfs4_proc_bind_conn_to_session_callback
>   NFS schedule bind_conn_to_session for new NFSv4.1 transport
> 
>  fs/nfs/client.c                      |  2 ++
>  fs/nfs/nfs4client.c                  | 29 +++++++++++++++++++++++++++--
>  fs/nfs/nfs4proc.c                    | 10 ++++++++++
>  include/linux/nfs_fs_sb.h            |  1 +
>  include/linux/sunrpc/clnt.h          |  1 +
>  include/linux/sunrpc/xprtmultipath.h |  6 +++++-
>  net/sunrpc/clnt.c                    | 20 +++++++++++++-------
>  net/sunrpc/xprtmultipath.c           | 35
>  +++++++++++++++++++++++++++++++++--
>  8 files changed, 92 insertions(+), 12 deletions(-)
> 
> --
> 1.8.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

-- 
-- 
Matt Benjamin
Red Hat, Inc.
315 West Huron Street, Suite 140A
Ann Arbor, Michigan 48103

http://www.redhat.com/en/technologies/storage

tel.  734-707-0660
fax.  734-769-8938
cel.  734-216-5309
