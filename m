Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:35933 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbbG0NoI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jul 2015 09:44:08 -0400
Received: by obnw1 with SMTP id w1so59354310obn.3
        for <linux-nfs@vger.kernel.org>; Mon, 27 Jul 2015 06:44:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150727070756.79f146c4@tlielax.poochiereds.net>
References: <1437994789-14133-1-git-send-email-jeff.layton@primarydata.com>
	<20150727070756.79f146c4@tlielax.poochiereds.net>
Date: Mon, 27 Jul 2015 09:44:07 -0400
Message-ID: <CAHQdGtQO0tAneQbPQQJ_6u-zihLPGwvuHn73Erg7o=CNzcNd+A@mail.gmail.com>
Subject: Re: [PATCH] nfs: hold state_lock when updating open stateid
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 27, 2015 at 7:07 AM, Jeff Layton
<jeff.layton@primarydata.com> wrote:
>
> On Mon, 27 Jul 2015 06:59:49 -0400
> Jeff Layton <jlayton@poochiereds.net> wrote:
>
> > Currently, we check to see if an open stateid needs updating, and then
> > update the stateid if so. The check and update however are not atomic,
> > so it's easily possible to end up finding an old seqid when we check
> > it only to have it updated by a newer one before we can get around to
> > updating it ourselves.

What am I missing? AFAICS, we always hold a write lock on the
state->seqlock in those functions.

The state->state_lock protects the state->lock_states list. It
shouldn't have any function as far as protecting open stateids.

Trond
