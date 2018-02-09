Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42554 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750942AbeBISbN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 9 Feb 2018 13:31:13 -0500
Date: Fri, 9 Feb 2018 13:31:12 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "luxy.fnst@cn.fujitsu.com" <luxy.fnst@cn.fujitsu.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Questions about pynfs:testLargeData-WRT5
Message-ID: <20180209183112.GC30030@parsley.fieldses.org>
References: <918ad604-2365-b612-56a2-8d88a29f77ff@cn.fujitsu.com>
 <20180209144942.GB30030@parsley.fieldses.org>
 <1518188679.8999.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1518188679.8999.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Feb 09, 2018 at 03:04:42PM +0000, Trond Myklebust wrote:
> For NFSv4, you would have the option of returning NFS4ERR_RESOURCE or
> possibly NFS4ERR_INVAL (personally, I'd prefer the latter, since
> NFS4ERR_RESOURCE is too wooly).
> 
> For NFSv4.1 or above, you probably have a choice of NFS4ERR_REQ_TOO_BIG
> (if the size is greater than ca_maxrequestsize) or NFS4ERR_INVAL.

I think this sort of problem is typically found early in the rpc code
(probably the check against sv_max_mesg in
net/sunrpc/svcsock.c:svc_tcp_recv_record()).  It drops the connection.
I'm not sure why.

Returning an NFS-level error does sound friendlier.  I guess I'd do that
by throwing away the rest of the request data and setting a flag on the
svc_rqst saying "this request was too long, don't trust the data" and
then making NFS check for that flag somewhere early on.

The only case I can recall seeing this in practice is when the limits
change across reboots.  Which is something to avoid.  But the choice of
failure mode might make this more or less easy to diagnose or recover
from....

--b.
