Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:40281 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752505Ab0KXPHJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Nov 2010 10:07:09 -0500
Date: Wed, 24 Nov 2010 10:07:08 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Joe Habermann <joe.habermann@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: incorrect EXDEV error occasionally returned for rename over NFS
Message-ID: <20101124150707.GA13737@fieldses.org>
References: <AANLkTim3GyG4Skr_=0QyELJw1ySjfvhYMD2g4JKztrOx@mail.gmail.com>
 <20101116185551.GD3971@fieldses.org>
 <AANLkTik=WkedMyy=oVorEuSW96vTdK7vBnneOTe1qgxh@mail.gmail.com>
 <20101119235717.GE12783@fieldses.org>
 <AANLkTimvvbDw+YYoK8ZuKt3fJHTjxrJgWhq7r9ucHjwo@mail.gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <AANLkTimvvbDw+YYoK8ZuKt3fJHTjxrJgWhq7r9ucHjwo@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 23, 2010 at 02:55:24PM -0600, Joe Habermann wrote:
> Sure, I'll take another look.  I definitely would prefer a more
> elegant solution.
> 
> With regard to the strcmp on ex_client->name(), I'm not sure that's 100% tight.
> Suppose we have an export such as:
>     *(rw,sync,no_subtree_check)
> And during the race window, that export is replaced with:
>     foo(rw,sync,no_subtree_check)
> And it's "foo" that's performing the rename.
> In this case, the export pointers will (generally) be different, as
> will the auth_domain pointers, as will the string pointed to by
> ex_client->name ("*" vs. "foo"), incorrectly leading to a failing
> check.

You're devious!  We need you reading more of the NFS code....

But I think we're both being stupid here: both exports are looked up
using the same auth_domain (rq_client), and it's really the filesystems
(or filesystem subtrees) that we want to compare anyway.

So just ditch the ex_client comparison and compare the two
(vfsmount,dentry) pairs.

(There may still be an odd race or two; e.g. if someone does

	mount --bind /export/path /export/path
	exportfs -f

between the two export lookups, could we end up with two different
vfsmounts that really could be treated as the same?  But I don't think
we need to support that.

Other alternatives would be to compare something like the fs-identifying
part of the filehandle, or the path. (Probably svc_export_match() should
be strcmp()'ing paths anyway--paths are what userspace deals in anyway,
so if we're ever in a situation where it makes a difference, and there
are two (mnt,dentry) pairs that alias to the same path, then we end up
with a cache request that userspace can never respond to.))

--b.
