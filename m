Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16937 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751815Ab2ATOjU convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jan 2012 09:39:20 -0500
Message-ID: <1327070356.23030.0.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/2] SUNRPC: make /proc helpers network-namespace-aware
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "bfields@fieldses.org" <bfields@fieldses.org>
Cc: Stanislav Kinsbursky <skinsbursky@parallels.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Date: Fri, 20 Jan 2012 09:39:16 -0500
In-Reply-To: <20120120143047.GB9877@fieldses.org>
References: <20111206123748.15702.93290.stgit@localhost6.localdomain6>
	 <4F19512F.1000903@parallels.com> <20120120143047.GB9877@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2012-01-20 at 09:30 -0500, bfields@fieldses.org wrote: 
> On Fri, Jan 20, 2012 at 03:34:07PM +0400, Stanislav Kinsbursky wrote:
> > Excuse me, Trond, Bruce, but what about this patch set?
> > It is not included in Trond's "devel" branch.
> > Maybe they are in your repo, Bruce?
> 
> Everything that I had from you is in -rc1 now.
> 
> --b.

I can carry these patches if you like. They don't seem to conflict with
anything already in my repository.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

