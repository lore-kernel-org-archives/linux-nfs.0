Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58392 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758609Ab2DYVCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 17:02:52 -0400
Date: Wed, 25 Apr 2012 17:02:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "Trond.Myklebust@netapp.com" <Trond.Myklebust@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: [PATCH 0/3] SUNRPC: three bugfixes for PipeFS event handling
Message-ID: <20120425210250.GA3251@fieldses.org>
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
 <20120425182409.GE751@fieldses.org>
 <4F98659B.6060409@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F98659B.6060409@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 26, 2012 at 12:59:07AM +0400, Stanislav Kinsbursky wrote:
> 25.04.2012 22:24, J. Bruce Fields написал:
> >On Fri, Apr 20, 2012 at 06:18:59PM +0400, Stanislav Kinsbursky wrote:
> >>These bugfixes were caught (or noticed) due to the following simple script:
> >I'm assuming Trond should take these (possibly for 3.4?).
> 
> I think so.
> But would be great if you'll take them as well (since I'm mostly
> working with your tree).
> Of course, only if its not a big deal for you.
> But if there will be any conflicts - then don't worry. I can just
> keep these patches in my repo.

If it's a bugfix that should go to 3.4, then best might be for Trond to
get it merged, then I'll pull it into my tree after that.

Or I'm happy to do it some other way if someone prefers.

--b.
