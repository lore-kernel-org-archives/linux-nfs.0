Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f182.google.com ([209.85.220.182]:34381 "EHLO
	mail-qk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbbDFOpj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2015 10:45:39 -0400
Received: by qkgx75 with SMTP id x75so25835351qkg.1
        for <linux-nfs@vger.kernel.org>; Mon, 06 Apr 2015 07:45:39 -0700 (PDT)
Date: Mon, 6 Apr 2015 10:45:36 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Mark Salter <msalter@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH] sunrpc: eliminate RPC_DEBUG
Message-ID: <20150406104536.63b01b09@synchrony.poochiereds.net>
In-Reply-To: <4110847.o7VvYRDU5Z@wuerfel>
References: <1428327960-22213-1-git-send-email-msalter@redhat.com>
	<20150406100452.402754a6@tlielax.poochiereds.net>
	<4110847.o7VvYRDU5Z@wuerfel>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 06 Apr 2015 16:38:09 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Monday 06 April 2015 10:04:52 Jeff Layton wrote:
> > > diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> > > index 665ef5a..a563ddb 100644
> > > --- a/fs/lockd/svcsubs.c
> > > +++ b/fs/lockd/svcsubs.c
> > > @@ -31,7 +31,7 @@
> > >  static struct hlist_head     nlm_files[FILE_NRHASH];
> > >  static DEFINE_MUTEX(nlm_file_mutex);
> > >  
> > > -#ifdef NFSD_DEBUG
> > > +#ifdef CONFIG_SUNRPC_DEBUG
> > 
> > Technically, you should use #if IS_ENABLED(CONFIG_SUNRPC_DEBUG). That's
> > supposed to help the compiler do checking of the code inside the block
> > even when it's not defined.
> 
> You probably meant the right thing and wrote something else: you should use
> 'if (IS_ENABLED(CONFIG_SUNRPC_DEBUG)) { ... }' to get that effect, but that
> only works within a function. '#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)' is just
> a nicer way to write '#if defined(CONFIG_SUNRPC_DEBUG) || 
> defined(CONFIG_SUNRPC_DEBUG_MODULE)', which is harmless but pointless here
> as the symbol would never be set to 'm'.
> 
> 	Arnd

Ahh ok, good to know. Then this patch is fine as-is then.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
