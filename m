Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59228 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934808Ab3IDPtX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Sep 2013 11:49:23 -0400
From: David Howells <dhowells@redhat.com>
In-Reply-To: <alpine.DEB.2.00.1308212203320.1479@cobra.newdream.net>
References: <alpine.DEB.2.00.1308212203320.1479@cobra.newdream.net> <cover.1375999914.git.milosz@adfin.com>
To: Sage Weil <sage@inktank.com>
Cc: dhowells@redhat.com, Milosz Tanski <milosz@adfin.com>,
        ceph-devel@vger.kernel.org, zheng.z.yan@intel.com,
        linux-cachefs@redhat.com, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCHv4 0/5] ceph: persistent caching with fscache
Date: Wed, 04 Sep 2013 16:49:13 +0100
Message-ID: <17341.1378309753@warthog.procyon.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sage Weil <sage@inktank.com> wrote:

> David, are the fscache patches here ready for the next merge window?  Do 
> you have a preference for whose tree they go through?

There's only one problem - patch 1 needs to come _after_ patch 2 to avoid
breaking git bisect.  Plus these patches 2 and 4 extend the fscache API
without adjusting the documentation - but that can be added later.

And I think Milosz deserves a beer (or other poison of his choice;-) for
finding a longstanding irritating bug.

I think AFS, CIFS, NFS and 9P all need patching too, but I can attend to that.

Should I take the patches through my tree?  Then I can make the adjustments.

David
