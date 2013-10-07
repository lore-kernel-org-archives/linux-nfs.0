Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59093 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614Ab3JGPUE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Oct 2013 11:20:04 -0400
Date: Mon, 7 Oct 2013 11:20:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, jlayton@redhat.com,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/13] Implement NFSv4 delegations, take 12
Message-ID: <20131007152002.GF18051@fieldses.org>
References: <1379623837-30798-1-git-send-email-bfields@redhat.com>
 <20131002135423.GA14808@fieldses.org>
 <20131002201627.GI14808@fieldses.org>
 <20131003194136.GB1577@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131003194136.GB1577@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 03:41:36PM -0400, J. Bruce Fields wrote:
> On Wed, Oct 02, 2013 at 04:16:27PM -0400, J. Bruce Fields wrote:
> > On Wed, Oct 02, 2013 at 09:54:23AM -0400, bfields wrote:
> > > On Thu, Sep 19, 2013 at 04:50:24PM -0400, J. Bruce Fields wrote:
> > > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > > 
> > > > Al, if you don't see any objections, could you queue this up for 3.13?
> > > 
> > > Note: if it's more convenient, the identical patches are also available
> > > from
> > > 
> > > 	git://linux-nfs.org/~bfields/linux.git for-viro
> > 
> > But kbuild points out I forgot to fix up some calls in ecryptfs.
> > 
> > I'll push out another version with the below folded in, once I've
> > checked whether there's anything else I touched that got turned off in
> > my test .config....
> 
> Done; the change below is now folded into the commits on the for-viro
> branch at the url above.

And kbuild also pointed out a typo in the !CONFIG_FILE_LOCKING case,
also now fixed in the git tree above.

I've also added two previously posted sets of patches to that branch for
you to cherry-pick as you'd like:

- miscellaneous DCACHE_DISCONECTED fixes
  http://mid.gmane.org/<1378579561-26868-2-git-send-email-bfields@redhat.com>
- problem looking up filehandles with 64-bit inodes
  http://mid.gmane.org/<1380749295-20854-1-git-send-email-bfields@redhat.com>

--b.
