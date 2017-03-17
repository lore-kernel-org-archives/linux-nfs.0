Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:33659 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751160AbdCQNDl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 09:03:41 -0400
Received: by mail-qk0-f195.google.com with SMTP id j127so9645391qke.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Mar 2017 06:02:22 -0700 (PDT)
Message-ID: <1489755736.2810.10.camel@poochiereds.net>
Subject: Re: [PATCH 01/23] net, sunrpc: convert rpc_cred.cr_count from
 atomic_t to refcount_t
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        "elena.reshetova@intel.com" <elena.reshetova@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "peterz@infradead.org" <peterz@infradead.org>,
        "ralf@linux-mips.org" <ralf@linux-mips.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ishkamiel@gmail.com" <ishkamiel@gmail.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "steffen.klassert@secunet.com" <steffen.klassert@secunet.com>,
        "nhorman@tuxdriver.com" <nhorman@tuxdriver.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "jreuter@yaina.de" <jreuter@yaina.de>,
        "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>,
        "linux-hams@vger.kernel.org" <linux-hams@vger.kernel.org>,
        "dwindsor@gmail.com" <dwindsor@gmail.com>,
        "keescook@chromium.org" <keescook@chromium.org>,
        "zyan@redhat.com" <zyan@redhat.com>,
        "sage@redhat.com" <sage@redhat.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>,
        "vyasevich@gmail.com" <vyasevich@gmail.com>,
        "linux-x25@vger.kernel.org" <linux-x25@vger.kernel.org>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "ceph-devel@vger.kernel.org" <ceph-devel@vger.kernel.org>
Date: Fri, 17 Mar 2017 09:02:16 -0400
In-Reply-To: <1489755011.6453.1.camel@primarydata.com>
References: <1489752646-8749-1-git-send-email-elena.reshetova@intel.com>
         <1489752646-8749-2-git-send-email-elena.reshetova@intel.com>
         <1489755011.6453.1.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2017-03-17 at 12:50 +0000, Trond Myklebust wrote:
> On Fri, 2017-03-17 at 14:10 +0200, Elena Reshetova wrote:
> > refcount_t type and corresponding API should be
> > used instead of atomic_t when the variable is used as
> > a reference counter. This allows to avoid accidental
> > refcounter overflows that might lead to use-after-free
> > situations.
> > 
> > Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
> > Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
> > Signed-off-by: Kees Cook <keescook@chromium.org>
> > Signed-off-by: David Windsor <dwindsor@gmail.com>
> > ---
> >  include/linux/sunrpc/auth.h |  8 ++++----
> >  net/sunrpc/auth.c           | 12 ++++++------
> >  2 files changed, 10 insertions(+), 10 deletions(-)
> > 
> > diff --git a/include/linux/sunrpc/auth.h
> > b/include/linux/sunrpc/auth.h
> > index b1bc62b..bd36e0b 100644
> > --- a/include/linux/sunrpc/auth.h
> > +++ b/include/linux/sunrpc/auth.h
> > @@ -15,7 +15,7 @@
> >  #include <linux/sunrpc/msg_prot.h>
> >  #include <linux/sunrpc/xdr.h>
> >  
> > -#include <linux/atomic.h>
> > +#include <linux/refcount.h>
> >  #include <linux/rcupdate.h>
> >  #include <linux/uidgid.h>
> >  #include <linux/utsname.h>
> > @@ -68,7 +68,7 @@ struct rpc_cred {
> >  #endif
> >  	unsigned long		cr_expire;	/* when to gc
> > */
> >  	unsigned long		cr_flags;	/* various
> > flags */
> > -	atomic_t		cr_count;	/* ref count */
> > +	refcount_t		cr_count;	/* ref count */
> > 
> 
> NACK. That's going to be hitting WARN_ONCE(!refcount_inc_not_zero(r),
> "refcount_t: increment on 0; use-after-free.\n") like there's no
> tomorrow...
> 
> Please stop with these automated conversions. They are going to cause a
> lot more bugs than they fix.
> 

Agreed. These patchsets are touching places where we've already banged
out most of the refcounting bugs. I'm against doing large scale
conversions like this without a damned good reason.

I think it may be best to do this sort of thing in a more piecemeal
fashion. Pick a subsystem or two and do the conversions there to prove
that they're better than what we have. If the subsystem already has
problems with its refcounting, then so much the better. Point to bugs
that this new infrastructure helped find.

Encourage people to adopt your new infrastructure as new refcounted
objects are introduced into the kernel. You might even consider a LWN
article about this.

Eventually we'll get around to changing existing code to use it, once
there is a sufficient advantage to doing so. Most likely when we're
reworking the code for other reasons, or when we're chasing some horrid
refcounting bug and think that this might help find it.
-- 
Jeff Layton <jlayton@poochiereds.net>
