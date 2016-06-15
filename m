Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:57640 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932130AbcFONb5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2016 09:31:57 -0400
Date: Wed, 15 Jun 2016 09:31:55 -0400
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: Always lock state exclusively.
Message-ID: <20160615133155.GB1836@fieldses.org>
References: <30E98D26-CB99-4BF8-8697-A2E9BB41920D@linuxhacker.ru>
 <1465781187-824653-1-git-send-email-green@linuxhacker.ru>
 <20160614154659.GE25973@fieldses.org>
 <799A23EB-FA33-4251-A137-028402BDA4C8@linuxhacker.ru>
 <20160614184655.GI25973@fieldses.org>
 <4B503C8E-0195-4016-96F2-C848F667218D@linuxhacker.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4B503C8E-0195-4016-96F2-C848F667218D@linuxhacker.ru>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 14, 2016 at 10:19:49PM -0400, Oleg Drokin wrote:
> On Jun 14, 2016, at 2:46 PM, J . Bruce Fields wrote:
> > diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> > index fa5fb5aa4847..41b59854c40f 100644
> > --- a/fs/nfsd/nfs4state.c
> > +++ b/fs/nfsd/nfs4state.c
> > @@ -3480,13 +3480,15 @@ alloc_init_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
> > }
> > 
> > static struct nfs4_ol_stateid *
> > -init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > -		struct nfsd4_open *open)
> > +init_open_stateid(struct nfs4_file *fp, struct nfsd4_open *open)
> > {
> > 
> > 	struct nfs4_openowner *oo = open->op_openowner;
> > 	struct nfs4_ol_stateid *retstp = NULL;
> > +	struct nfs4_ol_stateid *stp;
> > 
> > +	stp = open->op_stp;
> > +	open->op_stp = NULL;
> > 	/* We are moving these outside of the spinlocks to avoid the warnings */
> > 	mutex_init(&stp->st_mutex);
> > 	mutex_lock(&stp->st_mutex);
> > @@ -3512,9 +3514,12 @@ init_open_stateid(struct nfs4_ol_stateid *stp, struct nfs4_file *fp,
> > out_unlock:
> > 	spin_unlock(&fp->fi_lock);
> > 	spin_unlock(&oo->oo_owner.so_client->cl_lock);
> > -	if (retstp)
> > -		mutex_lock(&retstp->st_mutex);
> > -	return retstp;
> > +	if (retstp) {
> > +		nfs4_put_stid(&stp->st_stid);
> 
> So as I am trying to integrate this into my patchset,
> do we really need this?
> We don't if we took the other path and left this one
> hanging off the struct nfsd4_open (why do we need to
> assign it NULL before the search?) I imagine then
> we'd save some free/realloc churn as well?

Yes, good idea.

> I assume struct nfsd4_open cannot be shared between threads?

Right.

> Otherwise we have bigger problems at hand like mutex init on a locked
> mutex from another thread and stuff.
> 
> I'll try this theory I guess.

Sounds good!

--b.
