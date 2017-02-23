Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from quartz.orcorp.ca ([184.70.90.242]:53252 "EHLO quartz.orcorp.ca"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751165AbdBWU1U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 23 Feb 2017 15:27:20 -0500
Date: Thu, 23 Feb 2017 13:26:09 -0700
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Tom Talpey <tom@talpey.com>, Jeff Layton <jlayton@redhat.com>,
        trond.myklebust@primarydata.com, schumaker.anna@gmail.com,
        linux-nfs@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>,
        linux-rdma@vger.kernel.org
Subject: Re: [PATCH 1/4] sunrpc: flag transports as using IETF approved
 congestion control protocols
Message-ID: <20170223202609.GC26301@obsidianresearch.com>
References: <20170223170337.10686-1-jlayton@redhat.com>
 <20170223170337.10686-2-jlayton@redhat.com>
 <2152dfdf-f847-2511-1600-6499b6ea9708@talpey.com>
 <1487880034.3448.8.camel@redhat.com>
 <65056db6-f30a-c44d-b01c-b549887c4895@talpey.com>
 <20170223201109.GC11882@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170223201109.GC11882@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 23, 2017 at 03:11:09PM -0500, J. Bruce Fields wrote:

> (And if we really shouldn't be doing NFSv4 over some RDMA transports--is
> it worth supporting them at all, if the only support we can get is
> NFSv3-only?)

This seems like a strange comment - NFSv4 should be supported on all
RDMA transports, surely?

Largely RDMA lives in its own congestion management world. If a site
is running RDMA they have done something to mitigate interactions with
TCP style congestion control on the same wire.

Jason
