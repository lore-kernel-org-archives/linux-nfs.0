Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:33479 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965090AbeALVLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 12 Jan 2018 16:11:54 -0500
Date: Fri, 12 Jan 2018 22:12:19 +0100
From: Thorsten Kukuk <kukuk@suse.de>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Guillem Jover <gjover@sipwise.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        libtirpc List <libtirpc-devel@lists.sourceforge.net>
Subject: Re: [Libtirpc-devel] [PATCH] Do not bind to reserved ports
 registered in /etc/services
Message-ID: <20180112211219.GA17573@suse.de>
References: <20180110004920.11100-1-gjover@sipwise.com>
 <49E44F63-42CF-4BF8-91E0-F89945D7CFE6@oracle.com>
 <20180112180528.GA9479@thunder.hadrons.org>
 <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <BB34439C-4BC6-46AE-B2E8-45E5F7396F21@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 12, Chuck Lever wrote:

> > On Jan 12, 2018, at 1:05 PM, Guillem Jover <gjover@sipwise.com> wrote:

> > [F] <https://sources.debian.org/src/glibc/2.26-3/debian/patches/any/local-bindresvport_blacklist.diff/>
> > 
> > On the above Debian bug report, it was proposed to make libtirpc switch
> > to use the libc bindresvport() implementation so that at least on those
> > distributions where it is locally patched it would honor the
> > /etc/bindresvport.blacklist file. The problem with this, is of course
> > that it does not help any upstream code on any other non-patched system.
> 
> The community issue here is that there have evolved, over time,
> multiple RPC libraries with divergent capabilities. The only way
> to truly address this confusion is to eliminate all but one of
> them, which is far outside the scope of your bug fix. For now we
> have to live with it.

openSUSE is removing sunrpc from glibc, Fedora seems to be removing
sunrpc from glibc, so it's only a matter of time when libtirpc is the
only RPC implementation used on Linux.

  Thorsten

-- 
Thorsten Kukuk, Distinguished Engineer, Senior Architect SLES & CaaSP
SUSE LINUX GmbH, Maxfeldstr. 5, 90409 Nuernberg, Germany
GF: Felix Imendoerffer, Jane Smithard, Graham Norton, HRB 21284 (AG Nuernberg)
