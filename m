Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39554 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750751Ab1JTL7A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 20 Oct 2011 07:59:00 -0400
Date: Thu, 20 Oct 2011 07:58:59 -0400
To: Benny Halevy <bhalevy@tonian.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/7] Bakeathon server fixes
Message-ID: <20111020115859.GK5444@fieldses.org>
References: <4E9F82FC.2000904@tonian.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4E9F82FC.2000904@tonian.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 19, 2011 at 07:10:04PM -0700, Benny Halevy wrote:
> Here's the list of patches I tested here in the Bakeathon.

Thanks, Benny!  I need to run some tests of my own, and then I intend to
apply the first four (see individual replies for comments on the last
three).

--b.

> They pass the Connectathon tests over nfsv4.1 (no pnfs)
> against the linux client, but VMware reports a bug with
> OPEN with share_access==0x401 (1025)
> NFS4_SHARE_WANT_NO_DELEG | NFS4_SHARE_ACCESS_READ
> return NFS4ERR_GRACE for some reason.
> I haven't been able to track that down yet.
> 
> [PATCH 1/7] nfsd4: implement new 4.1 open reclaim types
> [PATCH 2/7] nfsd41: use SEQ4_STATUS_BACKCHANNEL_FAULT when
> [PATCH 3/7] nfsd4: seq->status_flags may be used unitialized
> [PATCH 4/7] nfsd4: allow NFS4_SHARE_SIGNAL_DELEG_WHEN_RESRC_AVAIL |
> [PATCH 5/7] nfsd4: implement NFS4_SHARE_WANT_NO_DELEG,
> [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
> [PATCH 7/7] nfsd4: share_access_to_flags should consider only nfs4.x
