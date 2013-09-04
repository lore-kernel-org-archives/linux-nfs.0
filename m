Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cobra.newdream.net ([66.33.216.30]:45969 "EHLO
	cobra.newdream.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934929Ab3IDPyf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Sep 2013 11:54:35 -0400
Date: Wed, 4 Sep 2013 08:54:34 -0700 (PDT)
From: Sage Weil <sage@inktank.com>
To: David Howells <dhowells@redhat.com>
cc: Milosz Tanski <milosz@adfin.com>, ceph-devel@vger.kernel.org,
        zheng.z.yan@intel.com, linux-cachefs@redhat.com,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCHv4 0/5] ceph: persistent caching with fscache
In-Reply-To: <17341.1378309753@warthog.procyon.org.uk>
Message-ID: <alpine.DEB.2.00.1309040851080.27503@cobra.newdream.net>
References: <alpine.DEB.2.00.1308212203320.1479@cobra.newdream.net> <cover.1375999914.git.milosz@adfin.com> <17341.1378309753@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi David!

On Wed, 4 Sep 2013, David Howells wrote:
> Sage Weil <sage@inktank.com> wrote:
> 
> > David, are the fscache patches here ready for the next merge window?  Do 
> > you have a preference for whose tree they go through?
> 
> There's only one problem - patch 1 needs to come _after_ patch 2 to avoid
> breaking git bisect.  Plus these patches 2 and 4 extend the fscache API
> without adjusting the documentation - but that can be added later.
> 
> And I think Milosz deserves a beer (or other poison of his choice;-) for
> finding a longstanding irritating bug.
> 
> I think AFS, CIFS, NFS and 9P all need patching too, but I can attend to that.
> 
> Should I take the patches through my tree?  Then I can make the adjustments.

Sure.  Do you want the Ceph patches as well, or just the fscache bits?  
I'll repost the latest version, as it's gotten several fixes squashed in.

Thanks!
sage
