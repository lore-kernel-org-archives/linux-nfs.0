Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:39896 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249Ab1CRCMX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2011 22:12:23 -0400
Date: Fri, 18 Mar 2011 13:12:14 +1100
From: NeilBrown <neilb@suse.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
Message-ID: <20110318131214.0e2c840a@notabene.brown>
In-Reply-To: <1300412966.9671.9.camel@lade.trondhjem.org>
References: <20110216171555.6642c630@notabene.brown>
	<1300405987.4621.10.camel@lade.trondhjem.org>
	<20110318120417.435551da@notabene.brown>
	<1300412966.9671.9.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 17 Mar 2011 21:49:26 -0400 Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:

> However we could adopt the Solaris convention of always starting
> writebacks with a FILE_SYNC, and then falling back to UNSTABLE for the
> second rpc call and all subsequent calls...
> 

That approach certainly has merit.

However, as we know from the wbc info whether the write is small and sync -
which is the only case where I think a STABLE write is needed - I cannot see
why you don't want to just use that information to guide the choice of
'stable' or not ???

NeilBrown

