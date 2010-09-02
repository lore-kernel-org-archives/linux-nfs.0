Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36853 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753411Ab0IBBcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Sep 2010 21:32:35 -0400
Date: Wed, 1 Sep 2010 21:32:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Neil Brown <neilb@suse.de>
Cc: Jeff Layton <jlayton@redhat.com>, steved@redhat.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet (try #2)
Message-ID: <20100902013202.GA22010@fieldses.org>
References: <1283283160-30024-1-git-send-email-jlayton@redhat.com>
 <20100901204818.GA10507@fieldses.org>
 <20100901165605.41f4978d@tlielax.poochiereds.net>
 <20100902073156.577757b5@notabene>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100902073156.577757b5@notabene>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 02, 2010 at 07:31:56AM +1000, Neil Brown wrote:
>  BTW, the 'new' cache has was added during 2.5 - definitely before Jan 2003.
>  So the old stuff really is quite old now.

Aren't a lot of the home-NAS-box-hackers stuck on 2.4 kernels?  (Thanks
to proprietary drivers.)

I suppose it's a small niche, and they probably don't need the latest
nfs-utils.

--b.
