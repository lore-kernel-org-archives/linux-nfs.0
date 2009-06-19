From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/5] nfsd: add support for NFSv4 callbacks over IPv6
	(try #2)
Date: Fri, 19 Jun 2009 15:58:10 -0400
Message-ID: <20090619195810.GB28506@fieldses.org>
References: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:50579 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbZFST6I (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Jun 2009 15:58:08 -0400
In-Reply-To: <1245436981-11806-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jun 19, 2009 at 02:42:56PM -0400, Jeff Layton wrote:
> Here's a second pass at adding support for NFSv4 callback channels over
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
> address to the same value as the sin6_scope_id in the svc_rqst->rq_addr.
> This allows the server to call back clients that mounted the server via
> one of its link-local addresses.
> 
> Again, tested using opensolaris and linux clients and watching the
> traffic with wireshark. Everything seems to work. Delegations and
> recalls work fine to opensolaris.
> 
> I seem to be having some trouble getting the server to issue delegations
> to linux clients, but I can see the callback channel being correctly
> established.
> 
> I think the problem with delegations is unrelated to this set. It seems
> to still be a problem even with IPv4 on an unpatched kernel. I think it
> has something to do with how linux clients are generating open_owner
> ID's. I'll email the list separately about that...

The usual problem here is just that delegations aren't given out on
first use of an open_owner.  You'll probably need to open the file
twice.

--b.

> 
> Jeff Layton (5):
>   nfsd: convert nfs4_callback struct to hold address in
>     sockaddr_storage
>   nfsd: break out setclientid port parsing into separate routine
>   nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
>   nfsd: add support for NFSv4 callbacks over IPv6
>   nfsd: populate sin6_scope_id on callback address with scopeid from
>     rq_addr on SETCLIENTID call
> 
>  fs/nfsd/nfs4callback.c     |   11 +--
>  fs/nfsd/nfs4state.c        |  221 ++++++++++++++++++++++++++++++++++++--------
>  include/linux/nfsd/state.h |    6 +-
>  3 files changed, 189 insertions(+), 49 deletions(-)
> 
