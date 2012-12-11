Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:38003 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752781Ab2LKO7A (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2012 09:59:00 -0500
Date: Tue, 11 Dec 2012 14:58:58 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        devel@openvz.org
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
Message-ID: <20121211145858.GI4939@ZenIV.linux.org.uk>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
 <20121206153447.30693.54128.stgit@localhost.localdomain>
 <20121210202842.GB17350@fieldses.org>
 <50C73C60.8060405@parallels.com>
 <50C73F58.1080005@parallels.com>
 <20121211145621.GA3336@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121211145621.GA3336@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2012 at 09:56:21AM -0500, J. Bruce Fields wrote:

> That looks simpler, but I still don't understand why we need it.
> 
> I'm confused about how d_path works; I would have thought that
> filesystem namespaces would have their own vfsmount trees and hence that
> the (vfsmount, dentry) would be enough to specify the path.  Is the root
> argument for the case of chroot?  Do we care about that?

__d_path() is relative pathname from here to there.  Whether (and what for)
is it wanted in case of nfsd patches is a separate question...

> Also, svc_export_request is called from mountd's read of
> /proc/net/rpc/nfsd.export/channel.  If mountd's root is wrong, then
> nothing's going to work anyway.
