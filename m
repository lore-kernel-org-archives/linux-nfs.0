Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:49181 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964923AbcDLOPf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Apr 2016 10:15:35 -0400
Date: Tue, 12 Apr 2016 07:15:33 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Steve Wise <swise@opengridcomputing.com>, linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 05/18] xprtrdma: Avoid using Write list for small NFS
 READ requests
Message-ID: <20160412141533.GA16218@infradead.org>
References: <20160411200323.20531.8893.stgit@manet.1015granger.net>
 <20160411201050.20531.53651.stgit@manet.1015granger.net>
 <033901d19431$b3725d20$1a571760$@opengridcomputing.com>
 <65CBC59F-3005-44FE-8C70-9DDBC8507C9E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <65CBC59F-3005-44FE-8C70-9DDBC8507C9E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 11, 2016 at 04:38:44PM -0400, Chuck Lever wrote:
> No, pre-4.2 Linux servers have a bug that can be fixed by
> applying the above commit, which shouldn't be difficult to
> backport.
> 
> Clients have always been allowed to send NFS READ this way.

But the clients might be out in a the wild.  I think we'll need at
least a mount option to work around them.
