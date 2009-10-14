Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:47759 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738AbZJNRNs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Oct 2009 13:13:48 -0400
Subject: Re: [NFS] NFS/krb and batch jobs - doable?
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: raini@rainiday.com
Cc: Jeff Layton <jlayton@redhat.com>, Kevin Coffman <kwc@citi.umich.edu>,
        linux-nfs@vger.kernel.org
In-Reply-To: <4603e94d7a85c40d7252308f394bb6ba.squirrel@webmail.rainiday.com>
References: <c8e974302190b867ad8ea49d8158f1db.squirrel@webmail.rainiday.com>
	 <20091009121602.5ec86dfb@tlielax.poochiereds.net>
	 <1c358fde92c49215d84129a1bfe2c6ec.squirrel@webmail.rainiday.com>
	 <20091010090039.4dfd1dfb@tlielax.poochiereds.net>
	 <ee56329e7d86a3e4b15001a39bb7e14a.squirrel@webmail.rainiday.com>
	 <20091013114441.2882c8b9@tlielax.poochiereds.net>
	 <4d569c330910130851o155050djdfed6a52e1f3177a@mail.gmail.com>
	 <1255452985.3711.85.camel@heimdal.trondhjem.org>
	 <20091013132701.72927b4d@tlielax.poochiereds.net>
	 <1255456293.3711.103.camel@heimdal.trondhjem.org>
	 <20091013140306.476b20fd@tlielax.poochiereds.net>
	 <4603e94d7a85c40d7252308f394bb6ba.squirrel@webmail.rainiday.com>
Content-Type: text/plain
Date: Wed, 14 Oct 2009 13:12:55 -0400
Message-Id: <1255540375.3173.4.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-10-14 at 09:47 -0700, raini@rainiday.com wrote:
> > On Tue, 13 Oct 2009 13:51:33 -0400
> > Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> >
> >> On Tue, 2009-10-13 at 13:27 -0400, Jeff Layton wrote:
> >> > Correct...and gssd actually does check the validity of the cache. If
> >> > TGT has expired or it's not valid for some other reason, then it skips
> >> > it and moves on.
> >> >
> >> > The problem comes when you have more than one valid credcache. In that
> >> > case it picks the one with the latest mtime. It seems that it should
> >> > instead pick the one with the latest TGT expiration time.
> >>
> >> So why do you think that is a problem? The result should be that
> >> rpc.gssd always ends up with a valid credential as long as there is at
> >> least one with a valid TGT.
> >> IOW: Who cares if the GSS session isn't going to last as long, as long
> >> as the RPC client can always instantiate a new one.
> >>
> >
> > Hrm...good point. I suppose that as long as gssd can pick a new
> > credcache if the context expires then this patch is superfluous. Wasn't
> > that support only added fairly recently (around a year ago?)? If so, it
> > may just be that raini isn't using a recent enough nfs-utils...
> 
> Hm - well I'm stuck on production machines (RHEL5) so currently on
> nfs-utils 1.0.9 which I'm going to take a wild guess may be problematic
> either way.  Could someone point me to information on this change (I see
> little in http://www.kernel.org/pub/linux/utils/nfs/)?
> 
> The reason I thought the new code would be useful is that if default
> tickets are non-renewable and short lifetime, it seems sensible for gssd
> to spot and use a longer lifetime renewable ticket in another ccache file
> - and say use krenew to keep the job alive (or even cope with the user
> renewing the ticket manually).
> 
> Seems to me therefore that in the absence of per-session ccaches, gssd
> should prefer long lifetime, and renewable.

No. That is not a necessary condition.

> Would the newer code you mention cope with this situation already?

Yes. Please reread the thread carefully again.

As long as gssd always select from among the valid (i.e. unexpired)
TGTs, then the actual remaining lifetime of the particular TGT that was
selected doesn't matter; gssd will always be able to renew the resulting
RPCSEC_GSS session when it expires.

  Trond

