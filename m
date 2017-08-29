Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59240 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751272AbdH2Vk2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 29 Aug 2017 17:40:28 -0400
Date: Tue, 29 Aug 2017 17:40:26 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170829214026.GI8822@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-3-git-send-email-bfields@redhat.com>
 <878ti4i9pi.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <878ti4i9pi.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 28, 2017 at 02:43:05PM +1000, NeilBrown wrote:
> On Fri, Aug 25 2017, J. Bruce Fields wrote:
> 
> > From: "J. Bruce Fields" <bfields@redhat.com>
> >
> > Pass around a new struct deleg_break_ctl instead of pointers to inode
> > pointers; in a future patch I want to use this to pass a little more
> > information from the nfs server to the lease code.
> 
> The information you are passing from the nfs server to the lease code is
> largely ignored by the lease code and is passed back to the nfs server,
> in the sm_breaker_owns_lease call back.
> 
> If try_break_deleg() passed the 'delegated_inode' pointer though to
> __break_lease(), it could pass it through any_leases_conflict() and
> leases_conflict() to the lm_breaker_owns_lease() callback.
> Then container_of() could be used to access whatever other data nfsd had
> stashed near the inode.  The common code wouldn't need to know any of
> the details.

The new information that we need is some notion of "who" (really, which
NFSv4 client) is doing the operation (unlink, whatever) that breaks the
lease.  We can't get that information from an inode pointer.

I may just not understand your suggestion.

--b.
