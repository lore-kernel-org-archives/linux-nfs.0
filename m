Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f194.google.com ([209.85.166.194]:50636 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726851AbeJDAo4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Oct 2018 20:44:56 -0400
Received: by mail-it1-f194.google.com with SMTP id j81-v6so9548925ite.0
        for <linux-nfs@vger.kernel.org>; Wed, 03 Oct 2018 10:55:30 -0700 (PDT)
Message-ID: <363f1a9b29ebbd5ca77a1c9f21b656744e8e62c8.camel@gmail.com>
Subject: Re: [PATCH 08/15] NFS: Lockless DNS lookups
From: Trond Myklebust <trondmy@gmail.com>
To: "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Date: Wed, 03 Oct 2018 13:55:28 -0400
In-Reply-To: <20181003161055.GF17517@fieldses.org>
References: <20181001144157.3515-1-trond.myklebust@hammerspace.com>
         <20181001144157.3515-2-trond.myklebust@hammerspace.com>
         <20181001144157.3515-3-trond.myklebust@hammerspace.com>
         <20181001144157.3515-4-trond.myklebust@hammerspace.com>
         <20181001144157.3515-5-trond.myklebust@hammerspace.com>
         <20181001144157.3515-6-trond.myklebust@hammerspace.com>
         <20181001144157.3515-7-trond.myklebust@hammerspace.com>
         <20181001144157.3515-8-trond.myklebust@hammerspace.com>
         <20181001144157.3515-9-trond.myklebust@hammerspace.com>
         <20181003161055.GF17517@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2018-10-03 at 12:10 -0400, J . Bruce Fields wrote:
> The individual conversions of these caches looks straightforward to
> me.
> Thanks for doing this in these small steps.  I'm assuming you're OK
> with
> these nfs/ changes going through the nfsd tree.
> 

Yes please. With the bulk of the changes being nfsd specific, that
makes more sense to me.

> --b.
> 
> On Mon, Oct 01, 2018 at 10:41:50AM -0400, Trond Myklebust wrote:
> > Enable RCU protected lookup in the legacy DNS resolver.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> > ---
> >  fs/nfs/dns_resolve.c | 15 ++++++++++++---
> >  1 file changed, 12 insertions(+), 3 deletions(-)
> > 
> > diff --git a/fs/nfs/dns_resolve.c b/fs/nfs/dns_resolve.c
> > index 060c658eab66..e93a5dc07c8c 100644
> > --- a/fs/nfs/dns_resolve.c
> > +++ b/fs/nfs/dns_resolve.c
> > @@ -65,6 +65,7 @@ struct nfs_dns_ent {
> >  
> >  	struct sockaddr_storage addr;
> >  	size_t addrlen;
> > +	struct rcu_head rcu_head;
> >  };
> >  
> >  
> > @@ -101,15 +102,23 @@ static void nfs_dns_ent_init(struct
> > cache_head *cnew,
> >  	}
> >  }
> >  
> > -static void nfs_dns_ent_put(struct kref *ref)
> > +static void nfs_dns_ent_free_rcu(struct rcu_head *head)
> >  {
> >  	struct nfs_dns_ent *item;
> >  
> > -	item = container_of(ref, struct nfs_dns_ent, h.ref);
> > +	item = container_of(head, struct nfs_dns_ent, rcu_head);
> >  	kfree(item->hostname);
> >  	kfree(item);
> >  }
> >  
> > +static void nfs_dns_ent_put(struct kref *ref)
> > +{
> > +	struct nfs_dns_ent *item;
> > +
> > +	item = container_of(ref, struct nfs_dns_ent, h.ref);
> > +	call_rcu(item, nfs_dns_ent_free_rcu);
> > +}
> > +
> >  static struct cache_head *nfs_dns_ent_alloc(void)
> >  {
> >  	struct nfs_dns_ent *item = kmalloc(sizeof(*item), GFP_KERNEL);
> > @@ -195,7 +204,7 @@ static struct nfs_dns_ent
> > *nfs_dns_lookup(struct cache_detail *cd,
> >  {
> >  	struct cache_head *ch;
> >  
> > -	ch = sunrpc_cache_lookup(cd,
> > +	ch = sunrpc_cache_lookup_rcu(cd,
> >  			&key->h,
> >  			nfs_dns_hash(key));
> >  	if (!ch)
> > -- 
> > 2.17.1
