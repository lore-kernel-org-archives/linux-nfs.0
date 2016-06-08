Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f195.google.com ([209.85.161.195]:34633 "EHLO
	mail-yw0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757817AbcFHRWp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 13:22:45 -0400
Received: by mail-yw0-f195.google.com with SMTP id j74so1777314ywg.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2016 10:22:44 -0700 (PDT)
Message-ID: <1465406560.30890.10.camel@poochiereds.net>
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Date: Wed, 08 Jun 2016 13:22:40 -0400
In-Reply-To: <A0A3CAA8-969A-4E12-9532-41DE9D257C74@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru>
	 <1465319435.3024.25.camel@poochiereds.net>
	 <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru>
	 <1465329897.3024.38.camel@poochiereds.net>
	 <752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru>
	 <1465344205.3024.42.camel@poochiereds.net>
	 <AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru>
	 <1465383501.27742.19.camel@poochiereds.net>
	 <A0A3CAA8-969A-4E12-9532-41DE9D257C74@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-06-08 at 12:10 -0400, Oleg Drokin wrote:
> On Jun 8, 2016, at 6:58 AM, Jeff Layton wrote:
> 
> > A simple way to confirm that might be to convert all of the read locks
> > on the st_rwsem to write locks. That will serialize all of the open
> > operations and should prevent that particular race from occurring.
> > 
> > If that works, we'd probably want to fix it in a less heavy-handed way,
> > but I'd have to think about how best to do that.
> 
> So I looked at the call sites for nfs4_get_vfs_file(), how about something like this:
> 
> after we grab the fp->fi_lock, we can do test_access(open->op_share_access, stp);
> 
> If that returns true - just drop the spinlock and return EAGAIN.
> 
> The callsite in nfs4_upgrade_open() would handle that by retesting the access map
> again and either coming back in or more likely reusing the now updated stateid
> (synchronised by the fi_lock again).
> We probably need to convert the whole access map testing there to be under
> fi_lock.
> Something like:
> nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *cur_fh, struct nfs4_ol_stateid *stp, struct nfsd4_open *open)
> {
>         __be32 status;
>         unsigned char old_deny_bmap = stp->st_deny_bmap;
> 
> again:
> +        spin_lock(&fp->fi_lock);
>         if (!test_access(open->op_share_access, stp)) {
> +		spin_unlock(&fp->fi_lock);
> +               status = nfs4_get_vfs_file(rqstp, fp, cur_fh, stp, open);
> +		if (status == -EAGAIN)
> +			goto again;
> +		return status;
> +	}
> 
>         /* test and set deny mode */
> -        spin_lock(&fp->fi_lock);
>         status = nfs4_file_check_deny(fp, open->op_share_deny);
> 
> 
> The call in nfsd4_process_open2() I think cannot hit this condition, right?
> probably can add a WARN_ON there? BUG_ON? more sensible approach?
> 
> Alternatively we can probably always call nfs4_get_vfs_file() under this spinlock,
> just have it drop that for the open and then reobtain (already done), not as transparent I guess.
> 

Yeah, I think that might be best. It looks like things could change
after you drop the spinlock with the patch above. Since we have to
retake it anyway in nfs4_get_vfs_file, we can just do it there.

> Or the fi_lock might be converted to say a mutex, so we can sleep with it held and
> then we can hold it across whole invocation of nfs4_get_vfs_file() and access testing and stuff.

I think we'd be better off taking the st_rwsem for write (maybe just
turning it into a mutex). That would at least be per-stateid instead of
per-inode. That's a fine fix for now.

It might slow down a client slightly that is sending two stateid
morphing operations in parallel, but they shouldn't affect each other.
I'm liking that solution more and more here.
Longer term, I think we need to further simplify OPEN handling. It has
gotten better, but it's still really hard to follow currently (and is
obviously error-prone).

-- 
Jeff Layton <jlayton@poochiereds.net>
