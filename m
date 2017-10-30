Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:48782 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932273AbdJ3PtC (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Oct 2017 11:49:02 -0400
Received: by mail-qk0-f194.google.com with SMTP id d67so16689666qkg.5
        for <linux-nfs@vger.kernel.org>; Mon, 30 Oct 2017 08:49:02 -0700 (PDT)
Message-ID: <1509378540.5412.31.camel@redhat.com>
Subject: Re: [PATCH] nlm_shutdown_hosts_net() cleanup
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Vasily Averin <vvs@virtuozzo.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Mon, 30 Oct 2017 11:49:00 -0400
In-Reply-To: <20171030144943.GG14098@fieldses.org>
References: <1d1a25d8-a34b-5175-bb6a-9549041c11f4@virtuozzo.com>
         <20171030144943.GG14098@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2017-10-30 at 10:49 -0400, J. Bruce Fields wrote:
> On Mon, Oct 30, 2017 at 04:47:58PM +0300, Vasily Averin wrote:
> > nlm_complain_hosts() walk through nlm_server_hosts hlist that should be
> > protected by nlm_host_mutex.
> 
> I haven't looked at the NLM locking in ages.  Do we know who else might
> actually be accessing this list concurrently?
> 
> --b.
> 

Since this is a per-net-ns shutdown, I suppose you could have concurrent
 rpc.nfsd's shutting down different namespaces. Holding the mutex for
longer looks like a reasonable fix.

That said...I don't think lockd was ever properly namespace-ified. YMMV
here.

> > 
> > Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
> > ---
> >  fs/lockd/host.c | 3 +--
> >  1 file changed, 1 insertion(+), 2 deletions(-)
> > 
> > diff --git a/fs/lockd/host.c b/fs/lockd/host.c
> > index d716c99..089c1d7 100644
> > --- a/fs/lockd/host.c
> > +++ b/fs/lockd/host.c
> > @@ -617,9 +617,8 @@ nlm_shutdown_hosts_net(struct net *net)
> >  
> >  	/* Then, perform a garbage collection pass */
> >  	nlm_gc_hosts(net);
> > -	mutex_unlock(&nlm_host_mutex);
> > -
> >  	nlm_complain_hosts(net);
> > +	mutex_unlock(&nlm_host_mutex);
> >  }
> >  
> >  /*
> > -- 
> > 2.7.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

You can add:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
