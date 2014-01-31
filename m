Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:54446 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932236AbaAaSnD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jan 2014 13:43:03 -0500
Date: Fri, 31 Jan 2014 18:42:58 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        Miklos Szeredi <mszeredi@suse.cz>
Subject: Re: [PATCH] dcache: make d_splice_alias use d_materialise_unique
Message-ID: <20140131184258.GN10323@ZenIV.linux.org.uk>
References: <20140115151749.GF23999@fieldses.org>
 <20140117121723.GA18375@infradead.org>
 <20140117153917.GA26636@fieldses.org>
 <20140117210343.GD26636@fieldses.org>
 <20140117212655.GE26636@fieldses.org>
 <20140123212700.GA30466@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140123212700.GA30466@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 23, 2014 at 04:27:00PM -0500, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> d_splice_alias can create duplicate directory aliases (in the !new
> case), or (in the new case) d_move directories without holding
> appropriate locks.

Details, please.  In the new case, we have IS_ROOT() alias found;
what locks would that need?  Note that d_materialise_unique() won't
bother with __d_unalias() in such case - it does what d_move() would've
done, without taking any mutex.

In the !new case, we'd need a preexisting dentry alias, complete with
parent.  IOW, that's the case when directory already in the tree
has been found during lookup from another parent.  In which case
we shouldn't be using d_splice_alias() at all, as it is (and it
certainly can't happen for any local fs).

Now, I agree that merging that with d_materialise_unique() might be
a good idea, but commit message is wrong as it, AFAICS.
