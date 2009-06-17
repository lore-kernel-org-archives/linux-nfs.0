From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/4] nfsd: add support for NFSv4 callbacks over IPv6
Date: Wed, 17 Jun 2009 14:47:01 -0400
Message-ID: <20090617184701.GD24040@fieldses.org>
References: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, chuck.lever@oracle.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:46819 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757171AbZFQSrC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Jun 2009 14:47:02 -0400
In-Reply-To: <1245262541-9362-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2009 at 02:15:37PM -0400, Jeff Layton wrote:
> This patchset is a first pass at adding IPv6 callback channel support
> for knfsd. The set is fairly straightforward, but it does require a
> number of changes to server side NFSv4 related structs that store
> addresses in places that are only suitable for IPv4 addresses.
> 
> I've tested this by having Linux and OpenSolaris clients mount the
> server over an IPv6 socket, get a delegation and ensure that the server
> can recall that delegation. It all seems to work as expected. IPv4
> callbacks also seem to continue to work correctly.
> 
> This patchset does change the some of the new 4.1 functions
> (nfsd4_exchange_id in particular). Those changes are untested as of yet
> but I'll see if I can do so if the approach in this set seems
> reasonable.

Thanks, just two quick comments:

	1. I've been working on the callback code, so check that this
	applies against for-2.6.31 (at
	git://linux-nfs.org/~bfields/linux.git).
	2. Any IP address checks in setclientid or exchange_id are
	probably bogus; the former should be gone, the latter may still
	be there but there'll be a patch queued up for 2.6.31 to fix
	that.

--b.

> 
> Comments welcome...
> 
> Jeff Layton (4):
>   nfsd: convert nfs4_callback struct to hold address in
>     sockaddr_storage
>   nfsd: break out setclientid port parsing into separate routine
>   nfsd: make nfs4_client->cl_addr a struct sockaddr_storage
>   nfsd: add support for NFSv4 callbacks over IPv6
> 
>  fs/nfsd/nfs4callback.c     |   11 +--
>  fs/nfsd/nfs4state.c        |  220 ++++++++++++++++++++++++++++++++++++-------
>  include/linux/nfsd/state.h |    6 +-
>  3 files changed, 189 insertions(+), 48 deletions(-)
> 
