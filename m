Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40146 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750815AbdHaTFd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 Aug 2017 15:05:33 -0400
Date: Thu, 31 Aug 2017 15:05:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: Re: [PATCH 2/3] fs: hide another detail of delegation logic
Message-ID: <20170831190531.GA8223@parsley.fieldses.org>
References: <1503697958-6122-1-git-send-email-bfields@redhat.com>
 <1503697958-6122-3-git-send-email-bfields@redhat.com>
 <878ti4i9pi.fsf@notabene.neil.brown.name>
 <20170829214026.GI8822@parsley.fieldses.org>
 <8760d5hol3.fsf@notabene.neil.brown.name>
 <20170830170938.GC24373@parsley.fieldses.org>
 <87wp5kfxi3.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87wp5kfxi3.fsf@notabene.neil.brown.name>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 31, 2017 at 09:26:28AM +1000, NeilBrown wrote:
> On Wed, Aug 30 2017, J. Bruce Fields wrote:
> 
> > On Wed, Aug 30, 2017 at 10:43:52AM +1000, NeilBrown wrote:
> >> I'm suggesting that nfsd have a local "struct deleg_break_ctl" (or
> >> whatever name you like) which contains a 'struct inode *delegated_inode'
> >> plus whatever else is useful to nfsd.
> >> Then nfsd/vfs.c, when it calls things like vfs_unlink(), passes
> >>  &dbc.delegated_inode
> >> (where 'struct deleg_break_ctl dbc').
> >> So the vfs codes doesn't know about 'struct deleg_break_ctl', it just
> >> knows about the 'struct inode ** inodep' like it does now, though with the
> >> understanding that "DELEG_NO_WAIT" in the **inodep means that same as
> >> inodep==NULL.
> >> 
> >> The vfs passes this same 'struct **inode' to lm_breaker_owns_lease() and
> >> the nfsd code uses
> >>    dbc = container_of(inodep, struct deleg_break_ctl, delegated_inode)
> >> to get the dbc, and it can use the other fields however it likes.
> >
> > Oh, now I understand.  That's an interesting idea.  I don't *think* it
> > works on its own, because I don't think we've got a way in that case to
> > know whether the passed-down delegated inode came from nfsd (and thus is
> > contained in a deleg_break_ctl structure).  We get the
> > lm_breaker_owns_lease operation from the lease that's already set on the
> > inode, but we don't know who that breaking operation is coming from.
> 
> That is a perfectly valid criticism and one that, I think, applies
> equally to your original code.
> 
>  +static bool nfsd_breaker_owns_lease(void *who, struct file_lock *fl)
>  +{
>  +	struct svc_rqst *rqst = who;
> 
> How does nfsd know that 'who' is an svc_rqst??

Only nfsd fills in the "who" field of deleg_break_ctl.  But non-nfsd
users do need to pass a non-NULL delegated_inode.

> You can save your code by passing
>    nfsd4_client_from_rqst(rqst)
> 
> as the 'who', and then testing
>  +		if (dl->dl_stid.sc_client != who) {
> 
> in the loop in nfsd_breaker_owns_lease.  So the only action performed
> on the void* is an equality test.

Yes, that sounds more robust, thanks for the suggestion.

--b.
