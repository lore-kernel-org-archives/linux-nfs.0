Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59168 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750710AbdEIVDv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 9 May 2017 17:03:51 -0400
Date: Tue, 9 May 2017 17:03:50 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Colin King <colin.king@canonical.com>,
        Ari Kauppi <ari@synopsys.com>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: avoid out of bounds read on array nfsd4_layout_ops
Message-ID: <20170509210350.GD6289@fieldses.org>
References: <20170509133121.26529-1-colin.king@canonical.com>
 <20170509140414.ycw4z6zsdevbkozm@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170509140414.ycw4z6zsdevbkozm@mwanda>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 09, 2017 at 05:04:14PM +0300, Dan Carpenter wrote:
> On Tue, May 09, 2017 at 02:31:21PM +0100, Colin King wrote:
> > diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> > index 1dbf62190bee..c453a1998e00 100644
> > --- a/fs/nfsd/nfs4proc.c
> > +++ b/fs/nfsd/nfs4proc.c
> > @@ -1259,7 +1259,8 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
> >  		return NULL;
> >  	}
> >  
> > -	if (layout_type >= 32 || !(exp->ex_layout_types & (1 << layout_type))) {
> > +	if (layout_type >= LAYOUT_TYPE_MAX ||
> > +	    !(exp->ex_layout_types & (1 << layout_type))) {
> 
> The 32 is there to prevent a shift wrapping bug.  The bit test prevents
> a buffer overflow so this can't actually overflow.

Yes, looks like a false positive for coverity.

> But this change doesn't hurt and is probably cleaner.

Sure.  Hope it's OK if I just merge this into the previous commit:

--b.

commit 16b6f81d8ed9
Author: Ari Kauppi <ari@synopsys.com>
Date:   Fri May 5 16:07:55 2017 -0400

    nfsd: fix undefined behavior in nfsd4_layout_verify
    
      UBSAN: Undefined behaviour in fs/nfsd/nfs4proc.c:1262:34
      shift exponent 128 is too large for 32-bit type 'int'
    
    Depending on compiler+architecture, this may cause the check for
    layout_type to succeed for overly large values (which seems to be the
    case with amd64). The large value will be later used in de-referencing
    nfsd4_layout_ops for function pointers.
    
    Reported-by: Jani Tuovila <tuovila@synopsys.com>
    Signed-off-by: Ari Kauppi <ari@synopsys.com>
    [colin.king@canonical.com: use LAYOUT_TYPE_MAX instead of 32]
    Reviewed-by: Dan Carpenter <dan.carpenter@oracle.com>
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index d86031b6ad79..c453a1998e00 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1259,7 +1259,8 @@ nfsd4_layout_verify(struct svc_export *exp, unsigned int layout_type)
 		return NULL;
 	}
 
-	if (!(exp->ex_layout_types & (1 << layout_type))) {
+	if (layout_type >= LAYOUT_TYPE_MAX ||
+	    !(exp->ex_layout_types & (1 << layout_type))) {
 		dprintk("%s: layout type %d not supported\n",
 			__func__, layout_type);
 		return NULL;
