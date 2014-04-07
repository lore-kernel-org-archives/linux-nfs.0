Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-o-3.desy.de ([131.169.56.156]:39031 "EHLO smtp-o-3.desy.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753190AbaDGSm2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Apr 2014 14:42:28 -0400
Received: from smtp-map-3.desy.de (smtp-map-3.desy.de [131.169.56.68])
	by smtp-o-3.desy.de (DESY-O-3) with ESMTP id 70AE828089A
	for <linux-nfs@vger.kernel.org>; Mon,  7 Apr 2014 20:35:26 +0200 (CEST)
Received: from ZITSWEEP2.win.desy.de (zitsweep2.win.desy.de [131.169.97.96])
	by smtp-map-3.desy.de (DESY_MAP_3) with ESMTP id 63ED82B7D
	for <linux-nfs@vger.kernel.org>; Mon,  7 Apr 2014 20:35:25 +0200 (MEST)
Date: Mon, 7 Apr 2014 20:35:25 +0200 (CEST)
From: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Message-ID: <1907491201.2131087.1396895725338.JavaMail.zimbra@desy.de>
In-Reply-To: <20140407165820.GE21195@fieldses.org>
References: <20140407165820.GE21195@fieldses.org>
Subject: Re: nfsd 3.14 status
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


3.15, I believe.

Tigran.

----- Original Message -----
> From: "J. Bruce Fields" <bfields@fieldses.org>
> To: linux-nfs@vger.kernel.org
> Sent: Monday, April 7, 2014 6:58:20 PM
> Subject: nfsd 3.14 status
> 
> The below is what I'm intending to merge for 3.14.  I think I've caught
> up with my mailbox; please let me know if I've missed anything from you.
> 
> Also, I'll be mostly offline for three weeks starting Friday--if you
> want anything from me before early May, ask now.
> 
> I decided to let the rest of the xdr patches sit a little longer.  I'll
> plan to get that queued up quickly for 3.16 once I'm back.
> 
> --b.
> 
> J. Bruce Fields (18):
>       nfsd4: buffer-length check for SUPPATTR_EXCLCREAT
>       nfsd4: session needs room for following op to error out
>       nfsd4: make set of large acl return efbig, not resource
>       nfsd4: leave reply buffer space for failed setattr
>       nfsd4: fix test_stateid error reply encoding
>       nfsd: notify_change needs elevated write count
>       nfsd: typo in nfsd_rename comment
>       rpc: Allow xdr_buf_subsegment to operate in-place
>       nfsd4: update comments with obsolete function name
>       nfsd4: nfsd4_replay_cache_entry should be static
>       nfsd4: minor nfsd4_replay_cache_entry cleanup
>       nfsd4: use more generous NFS4_ACL_MAX
>       nfsd4: remove redundant check from nfsd4_check_resp_size
>       nfsd4: fix setclientid encode size
>       nfsd4: fix nfs4err_resource in 4.1 case
>       nfsd: revert v2 half of "nfsd: don't return high mode bits"
>       nfsd4: don't create unnecessary mask acl
>       nfsd4: fix delegation cleanup on error
> 
> Jeff Layton (5):
>       svcrdma: fix printk when memory allocation fails
>       svcrpc: explicitly reject compounds that are not padded out to 4-byte
>       multiple
>       lockd: ensure we tear down any live sockets when socket creation fails
>       during lockd_up
>       xprtrdma: add separate Kconfig options for NFSoRDMA client and server
>       support
>       svcrdma: fix offset calculation for non-page aligned sge entries
> 
> Kinglong Mee (9):
>       NFSD: Traverse unconfirmed client through hash-table
>       NFSD: simplify saved/current fh uses in nfsd4_proc_compound
>       SUNRPC: fix memory leak of peer addresses in XPRT
>       NFSD: Using free_conn free connection
>       NFSD: Clear wcc data between compound ops
>       NFSD: Free backchannel xprt in bc_destroy
>       SUNRPC: New helper for creating client with rpc_xprt
>       NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
>       SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
> 
> Rashika Kheria (1):
>       net: Mark functions as static in net/sunrpc/svc_xprt.c
> 
> Stanislav Kinsbursky (1):
>       nfsd: check passed socket's net matches NFSd superblock's one
> 
> Tom Tucker (1):
>       Fix regression in NFSRDMA server
> 
> Trond Myklebust (1):
>       nfsd: Don't return NFS4ERR_STALE_STATEID for NFSv4.1+
> 
> Yan, Zheng (1):
>       nfsd4: fix memory leak in nfsd4_encode_fattr()
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
