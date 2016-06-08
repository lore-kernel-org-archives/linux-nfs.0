Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:35513 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539AbcFHK6Y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Jun 2016 06:58:24 -0400
Received: by mail-yw0-f175.google.com with SMTP id o16so3611288ywd.2
        for <linux-nfs@vger.kernel.org>; Wed, 08 Jun 2016 03:58:23 -0700 (PDT)
Message-ID: <1465383501.27742.19.camel@poochiereds.net>
Subject: Re: Files leak from nfsd in 4.7.1-rc1 (and more?)
From: Jeff Layton <jlayton@poochiereds.net>
To: Oleg Drokin <green@linuxhacker.ru>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        "<linux-kernel@vger.kernel.org> Mailing List"
	<linux-kernel@vger.kernel.org>
Date: Wed, 08 Jun 2016 06:58:21 -0400
In-Reply-To: <AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru>
References: <4EDA6CFD-1FE8-4FCA-ACCF-84250BE342CB@linuxhacker.ru>
	 <1465319435.3024.25.camel@poochiereds.net>
	 <0F21EDD6-5CBB-4B5B-A1FF-E066011D18D6@linuxhacker.ru>
	 <1465329897.3024.38.camel@poochiereds.net>
	 <752F7196-1EE7-4FB3-8769-177131C8A793@linuxhacker.ru>
	 <1465344205.3024.42.camel@poochiereds.net>
	 <AA8AB6FA-E3FF-42B9-A275-0173BD667B0F@linuxhacker.ru>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2016-06-07 at 22:22 -0400, Oleg Drokin wrote:
> On Jun 7, 2016, at 8:03 PM, Jeff Layton wrote:
> 
> > > > That said, this code is quite subtle. I'd need to look over it in more
> > > > detail before I offer up any fixes. I'd also appreciate it if anyone
> > > > else wants to sanity check my analysis there.
> > > > 
> > Yeah, I think you're right. It's fine since r/w opens have a distinct
> > slot, even though the refcounting just tracks the number of read and
> > write references. So yeah, the leak probably is in an error path
> > someplace, or maybe a race someplace.
> 
> So I noticed that set_access is always called locked, but clear_access is not,
> this does not sound right.
> 
> So I placed this strategic WARN_ON:
> @@ -3991,6 +4030,7 @@ static __be32 nfs4_get_vfs_file(struct svc_rqst *rqstp, struct nfs4_file *fp,
>                         goto out_put_access;
>                 spin_lock(&fp->fi_lock);
>                 if (!fp->fi_fds[oflag]) {
> +WARN_ON(!test_access(open->op_share_access, stp));
>                         fp->fi_fds[oflag] = filp;
>                         filp = NULL;
>        
> This is right in the place where nfsd set the access flag already, discovered
> that the file is not opened and went on to open it, yet some parallel thread
> came in and cleared the flag by the time we got the file opened.
> It did trigger (but there are 30 minutes left till test finish, so I don't
> know yet if this will correspond to the problem at hand yet, so below is speculation).
> 
> Now, at the exit from this function, the state will not have access for this file
> set and the file would be leaked, since the matching call, probably in
> release_all_access() does:
>                 if (test_access(i, stp))
>                         nfs4_file_put_access(stp->st_stid.sc_file, i);
>                 clear_access(i, stp);
> 
> Meaning that the refcount is not dropped due to no access flag set.
> 
> I imagine we can just set the flag back right after setting fp->fi_fds[oflag]
> and that particular race would be gone?
> 
> Would that be ok, or is it just wrong that somebody can come and drop
> (delegation downgrade seems to be the most likely suspect) access bits like this
> while they are in the middle of being acquired?
> 

I think you're on the right track...

Operations that morph the stateid's seqid should be serialized via the
st_rwsem. An OPEN_DOWNGRADE or CLOSE takes an exclusive lock on the
rwsem, but we do allow OPENs to run in parallel with each other, under
the assumption that on success you always get at least what you
requested. So, I don't think that OPEN can really race with an
OPEN_DOWNGRADE or CLOSE like you're thinking.

But...suppose we have two racing OPEN calls. They're both in
nfs4_get_vfs_file. One opens the file and succeeds and the other fails
and ends up in out_put_access. At that point, you could end up
clobbering the successful update to st_access_bmap from the other task,
and we'd end up not putting the file access references in
release_all_access.

A simple way to confirm that might be to convert all of the read locks
on the st_rwsem to write locks. That will serialize all of the open
operations and should prevent that particular race from occurring.

If that works, we'd probably want to fix it in a less heavy-handed way,
but I'd have to think about how best to do that.

-- 
Jeff Layton <jlayton@poochiereds.net>
