Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:36713 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755615AbaGNPCF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jul 2014 11:02:05 -0400
Received: by mail-qg0-f50.google.com with SMTP id j5so3464594qga.23
        for <linux-nfs@vger.kernel.org>; Mon, 14 Jul 2014 08:02:04 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 14 Jul 2014 11:02:02 -0400
To: Arnd Bergmann <arnd@arndb.de>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org, Paul McKenney <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/7] sunrpc: remove __rcu annotation from struct
 gss_cl_ctx->gc_gss_ctx
Message-ID: <20140714110202.4e311df2@tlielax.poochiereds.net>
In-Reply-To: <6702571.1HVrh55XfQ@wuerfel>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405303064-9102-2-git-send-email-jlayton@primarydata.com>
	<6702571.1HVrh55XfQ@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 14 Jul 2014 16:23:53 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Sunday 13 July 2014 21:57:38 Jeff Layton wrote:
> > 
> > Commit 5b22216e11f7 (nfs: __rcu annotations) added a __rcu annotation to
> > the gc_gss_ctx field. I see no rationale for adding that though, as that
> > field does not seem to be managed via RCU at all.
> > 
> > Cc: Arnd Bergmann <arnd@arndb.de>
> > Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> 
> Unfortunately, it's been too long ago for me to remember what led to me
> adding it. I also don't see a reason for it in today's code, but I don't
> know if the code has changed, if I made a mistake then, or if it's actually
> needed for some reason I don't see.
> 

Darn, I was hoping you would remember... ;)

I don't think the code that manipulates this field has changed
substantially since then, but I'm far from certain either. This field
does live in a structure that is RCU managed, so maybe that was part of
the rationale?

In any case, we're just removing the annotation here so this shouldn't
materially harm anything, AFAICT.

-- 
Jeff Layton <jlayton@primarydata.com>
