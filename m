Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:48274 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754405AbaGKStb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jul 2014 14:49:31 -0400
Date: Fri, 11 Jul 2014 14:49:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Wise <swise@opengridcomputing.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-rdma <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH 2/2] svcrdma: Remove extra writeargs sanity check for
 NFSv2/3
Message-ID: <20140711184929.GC9775@fieldses.org>
References: <20140710174225.3734.44692.stgit@klimt.1015granger.net>
 <20140710174435.3734.69638.stgit@klimt.1015granger.net>
 <20140710181944.GB26561@fieldses.org>
 <3BA364F8-E5ED-45A1-8662-E5F91AA7AF0A@oracle.com>
 <20140710184948.GC26561@fieldses.org>
 <B89AB7AC-32E1-4944-9287-73958A569A8E@oracle.com>
 <20140710194349.GD26561@fieldses.org>
 <F8AD3320-C653-4713-965F-FE52FF0D49CA@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F8AD3320-C653-4713-965F-FE52FF0D49CA@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 04:43:54PM -0400, Chuck Lever wrote:
> I think the sanity check you pointed out is strictly satisfied by
> testing against the unaligned number of bytes. Is there a strong
> reason to do the extra math for that check during each WRITE?

I can't think of any good reason why the check should be against the
rounded-up length.

So my worry was just a more general "uh-oh, a non-multiple-of-4-length
is pretty weird, future me may not remember that's a possibility."

--b.
