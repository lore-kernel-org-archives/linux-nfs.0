From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Don't convert NFS4ERR_RESOURCE to EREMOTEIO
Date: Wed, 4 Mar 2009 14:01:56 -0500
Message-ID: <20090304190156.GA27567@fieldses.org>
References: <49AECB96.5010909@uvm.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Benjamin Coddington <Benjamin.Coddington@uvm.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:41114 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754747AbZCDTCA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Mar 2009 14:02:00 -0500
In-Reply-To: <49AECB96.5010909@uvm.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 04, 2009 at 01:42:30PM -0500, Benjamin Coddington wrote:
> Fixes a test in nfs4_proc_setclientid_confirm() which allows the client  
> to retry an operation when the server returns NFS4ERR_RESOURCE, instead  
> of returning EREMOTEIO to the user.

I remember being confused as to whether NFS4ERR_RESOURCE is transitory
(hence worth being retried) or permanent (in which case retrying the
identical compound won't help).  The latter might happen if, for
example, the particular sequence of compounds sent by the client was
just too long or complicated for the server to handle.

But rfc3530 doesn't explicitly limit NFS4ERR_RESOURCE to that case, and
it appears that other clients:

	http://www.nfsv4.org/nfsv4-wg-archive-feb-03-feb-05/0747.html

retry.  That discussion isn't conclusive, though.  Hm, and there's
further discussion from Mike Eisler here:

	http://www.nfsv4-editor.org/cgi-bin/roundup/nfsv4/file7/comp-res.txt

which suggests it was intended as a permanent error.

What was the specific case where you hit this?

--b.

>
> ---
> fs/nfs/nfs4xdr.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
>
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index d1e4c8f..61dda13 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -4522,7 +4522,6 @@ static struct {
>         { NFS4ERR_SERVERFAULT,  -ESERVERFAULT   },
>         { NFS4ERR_BADTYPE,      -EBADTYPE       },
>         { NFS4ERR_LOCKED,       -EAGAIN         },
> -       { NFS4ERR_RESOURCE,     -EREMOTEIO      },
>         { NFS4ERR_SYMLINK,      -ELOOP          },
>         { NFS4ERR_OP_ILLEGAL,   -EOPNOTSUPP     },
>         { NFS4ERR_DEADLOCK,     -EDEADLK        },
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
