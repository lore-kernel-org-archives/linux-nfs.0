Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49500 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751395Ab1BPPVT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 10:21:19 -0500
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release
 to nfsiod
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110216095002.1e7944c9@tlielax.poochiereds.net>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	 <1297783898.10103.22.camel@heimdal.trondhjem.org>
	 <20110215113053.345e3abc@tlielax.poochiereds.net>
	 <1297813624.10103.34.camel@heimdal.trondhjem.org>
	 <1297865354.6596.13.camel@heimdal.trondhjem.org>
	 <1297866373.6596.18.camel@heimdal.trondhjem.org>
	 <20110216095002.1e7944c9@tlielax.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Feb 2011 10:21:17 -0500
Message-ID: <1297869677.6596.30.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-02-16 at 09:50 -0500, Jeff Layton wrote: 
> Thanks Trond,
> 
> This builds, but I can't plug in the module:
> 
> [  103.540405] sunrpc: Unknown symbol __wake_up_locked_key (err 0)
> 
> ...I think __wake_up_locked_key will need to be exported too. I'll do
> that and then test this out later today.

Thanks! I've added an EXPORT_SYMBOL_GPL() for __wake_up_locked_key to
the patch.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

