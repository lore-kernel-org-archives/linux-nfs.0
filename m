Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:46255 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbbAXLxl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 06:53:41 -0500
Received: by mail-qc0-f175.google.com with SMTP id c9so1443986qcz.6
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 03:53:41 -0800 (PST)
Date: Sat, 24 Jan 2015 06:53:39 -0500
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/5] NFSv4: Fix an atomicity problem in CLOSE
Message-ID: <20150124065339.75ab68f5@tlielax.poochiereds.net>
In-Reply-To: <20150124064628.0bc0b289@tlielax.poochiereds.net>
References: <1422077968-116473-1-git-send-email-trond.myklebust@primarydata.com>
	<1422077968-116473-2-git-send-email-trond.myklebust@primarydata.com>
	<20150124064628.0bc0b289@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 24 Jan 2015 06:46:28 -0500
Jeff Layton <jeff.layton@primarydata.com> wrote:

> On Sat, 24 Jan 2015 00:39:24 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> > If we are to remove the serialisation of OPEN/CLOSE, then we need to
> > ensure that the stateid sent as part of a CLOSE operation does not
> > change after we test the state in nfs4_close_prepare.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfs/nfs4proc.c       | 7 ++++++-
> >  fs/nfs/nfs4xdr.c        | 4 ++--
> >  include/linux/nfs_xdr.h | 2 +-
> >  3 files changed, 9 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> > index c347705b0161..4863dec10865 100644
> > --- a/fs/nfs/nfs4proc.c
> > +++ b/fs/nfs/nfs4proc.c
> > @@ -2587,6 +2587,11 @@ static void nfs4_close_done(struct rpc_task *task, void *data)
> >  		case -NFS4ERR_OLD_STATEID:
> >  		case -NFS4ERR_BAD_STATEID:
> >  		case -NFS4ERR_EXPIRED:
> > +			if (!nfs4_stateid_match(&calldata->arg.stateid,
> > +						&state->stateid)) {
> > +				rpc_restart_call_prepare(task);
> > +				goto out_release;
> > +			}
> 
> Do we need a similar check in the open codepath -- possibly in
> nfs4_open_done? AFAICT, currently if the OPEN ends up "losing" the race
> here, then we'll fall into full-on stateid recovery, which is almost
> certainly not what we want.
> 

(facepalm)

Oh nm...stupid q. The OPEN can't lose the race since you won't
necessarily have a stateid at the start of the call, and you're
upgrading anyway.

I think you're correct that CLOSE is the only place you have to worry
about it.

-- 
Jeff Layton <jeff.layton@primarydata.com>
