Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755267Ab0KRRjw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 12:39:52 -0500
Date: Thu, 18 Nov 2010 12:39:49 -0500
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: "William A. (Andy) Adamson" <androsadamson@gmail.com>, benny@panasas.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] NFS add minorversion to nfs_find_client search
Message-ID: <20101118173949.GA28975@fieldses.org>
References: <1289964990-4480-1-git-send-email-andros@netapp.com>
 <1289964990-4480-2-git-send-email-andros@netapp.com>
 <1290035454.3070.15.camel@heimdal.trondhjem.org>
 <AANLkTi=9RvncYzh1pRUNH1vZ9gwDxczc=5A7CeNvf=w-@mail.gmail.com>
 <1290091562.3187.16.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1290091562.3187.16.camel@heimdal.trondhjem.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Nov 18, 2010 at 09:46:02AM -0500, Trond Myklebust wrote:
> I can see why the NFS server would care to let the client quickly
> whether or not the RPC request is denied, but why do we care on the
> backchannel case? If a server is sending us callbacks, and we don't
> recognise that server, why should we waste computing and networking
> cycles by replying at all?

Agreed.  I have a hard time seeing a real benefit to returning an error
here.

Also, note the only reason to use pg_authenticate is if you want to
return an rpc-level error.

Not that it's a problem to do the work here in pg_authenticate if you
want to, but if it's easier to just allow the request through and let
the nfs layer decide what to do with it, that shouldn't be a problem
either.

--b.
