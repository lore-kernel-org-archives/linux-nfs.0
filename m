Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:46135 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752501AbbEKHQe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 May 2015 03:16:34 -0400
Date: Mon, 11 May 2015 00:16:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Clean up bc_send()
Message-ID: <20150511071634.GA31452@infradead.org>
References: <20150507232028.2092.78506.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150507232028.2092.78506.stgit@manet.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 07, 2015 at 07:20:28PM -0400, Chuck Lever wrote:
> Clean up: Merge bc_svc.c into backchannel_rqst.c, and adopt a more
> consistent naming scheme for bc_send().

Seems like a bit of an odd choise as none of the callchain bc_send
is in really touches backchannel_rqst.c.

How about just killing bc_send() and open coding it in bc_svc_process?

And while we're at it - bc_svc_process seems totally generic RPC
code that might want to be moved to net/sunrpc and converted to
a workqueue.
