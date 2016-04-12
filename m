Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:44102 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756097AbcDLOt6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2016 10:49:58 -0400
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 05/18] xprtrdma: Avoid using Write list for small NFS READ requests
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20160412141533.GA16218@infradead.org>
Date: Tue, 12 Apr 2016 10:49:24 -0400
Cc: Steve Wise <swise@opengridcomputing.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <06326E24-7170-4D09-A841-08ED31D143FF@oracle.com>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net> <20160411201050.20531.53651.stgit@manet.1015granger.net> <033901d19431$b3725d20$1a571760$@opengridcomputing.com> <65CBC59F-3005-44FE-8C70-9DDBC8507C9E@oracle.com> <20160412141533.GA16218@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Apr 12, 2016, at 10:15 AM, Christoph Hellwig <hch@infradead.org> wrote:
> 
> On Mon, Apr 11, 2016 at 04:38:44PM -0400, Chuck Lever wrote:
>> No, pre-4.2 Linux servers have a bug that can be fixed by
>> applying the above commit, which shouldn't be difficult to
>> backport.
>> 
>> Clients have always been allowed to send NFS READ this way.
> 
> But the clients might be out in a the wild.  I think we'll need at
> least a mount option to work around them.

Huh?

I'm talking about non-Linux clients. RFC 5666 allows
this behavior, it always has. The Linux server before
9d11b51ce7c1 is broken, full stop.

Our policy is that we do not work around broken NFS
servers on our client. The exception is existing bugs
in the Linux server, where we may work around them
temporarily until an upstream fix is available. The
client change is held off for one or two kernel
releases after the server is fixed.

I've made several changes like this already over the
past two years, and I fail to see why this one is
any different.

In addition, there is always NFS/TCP on IPoIB to fall
back on.

Can you explain your concern more fully?

--
Chuck Lever



