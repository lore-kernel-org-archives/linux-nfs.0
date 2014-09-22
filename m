Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40205 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752887AbaIVUVF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 16:21:05 -0400
Date: Mon, 22 Sep 2014 16:21:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Steve Dickson <SteveD@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Subject: Re: [PATCH 2/2] rpc.svcgssd: the build of rpc.svcgssd is off by
 default
Message-ID: <20140922202104.GG26763@fieldses.org>
References: <1411413608-16462-1-git-send-email-steved@redhat.com>
 <1411413608-16462-3-git-send-email-steved@redhat.com>
 <20140922194352.GF26763@fieldses.org>
 <54207D75.1080400@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <54207D75.1080400@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 22, 2014 at 03:50:13PM -0400, Steve Dickson wrote:
> 
> 
> On 09/22/2014 03:43 PM, J. Bruce Fields wrote:
> > On Mon, Sep 22, 2014 at 03:20:08PM -0400, Steve Dickson wrote:
> >> Due to the fact the gssproxy is not managing the
> >> GASSAPI credentials, on the server, there is
> >> no need to build/install rpc.svcgssd.
> >>
> >> To re-enable the build use the --enable-svcgss
> >> configure flag
> > 
> > Since we're not running rpc.svcgssd in those cases where it's not
> > needed, we should keep --enable-svcgss as the default for now.  It's an
> > easy way to keep old kernels working.
> Either way is fine with me... As long as there is a switch but 
> I have to wonder out loud... 
> 
> How often is it the case where the the latest nfs-utils is being 
> run on a a kernel that is over two years old...

Anyone trying to do a git-bisect to identify a kernel regression.

(You upgrade your NFS server from F19 to F20 and your network adapter
stops working.  You suspect a driver bug, so you try installing the
kernel from F19.)

And it's closer to one year than two.  When gss-proxy's a little older
I'll agree.

--b.
