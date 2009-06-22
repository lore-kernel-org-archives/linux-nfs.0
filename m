From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 0/5] nfsd: add support for NFSv4 callbacks over IPv6 (try #2)
Date: Mon, 22 Jun 2009 11:47:37 -0400
Message-ID: <C4F29AD4-164F-431D-9BEB-836717A6D65F@oracle.com>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
	Bruce Fields <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:58735 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752428AbZFVPsF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Jun 2009 11:48:05 -0400
In-Reply-To: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun 19, 2009, at 2:42 PM, Jeff Layton wrote:
> Here's a second pass at adding support for NFSv4 callback channels  
> over
> IPv6. The main changes since the last set are:
>
> 1) rebase to Bruce's master/for-2.6.31 branches. It applies cleanly to
> either.
>
> 2) cleaned up the IPv6-enablement patch: mostly this was done by
> removing conditional compilation from several places where it wasn't
> really required.
>
> 3) add patch that makes it set the sin6_scope_id for the callback
> address to the same value as the sin6_scope_id in the svc_rqst- 
> >rq_addr.
> This allows the server to call back clients that mounted the server  
> via
> one of its link-local addresses.

The rpcbind XDR patches I'm working on provide a full universal  
address 2 sockaddr conversion capability in sunrpc.ko, since several  
unrelated features in NFS/NFSD/sunrpc appear to require it.  I think  
the server-side callback client should use this common code instead of  
having its own version.

The new code is in my git repo; you should be able to pull HEAD to  
have a look.

> Again, tested using opensolaris and linux clients and watching the
> traffic with wireshark. Everything seems to work. Delegations and
> recalls work fine to opensolaris.
>
> I seem to be having some trouble getting the server to issue  
> delegations
> to linux clients, but I can see the callback channel being correctly
> established.
>
> I think the problem with delegations is unrelated to this set. It  
> seems
> to still be a problem even with IPv4 on an unpatched kernel. I think  
> it
> has something to do with how linux clients are generating open_owner
> ID's. I'll email the list separately about that...
>
> Jeff Layton (5):
>  nfsd: convert nfs4_callback struct to hold address in
>    sockaddr_storage
>  nfsd: break out setclientid port parsing into separate routine
>  nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
>  nfsd: add support for NFSv4 callbacks over IPv6
>  nfsd: populate sin6_scope_id on callback address with scopeid from
>    rq_addr on SETCLIENTID call
>
> fs/nfsd/nfs4callback.c     |   11 +--
> fs/nfsd/nfs4state.c        |  221 +++++++++++++++++++++++++++++++++++ 
> +--------
> include/linux/nfsd/state.h |    6 +-
> 3 files changed, 189 insertions(+), 49 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



