Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:32332 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752289Ab2F1Pn4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Jun 2012 11:43:56 -0400
Date: Thu, 28 Jun 2012 11:43:53 -0400
From: Jeff Layton <jlayton@redhat.com>
To: andros@netapp.com
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/1] SUNRPC handle EKEYEXPIRED in call_refreshresult
Message-ID: <20120628114353.4f75aabc@tlielax.poochiereds.net>
In-Reply-To: <1340827535-3062-1-git-send-email-andros@netapp.com>
References: <1340827535-3062-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 27 Jun 2012 16:05:34 -0400
andros@netapp.com wrote:

> From: Andy Adamson <andros@netapp.com>
> 
> Without this patch attempting to access a Kerberos mount with expired or no
> credentials resulted in the NFS client hanging while retrying to refresh creds
> for ever.
> 
> I tested NFSv3/v4/v4.1 sec=krb5 mounts. With expired or non-existent user
> Kerberos credentials, trying to ls the mountpoint, or cd into the mountpoint
> resulted in three failed upcalls to gssd (due to tk_cred_retry being set to 2)
> then the 'Operation not permitted' message is returned to the user.
> 
> I think this patch should go into the stable kernel.
> 
> Andy Adamson (1):
>   SUNRPC handle EKEYEXPIRED in call_refreshresult
> 
>  fs/nfs/nfs4proc.c |    2 --
>  net/sunrpc/clnt.c |    4 ++++
>  2 files changed, 4 insertions(+), 2 deletions(-)
> 

Wait...is this really the behavior you want here?

We had many complaints from users of krb5 mounts where long-running
jobs would routinely fail when the ticket expired.

The compromise behavior that we worked out at that time was to treat an
expired credcache differently from a "no credcache" situation. gssd would
return EKEYEXPIRED if the credcache existed but was expired, and
EACCES otherwise. The kernel would then treat those errors
differently:

    http://permalink.gmane.org/gmane.linux.nfsv4/11019

With EKEYEXPIRED, we'd want RPCs to hang indefinitely until the tickets
were renewed. With EACCES, the call would return an error. The idea
there is that the user would kdestroy if he needed to unwedge his krb5
mount.

This patch makes it sound like you're wanting to revert that behavior.
Is that the case? If so, what about people trying to run long-running
tasks on a kerberized mount? Are they just SOL if their ticket isn't
renewed in time?

-- 
Jeff Layton <jlayton@redhat.com>
