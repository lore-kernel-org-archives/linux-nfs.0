Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:36110 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934909AbcHJTG1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Aug 2016 15:06:27 -0400
Received: by mail-qk0-f169.google.com with SMTP id l2so53211924qkf.3
        for <linux-nfs@vger.kernel.org>; Wed, 10 Aug 2016 12:06:26 -0700 (PDT)
Message-ID: <1470855983.2694.5.camel@redhat.com>
Subject: Re: [lkp] [nfsd] b44061d0b9: BUG: Dentry
 ffff880027d7c540{i=1846f,n=0a} still in use (1) [unmount of btrfs vda]
From: Jeff Layton <jlayton@redhat.com>
To: Josef Bacik <jbacik@fb.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
Cc: kernel test robot <xiaolong.ye@intel.com>,
        Al Viro <viro@zeniv.linux.org.uk>, Chris Mason <clm@fb.com>,
        David Sterba <dsterba@suse.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Date: Wed, 10 Aug 2016 15:06:23 -0400
In-Reply-To: <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
References: <20160810053947.GG21941@yexl-desktop>
	 <CA+55aFxdcG4y4zWTFFT8SekEtxsvx12P+e=11kTCFc=zS__bXQ@mail.gmail.com>
	 <dc406145-b465-b7e9-e370-91910abb8e6a@fb.com>
	 <CA+55aFzdTMBc7f5=bQLRUtceu-Kg-MGmzWrAv1r96_ra8yutJA@mail.gmail.com>
	 <e6fb50d4-2a27-13cd-02c8-5b8439a16b3f@fb.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-08-10 at 14:46 -0400, Josef Bacik wrote:
> On 08/10/2016 02:25 PM, Linus Torvalds wrote:
> > 
> > > > On Wed, Aug 10, 2016 at 11:22 AM, Josef Bacik <jbacik@fb.com> wrote:
> > > 
> > > On 08/10/2016 02:06 PM, Linus Torvalds wrote:
> > > > 
> > > > 
> > > > More information in the original email on lkml.
> > > 
> > > I'm not subscribed to lkml and for some reason I can't find the original
> > > email in any of the lkml/linux-nfs archives.  Could you forward more of the
> > > details?
> > 
> > Done.
> > 
> 
> So my naive fix would be something like this
> 
> 
> > From: Josef Bacik <jbacik@fb.com>
> Date: Wed, 10 Aug 2016 14:43:08 -0400
> Subject: [PATCH] nfsd: fix dentry refcounting problem
> 
> b44061d0b9 introduced a dentry ref counting bug, previously we were grabbing one
> ref to dchild in nfsd_create(), but with the creation of nfsd_create_locked() we
> have a ref for dchild from the lookup in nfsd_create(), and then another ref in
> nfsd_create_locked().  The ref from the lookup in nfsd_create() is never dropped
> and results in dentries still in use at unmount.
> 
> > Signed-off-by: Josef Bacik <jbacik@fb.com>
> ---
>   fs/nfsd/vfs.c | 9 ++++++---
>   1 file changed, 6 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index ba944123..ff476e6 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1252,10 +1252,13 @@ nfsd_create(struct svc_rqst *rqstp, struct svc_fh *fhp,
> >   	if (IS_ERR(dchild))
> >   		return nfserrno(host_err);
> >   	err = fh_compose(resfhp, fhp->fh_export, dchild, fhp);
> > -	if (err) {
> > -		dput(dchild);
> > +	/*
> > +	 * We unconditionally drop our ref to dchild as fh_compose will have
> > +	 * already grabbed its own ref for it.
> > +	 */
> > +	dput(dchild);
> > +	if (err)
> >   		return err;
> > -	}
> >   	return nfsd_create_locked(rqstp, fhp, fname, flen, iap, type,
> >   					rdev, resfhp);
>   }

Looks correct to me:

Reviewed-by: Jeff Layton <jlayton@redhat.com>
