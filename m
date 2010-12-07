Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41253 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab0LGWjs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Dec 2010 17:39:48 -0500
Date: Tue, 7 Dec 2010 17:39:45 -0500
To: Jim Rees <rees@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] nfsd: fix offset printk's in nfsd3 read/write
Message-ID: <20101207223945.GA28044@fieldses.org>
References: <1291680566-13980-1-git-send-email-bfields@redhat.com>
 <1291680566-13980-4-git-send-email-bfields@redhat.com>
 <20101207003104.GA4317@merit.edu>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101207003104.GA4317@merit.edu>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Dec 06, 2010 at 07:31:04PM -0500, Jim Rees wrote:
> J. Bruce Fields wrote:
> 
>   Thanks to dysbr01@ca.com for noticing that the debugging printk in
>   the v3 write procedure can print >2GB offsets as negative numbers:
>   	https://bugzilla.kernel.org/show_bug.cgi?id=23342
>   
>   Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>   ---
>    fs/nfsd/nfs3proc.c |    8 ++++----
>    1 files changed, 4 insertions(+), 4 deletions(-)
>   
>   diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
>   index 5b7e302..2247fc9 100644
>   --- a/fs/nfsd/nfs3proc.c
>   +++ b/fs/nfsd/nfs3proc.c
>   @@ -151,10 +151,10 @@ nfsd3_proc_read(struct svc_rqst *rqstp, struct nfsd3_readargs *argp,
>    	__be32	nfserr;
>    	u32	max_blocksize = svc_max_payload(rqstp);
>    
>   -	dprintk("nfsd: READ(3) %s %lu bytes at %lu\n",
>   +	dprintk("nfsd: READ(3) %s %lu bytes at %Lu\n",
> 
> Isn't "llu" preferred over "Lu" these days?

Uh, OK, reading sprintf(3), "L" seems to only be meaningful for floating
point, and "ll" a long long.

Looking at the kernel's printk(), "L" seems to be a synomym for "ll".

Both seem to be used all over.

I'm leaving it as is out of laziness and consistency with the one
preexisting use in this file, unless someone wants to argue otherwise.

--b.
