Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43136 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751480AbcBVScM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Feb 2016 13:32:12 -0500
Date: Mon, 22 Feb 2016 13:32:11 -0500
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 01/10] svcrdma: Do not write xdr_buf::tail in a Write
 chunk
Message-ID: <20160222183211.GA22270@fieldses.org>
References: <20160218173840.12825.26769.stgit@klimt.1015granger.net>
 <20160218174353.12825.14732.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160218174353.12825.14732.stgit@klimt.1015granger.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 18, 2016 at 12:43:53PM -0500, Chuck Lever wrote:
> The fix is to send only the contents of the xdr_buf's page list in
> a Write chunk.

This isn't quite right either.  A large-enough non-readlike reply will
use the page list if that's the only way to fit the reply.

You might be able to hit such cases, for example, using nfs4_getfacl on
a file with a sufficiently large ACL.

--b.
