Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:41299 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760075AbaIOXLc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Sep 2014 19:11:32 -0400
Received: by mail-qc0-f181.google.com with SMTP id r5so5073520qcx.12
        for <linux-nfs@vger.kernel.org>; Mon, 15 Sep 2014 16:11:31 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 15 Sep 2014 19:11:29 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 1/5] lockd: move lockd's grace period handling into
 its own module
Message-ID: <20140915191129.395fd40d@tlielax.poochiereds.net>
In-Reply-To: <20140915220813.GC31157@fieldses.org>
References: <1408473509-14010-1-git-send-email-jlayton@primarydata.com>
	<1408473509-14010-2-git-send-email-jlayton@primarydata.com>
	<20140828200059.GB25203@fieldses.org>
	<20140828202442.GC25203@fieldses.org>
	<20140915220813.GC31157@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 15 Sep 2014 18:08:13 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Aug 28, 2014 at 04:24:43PM -0400, J. Bruce Fields wrote:
> > On Thu, Aug 28, 2014 at 04:01:00PM -0400, J. Bruce Fields wrote:
> > > On Tue, Aug 19, 2014 at 02:38:25PM -0400, Jeff Layton wrote:
> > > > Currently, all of the grace period handling is part of lockd. Eventually
> > > > though we'd like to be able to build v4-only servers, at which point
> > > > we'll need to put all of this elsewhere.
> > > > 
> > > > Move the code itself into fs/nfs_common and have it build a grace.ko
> > > > module. Then, rejigger the Kconfig options so that both nfsd and lockd
> > > > enable it automatically.
> > > 
> > > Thanks, applying this one for 3.18 indepedently of the others.
> > 
> > This code should also be fixed, though.
> > 
> > Currently nfsd is recording the grace period as done when its own timer
> > runs out, but then it continuing to accept reclaims until lockd is also
> > done.
> 
> I sat down to fix this today then decided there's not a real bug:
> 
> All the grace_done upcall really does is throw away any previous clients
> that haven't reclaimed yet.
> 
> It's legal to do that as soon as the correct amount of time has passed.
> It's actually OK to continue to allow the grace period to run past that
> point, the only requirement is that all reclaims precede all new opens,
> which the code still does enforce.
> 
> So I think it might just be worth a little extra explanation.
> 
> --b.
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a298c3d..ca6f6ee 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -4122,8 +4122,23 @@ nfsd4_end_grace(struct nfsd_net *nn)
>  
>  	dprintk("NFSD: end of grace period\n");
>  	nn->grace_ended = true;
> +	/*
> +	 * If the server goes down again right now, an NFSv4
> +	 * client will still be allowed to reclaim after it comes back up,
> +	 * even if it hasn't yet had a chance to reclaim state this time.
> +	 */

Might even be reasonable to lay out the v4.0/v4.1+ difference here? For
a v4.0 client any lock reclaim will do, but for v4.1+ the client must
have _completed_ reclaim at this point (a'la RECLAIM_COMPLETE)

...or at least that'll be the situation once the patches I sent go in...
 
>  	nfsd4_record_grace_done(nn);
> +	/*
> +	 * At this point, NFSv4 clients can still reclaim.  But if
> the
> +	 * server crashes, any that have not yet reclaimed will be
> out
> +	 * of luck on the next boot.
> +	 */
>  	locks_end_grace(&nn->nfsd4_manager);
> +	/*
> +	 * At this point, and once lockd and/or any other containers
> +	 * exit their grace period, further reclaims aren't permitted
> +	 * and regular locking can resume.
> +	 */
>  }
>  
>  static time_t
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> in the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

ACK, overall. The comments make sense to me and it does clarify things
a bit.

-- 
Jeff Layton <jlayton@primarydata.com>
