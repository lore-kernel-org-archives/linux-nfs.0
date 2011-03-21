Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41423 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754506Ab1CUWy6 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2011 18:54:58 -0400
Subject: Re: Small O_SYNC writes are no longer NFS_DATA_SYNC
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <20110322091757.7bf56d80@notabene.brown>
References: <20110216171555.6642c630@notabene.brown>
	 <1300405987.4621.10.camel@lade.trondhjem.org>
	 <20110318120417.435551da@notabene.brown>
	 <1300412966.9671.9.camel@lade.trondhjem.org>
	 <20110318131214.0e2c840a@notabene.brown>
	 <1300415108.13476.6.camel@lade.trondhjem.org>
	 <20110318145232.7bbb4216@notabene.brown>
	 <1300741320.13307.50.camel@lade.trondhjem.org>
	 <20110322091757.7bf56d80@notabene.brown>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 21 Mar 2011 18:54:55 -0400
Message-ID: <1300748095.26546.12.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 2011-03-22 at 09:17 +1100, NeilBrown wrote:
> On Mon, 21 Mar 2011 17:02:00 -0400 Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> I must admit that I found the terminology a bit confusing for 
> FLUSH_COND_STABLE.
> What is means is "if this turns out to be part of a larger request, then clear
> FLUSH_STABLE" - which sounds a bit more like "FLUSH_COND_UNSTABLE" - i.e. if
> a condition is met, then make it unstable.
> But I don't think that change would help at all.
> 
> How about changing the test in nfs_write_rpcsetup to
> 	if (how & (FLUSH_STABLE|FLUSH_CONDSTABLE)) {
> 		data->args.stable = NFS_DATA_SYNC;
> 		if (!nfs_need_commit(NFS_I(inode)))
> 			data->args.stable = NFS_FILE_SYNC;
> 	}
> 
> and then just set either FLUSH_STABLE or FLUSH_COND_STABLE - never both -
> and when you test FLUSH_COND_STABLE and then some other condition, just
> clear FLUSH_COND_STABLE.
> 
> I would find that quite a bit more readable.

The reason why I opted not to go for that approach was because
nfs_write_rpcsetup() doesn't really know about whether or not there are
any more RPCs pending (and so having a 'conditional' flag being
interpreted there didn't appear to make sense), but if you feel that is
easier on the eyes then I'm happy to change my opinion.

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

