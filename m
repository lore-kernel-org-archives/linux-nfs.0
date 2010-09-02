Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60372 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab0IBOZh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 10:25:37 -0400
Date: Thu, 2 Sep 2010 10:25:01 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Jeff Layton <jlayton@redhat.com>, Steve Dickson <SteveD@redhat.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100902142501.GD13117@fieldses.org>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
 <20100901204818.GA10507@fieldses.org>
 <20100901165605.41f4978d@tlielax.poochiereds.net>
 <20100902073156.577757b5@notabene>
 <4C7F8A80.3050705@RedHat.com>
 <20100902075518.58a1daf3@corrin.poochiereds.net>
 <8310F0E2-777C-4F17-B133-766FBAD30E19@oracle.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8310F0E2-777C-4F17-B133-766FBAD30E19@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 02, 2010 at 10:04:19AM -0400, Chuck Lever wrote:
> Neil's patches are now in upstream nfs-utils.  You can disable all of
> the network listeners with command line options on mountd.
> 
> It's been said that people complain that they don't like running
> rpc.mountd on NFSv4-only servers.  I'm not sure why that's a problem
> we have to fix with a code change.  Better documentation, better
> automatic configuration detection in the NFS start-up scripts, or
> simply renaming rpc.mountd could solve this issue without the need for
> rip-and-replace of well-tested code.

Yeah, I've suggested a separate upcall-handling daemon before, but agree
that for now we should leave well enough alone.

--b.
