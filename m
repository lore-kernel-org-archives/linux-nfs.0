Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57819 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752020Ab2EUPvN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 21 May 2012 11:51:13 -0400
Date: Mon, 21 May 2012 11:51:11 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 07/14] NFS: Don't swap bytes in
 nfs4_construct_boot_verifier()
Message-ID: <20120521155111.GG24299@fieldses.org>
References: <20120518220145.774.53741.stgit@degas.1015granger.net>
 <20120518220615.774.43776.stgit@degas.1015granger.net>
 <20120521154006.GF24299@fieldses.org>
 <82C7ADD1-2B2A-4776-AFCA-122DD30772A5@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <82C7ADD1-2B2A-4776-AFCA-122DD30772A5@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 21, 2012 at 11:47:38AM -0400, Chuck Lever wrote:
> Hi-
> 
> On May 21, 2012, at 11:40 AM, J. Bruce Fields wrote:
> 
> > On Fri, May 18, 2012 at 06:06:16PM -0400, Chuck Lever wrote:
> >> The SETCLIENTID boot verifier is opaque to NFSv4 servers, thus there
> >> is no requirement for byte swapping before the client puts the
> >> verifier on the wire.
> >> 
> >> This treatment is similar to other timestamp-based verifiers.
> > 
> > The fact that it's opaque means we don't *have* to be consistent about
> > byte-order.  But we can still choose to do so.
> 
> Agree, and that's consistent with "no requirement for byte swapping".
> 
> > It may help debugging a
> > little (by making it just a little easier to decode the on-the-wire
> > verifier).
> 
> In this case, I doubt it.  We're talking about raw timestamps here, there's nothing we can really recognize in those.  If this were a structured piece of data, I'd feel more agreement about debugging ease.
> 
> > And changing the encoding of the verifier means it won't
> > work over boots that cross kernel versions.
> 
> The boot verifier is *supposed* to change over a reboot, so I think this is not consequential.  The server is only looking for a mismatch between verifiers, and this changes preserves that semantic.

Whoops, you're right (ignoring amusing but unlikely cases where
subsequent boot times happen to be byte-swaps of each other).

> > (I'll admit that's *not* a
> > big deal--most clients probably take longer than most servers' lease
> > times anyway--but why do this without a reason?)
> 
> It reduces code clutter for the subsequent patch which adds the NFS4CLNT_PURGE_STATE bit.

Huh, I don't see that it makes much difference.

Whatever, I don't care much.

--b.

> 
> > 
> > --b.
> > 
> >> 
> >> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> >> ---
> >> 
> >> fs/nfs/nfs4proc.c |    4 ++--
> >> 1 files changed, 2 insertions(+), 2 deletions(-)
> >> 
> >> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> >> index db7b76a..73cfd9e 100644
> >> --- a/fs/nfs/nfs4proc.c
> >> +++ b/fs/nfs/nfs4proc.c
> >> @@ -3937,8 +3937,8 @@ static void nfs4_construct_boot_verifier(struct nfs_client *clp,
> >> {
> >> 	__be32 verf[2];
> >> 
> >> -	verf[0] = htonl((u32)clp->cl_boot_time.tv_sec);
> >> -	verf[1] = htonl((u32)clp->cl_boot_time.tv_nsec);
> >> +	verf[0] = (__be32)clp->cl_boot_time.tv_sec;
> >> +	verf[1] = (__be32)clp->cl_boot_time.tv_nsec;
> >> 	memcpy(bootverf->data, verf, sizeof(bootverf->data));
> >> }
> >> 
> >> 
> >> --
> >> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> >> the body of a message to majordomo@vger.kernel.org
> >> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
