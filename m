Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58948 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752023Ab2A3Vny (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 30 Jan 2012 16:43:54 -0500
Date: Mon, 30 Jan 2012 16:43:51 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jesper Juhl <jj@chaosbits.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Kendrick Smith <kmsmith@umich.edu>, Andy Adamson <kandros@umich.edu>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS4: Fix NULL deref in nfsd4_lock() by makeing
 unhash_lockowner() safe to call with NULL arg
Message-ID: <20120130214351.GA1518@fieldses.org>
References: <alpine.LNX.2.00.1201292226380.27749@swampdragon.chaosbits.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.LNX.2.00.1201292226380.27749@swampdragon.chaosbits.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 29, 2012 at 10:29:24PM +0100, Jesper Juhl wrote:
> The Coverity checker noticed a path through nfsd4_lock() where we call
> release_lockowner(lock_sop); (at the 'out:' label) where 'lock_sop' is
> NULL.
> That goes bad since release_lockowner() calls unhash_lockowner() which
> dereferences its argument.
> release_lockowner() also calls nfs4_free_lockowner(), but that's not a
> problem since that function just calls kfree() and kmem_cache_free(),
> both of which are safe to call with NULL as argument.
> 
> There are several ways to fix the bug.
>  - rework nfsd4_lock() so the call to release_lockowner(NULL) will never happen.
>  - let release_lockowner() test for NULL and return if given one.
>  - let unhash_lockowner() test for NULL and return if given one (which makes both it and release_lockowner() safe).
> 
> I chose the last option for this patch.
> 
> For information, the path Coverity spotted (in defect report 201504) is this:
> 
...


> [...]
> 4098out:
> At conditional (12): "status" taking the true branch.
> At conditional (13): "new_state" taking the true branch.
> 4099        if (status && new_state)

new_state is initialized false, and referenced otherwise only once,
when a reference ot is is passed here:


> 4010                status = lookup_or_create_lock_state(cstate, open_stp, lock,
> 4011                                                        &lock_stp, &new_state);

so if new_state is true, then lookup_or_create_lock_state() set it to
true.  But it sets that only in one spot, at the end:

	*new = true;
	return nfs_ok;

Note nfs_ok is zero.  Therefore:

> At conditional (11): "status" taking the true branch.
> 4012                if (status)
> 4013                        goto out;

this could not have happened.

So it looks like a Coverity bug.

--b.
