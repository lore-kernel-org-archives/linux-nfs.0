Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:34967 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935093AbcHaOj4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Aug 2016 10:39:56 -0400
Date: Wed, 31 Aug 2016 10:39:53 -0400
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20160831143953.GV12660@htj.duckdns.org>
References: <20160830205348.GA31915@Karyakshetra>
 <1472591243.4095.7.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1472591243.4095.7.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Tue, Aug 30, 2016 at 05:07:23PM -0400, Jeff Layton wrote:
> Hah! I have almost exactly the same patch in my tree. I've only not
> sent it because I haven't had the chance to test it well.
> 
> The only difference in mine is that it passes in WQ_UNBOUND. ISTM that
> we don't really need a bound workqueue here since we only use this to
> kick off callbacks to the client. I doubt we'd get much out of strictly
> maintaining cache locality here, and we're better off just sending it
> the callback as quickly as possible.

We recently broke strong locality guarantee for users which don't use
queue_work_on(), so the default locality is now only for optimization
instead of correctness anyway.  Unless there are actual benefits to
using WQ_UNBOUND, I think in general it's better to stick with as
little attributes as possible so that we have more maneuvering room
down the line.  But, yeah, if this can impact performance in subtle
ways, it could be best to just do an identity conversion at least for
now.

Thanks.

-- 
tejun
