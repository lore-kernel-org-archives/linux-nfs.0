Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59817 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935542Ab0KQWtG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Nov 2010 17:49:06 -0500
Date: Wed, 17 Nov 2010 17:49:03 -0500
To: andros@netapp.com
Cc: benny@panasas.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/3] NFSv4 callback pg_authenticate fix
Message-ID: <20101117224903.GC31009@fieldses.org>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1289964990-4480-1-git-send-email-andros@netapp.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 16, 2010 at 10:36:27PM -0500, andros@netapp.com wrote:
> The back channel server svc_process_common RPC layer pg_authenticate call
> [nfs_callback_authenticate] is shared by both the NFSv4.0 and the NFSv4.1
> callback threads. It authenticates the incoming request by finding (and
> referencing) an nfs_client struct based on the incoming request address
> and the NFS version (4). This is akin to the NFS server which authenticates
> requests by matching the server address to the exports file client list.
> 
> Since there is no minorversion in the search, it may find the wrong
> nfs_client struct.

What really matters to a sessions client is which connection the request
came over--if a server attempts to open a new connection back to a
client and send a 4.1 callback over it, it'd probably be best if the
client just refused that callback, even if it's from the right IP
address.

Would it be better to match cl_rpcclient->cl_xprt against rqstp->rq_xprt
somehow?  (Or maybe just check that the port number matches as well as
the ip address?)

--b.

> For the nfsv4.0 callback service thread, this means it
> could find an NFSv4.1 nfs_client. For the NFSv4.1 callback service thread, it
> could find an NFSv4.0 instead of v4.1, or find an NFSv4.1 nfs_client with the
> wrong session.
> 
> The nfs_client is dereferenced at the end of pg_authenticate. Another
> nfs_find_client call is done in the per operation  dispatcher routines
> for NFSv4.0 and in the cb_sequence operation dispatcher routine for NFSv4.1
> after decoding.
> 
> This means the callback server could start processing a callback, passing
> the pg_authenticate test, and have the nfs_client struct freed between the
> pg_authenticate call and the dispatcher operation call. Or, it could have
> found the wrong nfs_client in the pg_authenticate call.
> 
> The current code has this behaviour: If the nfs_client is not found in
> pg_authenticate, the request is simply dropped (SVC_DROP). If an nfs_client
> is not found in the dispatcher routines NFS4ERR_BADSESSION is returned for
> v4.1 requests and NFS4ERR_BADHANDLE for v4.0 requests.
> 
> The first patch fixes some of these issues. It adds a minorversion to the
> nfs_find_client routine which means that the NFSv4.0 back channel service always
> finds the correct nfs_client struct. The NFSv4.1 back channel service requires
> the sessionid from the CB_SEQUENCE operation to guarantee that the correct
> nfs_client struct is being used.
> 
> The minorversion is assigned by checking for the existance of the
> bc_xprt field in the svc_rqst. This method of determining minorversion will
> work until we support stand alone back channels for NFSv4.1.
> 
> The SVC_DROP return in pg_authenticate is changed to SVC_DENIED which sends
> an rpc auth error back to the caller. This matches nfsd which returns
> SVC_DENIED if there is no matching client address in the /etc/exports file.
> SVC_DROP is used for a memory allocation error.
> 
> 0001-NFS-add-minorversion-to-nfs_find_client-search.patch
> 0002-SQUASHME-pnfs-submit-fix-highest-backchannel-slot-us.patch
> 
> Both NFSv4.0 CB_RECALL and NFSv4.1 CB_LAYOUT_RECALL have been tested.
> 
> This third patch is for comment only. It compiles but has not been tested.
> It returns SVC_DENIED if the dispatcher routines fail to find an
> nfs_client struct - replacing the NFS4ERR_BADSESSION and NFS4ERR_BADHANDLE
> currently returned. I'm not fully convinced that this is the behavior we want,
> comments appreciated.
> 
> 0003-NFS-return-an-rpc-auth-error-on-back-channel.patch
> 
> -->Andy
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
