Return-Path: <jlayton@redhat.com>
Message-ID: <1477424971.2654.14.camel@redhat.com>
Subject: Re: [PATCH 3/5] NFSv4: change nfs4_select_rw_stateid to take a
 lock_context inplace of lock_owner
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.com>, Anna Schumaker <Anna.Schumaker@netapp.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Benjamin Coddington <bcodding@redhat.com>,
        Linux NFS Mailing List
 <linux-nfs@vger.kernel.org>,
        Bruce Fields <bfields@fieldses.org>,
        Chuck
 Lever <chuck.lever@oracle.com>
Date: Tue, 25 Oct 2016 15:49:31 -0400
In-Reply-To: <87bmyo28tb.fsf@notabene.neil.brown.name>
References: <147623977637.19592.12766016823334433969.stgit@noble>
	 <147623995856.19592.8461168656619949864.stgit@noble>
	 <1476275602.2541.20.camel@redhat.com>
	 <3006e49d-0e09-96c1-74c6-9ffe789ce0e5@Netapp.com>
	 <87bmyo28tb.fsf@notabene.neil.brown.name>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-10-13 at 15:04 +1100, NeilBrown wrote:
> On Thu, Oct 13 2016, Anna Schumaker wrote:
> > 
> > > 
> > > 
> > > Also, as a side note: There were some changes around the NFS file
> > > locking code that went into the CB_NOTIFY_LOCK patches. Those are in
> > > linux-next now, and I _think_ Anna is going to merge them for v4.9. I
> > > don't see any obvious conflicts here, but you may want to ensure that
> > > you're basing this on top of linux-next to minimize them.
> > 
> > Yep, they'll be in 4.9.  Updating against those changes wouldn't hurt :)
> 
> Ok....
> I note that
>   git://git.linux-nfs.org/projects/anna/linux-nfs.git#linux-next
> 
> isn't in
>   git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
> 
> Should it be?
> 
> NeilBrown

Yes, it seems like that should be going into -next.

Anna, do you and Trond have something worked out where the patches in
your pull requests are going into -next through Trond's tree?
-- 
Jeff Layton <jlayton@redhat.com>
