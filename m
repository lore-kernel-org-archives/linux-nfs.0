Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:33363 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752827AbcBARH7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Feb 2016 12:07:59 -0500
Received: by mail-ob0-f176.google.com with SMTP id is5so124869439obc.0
        for <linux-nfs@vger.kernel.org>; Mon, 01 Feb 2016 09:07:59 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <56ADE4A4.9060604@gmail.com>
References: <1453730956-5325-1-git-send-email-trond.myklebust@primarydata.com>
	<1453730956-5325-2-git-send-email-trond.myklebust@primarydata.com>
	<1453730956-5325-3-git-send-email-trond.myklebust@primarydata.com>
	<1453730956-5325-4-git-send-email-trond.myklebust@primarydata.com>
	<1453730956-5325-5-git-send-email-trond.myklebust@primarydata.com>
	<56ADE4A4.9060604@gmail.com>
Date: Mon, 1 Feb 2016 12:07:59 -0500
Message-ID: <CAHQdGtS4UHOUiAtYsHPQ-gnmDcDGbcTxuYv79LLXxaAS3LZrCg@mail.gmail.com>
Subject: Re: [PATCH 4/5] NFSv4.x: Fix wraparound issues when validing the
 callback sequence id
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 31, 2016 at 5:40 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
>
>
> On 1/25/2016 22:09, Trond Myklebust wrote:
> > We need to make sure that we don't allow args->csa_sequenceid == 0.
> >
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > ---
> >  fs/nfs/callback_proc.c | 43 +++++++++++++++++--------------------------
> >  1 file changed, 17 insertions(+), 26 deletions(-)
> ... snip ...
> > @@ -486,6 +476,13 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
> >               goto out_unlock;
> >       }
> >
> > +     status = validate_seqid(tbl, slot, args);
> > +     if (status)
> > +             goto out_unlock;
>
> For NFS4ERR_RETRY_UNCACHED_REP error, nfs should initialize
> cb_sequenceres information, but goto out_unlock will skip it.
>

Good point! I've appended a patch that fixes this.

Thanks!
  Trond
