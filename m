Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:36702 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752553AbbG0NvU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 09:51:20 -0400
Received: by qges31 with SMTP id s31so5003825qge.3
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 06:51:20 -0700 (PDT)
Date: Mon, 27 Jul 2015 09:51:14 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: hold state_lock when updating open stateid
Message-ID: <20150727095114.1a0a9d12@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtQO0tAneQbPQQJ_6u-zihLPGwvuHn73Erg7o=CNzcNd+A@mail.gmail.com>
References: <1437994789-14133-1-git-send-email-jeff.layton@primarydata.com>
	<20150727070756.79f146c4@tlielax.poochiereds.net>
	<CAHQdGtQO0tAneQbPQQJ_6u-zihLPGwvuHn73Erg7o=CNzcNd+A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 27 Jul 2015 09:44:07 -0400
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Mon, Jul 27, 2015 at 7:07 AM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> >
> > On Mon, 27 Jul 2015 06:59:49 -0400
> > Jeff Layton <jlayton@poochiereds.net> wrote:
> >
> > > Currently, we check to see if an open stateid needs updating, and then
> > > update the stateid if so. The check and update however are not atomic,
> > > so it's easily possible to end up finding an old seqid when we check
> > > it only to have it updated by a newer one before we can get around to
> > > updating it ourselves.
> 
> What am I missing? AFAICS, we always hold a write lock on the
> state->seqlock in those functions.
> 
> The state->state_lock protects the state->lock_states list. It
> shouldn't have any function as far as protecting open stateids.
> 
> Trond

Ahh my bad. You aren't missing anything. I was thinking that the
write_seqlock calls would just bump a counter, and missed the fact that
they have a spinlock embedded within them.

In that case, there is no bug here and this patch can be dropped.

Thanks!
-- 
Jeff Layton <jeff.layton@primarydata.com>
