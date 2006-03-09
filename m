From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 000 of 14] knfsd: Introduction
Date: Thu, 09 Mar 2006 12:10:11 -0500
Message-ID: <1141924212.8293.52.camel@lade.trondhjem.org>
References: <20060309174755.24381.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750726AbWCIRKe@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <20060309174755.24381.patches@notabene>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, 2006-03-09 at 17:51 +1100, NeilBrown wrote:
>  [PATCH 000 of 14] knfsd: Introduction
>  [PATCH 001 of 14] knfsd: Change the store of auth_domains to not be a 'cache'.
>  [PATCH 002 of 14] knfsd: Break the hard linkage from svc_expkey to svc_export
>  [PATCH 003 of 14] knfsd: Get rid of 'inplace' sunrpc caches
>  [PATCH 004 of 14] knfsd: Create cache_lookup function instead of using a macro to declare one.
>  [PATCH 005 of 14] knfsd: Convert ip_map cache to use the new lookup routine.
>  [PATCH 006 of 14] knfsd: Use new cache_lookup for svc_export
>  [PATCH 007 of 14] knfsd: Use new cache_lookup for svc_expkey cache.
>  [PATCH 008 of 14] knfsd: Use new sunrpc cache for rsi cache
>  [PATCH 009 of 14] knfsd: Use new cache code for rsc cache
>  [PATCH 010 of 14] knfsd: Use new cache code for name/id lookup caches
>  [PATCH 011 of 14] knfsd: An assortment of little fixes to the sunrpc cache code.
>  [PATCH 012 of 14] knfsd: Remove DefineCacheLookup
>  [PATCH 013 of 14] knfsd: Unexport cache_fresh and fix a small race.
>  [PATCH 014 of 14] knfsd: Convert sunrpc_cache to use krefs

Any plans to update Documentation/rpc-cache.txt?

Cheers,
  Trond
