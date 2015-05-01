Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:51672 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbEACD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2015 22:03:26 -0400
Date: Fri, 1 May 2015 03:03:24 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: NeilBrown <neilb@suse.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150501020324.GP889@ZenIV.linux.org.uk>
References: <20150422150703.GA1247@fieldses.org>
 <20150423094431.1a8aa68b@notabene.brown>
 <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150501115326.51f5613a@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2015 at 11:53:26AM +1000, NeilBrown wrote:
> While writing that I began to wonder if lookup_one_len is really the right
> interface to be used, even though it was introduced (in 2.3.99pre2-4)
> specifically for nfsd.
> The problem is that it assumes things about the filesystem.  So it makes
> perfect sense for various filesystems to use it on themselves, but I'm not
> sure how *right* it is for nfsd (or cachefiles etc) to use it on some
> *other* filesystem.
> The particular issue is that it avoids the d_revalidate call.
> Both vfat and reiserfs have that call ... I wonder if that could ever be a
> problem.
> 
> So I'm really leaning towards creating a variant of kern_path_mountpoint and
> using a variant of that which takes a length.

NAK.  As in, "no way in hell".  And yes, lookup_one_len() *does* revalidate -
RTFS(lookup_dcache), please.

What kind of consistency warranties do callers expect, BTW?  You do realize
that between iterate_dir() and callbacks an entry might have been removed
and/or replaced?
