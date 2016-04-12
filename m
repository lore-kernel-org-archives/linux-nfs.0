Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:36958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932994AbcDLUFD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Apr 2016 16:05:03 -0400
Date: Tue, 12 Apr 2016 16:05:01 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: server commit commit 9d11b51ce7c1
Message-ID: <20160412200501.GA22336@fieldses.org>
References: <6023A91E-B305-403D-8982-BF29265AEC2B@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6023A91E-B305-403D-8982-BF29265AEC2B@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 12, 2016 at 03:32:18PM -0400, Chuck Lever wrote:
> commit 9d11b51ce7c150a69e761e30518f294fc73d55ff
> Author:     Chuck Lever <chuck.lever@oracle.com>
> AuthorDate: Thu Jul 9 16:45:18 2015 -0400
> Commit:     J. Bruce Fields <bfields@redhat.com>
> CommitDate: Mon Jul 20 14:58:47 2015 -0400
> 
>     svcrdma: Fix send_reply() scatter/gather set-up
> 
> be applied to stable kernels? It is a small patch
> that fixes a bug that has been in the NFS/RDMA
> code since 2010.

Of course, anyone can mail a patch to stable@vger.kernel.org with a cc:
to me, if you notice I overlooked something.

--b.
