Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32826 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754013AbcHSOwM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 10:52:12 -0400
Date: Fri, 19 Aug 2016 10:51:43 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: WARN_ON added to rpc_create()
Message-ID: <20160819145143.GB2956@parsley.fieldses.org>
References: <42D0C152-58F9-4467-B86D-2A7A25544CE4@oracle.com>
 <20160803174724.GA5993@fieldses.org>
 <5E7D6A55-B7F3-411D-A74B-E8BCE04BCF02@oracle.com>
 <20F73E14-8CEC-4ED1-8A04-203343839860@oracle.com>
 <20160818215642.GB25052@fieldses.org>
 <E884FAC0-09C6-467D-8A90-AC1AEC72ED81@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E884FAC0-09C6-467D-8A90-AC1AEC72ED81@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 18, 2016 at 05:59:12PM -0400, Chuck Lever wrote:
> Thanks for checking.
> 
> I've tracked the misbehavior down to a DMA mapping mismatch. It's
> not related to the backchannel at all. I'm putting together a fix
> right now.
> 
> But I would like to use NFSv4.1/RDMA without that warning firing.
> Any reason to keep it (in either place) ?

I thought you said the BC_TCP->BC change fixed it?  If so, we should
just do that.

--b.
