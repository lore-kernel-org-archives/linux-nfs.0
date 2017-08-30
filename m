Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42262 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751333AbdH3RJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 30 Aug 2017 13:09:41 -0400
Date: Wed, 30 Aug 2017 13:09:39 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170830170938.GC24373@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-3-git-send-email-bfields@redhat.com>
 <878ti4i9pi.fsf@notabene.neil.brown.name>
 <20170829214026.GI8822@parsley.fieldses.org>
 <8760d5hol3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <8760d5hol3.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 30, 2017 at 10:43:52AM +1000, NeilBrown wrote:
> On Tue, Aug 29 2017, J. Bruce Fields wrote:
> 
> > On Mon, Aug 28, 2017 at 02:43:05PM +1000, NeilBrown wrote:
> >> On Fri, Aug 25 2017, J. Bruce Fields wrote:
> >> 
> >> > From: "J. Bruce Fields" <bfields@redhat.com>
> >> >
> >> > Pass around a new struct deleg_break_ctl instead of pointers to inode
> >> > pointers; in a future patch I want to use this to pass a little more
> >> > information from the nfs server to the lease code.
> >> 
> >> The information you are passing from the nfs server to the lease code is
> >> largely ignored by the lease code and is passed back to the nfs server,
> >> in the sm_breaker_owns_lease call back.
> >> 
> >> If try_break_deleg() passed the 'delegated_inode' pointer though to
> >> __break_lease(), it could pass it through any_leases_conflict() and
> >> leases_conflict() to the lm_breaker_owns_lease() callback.
> >> Then container_of() could be used to access whatever other data nfsd had
> >> stashed near the inode.  The common code wouldn't need to know any of
> >> the details.
> >
> > The new information that we need is some notion of "who" (really, which
> > NFSv4 client) is doing the operation (unlink, whatever) that breaks the
> > lease.  We can't get that information from an inode pointer.
> >
> > I may just not understand your suggestion.
> 
> Probably I was too terse.
> 
> I'm suggesting that nfsd have a local "struct deleg_break_ctl" (or
> whatever name you like) which contains a 'struct inode *delegated_inode'
> plus whatever else is useful to nfsd.
> Then nfsd/vfs.c, when it calls things like vfs_unlink(), passes
>  &dbc.delegated_inode
> (where 'struct deleg_break_ctl dbc').
> So the vfs codes doesn't know about 'struct deleg_break_ctl', it just
> knows about the 'struct inode ** inodep' like it does now, though with the
> understanding that "DELEG_NO_WAIT" in the **inodep means that same as
> inodep==NULL.
> 
> The vfs passes this same 'struct **inode' to lm_breaker_owns_lease() and
> the nfsd code uses
>    dbc = container_of(inodep, struct deleg_break_ctl, delegated_inode)
> to get the dbc, and it can use the other fields however it likes.

Oh, now I understand.  That's an interesting idea.  I don't *think* it
works on its own, because I don't think we've got a way in that case to
know whether the passed-down delegated inode came from nfsd (and thus is
contained in a deleg_break_ctl structure).  We get the
lm_breaker_owns_lease operation from the lease that's already set on the
inode, but we don't know who that breaking operation is coming from.

Maybe something alon those lines could be made to work.

> Then instead of the rather task-specific name "lm_breaker_owns_lease" we
> could have a more general name like "lm_lease_compatible" ... or
> something.  "lm_break_doesn't_see_this_lease_as_being_in_conflict" is a
> bit long, and contains "'".

Hah, yes.--b.
