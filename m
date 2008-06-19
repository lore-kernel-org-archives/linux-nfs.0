From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH - take 2] knfsd: nfsd: Handle ERESTARTSYS from syscalls.
Date: Wed, 18 Jun 2008 21:09:47 -0400
Message-ID: <20080618210947.2110a541@tleilax.poochiereds.net>
References: <20080619101025.24263.patches@notabene>
	<1080619001109.24338@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:48644 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754350AbYFSBJw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 21:09:52 -0400
In-Reply-To: <1080619001109.24338@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 19 Jun 2008 10:11:09 +1000
NeilBrown <neilb@suse.de> wrote:

> 
> OCFS2 can return -ERESTARTSYS from write requests (and possibly
> elsewhere) if there is a signal pending.
> 
> If nfsd is shutdown (by sending a signal to each thread) while there
> is still an IO load from the client, each thread could handle one last
> request with a signal pending.  This can result in -ERESTARTSYS
> which is not understood by nfserrno() and so is reflected back to
> the client as nfserr_io aka -EIO.  This is wrong.
> 
> Instead, interpret ERESTARTSYS to mean "try again later" by returning
> nfserr_jukebox.  The client will resend and - if the server is
> restarted - the write will (hopefully) be successful and everyone will
> be happy.
> 
>  The symptom that I narrowed down to this was:
>     copy a large file via NFS to an OCFS2 filesystem, and restart
>     the nfs server during the copy.
>     The 'cp' might get an -EIO, and the file will be corrupted -
>     presumably holes in the middle where writes appeared to fail.
> 
> 
> Signed-off-by: Neil Brown <neilb@suse.de>
> 
> ### Diffstat output
>  ./fs/nfsd/nfsproc.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff .prev/fs/nfsd/nfsproc.c ./fs/nfsd/nfsproc.c
> --- .prev/fs/nfsd/nfsproc.c	2008-06-19 10:06:36.000000000 +1000
> +++ ./fs/nfsd/nfsproc.c	2008-06-19 10:07:58.000000000 +1000
> @@ -614,6 +614,7 @@ nfserrno (int errno)
>  #endif
>  		{ nfserr_stale, -ESTALE },
>  		{ nfserr_jukebox, -ETIMEDOUT },
> +		{ nfserr_jukebox, -ERESTARTSYS },
>  		{ nfserr_dropit, -EAGAIN },
>  		{ nfserr_dropit, -ENOMEM },
>  		{ nfserr_badname, -ESRCH },
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

No objection to the patch, but what signal was being sent to nfsd when
you saw this? If it's anything but a SIGKILL, then I wonder if we have
a race that we need to deal with. My understanding is that we have nfsd
flip between 2 sigmasks to prevent anything but a SIGKILL from being
delivered while we're handling the local filesystem operation.

>From nfsd():

----------[snip]-----------
                sigprocmask(SIG_SETMASK, &shutdown_mask, NULL);

                /*
                 * Find a socket with data available and call its
                 * recvfrom routine.
                 */
                while ((err = svc_recv(rqstp, 60*60*HZ)) == -EAGAIN)
                        ;
                if (err < 0)
                        break;
                update_thread_usage(atomic_read(&nfsd_busy));
                atomic_inc(&nfsd_busy);

                /* Lock the export hash tables for reading. */
                exp_readlock();

                /* Process request with signals blocked.  */
                sigprocmask(SIG_SETMASK, &allowed_mask, NULL);

                svc_process(rqstp);

----------[snip]-----------

What happens if this catches a SIGINT after the err<0 check, but before
the mask is set to allowed_mask? Does svc_process() then get called with
a signal pending?

-- 
Jeff Layton <jlayton@redhat.com>
