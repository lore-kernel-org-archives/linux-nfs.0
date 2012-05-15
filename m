Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:43021 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756810Ab2EONx4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 May 2012 09:53:56 -0400
Date: Tue, 15 May 2012 16:57:33 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: Re: [patch] NFS: kmalloc() doesn't return an ERR_PTR()
Message-ID: <20120515135733.GJ16984@mwanda>
References: <20120514194528.GA19613@elgon.mountain>
 <4FB25EA7.9050702@panasas.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4FB25EA7.9050702@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 15, 2012 at 04:48:23PM +0300, Boaz Harrosh wrote:
> On 05/14/2012 10:45 PM, Dan Carpenter wrote:
> 
> > Obviously we should check for NULL here instead of IS_ERR().
> > 
> > Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> > 
> > diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
> > index ba3019f..233beea 100644
> > --- a/fs/nfs/idmap.c
> > +++ b/fs/nfs/idmap.c
> > @@ -644,14 +644,14 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
> >  
> >  	/* msg and im are freed in idmap_pipe_destroy_msg */
> >  	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
> > -	if (IS_ERR(msg)) {
> > -		ret = PTR_ERR(msg);
> > +	if (!msg) {
> 
> 
> While at it please put an unlikely()
> 

Normally we wouldn't put an unlikely() here.  It makes the code
less readable and it's not going to affect benchmarks.  But I can
add one if people prefer.

regards,
dan carpenter

