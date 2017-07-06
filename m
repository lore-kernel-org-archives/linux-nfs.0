Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50366 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751861AbdGFOCV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Jul 2017 10:02:21 -0400
Date: Thu, 6 Jul 2017 10:02:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1] sunrpc: Allocate up to RPCSVC_MAXPAGES per svc_rqst
Message-ID: <20170706140216.GB29025@fieldses.org>
References: <20170630160258.11995.10205.stgit@klimt.1015granger.net>
 <20170630201653.GD14868@fieldses.org>
 <222F5E88-CC11-418B-B9FF-1EF10DE60BEB@oracle.com>
 <20170630204733.GE14868@fieldses.org>
 <794E47E1-E7D0-4B10-A5C7-0C5DF97F9DB9@oracle.com>
 <5E60EBFD-F5D6-4959-A590-34ACBDC95202@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5E60EBFD-F5D6-4959-A590-34ACBDC95202@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 05, 2017 at 10:36:17AM -0400, Chuck Lever wrote:
> I would like to get this resolved quickly so that my nfsd-rdma-for-4.13
> series can be included in v4.13.

It will be in 4.13.

> Is the v1 patch acceptable, or do we need a comment here? If a comment
> is necessary, please provide the text you want to see.

It's fine, we can do more later.

The holdup is I'm still confused about the non-RDMA case: it looks to me
like we're not reserving quite enough for an unaligned maximum-length
read, but a pynfs test doesn't seem to be hitting any problem, so I
think I'm misunderstanding that case....

--b.
