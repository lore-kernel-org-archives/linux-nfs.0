Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:64891 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932817AbaGQOmD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jul 2014 10:42:03 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so2108716qgd.9
        for <linux-nfs@vger.kernel.org>; Thu, 17 Jul 2014 07:42:01 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Thu, 17 Jul 2014 10:41:59 -0400
To: Miklos Szeredi <miklos@szeredi.hu>
Cc: Jeff Layton <jeff.layton@primarydata.com>, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>,
        NFS <linux-nfs@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>
Subject: Re: [PATCH] NFS: nfs4_lookup_revalidate need to report STALE
 inodes.
Message-ID: <20140717104159.59ea2f6f@tlielax.poochiereds.net>
In-Reply-To: <CAJfpegs+EzqtDTZEWTHP0b7HNM+4sFPN4KwsdEhEh6gabmdjWA@mail.gmail.com>
References: <20140714151405.2fa06dd7@notabene.brown>
	<20140714081455.69f55224@tlielax.poochiereds.net>
	<20140714223513.47807c98@notabene.brown>
	<20140714090028.6f04fd2c@tlielax.poochiereds.net>
	<20140715085727.6fa12272@notabene.brown>
	<20140714194738.5aafaf25@tlielax.poochiereds.net>
	<20140717115024.1eb7433d@notabene.brown>
	<20140717072241.2c1549a3@tlielax.poochiereds.net>
	<CAJfpegs+EzqtDTZEWTHP0b7HNM+4sFPN4KwsdEhEh6gabmdjWA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Jul 2014 14:52:00 +0200
Miklos Szeredi <miklos@szeredi.hu> wrote:

> On Thu, Jul 17, 2014 at 1:22 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> 
> > What's so special about an EOPENSTALE return from finish_open that we
> > need to handle retries in do_last? It seems like we could get rid of the
> > stale_open label and just let do_filp_open handle it like we would
> > an ESTALE return from any other spot in the function.
> >
> > Just for giggles, here's an RFC patch. It builds but I haven't tested
> > it. It might also be possible to do some cleanup around saved_parent
> > with this.
> >
> > Thoughts?
> 
> EOPENSTALE is an optimization for the redoing only the last component.
> It's the analogue of ->d_revalidate() failure, in which case lookup of
> that component only is retried path components before that are not.
> 
> I'm not sure if it's a valid optimization, but if not, then we should
> also consider doing LOOKUP_REVAL on the whole path on any
> d_revalidate() failure as well.
> 
> Thanks,
> Miklos


Ok, that makes sense and it's seems like good enough reason to keep it
as is for now. We can just drop my RFC patch...

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
