From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Don't convert NFS4ERR_RESOURCE to EREMOTEIO
Date: Wed, 04 Mar 2009 13:57:23 -0500
Message-ID: <1236193043.7807.9.camel@heimdal.trondhjem.org>
References: <49AECB96.5010909@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50982 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757564AbZCDS5c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Mar 2009 13:57:32 -0500
In-Reply-To: <49AECB96.5010909@uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-03-04 at 13:42 -0500, Benjamin Coddington wrote:
> Fixes a test in nfs4_proc_setclientid_confirm() which allows the client 
> to retry an operation when the server returns NFS4ERR_RESOURCE, instead 
> of returning EREMOTEIO to the user.
> 
> ---
> fs/nfs/nfs4xdr.c |    1 -
>   1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index d1e4c8f..61dda13 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4522,7 +4522,6 @@ static struct {
>          { NFS4ERR_SERVERFAULT,  -ESERVERFAULT   },
>          { NFS4ERR_BADTYPE,      -EBADTYPE       },
>          { NFS4ERR_LOCKED,       -EAGAIN         },
> -       { NFS4ERR_RESOURCE,     -EREMOTEIO      },
>          { NFS4ERR_SYMLINK,      -ELOOP          },
>          { NFS4ERR_OP_ILLEGAL,   -EOPNOTSUPP     },
>          { NFS4ERR_DEADLOCK,     -EDEADLK        },

Big NACK.

Firstly, if you want to return the unmapped NFS4ERR_RESOURCE to
setclientid, then you should turn off the mapping of the error in
decode_setclientid instead of breaking all the other cases.

Secondly. The definition of NFS4ERR_RESOURCE is:
                For the processing of the COMPOUND procedure, the server
                may exhaust available resources and can not continue
                processing operations within the COMPOUND procedure.
                This error will be returned from the server in those
                instances of resource exhaustion related to the
                processing of the COMPOUND procedure.

There is nothing there that states this is a temporary condition, and
that the client should retry (which is why NFSv4.1 gets rid of it
altogether). If servers want the client to retry, they should be using
NFS4ERR_DELAY.

  Trond

