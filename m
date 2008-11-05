From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/6] SLAB-ify nlm_host cache
Date: Wed, 05 Nov 2008 16:56:36 -0500
Message-ID: <1225922196.16857.60.camel@heimdal.trondhjem.org>
References: <20081105215042.16549.50065.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:34915 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753009AbYKEV4o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 16:56:44 -0500
In-Reply-To: <20081105215042.16549.50065.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2008-11-05 at 16:51 -0500, Chuck Lever wrote:
> Here's a set of patches to change the NLM host cache to use a slab.

OK, I'll bite. Why would we care about slabifying the NLM host cache?

