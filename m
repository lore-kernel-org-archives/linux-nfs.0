Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:35957 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932390AbcKIPRL (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Nov 2016 10:17:11 -0500
Received: by mail-qk0-f195.google.com with SMTP id h201so17285940qke.3
        for <linux-nfs@vger.kernel.org>; Wed, 09 Nov 2016 07:17:11 -0800 (PST)
Message-ID: <1478704627.7930.13.camel@poochiereds.net>
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
From: Jeff Layton <jlayton@poochiereds.net>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "tj@kernel.org" <tj@kernel.org>
Cc: "bhaktipriya96@gmail.com" <bhaktipriya96@gmail.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 09 Nov 2016 10:17:07 -0500
In-Reply-To: <1478704129.15658.1.camel@primarydata.com>
References: <20160830205348.GA31915@Karyakshetra>
         <20161108213911.GA27681@fieldses.org>
         <20161108225221.GB6460@htj.duckdns.org>
         <20161109012725.GA29930@fieldses.org>
         <1478697488.7930.7.camel@poochiereds.net>
         <1478704129.15658.1.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-11-09 at 15:08 +0000, Trond Myklebust wrote:
> On Wed, 2016-11-09 at 08:18 -0500, Jeff Layton wrote:
> > 
> > On Tue, 2016-11-08 at 20:27 -0500, J. Bruce Fields wrote:
> > > 
> > > 
> > > On Tue, Nov 08, 2016 at 05:52:21PM -0500, Tejun Heo wrote:
> > > > 
> > > > 
> > > > 
> > > > Hello, Bruce.
> > > > 
> > > > On Tue, Nov 08, 2016 at 04:39:11PM -0500, J. Bruce Fields wrote:
> > > > > 
> > > > > 
> > > > > 
> > > > > Apologies, just cleaning out old mail and finding some I should
> > > > > have
> > > > > responded to long ago:
> > > > > 
> > > > > On Wed, Aug 31, 2016 at 02:23:48AM +0530, Bhaktipriya Shridhar
> > > > > wrote:
> > > > > > 
> > > > > > 
> > > > > > 
> > > > > > The workqueue "callback_wq" queues a single work item &cb-
> > > > > > > 
> > > > > > > cb_work per
> > > > > > nfsd4_callback instance and thus, it doesn't require
> > > > > > execution ordering.
> > > > > 
> > > > > What's "execution ordering"?
> > > > > 
> > 
> > AIUI, it means that jobs are always run in the order queued and are
> > serialized.
> > 
> > > 
> > > 
> > > > 
> > > > 
> > > > > 
> > > > > 
> > > > > We definitely do depend on the fact that at most one of these
> > > > > is running
> > > > > at a time.
> > > > 
> > 
> > We do?
> > 
> > > 
> > > 
> > > > 
> > > > 
> > > > If there can be multiple cb's and thus cb->cb_work's per
> > > > callback_wq,
> > > > it'd need explicit ordering.  Is that the case?
> > > 
> > 
> > These are basically client RPC tasks, and the cb_work just handles
> > the
> > submission into the client RPC state machine. Just because we're
> > running
> > several callbacks at the same time doesn't mean that they need to be
> > strictly ordered. The client state machine can certainly handle
> > running
> > these in parallel.
> > 
> > > 
> > > 
> > > Yes, there can be multiple cb_work's.
> > > 
> > 
> > Yes, but each is effectively a separate work unit. I see no reason
> > why
> > we'd need to order them at all.
> > 
> 
> There needs to be serialisation at the session level (i.e. the
> callbacks have to respect the slot limits set by the client) however
> there shouldn’t be a need for serialisation at the RPC level.
> 
> Cheers
>   Trond

Yes, that all happens in nfsd4_cb_prepare, which is the rpc_call_prepare
operation for the callback. That gets run by the rpc state machine in
the context of the rpciod workqueues. None of that happens in the
context of the cb_work here.

If you have a look at nfsd4_run_cb_work, you can see that it just does a
cb_ops->prepare and then submits it to the client rpc engine with
rpc_call_async. None of that should require singlethreaded workqueue
semantics.

-- 
Jeff Layton <jlayton@poochiereds.net>
