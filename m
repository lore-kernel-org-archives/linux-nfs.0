Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45957 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751081Ab2KGTa1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 14:30:27 -0500
Date: Wed, 7 Nov 2012 14:30:25 -0500
To: Pawel Dziepak <pdziepak@quarnos.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Unprivileged port and ERR_PERM
Message-ID: <20121107193025.GF7421@fieldses.org>
References: <CALS3df3f-H=UKP2kARY4p0qtK2VaEMVQgZM-omBU-LJZejOT8w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <CALS3df3f-H=UKP2kARY4p0qtK2VaEMVQgZM-omBU-LJZejOT8w@mail.gmail.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Aug 24, 2012 at 10:51:26PM +0200, Pawel Dziepak wrote:
> I have noticed that when a client issues a request from insecure port
> (involving an object from export that does not allow that) nfsd
> returns ERR_PERM. This does not seem to conform to the either NFS or
> RPC specification. First of all, NFS4 specification states that only
> CREATE, OPEN and SETATTR operations may return ERR_PERM, in situation
> when:
> 
> "Not owner. The operation was not allowed
> because the caller is either not a privileged
> user (root) or not the owner of the target of
> the operation."
> 
> Moreover, definition of ERR_ACCESS points out the difference between
> these two error codes.
> 
> "Contrast this with NFS4ERR_PERM,
> which restricts itself to owner or privileged
> user permission failures."
> 
> I believe that ERR_ACCESS is more suitable error code when access is
> denied due to insecure port, at least no client will get unexpected
> ERR_PERM.
> However, rejecting RPC request and setting rejection reason to
> AUTH_TOOWEAK seems to be the best solution. In appendix A RPC version
> 2 specification suggests that using privileged transport addresses may
> be a part of client authentication.

That does sound more logical.

That said, I suspect the server's been doing this forever, so this isn't
too high on my list for now; patches welcomed.

Since we allow the use of "secure" ports to vary from one export to
another we can't make the decision until we've actually looked up a
filehandle, which may make it tricky (maybe impossible at least with
some odd v4 compounds) to return an rpc-layer error.

--b.

> 
> "The authentication provided by this scheme can be considered
> legitimate only when applications using this scheme and the network
> can be secured externally, and privileged transport addresses are
> used for the communicating end-points (an example of this is the use
> of privileged TCP/UDP ports in UNIX systems -- note that not all
> systems enforce privileged transport address mechanisms)."
> 
> Hence, AUTH_TOOWEAK would clearly state that access was denied due to
> authentication problem, use of insecure port in this case. IIRC this
> is the way nfsportmon behaves.
> 
> Paweł Dziepak
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
