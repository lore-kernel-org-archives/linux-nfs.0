Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52037 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756217Ab2ASWbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Jan 2012 17:31:23 -0500
Date: Thu, 19 Jan 2012 17:31:18 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH v2 2/5] SUNRPC: create unix gid cache per network
 namespace
Message-ID: <20120119223118.GA5177@fieldses.org>
References: <20120119173823.23767.91876.stgit@localhost6.localdomain6>
 <20120119174229.23767.23.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120119174229.23767.23.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 19, 2012 at 09:42:29PM +0400, Stanislav Kinsbursky wrote:
> v2:
> 1) fixed silly usage of template cache as a real one (this code left from
> static global cache for all)

Looks good, thanks.

--b.
