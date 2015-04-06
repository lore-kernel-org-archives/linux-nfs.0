Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.131]:56689 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbbDFOiY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Apr 2015 10:38:24 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Mark Salter <msalter@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-api@vger.kernel.org
Subject: Re: [PATCH] sunrpc: eliminate RPC_DEBUG
Date: Mon, 06 Apr 2015 16:38:09 +0200
Message-ID: <4110847.o7VvYRDU5Z@wuerfel>
In-Reply-To: <20150406100452.402754a6@tlielax.poochiereds.net>
References: <1428327960-22213-1-git-send-email-msalter@redhat.com> <20150406100452.402754a6@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday 06 April 2015 10:04:52 Jeff Layton wrote:
> > diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
> > index 665ef5a..a563ddb 100644
> > --- a/fs/lockd/svcsubs.c
> > +++ b/fs/lockd/svcsubs.c
> > @@ -31,7 +31,7 @@
> >  static struct hlist_head     nlm_files[FILE_NRHASH];
> >  static DEFINE_MUTEX(nlm_file_mutex);
> >  
> > -#ifdef NFSD_DEBUG
> > +#ifdef CONFIG_SUNRPC_DEBUG
> 
> Technically, you should use #if IS_ENABLED(CONFIG_SUNRPC_DEBUG). That's
> supposed to help the compiler do checking of the code inside the block
> even when it's not defined.

You probably meant the right thing and wrote something else: you should use
'if (IS_ENABLED(CONFIG_SUNRPC_DEBUG)) { ... }' to get that effect, but that
only works within a function. '#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)' is just
a nicer way to write '#if defined(CONFIG_SUNRPC_DEBUG) || 
defined(CONFIG_SUNRPC_DEBUG_MODULE)', which is harmless but pointless here
as the symbol would never be set to 'm'.

	Arnd
