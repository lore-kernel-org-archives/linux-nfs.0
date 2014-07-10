Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:59027 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114AbaGJLcQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 07:32:16 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so7865661qcr.30
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jul 2014 04:32:15 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 10 Jul 2014 07:32:14 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 011/100] nfsd: refactor nfs4_file_get_access and
 nfs4_file_put_access
Message-ID: <20140710073214.5621293f@tlielax.poochiereds.net>
In-Reply-To: <20140710075920.GA6226@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
	<1404842668-22521-12-git-send-email-jlayton@primarydata.com>
	<20140710075920.GA6226@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 10 Jul 2014 00:59:20 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> > +static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> >  {
> > +	int oflag = nfs4_access_to_omode(access);
> > +
> > +	/* Note: relies on NFS4_SHARE_ACCESS_BOTH == READ|WRITE */
> > +	access &= NFS4_SHARE_ACCESS_BOTH;
> > +	if (access == 0)
> > +		return;
> > +
> >  	if (oflag == O_RDWR) {
> 
> This fragment looks odd to me in several ways.
> 
> For one NFS4_SHARE_ACCESS_BOTH isn't == READ|WRITE, although reading it
> again I suspect this supposed to mean
> NFS4_SHARE_ACCESS_READ|NFS4_SHARE_ACCESS_WRITE. 

Yeah, that's correct. I probably shouldn't abbreviate those, sorry...

> Second why to the &=
> on access if it's not used except for the test, or for that matter
> why don't we do the check on the oflag?
> 

That &= made more sense in Trond's original patch, but it probably can
be removed now.

> I can see two sensible ways to do this:
> 
> a)
> 
> static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> {
> 	int oflag = nfs4_access_to_omode(access);
> 
> 	if (oflag == O_RDWR) {
> 		__nfs4_file_get_access(fp, O_RDONLY);
> 		__nfs4_file_get_access(fp, O_WRONLY);
> 	} else if (oflag == O_RDONLY || oflag == O_RDONLY)
> 		__nfs4_file_get_access(fp, oflag);
> 	}
> }
> 
> Or even better just avoid the nfs4_file_get_access call altogether:
> 
> static void nfs4_file_get_access(struct nfs4_file *fp, u32 access)
> {
> 	WARN_ON_ONCE(access & ~NFS4_SHARE_ACCESS_BOTH);
> 
> 	if (access & NFS4_SHARE_ACCESS_WRITE)
> 		__nfs4_file_get_access(fp, O_WRONLY);
> 	if (access & NFS4_SHARE_ACCESS_READ)
> 		__nfs4_file_get_access(fp, O_RDONLY);
> }
> 
> Same for the put side.
> 


Yeah, that second one looks fine. I'll change the patch to do that
here, but I'm not sure if I'll need to morph that a bit in the later
patches.

> 
> Btw, what is the story about the third fd in fi_fds? Seems like
> nfs4_get_vfs_file can put a file pointer in there, but
> nfs4_file_get_access never grabs a reference to it.

This code is just plain odd altogether, but it does make a perverse
sort of sense. Here's the (patched) __nfs4_file_put_access:

        if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
                struct file *f1 = NULL;
                struct file *f2 = NULL;

                swap(f1, fp->fi_fds[oflag]);
                if (atomic_read(&fp->fi_access[1 - oflag]) == 0)
                        swap(f2, fp->fi_fds[O_RDWR]);
                spin_unlock(&fp->fi_lock);

So, we decrement the fi_access counter on the O_*ONLY flag that we want
to put. If it goes to zero, then we check the other O_*ONLY counter and
if it's also zero, we fput the O_RDWR file.

So, you're correct that we never take an fi_access reference for O_RDWR,
which is why the array doesn't have a slot for it:

        atomic_t                fi_access[2];

...it's tracked by the union of the O_RDONLY and O_WRONLY counters.

-- 
Jeff Layton <jlayton@primarydata.com>
