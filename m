Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35217 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754523AbcKBNtE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 2 Nov 2016 09:49:04 -0400
Date: Wed, 2 Nov 2016 14:49:02 +0100
From: Thorsten Kukuk <kukuk@suse.de>
To: Steve Dickson <SteveD@redhat.com>
Cc: NeilBrown <neilb@suse.com>, linux-nfs@vger.kernel.org,
        libtirpc-devel@lists.sourceforge.net
Subject: Re: [Libtirpc-devel] [PATCH - rpcbind] Provide systemd unit files
 for rpcbind
Message-ID: <20161102134902.GA6446@suse.de>
References: <87oa2q14yc.fsf@notabene.neil.brown.name>
 <8c1fa65d-9efc-462a-b6c8-7ed518f0dfe4@RedHat.com>
 <87r36vq85k.fsf@notabene.neil.brown.name>
 <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <ff5e0322-2f5e-9102-326f-1f23968cb0a8@RedHat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 02, Steve Dickson wrote:

> I just took a look and we don't set that... Here is what we
> set in Fedora
> 
> RPCBDIR=/tmp
> %configure CFLAGS="$CFLAGS" LDFLAGS="-pie" \
>     --enable-warmstarts \
>     --with-statedir="$RPCBDIR" \
>     --with-rpcuser="$RPCBUSR" \
>     --with-nss-modules="files altfiles" \
>     --enable-libwrap \
>     --enable-debug

The rpcbind Makefile has:
bin_PROGRAMS = rpcbind rpcinfo

So per default, "make install" should install it into /usr/bin
and the patch from Niel with bin is correct.

  Thorsten

-- 
Thorsten Kukuk, Distinguished Engineer, Senior Architect SLES & CASP
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)
