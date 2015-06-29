Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:53930 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750834AbbF2EYO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Jun 2015 00:24:14 -0400
Date: Mon, 29 Jun 2015 14:24:06 +1000
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC] NFSv4 - do not accept an incompatible delegation.
Message-ID: <20150629142406.0afdd862@noble>
In-Reply-To: <CAHQdGtTWszzRdN+akenDkbiXd7xAJwAr6=144m6+dPWSxZ=boA@mail.gmail.com>
References: <20150622175318.6e840b23@noble>
	<CAHQdGtS2P7gU+9NWjEX5ejrtntMFv+8v6WCPRf3b7XCLuVXxLQ@mail.gmail.com>
	<20150623070414.2bbafec7@noble>
	<CAHQdGtS7pw3wicgAw9hdJrAQjtUKU==UhnaMGhNxcCnZ8WnnoQ@mail.gmail.com>
	<20150623110717.783535ca@noble>
	<CAHQdGtTWszzRdN+akenDkbiXd7xAJwAr6=144m6+dPWSxZ=boA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 22 Jun 2015 21:16:37 -0400 Trond Myklebust
<trond.myklebust@primarydata.com> wrote:

> On Mon, Jun 22, 2015 at 9:07 PM, NeilBrown <neilb@suse.com> wrote:

> > So maybe something like this:
> >
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index 55e1e3a..ce5f1489 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -1553,6 +1553,10 @@ static int nfs4_open_recover_helper(struct nfs4_opendata *opendata, fmode_t fmod
> >         struct nfs4_state *newstate;
> >         int ret;
> >
> > +       if ((opendata->o_arg.claim == NFS4_OPEN_CLAIM_DELEGATE_CUR ||
> > +            opendata->o-arg.claim == NFS4_OPEN_CLAIM_DELE_CUR_FH) &&
> > +           (opendata->o_arg.u_delegation_type & mode) != mode)
> > +               return 0;
> >         opendata->o_arg.open_flags = 0;
> >         opendata->o_arg.fmode = fmode;
> >         opendata->o_arg.share_access = nfs4_map_atomic_open_share(
> >
> >
> > I'm not entirely clear on the process of reclaiming opens and
> > delegations after a server reboot, so this may need to be adjusted to
> > handle that correctly.
> 
> The above is along the lines of what I was suggesting. I hope it tests out OK.
> 

Once I fixed the syntax errors, this was all I needed.
I was concerned there might be similar issues with
OPEN_CLAIM_DELEGATE_PREV (or whatever it is called) but Linux doesn't
appear to use that.

I tested it by commenting out

	status = vfs_setlease(filp, fl->fl_type, &fl, NULL);

in nfs4_setlease in the Linux nfsd, so that it would always return a
read delegation.  This was enough to demonstrate the problem and verify
the fix.
I haven't yet received confirmation from people with access to the
Netapp but I would be very surprised if this doesn't work (though I
think there are other issues that still need to be examined).

Separately I've discovered a bug that causes a livelock when a TCP
sendmsg fails because kmalloc failed.  I'll send patches for both.

NeilBrown
